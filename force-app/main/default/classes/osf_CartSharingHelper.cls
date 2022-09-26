/**
 * File:        osf_CartSharingHelper.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 10, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Giving Sharing permissions for CC Cart when it is submitted.
  ************************************************************************
 * History:
 */

public without sharing class osf_CartSharingHelper {
    
    /**********************************************************************************************
    * @Name         : shareCartWithSupervisor
    * @Description  : Giving Sharing Permission to the manager that the cart is submitted
    * @Created By   : Ozgun Eser
    * @param        : Id cartId
    * @Return       : Set<Id> userIdSet
    *********************************************************************************************/
    public static Boolean shareCartWithSupervisor(Id cartId, Set<Id> userIdSet) {
        List<ccrz__E_Cart__Share> cartShareList = new List<ccrz__E_Cart__Share> ();
        for(Id userId : userIdSet) {
            cartShareList.add(new ccrz__E_Cart__Share(
                ParentId = cartId,
                UserOrGroupId = userId,
                RowCause = Schema.ccrz__E_Cart__Share.RowCause.Manual,
                AccessLevel = osf_constant_strings.ACCESS_LEVEL_EDIT
            ));
        }
        List<Database.SaveResult> saveResultList = Database.insert(cartShareList, false);
        for(Database.SaveResult saveResult : saveResultList) {
            if(!saveResult.isSuccess()) {
                return false;
            }
        }
        return true;
    }

    /**********************************************************************************************
    * @Name         : readPermissionToOldOwner
    * @Description  : Giving Read Permission to the old owners of the carts
    * @Created By   : Ozgun Eser
    * @param        : Id cartId
    * @Return       : Set<Id> userIdSet
    *********************************************************************************************/
    public static Boolean readPermissionToOldOwner(Id cartId, Set<Id> userIdSet) {
        List<ccrz__E_Cart__Share> cartShareList = new List<ccrz__E_Cart__Share> ();
        for(Id userId : userIdSet) {
            cartShareList.add(new ccrz__E_Cart__Share(
                ParentId = cartId,
                UserOrGroupId = userId,
                RowCause = Schema.ccrz__E_Cart__Share.RowCause.Manual,
                AccessLevel = osf_constant_strings.ACCESS_LEVEL_READ
            ));
        }
        List<Database.SaveResult> saveResultList = Database.insert(cartShareList, false);
        for(Database.SaveResult saveResult : saveResultList) {
            if(!saveResult.isSuccess()) {
                return false;
            }
        }
        return true;
    }

    /**********************************************************************************************
    * @Name         : shareOrderWithSupervisor
    * @Description  : Giving Sharing Permission to the any user in hierarchy line of CC Order.
    * @Created By   : Ozgun Eser
    * @param        : ccrz__E_Order__c order, created order,
    * @param        : ccrz__E_Cart__c cart, originated cart
    * @Return       : Boolean isSuccefullyShared
    *********************************************************************************************/
    public static Boolean shareOrderWithSupervisor(ccrz__E_Order__c order, ccrz__E_Cart__c cart) {
        Set<String> contactIdSet = new Set<String> ();
        List<ccrz__E_Order__Share> orderShareList = new List<ccrz__E_Order__Share> ();
        Set<Id> userIdSet = new Set<Id> ();
        for(ccrz__E_Cart__Share cartShare : [SELECT UserOrGroupId FROM ccrz__E_Cart__Share WHERE ParentId = :cart.Id AND UserOrGroupId != :ccrz.cc_CallContext.currUserId]) {
            userIdSet.add(cartShare.UserOrGroupId);
        }
        for(Contact contact : [SELECT Id, osf_supervisor__c, osf_supervisor_2__c FROM Contact WHERE Id = :ccrz.cc_CallContext.currContact.Id OR (osf_role__c = :osf_constant_strings.ACCOUNT_ADMIN AND AccountId = :ccrz.cc_CallContext.currAccountId)]) {
            if(contact.Id == ccrz.cc_CallContext.currContact.Id) {
                if(String.isNotBlank(contact.osf_supervisor__c)) {
                    contactIdSet.add(contact.osf_supervisor__c);
                }
                if(String.isNotBlank(contact.osf_supervisor_2__c)) {
                    contactIdSet.add(contact.osf_supervisor_2__c);
                }
            } else {
                contactIdSet.add(contact.Id);
            }
        }
        for(User user : [SELECT Id FROM User WHERE ContactId IN :contactIdSet]) {
            userIdSet.add(user.Id);
        }
        for(Id userId : userIdSet) {
            orderShareList.add(new ccrz__E_Order__Share(
                ParentId = order.Id,
                UserOrGroupId = userId,
                RowCause = Schema.ccrz__E_Order__Share.RowCause.Manual,
                AccessLevel = osf_constant_strings.ACCESS_LEVEL_EDIT
            ));
        }
        List<Database.SaveResult> saveResultList = Database.insert(orderShareList, false);
        for(Database.SaveResult saveResult : saveResultList) {
            if(!saveResult.isSuccess()) {
                return false;
            }
        }
        return true;
    }

    /**********************************************************************************************
    * @Name         : getEmptyOpenCarts
    * @Description  : get empty open carts for a set of users
    * @Created By   : Alina Craciunel
    * @Created Date : Apr 28, 2020
    * @param        : Set<String> userIdSet
    * @Return       : Map<Id, ccrz__E_Cart__c>
    *********************************************************************************************/
    public static Map<Id, ccrz__E_Cart__c> getEmptyOpenCarts(Set<String> userIdSet) {
        List<ccrz__E_Cart__c> lstOpenEmptyCarts = new List<ccrz__E_Cart__c>([SELECT Id, OwnerId, ccrz__EncryptedId__c, (SELECT Id FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE OwnerId IN :userIdSet AND ccrz__Storefront__c =: osf_constant_strings.DEFAULT_STORE AND ccrz__CartType__c =: osf_constant_strings.CART_TYPE_CART AND ccrz__CartStatus__c =: osf_constant_strings.CART_STATUS_OPEN AND ccrz__CurrencyISOCode__c =: osf_constant_strings.CURRENCY_EUR AND ccrz__TotalAmount__c = 0 ORDER BY LastModifiedDate DESC]);
        Map<Id, ccrz__E_Cart__c> mapUserIdCarts = new Map<Id, ccrz__E_Cart__c>();
        for (ccrz__E_Cart__c cart : lstOpenEmptyCarts) {
            if (cart.ccrz__E_CartItems__r == null || cart.ccrz__E_CartItems__r.isEmpty()) {
                if (mapUserIdCarts.get(cart.OwnerId) == null) {
                    mapUserIdCarts.put(cart.OwnerId, cart);
                }
            }
        }
        return mapUserIdCarts;
    }
}