/**
 * File:        osf_ctrl_cartdetail_actionstotal.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 24, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class osf_cartdetail_actionstotals component.
  ***********************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_ctrl_cartdetail_actionstotal {

    /* 
    * @description  : Submit Cart to Supervisors
    * @author       : Ozgun Eser
    * @createdDate  : Feb 24, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult submitCart(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try {
            ccrz__E_Cart__c cart = [SELECT Id, osf_submitted_to__c, osf_submitted_to_2__c, ccrz__Name__c, Name, OwnerId, ccrz__User__c, ccrz__Contact__c, CreatedById FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :context.currentCartId];
            Contact contact = [SELECT Id, osf_supervisor__c, osf_supervisor_2__c, FirstName, Lastname FROM Contact WHERE Id = :ccrz.cc_CallContext.currContact.Id];
            Map<String, User> contactIdToUserMap = fetchUsersFromContact(contact, cart);            
            Set<Id> oldOwnerIdSet = new Set<Id> ();    
            Set<Id> supervisorIdSet = new Set<Id> {};
            if(contactIdToUserMap.containsKey(contact.osf_supervisor_2__c)) {
                supervisorIdSet.add(contactIdToUserMap.get(contact.osf_supervisor_2__c).Id);
            }
            if(contactIdToUserMap.containsKey(cart.osf_submitted_to__c)) {
                oldOwnerIdSet.add(contactIdToUserMap.get(cart.osf_submitted_to__c).Id);
            }
            if(contactIdToUserMap.containsKey(cart.osf_submitted_to_2__c)) {
                oldOwnerIdSet.add(contactIdToUserMap.get(cart.osf_submitted_to_2__c).Id);
            }
            oldOwnerIdSet.add(cart.CreatedById);
            updateCart(cart, contact, contactIdToUserMap.get(contact.osf_supervisor__c).Id);
            if(osf_CartSharingHelper.shareCartWithSupervisor(cart.Id, supervisorIdSet)) {
                if(osf_CartSharingHelper.readPermissionToOldOwner(cart.Id, oldOwnerIdSet)) {
                    List<ccrz__E_Cart__Share> shareList = [SELECT AccessLevel FROM ccrz__E_Cart__Share WHERE ParentId = :cart.Id AND UserOrGroupId = :contactIdToUserMap.get(contact.osf_supervisor__c).Id];
                    Map<Id, ccrz__E_Cart__c> mapUserIdCarts = osf_CartSharingHelper.getEmptyOpenCarts(new Set<String> { ccrz.cc_CallContext.currUserId});
                    if (mapUserIdCarts.isEmpty()) {
                        Map<String, Object> outputData = ccrz.ccAPICart.create(new Map<String, Object> {
                            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                        });
                        data.put(osf_constant_strings.NEW_CART_ID, outputData.get(ccrz.ccAPICart.CART_ENCID));
                    } else {
                        ccrz__E_Cart__c cartToActivate = mapUserIdCarts.get(ccrz.cc_CallContext.currUserId);
                        cartToActivate.ccrz__ActiveCart__c = true;
                        update cartToActivate;
                        data.put(osf_constant_strings.NEW_CART_ID, cartToActivate.ccrz__EncryptedId__c);
                    }
                    result.success = true;
                }
            }

            if(result.success) {
                Set<String> contactIdSetForEmail = new Set<String> ();
                contactIdSetForEmail.add(ccrz.cc_CallContext.currContact.Id);
                for(String contactId : contactIdToUserMap.keySet()) {
                    contactIdSetForEmail.add(contactId);
                }
                for(Contact accountAdmin : [SELECT Id FROM Contact WHERE osf_role__c = :osf_constant_strings.ACCOUNT_ADMIN AND AccountId = :ccrz.cc_CallContext.currAccountId]) {
                    contactIdSetForEmail.add(accountAdmin.Id);
                }
                sendSubmitCartEmail(cart.Id, contactIdSetForEmail, Site.getBaseUrl() + osf_constant_strings.MY_CARTS_LINK);
            }
        } catch (Exception e) {
            ccrz.ccLog.log(Logginglevel.ERROR, 'osf:ctrl:cartdetail:actionsTotal:submitCart:Error', e);
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : Updating Submitted Cart Information
    * @author       : Ozgun Eser
    * @createdDate  : Mar 17, 2020
    * @param        : ccrz__E_Cart__c cart, submitted cart
    * @param        : Contact contact, current contact
    * @param        : String userId, new owner Id
    * @return       : 
    */
    private static void updateCart (ccrz__E_Cart__c cart, Contact contact, Id userId) {
        cart.ccrz__Name__c = osf_constant_strings.SUBMITTED_BY + contact.FirstName + osf_constant_strings.EMPTY_SPACE + contact.LastName + osf_constant_strings.EMPTY_SPACE + cart.Name;
        cart.osf_submitted_to__c = contact.osf_supervisor__c;
        cart.osf_submitted_to_2__c = contact.osf_supervisor_2__c;
        cart.ccrz__ActiveCart__c = false;
        cart.ccrz__Contact__c = contact.osf_supervisor__c;
        cart.ccrz__User__c = userId;
        cart.OwnerId = userId;
        update cart;
    }

    /* 
    * @description  : fetching User from Contact Information
    * @author       : Ozgun Eser
    * @createdDate  : Mar 17, 2020
    * @param        : ccrz__E_Cart__c cart, submitted cart
    * @param        : Contact contact, current contact
    * @return       : Map<String, User> contact Id to User Map
    */
    private static Map<String, User> fetchUsersFromContact(Contact contact, ccrz__E_Cart__c cart) {
        Map<String, User> contactIdToUserMap = new Map<String, User> ();
        Set<String> contactIdSet = new Set<String> {contact.osf_supervisor__c};
        if(String.isNotBlank(contact.osf_supervisor_2__c)) {
            contactIdSet.add(contact.osf_supervisor_2__c);
        }
        if(String.isNotBlank(cart.osf_submitted_to__c)) {
            contactIdSet.add(cart.osf_submitted_to__c);
        }
        if(String.isNotBlank(cart.osf_submitted_to_2__c)) {
            contactIdSet.add(cart.osf_submitted_to_2__c);
        }
        for(User user : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIdSet]) {
            contactIdToUserMap.put(user.ContactId, user);
        }
        return contactIdToUserMap;
    }

    @future
    private static void sendSubmitCartEmail(String cartId, Set<String> contactIdSet, String myCartsUrl) {
        ccrz__E_Cart__c cart = [SELECT Id, Name, osf_submitted_to__r.Name, osf_submitted_to_2__r.Name, CreatedBy.ContactId, LastModifiedBy.Name, osf_submitted_to__c, osf_submitted_to_2__c, CreatedBy.LocaleSidKey FROM ccrz__E_Cart__c WHERE Id = :cartId];
        List<String> emailToAddressList = new List<String> ();
        contactIdSet.add(cart.CreatedBy.ContactId);
        contactIdSet.add(cart.osf_submitted_to__c);
        if(String.isNotBlanK(cart.osf_submitted_to_2__c)) {
            contactIdSet.add(cart.osf_submitted_to_2__c);
        }
        for(Contact contact : [SELECT Email FROM Contact WHERE Id IN :contactIdSet]) {
            emailToAddressList.add(contact.Email);
        }
        String emailTemplateName = cart.CreatedBy.LocaleSidKey == osf_constant_strings.SPANISH_LOCALE ? osf_constant_strings.SUBMIT_CART_EMAIL_TEMPLATE : osf_constant_strings.SUBMIT_CART_EMAIL_TEMPLATE_CATALAN;
        List<EmailTemplate> emailTemplateList = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = :emailTemplateName LIMIT 1];
        if(emailTemplateList.isEmpty()) {
            return;
        }
        String emailAnd = cart.CreatedBy.LocaleSidKey == osf_constant_strings.SPANISH_LOCALE ? osf_constant_strings.SUBMIT_CART_EMAIL_AND : osf_constant_strings.SUBMIT_CART_EMAIL_AND_CATALAN;
        EmailTemplate emailTemplate = emailTemplateList[0];
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace(osf_constant_strings.SUBMIT_CART_EMAIL_CART_NAME, cart.Name);               
        htmlBody = htmlBody.replace(osf_constant_strings.SUBMIT_CART_EMAIL_CART_SUBMITTED, cart.osf_submitted_to__r.Name);               
        htmlBody = htmlBody.replace(osf_constant_strings.SUBMIT_CART_EMAIL_CART_SUBMITTED2, String.isBlank(cart.osf_submitted_to_2__r.Name) ? osf_constant_strings.EMPTY_STRING : emailAnd + cart.osf_submitted_to_2__r.Name);           
        htmlBody = htmlBody.replace(osf_constant_strings.SUBMIT_CART_EMAIL_MY_CARTS_LINK, myCartsUrl);
        htmlBody = htmlBody.replace(osf_constant_strings.SUBMIT_CART_EMAIL_SUBMITTED_BY, cart.LastModifiedBy.Name);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset(osf_constant_strings.CHARSET_UTF_8);
        mail.setToAddresses(emailToAddressList);
        mail.setSubject(emailTemplate.Subject.replace(osf_constant_strings.SUBMIT_CART_EMAIL_CART_NAME, cart.Name));
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
}