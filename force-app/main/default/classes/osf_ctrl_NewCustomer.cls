/**
 * File:        osf_ctrl_NewCustomer.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        March 04, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class for osf_newcustomer Apex Component.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_ctrl_NewCustomer {

    private static final String DEFAULT_RECORD_OWNER = 'Default Record Owner';
    private static final String OSF_ACCOUNT_GROUP_ID = '10';
    private static final String EPR_ACCOUNT_NAME = 'nom';
    private static final String DEFAULT_PAYMENT = 'Credit Card';
    //private static final String DEFAULT_PAYMENT_EXISTING = 'Credit Card;No Payment';
    private static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    private static final String SPAIN_NAME = 'España';
    private static final String SPAIN_CODE = 'ES';
    private static final String ADDRESS_TYPE_BILLING = 'Billing';
    private static final String ADDRESS_TYPE_SHIPPING = 'Shipping';
    private static final String INTERLUCATOR_AG = 'AG';
    private static final String FORMA_PAGAMENT_1 = '1';
    private static final String NO_PAYMENT = 'No Payment';
    
    /* 
    * @description  : Register New Customer
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : Map<String, Object> formData, containing form data filled by user
    * @param        : Boolean isSubscribed, true if user checked subscribe checkbox, false otherwise
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult registerCustomer(ccrz.cc_RemoteActionContext context, Map<String, Object> formData, Boolean isSubscribed) {
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'osf:ctrl:newCustomer:registerCustomer', formData);
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        try {
            if(formData.containsKey(osf_constant_strings.CLIENT_ID)) {
                result = createExistingUser(formData, result, isSubscribed);
            } else {
                result = createNewUser(formData, result, isSubscribed);
            }
        } catch (Exception e) {
            System.debug('Exception is -----> ' + e.getMessage() + '\nStacktrace:' + e.getStackTraceString());
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : Register Brand New Customer, creates user, contact and accoutn for customer selected "No Soc Cliente"
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : ccrz.cc_RemoteActionResult result
    * @param        : Map<String, Object> formData, containing form data filled by user
    * @param        : Boolean isSubscribed, true if user checked subscribe checkbox, false otherwise
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    private static ccrz.cc_RemoteActionResult createNewUser(Map<String, Object> formData, ccrz.cc_RemoteActionResult result, Boolean isSubscribed) {
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        String vat = (String) formData.get(osf_constant_strings.CIF);
        List<Account> accountList = [SELECT Id FROM Account WHERE osf_cif_number__c = :vat LIMIT 1];
        if(!accountList.isEmpty()) {
            data.put(osf_constant_strings.EXISTING_CLIENT, true);
            return result;
        }
        absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = osf_utilityERP.checkCustomerExistsInERP(vat, osf_constant_strings.EMPTY_STRING);
        if(resultatConsultarClientsB2BSalesforce.llistaDireccions != null && !Test.isRunningTest()) {
            data.put(osf_constant_strings.EXISTING_CLIENT, true);
            return result;
        }

        Account account = new Account(
            Name = (String) formData.get(osf_constant_strings.COMPANY_NAME),
            osf_validPaymentTypes__c = DEFAULT_PAYMENT,
            ccrz__E_AccountGroup__r = new ccrz__E_AccountGroup__c (ccrz__AccountGroupID__c = OSF_ACCOUNT_GROUP_ID),
            osf_cif_number__c = (String) formData.get(osf_constant_strings.CIF),
            OwnerId = getAdminUserId()
        );
        insert account;
        
        Contact contact = createContact(formData, isSubscribed, account);
        insert contact;
        
        User user = createUserFromFormData(contact);
        
        String userId = Site.createExternalUser(user, account.Id);
        result.success = String.isNotBlank(userId);
        return result;
    }
    
    /* 
    * @description  : Register A User for Existing Account, creates user, contact and accoutn(if not exists in Salesforce) for customer selected "Soc Cliente"
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : ccrz.cc_RemoteActionResult result
    * @param        : Map<String, Object> formData, containing form data filled by user
    * @param        : Boolean isSubscribed, true if user checked subscribe checkbox, false otherwise
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    private static ccrz.cc_RemoteActionResult createExistingUser(Map<String, Object> formData, ccrz.cc_RemoteActionResult result, Boolean isSubscribed) {
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        String username = formData.containsKey(osf_constant_strings.USER_NAME) ? (String) formData.get(osf_constant_strings.USER_NAME) : osf_constant_strings.EMPTY_STRING;
        String vat = formData.containsKey(osf_constant_strings.CIF) ? (String) formData.get(osf_constant_strings.CIF) : osf_constant_strings.EMPTY_STRING;
        String clientId = formData.containsKey(osf_constant_strings.CLIENT_ID) ? (String) formData.get(osf_constant_strings.CLIENT_ID) : osf_constant_strings.EMPTY_STRING;
        absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = osf_utilityERP.checkCustomerExistsInERP(vat, clientId);
        if(resultatConsultarClientsB2BSalesforce.llistaDireccions == null) {
            data.put(osf_constant_strings.INVALID_DATA, true);
            return result;
        }
        absisIntranetAbacus.direccioClient[] llistaDireccions = resultatConsultarClientsB2BSalesforce.llistaDireccions;
        Account account;
        List<Account> accountList = [SELECT Id, (SELECT Id, FirstName, LastName, Email FROM Contacts WHERE Email = :username LIMIT 1) FROM Account WHERE osf_cif_number__c = :vat AND osf_client_code__c = :clientId LIMIT 1];
        if(accountList.isEmpty()) {
            if(llistaDireccions.isEmpty()) {
                data.put(osf_constant_strings.INVALID_DATA, true);
                return result;
            }
            absisIntranetAbacus.direccioClient direccion = llistaDireccions[0];
            account = new Account(
                Name = direccion.nom,
                osf_validPaymentTypes__c = !String.isBlank(resultatConsultarClientsB2BSalesforce.formaPagament) ? (resultatConsultarClientsB2BSalesforce.formaPagament == FORMA_PAGAMENT_1 ? osf_constant_strings.DEFAULT_PAYMENT_TYPES : NO_PAYMENT) : null,
                ccrz__E_AccountGroup__r = new ccrz__E_AccountGroup__c(ccrz__AccountGroupID__c = OSF_ACCOUNT_GROUP_ID),
                osf_cif_number__c = vat,
                osf_client_code__c = clientId,
                OwnerId = getAdminUserId()
            );
            insert account;
            createAddresses(account, llistaDireccions, formData);            
        } else {
            account = accountList[0];
        }
        Contact contact;
        if(!accountList.isEmpty() && !accountList[0].Contacts.isEmpty()) {
            contact = accountList[0].Contacts[0];
        } else {
            contact = createContact(formData, isSubscribed, account);
        }
        User user = createUserFromFormData(contact);
        String userId = Site.createExternalUser(user, account.Id);
        result.success = String.isNotBlank(userId);
        return result;
    }
    
    /* 
    * @description  : Create User Object from Form Data Filled By User
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : Contact contact, created Contact from form data
    * @return       : User user, created user.
    */
    private static User createUserFromFormData(Contact contact) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :osf_testUtility.COMMUNITY_PROFILE];
        return new User (
            FirstName = contact.FirstName,
            LastName = contact.LastName,
            Username = contact.Email,
            Email = contact.Email,
            CommunityNickName = contact.Email,
            Alias = createAlias(contact.FirstName, contact.lastName),
            ProfileId = profile.Id,
            ccrz__CC_CurrencyCode__c = osf_testUtility.CURRENCY_ISO_CODE,
            ContactId = contact.Id
        );
    }
    
    /* 
    * @description  : Create Alias for User (for ex. jdoe for John Doe)
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : String first name
    * @param        : String last name
    * @return       : String, created alias.
    */
    private static String createAlias(String firstName, String lastName) {
        String alias = firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
        if(alias.length() > 8) {
            alias = alias.substring(0, 7);
        }
        return alias;
    }
    
    /* 
    * @description  : Create Contact from form data
    * @author       : Ozgun Eser
    * @createdDate  : Apr 10, 2020
    * @param        : Account account
    * @param        : Map<String, Object> formData, containing form data filled by user
    * @param        : Boolean isSubscribed, true if user checked subscribe checkbox, false otherwise
    * @return       : Contact contact, created Contact
    */
    private static Contact createContact(Map<String, Object> formData, Boolean isSubscribed, Account account) {
        return new Contact(
            FirstName = (String) formData.get(osf_constant_strings.FIRST_NAME),
            LastName = (String) formData.get(osf_constant_strings.LAST_NAME),
            Email = (String) formData.get(osf_constant_strings.USER_NAME),
            osf_role__c = osf_constant_strings.STANDARD_USER,
            osf_allow_checkout__c = true,
            HasOptedOutOfEmail = !isSubscribed,
            AccountId = account.Id
        );
    }

    /* 
    * @description  : get Random System Admin User Id for OwnerId of Account.
    * @author       : Ozgun Eser
    * @createdDate  : May 30, 2020
    * @return       : ID, id of the user.
    */
    private static Id getAdminUserId() {
        User user = [SELECT Id FROM User WHERE Profile.PermissionsModifyAllData = true AND UserRoleId != null AND IsActive = true LIMIT 1];
        return user.Id;
    }

    /* 
    * @description  : createAddress
    * @author       : Ozgun Eser
    * @createdDate  : Jun 03, 2020
    * @param        : Account account
    * @param        : absisIntranetAbacus.direccioClient[] llistaDireccions, user list returned from ERP.
    * @param        : Map<String, Object> formData, form data filled by user
    * @return       : 
    */
    private static void createAddresses(Account account, absisIntranetAbacus.direccioClient[] llistaDireccions, Map<String, Object> formData) {
        Set<String> addressERPIdSet = new Set<String> ();
        List<sObject> listToInsert = new List<sObject> ();
        for(absisIntranetAbacus.direccioClient direccion : llistaDireccions) {
            String direccionId = direccion.direccio;
            if(String.isBlank(direccionId) || addressERPIdSet.contains(direccionId)) {
                continue;
            }
            addressERPIdSet.add(direccionId);
            ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c (
                ccrz__FirstName__c = (String) formData.get(osf_constant_strings.FIRST_NAME),
                ccrz__LastName__c = (String) formData.get(osf_constant_strings.LAST_NAME),
                ccrz__AddressFirstline__c = direccion.direccio,
                ccrz__AddressSecondLine__c = direccion.numero + osf_constant_strings.COMMA + osf_constant_strings.EMPTY_SPACE + direccion.escala + osf_constant_strings.COMMA + osf_constant_strings.EMPTY_SPACE + direccion.pis + direccion.porta,
                osf_account__c = account.Id,
                ccrz__Country__c = SPAIN_NAME,
                ccrz__CountryISOCode__c = SPAIN_CODE,
                ccrz__DaytimePhone__c = direccion.telefonContacte,
                ccrz__Email__c = (String) formData.get(osf_constant_strings.USER_NAME),
                ccrz__CompanyName__c = account.Name,
                OwnerId = account.OwnerId,
                ccrz__ContactAddrId__c = direccionId
            );
            absisIntranetAbacus.poblacio poblacio = direccion.poblacio;
            if(poblacio != null) {
                absisIntranetAbacus.provincia province = poblacio.provincia;
                if(province != null) {
                    contactAddress.ccrz__City__c = province.nom;
                    contactAddress.ccrz__State__c = province.nom;
                }
                contactAddress.ccrz__PostalCode__c = poblacio.codiPostal;
            }

            listToInsert.add(contactAddress);
            listToInsert.add(new ccrz__E_AccountAddressBook__c (
                Name = direccionId + osf_constant_strings.LINE + ADDRESS_TYPE_BILLING,
                ccrz__Default__c = !String.isBlank(direccion.principal), //String.isNotBlank(direccion.interlocutor) && direccion.interlocutor.contains(INTERLUCATOR_AG),
                ccrz__Owner__c = account.OwnerId,
                ccrz__Account__c = account.Id,
                ccrz__AccountId__c = account.Id,
                OwnerId = account.OwnerId,
                ccrz__E_ContactAddress__r = new ccrz__E_ContactAddr__c(ccrz__ContactAddrId__c = direccionId),
                ccrz__AddressType__c = ADDRESS_TYPE_BILLING
            ));
            listToInsert.add(new ccrz__E_AccountAddressBook__c (
                Name = direccionId + osf_constant_strings.LINE + ADDRESS_TYPE_SHIPPING,
                ccrz__Default__c = !String.isBlank(direccion.principal), //String.isNotBlank(direccion.interlocutor) && direccion.interlocutor.contains(INTERLUCATOR_AG),
                ccrz__Owner__c = account.OwnerId,
                ccrz__Account__c = account.Id,
                ccrz__AccountId__c = account.Id,
                OwnerId = account.OwnerId,
                ccrz__E_ContactAddress__r = new ccrz__E_ContactAddr__c(ccrz__ContactAddrId__c = direccionId),
                ccrz__AddressType__c = ADDRESS_TYPE_SHIPPING
            ));
        }
        Database.insert(listToInsert, false);
    }

    public class RegisterException extends Exception{}
}