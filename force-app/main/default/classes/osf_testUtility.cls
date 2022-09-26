/**
 * File:        osf_testUtility.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Jan 6, 2019
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Test data creation
  ************************************************************************
 * History:
 */

@IsTest
public with sharing class osf_testUtility {
    public static final String STOREFRONT = 'DefaultStore';
    public static final String COMMUNITY_PROFILE = 'Abacus Shop User';
    public static final String SYS_ADMIN_PROFILE = 'System Administrator';
    public static final String CURRENCY_ISO_CODE = 'EUR';
    public static final String PRICELIST_NAME = 'osfPriceList';
    public static final String ACCOUNT_GROUP_PRICE_LIST = 'osfAccountGroupPriceList';
    public static final String ACCOUNT_GROUP = 'osfAccountGroup';
    public static final String ACCOUNT_NAME1 = 'osfAccount1';
    public static final String CONTACT_NAME1 = 'osfContact1';
    public static final String CONTACT_NAME2 = 'osfContact2';
    public static final String CONTACT_EMAIL1 = 'osfContact1@test.com';
    public static final String CONTACT_EMAIL2 = 'osfContact2@test.com';
    public static final String CONTACT_FIRST_NAME1 = 'A';
    public static final String CONTACT_FIRST_NAME2 = 'B';
    public static final String CONTACT_LAST_NAME1 = 'Contact';
    public static final String CONTACT_LAST_NAME2 = 'Contact';
    public static final String USER_DATA_ID1 = 'OsfUser';
    public static final String USER_EMAIL1 = 'OsfUser@test.com';
    public static final String USER_FIRST_NAME1 = 'Osf';
    public static final String USER_LAST_NAME1 = 'UserA';
    public static final String USER_DATA_ID2 = 'OsfUserA';
    public static final String USER_EMAIL2 = 'OsfUserA@test.com';
    public static final String USER_FIRST_NAME2 = 'OsfA';
    public static final String USER_LAST_NAME2 = 'UserA';
    public static final String USER_DATA_ID = 'OsfAdmin';
    public static final String LOCALE = 'es_ES';
    public static final String LANGUAGE_LOCALE_KEY = 'es';
    public static final String UTF = 'UTF-8';
    public static final String GMT = 'GMT';
    public static final String UNITED_STATES = 'United States';
    public static final String BEST_PRICE = 'Best Price';
    public static final String THEME = 'CC Test Theme';
    public static final String PRODUCT_TYPE = 'Product';
    public static final String PRODUCT_STATUS = 'Released';
    public static final String CART_TYPE = 'Cart';
    public static final String CART_NAME = 'New Cart';
    public static final String OPEN_STATUS = 'Open';
    public static final String CUSTOMER_TYPE_CODE_GENERAL = 'General';
    public static final String PROMOTION_LOCATION_TYPE = 'Splash';
    public static final String PROMOTION_PAGE_LOCATION = 'Landing Page';
    public static final String PROMOTION_IMAGE_SOURCE = 'URI';
    private Map<String, Object> testData;
    private ccrz__E_Cart__c defaultCart;
    private List<ccrz__E_CartItem__c> defaultCartItemList;
    private ccrz__E_Product__c defaultProduct;
    public static final String PRODUCT_TYPE_AGGREGATED = 'Aggregated';

    /**********************************************************************************************
    * @Name         : osf_testUtility
    * @Description  : Class constructor
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2019
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
    public osf_testUtility() {
        Profile communityUserProfile =[SELECT Id FROM Profile WHERE Name =: COMMUNITY_PROFILE LIMIT 1];
        Map<String, Map<String, Object>> config = new Map<String, Map<String, Object>> {
                ccrz.ccApiTestData.DATAOPTIONS => new Map<String, Object>{
                ccrz.ccApiTestData.INSERTDATA => true,
                ccrz.ccApiTestData.LOADDEFAULTS => false
            },
            STOREFRONT => new Map<String, Object> {
                'Allow_Anonymous_Browsing__c' => true,
                'Currencies__c' => CURRENCY_ISO_CODE,
                'Languages__c' => 'es_ES;ca_ES',
                'Customer_Portal_Account_Name__c' => 'PortalAccount',
                'CustomerPortalAcctGroupName__c' => 'PortalAccount',
                'DefaultCurrencyCode__c' => CURRENCY_ISO_CODE,
                'DefaultLocale__c' => LOCALE,
                'InventoryCheckFlag__c' => false,
                'Quoting_Enabled__c' => true,
                'Root_Category_Id__c' => 999999,
                'SearchRank_ExactProductNum__c' => 700.0,
                'SearchRank_ShortDesc__c' => 50.0,
                'SearchRank_InDisplayName__c' => 200.0,
                'SearchRank_InProdNum__c' => 100.0,
                'Skip_Tax_Calculation__c' => false,
                'Filter_Orders_Based_on_Owner__c' => true
            },
            ccrz.ccAPITestData.APPLICATION_SETTINGS => new Map<String, Object> {
                'Anonymous_Account_Name__c' => 'CCAnonymous',
                'Default_Storefront__c' => STOREFRONT
            },
            ccrz.ccApiTestData.ACCOUNT_DATA => new Map<String,Object> {   
                ccrz.ccApiTestData.ACCOUNT_LIST => new List<Map<String,Object>> {
                    new Map<String,Object> {
                        'name' => ACCOUNT_NAME1,
                        'ccrz__dataId__c' => ACCOUNT_NAME1,
                        'ccrz__E_AccountGroup__r' => new ccrz__E_AccountGroup__c(ccrz__dataId__c = ACCOUNT_GROUP)
                    }
                }
            },
            ccrz.ccApiTestData.ACCOUNTGROUP_DATA => new Map<String,Object>{
                ccrz.ccApiTestData.ACCOUNTGROUP_LIST => new List<Map<String,Object>>{
                    new Map<String,Object>{
                        'name' => ACCOUNT_GROUP,
                        'ccrz__dataId__c' => ACCOUNT_GROUP,
                        'ccrz__desc__c' => ACCOUNT_GROUP,
                        'ccrz__PriceListSelectionMethod__c' => BEST_PRICE,
                        'ccrz__ThemeName__c' => THEME
                    }
                }
            },
            ccrz.ccApiTestData.CONTACT_DATA => new Map<String,Object> {
                ccrz.ccApiTestData.CONTACT_LIST => new List<Map<String,Object>> {
                    new Map<String,Object> {
                        'ccrz__dataId__c' => CONTACT_NAME1,
                        'account' => new Account(ccrz__dataId__c = ACCOUNT_NAME1),
                        'email' => CONTACT_EMAIL1,
                        'lastName' => CONTACT_LAST_NAME1,
                        'firstName' => CONTACT_FIRST_NAME1
                    },
                    new Map<String,Object> {
                        'ccrz__dataId__c' => CONTACT_NAME2,
                        'account' => new Account(ccrz__dataId__c = ACCOUNT_NAME1),
                        'email' => CONTACT_EMAIL2,
                        'lastName' => CONTACT_LAST_NAME2,
                        'firstName' => CONTACT_FIRST_NAME2
                    }
                }
            },
            ccrz.ccApiTestData.USER_DATA => new Map<String, Object> {
                ccrz.ccApiTestData.USER_LIST => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'ccrz__dataId__c' => USER_DATA_ID1,
                        'alias' => USER_DATA_ID1,
                        'email' => USER_EMAIL1,
                        'lastName' => USER_LAST_NAME1,
                        'firstName' => USER_FIRST_NAME1,
                        'languageLocaleKey' => LANGUAGE_LOCALE_KEY,
                        'localeSIDKey' => LOCALE,
                        'emailEncodingKey' => UTF,
                        'profileId' => communityUserProfile.Id,
                        'username' => USER_EMAIL1,
                        'ccrz__CC_CurrencyCode__c' => CURRENCY_ISO_CODE,
                        'contact' => new Contact(ccrz__dataId__c = CONTACT_NAME1),
                        'timezoneSIDKey' => GMT,
                        'Country' => UNITED_STATES
                    },
                    new Map<String, Object> {
                        'ccrz__dataId__c' => USER_DATA_ID2,
                        'alias' => USER_DATA_ID2,
                        'email' => USER_EMAIL2,
                        'lastName' => USER_LAST_NAME2,
                        'firstName' => USER_FIRST_NAME2,
                        'languageLocaleKey' => LANGUAGE_LOCALE_KEY,
                        'localeSIDKey' => LOCALE,
                        'emailEncodingKey' => UTF,
                        'profileId' => communityUserProfile.Id,
                        'username' => USER_EMAIL2,
                        'ccrz__CC_CurrencyCode__c' => CURRENCY_ISO_CODE,
                        'contact' => new Contact(ccrz__dataId__c = CONTACT_NAME2),
                        'timezoneSIDKey' => GMT,
                        'Country' => UNITED_STATES
                    }
                }
            },
            ccrz.ccApiTestData.PRICELIST_DATA => new Map<String,Object> {
                ccrz.ccApiTestData.PRICELIST_LIST => new List<Map<String,Object>> {
                    new Map<String,Object> {
                        'name' => PRICELIST_NAME,
                        'ccrz__dataId__c' => PRICELIST_NAME,
                        'ccrz__desc__c' => PRICELIST_NAME,
                        'ccrz__Enabled__c' => true,
                        'ccrz__StartDate__c' => Date.today().addDays(-10),
                        'ccrz__EndDate__c' => Date.today().addDays(10),
                        'ccrz__Storefront__c' => STOREFRONT,
                        'ccrz__CurrencyISOCode__c' => CURRENCY_ISO_CODE,
                        'ccrz__PricelistId__c' => PRICELIST_NAME
                    }
                }
            },
            ccrz.ccApiTestData.AGPL_DATA => new Map<String,Object> {
                ccrz.ccApiTestData.AGPL_LIST => new List<Map<String,Object>> {
                    new Map<String,Object> {
                        'ccrz__dataId__c' => ACCOUNT_GROUP_PRICE_LIST,
                        'ccrz__Enable__c' => true,
                        'ccrz__StartDate__c' => Date.today().addDays(-10),
                        'ccrz__EndDate__c' => Date.today().addDays(10),
                        'ccrz__Sequence__c' => 100,
                        'ccrz__Pricelist__r' => new ccrz__E_Pricelist__c(ccrz__dataId__c = PRICELIST_NAME),
                        'ccrz__AccountGroup__r' => new ccrz__E_AccountGroup__c(ccrz__dataId__c = ACCOUNT_GROUP)
                    }
                }
            },
            ccrz.ccApiTestData.HOOK_SETTINGS => new Map<String,Object>{
                STOREFRONT => new Map<String,Object>{
                    ccrz.cc_hk_UserInterface.HK_ID => 'c.osf_hk_UserInterface'
                }
            },
            ccrz.ccAPITestData.LOGIC_SETTINGS => new Map<String, Object> {
                STOREFRONT => new Map<String, Object> {
                    'ccLogicProductPricing' => 'c.osf_logicProductPricing'
                }
            }
        }; 
        testData = ccrz.ccAPITestData.setupData(config);
    }

    public Account getDefaultAccount() {
        Map<String, Object> accountData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.ACCOUNT_DATA);
        List<sObject> accountList = (List<sObject>) accountData.get(ccrz.ccAPITestData.ACCOUNT_LIST);
        return (Account) accountList.get(0);
    }

    public ccrz__E_Pricelist__c getDefaultPricelist() {
        Map<String, Object> pricelistData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.PRICELIST_DATA);
        List<sObject> pricelistList = (List<sObject>) pricelistData.get(ccrz.ccAPITestData.PRICELIST_LIST);
        return (ccrz__E_Pricelist__c) pricelistList.get(0);
    }

    public ccrz__E_AccountGroupPricelist__c getDefaultAccountGroupPricelist() {
        Map<String, Object> accountGroupPricelistData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.AGPL_DATA);
        List<sObject> accountGroupPricelistList = (List<sObject>) accountGroupPricelistData.get(ccrz.ccAPITestData.AGPL_LIST);
        return (ccrz__E_AccountGroupPricelist__c) accountGroupPricelistList.get(0);
    }

    public Map<String, Contact> getContactByEmail() {
        Map<String, Contact> emailToContactMap = new Map<String, Contact> ();
        Map<String, Object> contactData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.CONTACT_DATA);
        List<sObject> contactList = (List<sObject>) contactData.get(ccrz.ccAPITestData.CONTACT_LIST);
        for(sObject contactObject : contactList) {
            Contact contact = (Contact) contactObject;
            emailToContactMap.put(contact.Email, contact);
        }
        return emailToContactMap;
    }

    public Map<String, User> getUsernameMap () {
        Map<String, User> usernameToUserMap = new Map<String, User> ();
        Map<String, Object> userData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.USER_DATA);
        List<sObject> userList = (List<sObject>) userData.get(ccrz.ccAPITestData.USER_LIST);
        for(sObject userObject : userList) {
            User user = (User) userObject;
            usernameToUserMap.put(user.Username, user);
        } 
        return usernameToUserMap;
    }

    public ccrz__E_AccountGroup__c getDefaultAccountGroup() {
        Map<String, Object> accountGroupData = (Map<String, Object>) this.testData.get(ccrz.ccAPITestData.ACCOUNTGROUP_DATA);
        List<sObject> accountGroupList = (List<sObject>) accountGroupData.get(ccrz.ccAPITestData.ACCOUNTGROUP_LIST);
        return (ccrz__E_AccountGroup__c) accountGroupList.get(0);
    }

    /**
	* Must be run with System.runAs
	*/
    public ccrz__E_Cart__c getDefaultCart() {
        if(this.defaultCart == null) {
            Map<String, Object> outputData = ccrz.ccAPICart.addTo(new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
            });
            this.defaultCart = [SELECT Id, ccrz__EncryptedId__c, ccrz__ActiveCart__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :(String) outputData.get(ccrz.ccAPICart.CART_ENCID)];
        }
        return this.defaultCart;
    }


    @isTest
    public static void test_hk_UserInterface()
    {
        Test.startTest();
        osf_hk_UserInterface osf_ui = new osf_hk_UserInterface();
        Map<String,Object> outPut = osf_ui.endContent(new Map<String,Object>{ ccrz.cc_hk_UserInterface.EOB_CONTENT => '' });
        System.debug(LoggingLevel.DEBUG, outPut);
        String endContent = (String)outPut.get(ccrz.cc_hk_UserInterface.EOB_CONTENT);
        System.assert( endContent.contains('js/main.js') , 'main.js is included!');
        Test.stopTest();
    }

    /**********************************************************************************************
    * @Name         : createCCProduct
    * @Description  : The Method will be called to create products for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2019
    * @Param        : String sku
    * @Param        : String name
    * @Return       : created ccrz__E_Product__c record
    *********************************************************************************************/
    public static ccrz__E_Product__c createCCProduct(String sku, String name) {
        return new ccrz__E_Product__c(
            Name = name,
            ccrz__SKU__c = sku, 
            ccrz__ProductType__c = PRODUCT_TYPE,
            ccrz__Storefront__c = STOREFRONT,
            ccrz__StartDate__c = Date.today().addDays(-10),
            ccrz__EndDate__c = Date.today().addDays(355),
            ccrz__Quantityperunit__c = 1.000,
            ccrz__ProductStatus__c = PRODUCT_STATUS
        );
    }

    /**********************************************************************************************
    * @Name         : createCart
    * @Description  : The Method will be called to create carts for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_ContactAddr__c billTo
    * @Param        : ccrz__E_ContactAddr__c shipTo
    * @Param        : Decimal taxAmount
    * @Param        : Decimal shippingAmount
    * @Param        : Account account
    * @Param        : User user
    * @Param        : Contact contact
    * @Return       : created ccrz__E_Cart__c record
    *********************************************************************************************/
   public static ccrz__E_Cart__c createCart(ccrz__E_ContactAddr__c billTo, ccrz__E_ContactAddr__c shipTo, Decimal taxAmount, Decimal shippingAmount, Account account, User user, Contact contact) {
       return new ccrz__E_Cart__c(
           ccrz__ShipTo__c = shipTo != null ? shipTo.Id : null,
           ccrz__BillTo__c = billTo != null ? billTo.Id : null,
           ccrz__Name__c = CART_NAME,
           ccrz__CartType__c = CART_TYPE,
           ccrz__CurrencyISOCode__c = CURRENCY_ISO_CODE,
           ccrz__Storefront__c = STOREFRONT,
           ccrz__CartStatus__c = OPEN_STATUS,
           ccrz__ShipAmount__c = shippingAmount,
           ccrz__TaxAmount__c = taxAmount,
           ccrz__Account__c = account.Id,
           ccrz__User__c = user.Id,
           ccrz__Contact__c = contact.Id
       );
   }

   /**********************************************************************************************
    * @Name         : createCartItem
    * @Description  : The Method will be called to create cart items for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Product__c product
    * @Param        : ccrz__E_Cart__c cart
    * @Param        : Integer quantity
    * @Param        : Decimal price
    * @Return       : created ccrz__E_CartItem__c record
    *********************************************************************************************/
     public static ccrz__E_CartItem__c createCartItem(ccrz__E_Product__c product, ccrz__E_Cart__c cart, Integer quantity, Decimal price) {
        return new ccrz__E_CartItem__c(
            ccrz__Product__c = product.Id,
            ccrz__Cart__c = cart.Id,
            ccrz__Quantity__c = quantity,
            ccrz__Price__c = price,
            ccrz__SubAmount__c = price
        );
     }

    /**********************************************************************************************
    * @Name         : getRemoteActionContext
    * @Description  : The Method will be called to get the remote action context
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : User user
    * @Param        : String storefront
    * @Return       : cc_RemoteActionContext record
    *********************************************************************************************/
    public ccrz.cc_RemoteActionContext getRemoteActionContext(User user, String storefront) {
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.portalUserId = user.Id;
        ctx.userLocale = user.LanguageLocaleKey;
        System.runAs(user){
            ctx.currentCartId = getDefaultCart().ccrz__EncryptedId__c;
        }
        return ctx;
    }

    /**********************************************************************************************
    * @Name         : getRemoteActionContext
    * @Description  : The Method will be called to get the remote action context
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : User user
    * @Param        : String storefront
    * @Param        : ccrz__E_Cart__c cart
    * @Return       : cc_RemoteActionContext record
    *********************************************************************************************/
    public static ccrz.cc_RemoteActionContext getRemoteActionContext(User user, String storefront, ccrz__E_Cart__c cart) {
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.portalUserId = user.Id;
        ctx.userLocale = user.LanguageLocaleKey;
        System.runAs(user){
            if(String.isBlank(cart.ccrz__EncryptedId__c)) {
                cart = [SELECT ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE Id = :cart.Id];
            }
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
        }
        return ctx;
    }

    /**********************************************************************************************
    * @Name         : createContactAddress
    * @Description  : The Method will be called to create CC Contact Address for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String firstName,
    * @Param        : String lastName,
    * @Param        : String address,
    * @Param        : String city,
    * @Param        : String state,
    * @Param        : String country,
    * @Param        : String countryISOCode,
    * @Param        : String postalCode,
    * @Param        : String companyName,
    * @Return       : ccrz__E_ContactAddr__c, created CC Contact Address record. Returning before insert in case, some list insertion required in test class
    *********************************************************************************************/
    public static ccrz__E_ContactAddr__c createContactAddress(String firstName, String lastName, String address, String city, String state, String country, String countryISOCode, String postalCode, String companyName) {
        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
        contactAddress.ccrz__FirstName__c = firstName;
        contactAddress.ccrz__LastName__c = lastName;
        contactAddress.ccrz__AddressFirstline__c = address;
        contactAddress.ccrz__City__c = city;
        contactAddress.ccrz__State__c = state;
        contactAddress.ccrz__Country__c = country;
        contactAddress.ccrz__CountryISOCode__c = countryISOCode;
        contactAddress.ccrz__PostalCode__c = postalCode;
        contactAddress.ccrz__CompanyName__c = companyName;
        return contactAddress;
    }

    /**********************************************************************************************
    * @Name         : createCCOrder
    * @Description  : The Method will be called to create CC Order for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Return       : ccrz__E_Order__c, created CC Order record. Returning before insert in case, some list insertion required in test class
    *********************************************************************************************/
    public static ccrz__E_Order__c createCCOrder(ccrz__E_Cart__c cart) {
        ccrz__E_Order__c order = new ccrz__E_Order__c();
        order.ccrz__Storefront__c = STOREFRONT;
        order.ccrz__ShipTo__c = cart.ccrz__ShipTo__c;
        order.ccrz__BillTo__c = cart.ccrz__BillTo__c;
        order.ccrz__IsAnonymous__c = false;
        order.ccrz__OriginatedCart__c = cart.Id;
        return order;
    }

    /**********************************************************************************************
    * @Name         : createCCOrderItem
    * @Description  : The Method will be called to create CC Order Item for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Order__c order
    * @Param        : ccrz__E_Product__c product
    * @Param        : Integer quantity
    * @Param        : Decimal price
    * @Return       : ccrz__E_OrderItem__c, created CC Order Item record
    *********************************************************************************************/
    public static ccrz__E_OrderItem__c createCCOrderItem(ccrz__E_Order__c order, ccrz__E_Product__c product, Integer quantity, Decimal price) {
        return new ccrz__E_OrderItem__c(
            ccrz__Product__c = product.Id,
            ccrz__Order__c = order.Id,
            ccrz__Quantity__c = quantity,
            ccrz__Price__c = price,
            ccrz__SubAmount__c = price
        );
    }

    /**********************************************************************************************
    * @Name         : createAccount
    * @Description  : The Method will be called to create an Account for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String name
    * @Return       : Account record
    *********************************************************************************************/
    public static Account createAccount(String name) {
        return new Account(Name = name);
    }

    /**********************************************************************************************
    * @Name         : createContact
    * @Description  : The Method will be called to create a Contact for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String firstName
    * @Param        : String lastName
    * @Param        : Account account
    * @Param        : String email
    * @Return       : Contact record
    *********************************************************************************************/
    public static Contact createContact(String firstName, String lastName, Account account, String email) {
        return new Contact(
            FirstName = firstName, 
            LastName = lastName,
            AccountId = account.Id,
            Email = email
        );
    }

    /**********************************************************************************************
    * @Name         : createUser
    * @Description  : The Method will be called to create users for test purposes.
    * @Created By   : Alina Craciunel
    * @Created Date : Jan 6, 2020
    * @Param        : Profile profile
    * @Param        : String alias
    * @Param        : String email
    * @Param        : String firstName
    * @Param        : String lastName
    * @Return       : created User record
    *********************************************************************************************/
    public static User createUser(Profile profile, String alias, String email, String firstName, String lastName, String data) {
        return new User (
            Alias = alias, 
            Email = email, 
            EmailEncodingKey = UTF, 
            FirstName = firstName,
            LastName = lastName, 
            LanguageLocaleKey = LANGUAGE_LOCALE_KEY, 
            LocaleSidKey = LOCALE, 
            ProfileId = profile.Id, 
            TimeZoneSidKey = GMT, 
            UserName = email,
            IsActive = true,
            ccrz__dataId__c = data
        );
    }

    /**********************************************************************************************
    * @Name         : create User
    * @Description  : The Method will be called to create a User for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : Contact contact
    * @Return       : User record
    *********************************************************************************************/
    public static User createUser(Contact contact) {
        return new User (
            Alias = contact.FirstName.substring(0,1).toLowerCase() + contact.LastName.toLowerCase(),
            EmailEncodingKey = UTF,
            Email = contact.Email,
            LanguageLocaleKey = LANGUAGE_LOCALE_KEY,
            FirstName = contact.FirstName,
            LastName = contact.LastName,
            LocaleSidKey = LOCALE,
            Country = UNITED_STATES,
            IsActive = true,
            TimeZoneSidKey = GMT,
            Username = contact.Email,
            CommunityNickname = contact.Email
        );
    }

    /**********************************************************************************************
    * @Name         : createCommunityUser
    * @Description  : The Method will be called to create a User for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : Contact contact
    * @Return       : User record
    *********************************************************************************************/
    public static User createCommunityUser(Contact contact) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_PROFILE];
        User user = createUser(contact);
        user.ProfileId = profile.Id;
        user.ContactId = contact.Id;
        return user;
    }

    /**********************************************************************************************
    * @Name         : createProductMedia
    * @Description  : The Method will be called to create a Product Media for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan6, 2020
    * @Param        : ccrz__E_Product__c product
    * @Param        : String locale
    * @Param        : String mediaType
    * @Param        : String mediaSource
    * @Return       : ccrz__E_ProductMedia__c record
    *********************************************************************************************/
    public static ccrz__E_ProductMedia__c createProductMedia(ccrz__E_Product__c product, String locale, String mediaType, String mediaSource) {
        return new ccrz__E_ProductMedia__c (
            ccrz__Product__c = product.Id,
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__Sequence__c = 500,
            ccrz__Enabled__c = true,
            ccrz__Locale__c = locale,
            ccrz__MediaType__c = mediaType,
            ccrz__ProductMediaSource__c = mediaSource
        );
    }

    /**********************************************************************************************
    * @Name         : setupStorefront
    * @Description  : The Method will be called to setup Storefront Settings
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Return       : 
    *********************************************************************************************/
    public static void setupStorefront() {
        ccrz.ccAPITestData.setupData(new Map<String, Map<String, Object>> {
            STOREFRONT => new Map<String, Object> {
                'Allow_Anonymous_Browsing__c' => true,
                'Currencies__c' => 'EUR',
                'Languages__c' => 'es_ES',
                'Customer_Portal_Account_Name__c' => 'PortalAccount',
                'CustomerPortalAcctGroupName__c' => 'PortalAccount',
                'DefaultCurrencyCode__c' => 'EUR',
                'DefaultLocale__c' => 'es_ES',
                'InventoryCheckFlag__c' => false,
                'Quoting_Enabled__c' => true,
                'Root_Category_Id__c' => 999999,
                'SearchRank_ExactProductNum__c' => 700.0,
                'SearchRank_ShortDesc__c' => 50.0,
                'SearchRank_InDisplayName__c' => 200.0,
                'SearchRank_InProdNum__c' => 100.0,
                'Skip_Tax_Calculation__c' => false,
                'Filter_Orders_Based_on_Owner__c' => true
            }
        });
    }

    /**********************************************************************************************
    * @Name         : createCCAccountGroup
    * @Description  : The Method will be called to create a CC Account Group object for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String name
    * @Return       : ccrz__E_AccountGroup__c accountGroup
    *********************************************************************************************/
    public static ccrz__E_AccountGroup__c createCCAccountGroup(String name) {
        return new ccrz__E_AccountGroup__c (
            Name = name,
            ccrz__AccountGroupID__c = name,
            ccrz__PriceListSelectionMethod__c = BEST_PRICE           
        );
    }

    /**********************************************************************************************
    * @Name         : createPricelist
    * @Description  : The Method will be called to create a CC Pricelist object for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String name
    * @Return       : ccrz__E_Pricelist__c pricelist
    *********************************************************************************************/
    public static ccrz__E_Pricelist__c createPricelist(String name) {
        return new ccrz__E_Pricelist__c (
            Name = name,
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__Storefront__c = STOREFRONT,
            ccrz__CurrencyISOCode__c = CURRENCY_ISO_CODE,
            ccrz__Desc__c = name,
            ccrz__Enabled__c = true,
            ccrz__CustomerTypeCode__c = CUSTOMER_TYPE_CODE_GENERAL,
            ccrz__PricelistId__c = name
        );
    }

    /**********************************************************************************************
    * @Name         : createPricelistItem
    * @Description  : The Method will be called to create a CC Pricelist Item object for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Pricelist__c pricelist
    * @Param        : ccrz__E_Product__c product
    * @Param        : Decimal price
    * @Return       : ccrz__E_PricelistItem__c
    *********************************************************************************************/
    public static ccrz__E_PricelistItem__c createPricelistItem(ccrz__E_Pricelist__c pricelist, ccrz__E_Product__c product, Decimal price) {
        return new ccrz__E_PricelistItem__c(
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__Pricelist__c = pricelist.Id,
            ccrz__PricelistItemId__c = pricelist.Id + '-' + product.Id,
            ccrz__Product__c = product.Id,
            ccrz__Price__c = price,
            ccrz__StartDate__c = System.today()
        );
    }

    /**********************************************************************************************
    * @Name         : createCCAccountGroupPricelist
    * @Description  : The Method will be called to create a CC Account Group Pricelist object for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_AccountGroup__c accountGroup
    * @Param        : ccrz__E_Pricelist__c pricelist
    * @Return       : ccrz__E_AccountGroupPricelist__c accountGroupPricelist
    *********************************************************************************************/
    public static ccrz__E_AccountGroupPricelist__c createCCAccountGroupPricelist(ccrz__E_AccountGroup__c accountGroup, ccrz__E_Pricelist__c pricelist) {
        return new ccrz__E_AccountGroupPricelist__c (
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__Sequence__c = 500,
            ccrz__AccountGroup__c = accountGroup.Id,
            ccrz__Pricelist__c = pricelist.Id,
            ccrz__Enable__c = true,
            ccrz__DataId__c = accountGroup.Id + '-' + pricelist.Id,
            ccrz__AccountGroupPriceListID__c = accountGroup.Id + '-' + pricelist.Id
        );
    }

    /**********************************************************************************************
    * @Name         : createSpec
    * @Description  : The Method will be called to create CC Spec for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String name
    * @Return       : ccrz__E_Spec__c, created CC Spec record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_Spec__c createSpec(String name) {
        ccrz__E_Spec__c spec = new ccrz__E_Spec__c();
        spec.Name = name;
        spec.ccrz__DisplayName__c = name;
        return spec;
    }

    /**********************************************************************************************
    * @Name         : createProductSpec
    * @Description  : The Method will be called to create CC Product Spec for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Product__c product
    * @Param        : ccrz__E_Spec__c spec
    * @Param        : String value
    * @Return       : ccrz__E_ProductSpec__c, created CC Product Spec record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_ProductSpec__c createProductSpec(ccrz__E_Product__c product, ccrz__E_Spec__c spec, String value) {
        return new ccrz__E_ProductSpec__c (
            ccrz__Product__c = product.Id,
            ccrz__Spec__c = spec.Id,
            ccrz__SpecValue__c = value
        );
    }

    /**********************************************************************************************
    * @Name         : createCategory
    * @Description  : The Method will be called to create CC Category for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : String name
    * @Return       : ccrz__E_Category__c, created CC Category record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_Category__c createCategory(String name) {
        return new ccrz__E_Category__c(
            Name = name,
            ccrz__CategoryID__c = name,
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__StartDate__c = System.today(),
            ccrz__Sequence__c = 500
        );
    }

    /**********************************************************************************************
    * @Name         : createProductCategory
    * @Description  : The Method will be called to create CC Product Category for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Category__c category
    * @Param        : ccrz__E_Product__c product
    * @Return       : ccrz__E_ProductCategory__c, created CC Product Category record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_ProductCategory__c createProductCategory(ccrz__E_Category__c category, ccrz__E_Product__c product) {
        return new ccrz__E_ProductCategory__c(
            ccrz__Product__c = product.Id,
            ccrz__Category__c = category.Id,
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__Sequence__c = 500
        );
    }

    /**********************************************************************************************
    * @Name         : generateUniqueName
    * @Description  : The Method will generate a random unique name for test purposes
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 8, 2019
    * @Return       : String uniqueName
    *********************************************************************************************/
    public static String generateUniqueName() {
        return UserInfo.getOrganizationId() + String.valueOf(System.now()).trim().replace(osf_constant_strings.COLON, osf_constant_strings.EMPTY_STRING).replace(osf_constant_strings.LINE, osf_constant_strings.EMPTY_STRING) + Integer.valueOf(Math.rint(Math.random() * 1000000));
    }

    /**********************************************************************************************
    * @Name         : createProminentProduct
    * @Description  : The Method will be called to create Prominent Product for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 6, 2020
    * @Param        : ccrz__E_Product__c product
    * @Param        : String type
    * @Return       : osf_prominent_product__c, created Prominent Product record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static osf_prominent_product__c createProminentProduct(ccrz__E_Product__c product, String type) {
        return new osf_prominent_product__c (
            osf_product__c = product.Id,
            osf_type__c = type
        );
    }

    /**********************************************************************************************
    * @Name         : createPromotion
    * @Description  : The Method will be called to create CC Promotion for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 8, 2020
    * @Param        : Boolean isDefault
    * @Return       : ccrz__E_Promo__c, created CC Promotion record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_Promo__c createPromotion(Boolean isDefault) {
        return new ccrz__E_Promo__c (
            Name = generateUniqueName(),
            ccrz__Sequence__c = 100,
            ccrz__LocationType__c = PROMOTION_LOCATION_TYPE,
            ccrz__PageLocation__c = PROMOTION_PAGE_LOCATION,
            ccrz__Enabled__c = true,
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = Date.newInstance(2099, 12, 31),
            ccrz__ImageSource__c = PROMOTION_IMAGE_SOURCE,
            ccrz__Storefront__c = STOREFRONT,
            ccrz__StorefrontMS__c = STOREFRONT,
            osf_default__c = isDefault
        );
    }

    /**********************************************************************************************
    * @Name         : createAccountPromotion
    * @Description  : The Method will be called to create Account Promotion for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 8, 2020
    * @Param        : Account account,
    * @Param        : ccrz__E_Promot__c promotion
    * @Return       : osf_account_promotion__c, created Account Promotion record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static osf_account_promotion__c createAccountPromotion(Account account, ccrz__E_Promo__c promotion) {
        return new osf_account_promotion__c (
            osf_account__c = account.Id,
            osf_promotion__c = promotion.Id
        );
    }

    /**********************************************************************************************
    * @Name         : createCoupon
    * @Description  : The Method will be called to create CC Coupon for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 23, 2020
    * @Param        : String couponCode
    * @Param        : String ruleType,
    * @Param        : String discountType
    * @Param        : Decimal discountAmount
    * @Return       : ccrz__E_Coupon__c, created CC Coupon record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_Coupon__c createCoupon(String couponCode, String ruleType, String discountType, Decimal discountAmount) {
        return new ccrz__E_Coupon__c (
            ccrz__CouponName__c = couponCode,
            ccrz__StartDate__c = Date.today().addDays(-7),
            ccrz__EndDate__c = Date.newInstance(2099, 12 ,31),
            ccrz__CouponCode__c = couponCode,
            ccrz__RuleType__c = ruleType,
            ccrz__DiscountType__c = discountType,
            ccrz__DiscountAmount__c = discountAmount,
            ccrz__MaxUse__c = 1000,
            ccrz__TotalUsed__c = 0,
            ccrz__Storefront__c = STOREFRONT,
            ccrz__Enabled__c = true,
            ccrz__CartTotalAmount__c = 0
        );
    }

    /**********************************************************************************************
    * @Name         : createNegotiatedDiscount
    * @Description  : The Method will be called to create Negotiated Discount for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 23, 2020
    * @Param        : Account account
    * @Param        : Decimal discountRate
    * @Param        : String productId
    * @Param        : String catalogId
    * @Param        : String couponId
    * @Return       : osf_negotiated_discount__c, created Negotiated Discount record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static osf_negotiated_discount__c createNegotiatedDiscount(Account account, Decimal discountRate, String productId, String catalogId, String couponId) {
        return new osf_negotiated_discount__c(
            osf_account__c = account.Id,
            osf_start_date__c = Date.today().addDays(-7),
            osf_end_date__c = Date.newInstance(2099, 12, 31),
            osf_discount_rate__c = discountRate,
            osf_product__c = productId,
            osf_catalog_id__c = catalogId,
            osf_coupon__c = couponId
        );
    }

    /**********************************************************************************************
    * @Name         : createCartCoupon
    * @Description  : The Method will be called to create CC Cart Coupon for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jan 24, 2020
    * @Param        : ccrz__E_Cart__c cart
    * @Param        : ccrz__E_Coupon__c coupon
    * @Return       : ccrz__E_CartCoupon__c, created CC Cart Coupon record. Returning before insert in case, some list insertion required in test class  
    *********************************************************************************************/
    public static ccrz__E_CartCoupon__c createCartCoupon(ccrz__E_Cart__c cart, ccrz__E_Coupon__c coupon) {
        return new ccrz__E_CartCoupon__c(
            ccrz__Cart__c = cart.Id,
            ccrz__Coupon__c = coupon.Id,
            Name = cart.Id + osf_constant_strings.LINE + coupon.Id,
            ccrz__Enabled__c = true
        );
    }

    
    /**********************************************************************************************
    * @Name         : createTaxClass
    * @Description  : The Method will be called to create a osf_tax_class__c object for test purposes.
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 13, 2020
    * @Param        : String className
    * @Param        : Decimal taxRate
    * @Return       : osf_tax_class__c, created record
    *********************************************************************************************/
    public static osf_tax_class__c createTaxClass(String className, Decimal taxRate){
        return new osf_tax_class__c(
            osf_taxClassName__c = className,
            osf_tax_rate__c = taxRate
        );
    }

    /**********************************************************************************************
    * @Name         : createCompositeProduct
    * @Description  : The Method will be called to create a ccrz__E_CompositeProduct__c object for test purposes.
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 15, 2020
    * @Param        : ccrz__E_Product__c parent
    * @Param        : ccrz__E_Product__c child
    * @Return       : ccrz__E_CompositeProduct__c, created record
    *********************************************************************************************/
    public static ccrz__E_CompositeProduct__c createCompositeProduct(ccrz__E_Product__c parent, ccrz__E_Product__c child) {
        return new ccrz__E_CompositeProduct__c(
            ccrz__Composite__c = parent.Id,
            ccrz__Component__c = child.Id,
            ccrz__Quantity__c = 1,
            ccrz__Sequence__c = 500
        );
    }

    /**********************************************************************************************
    * @Name         : createAccountAddressBook
    * @Description  : The Method will be called to create a ccrz__E_AccountAddressBook__c object for test purposes.
    * @Created By   : Ozgun Eser
    * @Created Date : Jun 8, 2020
    * @Param        : String name
    * @Param        : Account account
    * @Param        : ccrz__E_ContactAddr__c contactAddress
    * @Param        : String addressType
    * @Param        : Boolean isDefault
    * @Return       : ccrz__E_AccountAddressBook__c, created record
    *********************************************************************************************/
    public static ccrz__E_AccountAddressBook__c createAccountAddressBook(String name, Account account, ccrz__E_ContactAddr__c contactAddress, String addressType, Boolean isDefault) {
        return new ccrz__E_AccountAddressBook__c(
            Name = name,
            ccrz__AddressBookId__c = name,
            ccrz__Default__c = isDefault,
            ccrz__Account__c = account.Id,
            ccrz__AccountId__c = account.Id,
            ccrz__E_ContactAddress__c = contactAddress.Id,
            ccrz__AddressType__c = addressType
        );
    }   
}