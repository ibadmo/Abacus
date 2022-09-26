/**
 * File:        osf_hk_TaxCalculation_test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 12, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test class for osf_hk_TaxCalculation
  ************************************************************************
 * History:
 */

@IsTest
public with sharing class osf_hk_TaxCalculation_test {
    
    /**********************************************************************************************
    * @Name         : createTestData
    * @Description  : creates test data
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 12, 2020
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
    @TestSetup
    public static void createTestData(){
        insert new osf_Abacus_B2B_config__c (
            osf_balearic_island_free_shipping_limit__c = 50,
            osf_balearic_island_shipping_cost__c = 7,
            osf_free_shipping_limit__c = 35,
            osf_shipping_cost__c = 4.95
        );
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();
        Contact contact = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        osf_tax_class__c taxClass = osf_testUtility.createTaxClass('Class10', 10);
        Database.insert(taxClass);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        product.osf_tax_class__c = taxClass.Id;
        Database.insert(product);
        System.runAs(user) {
            ccrz__E_Cart__c cart = testutility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress;
            cart.ccrz__ShipTo__c = contactAddress.Id;
            cart.ccrz__BillTo__c = contactAddress.Id;
            update cart;
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            Database.insert(cartItem);
        }
    } 
    
    /**********************************************************************************************
    * @Name         : testGetTaxAmount
    * @Description  : Test method for getTaxAmount
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 12, 2020
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
    @IsTest
    public static void testGetTaxAmount() {
        User user = [SELECT Id FROM User WHERE ccrz__dataId__c =: osf_testUtility.USER_DATA_ID1];
        Decimal totalTaxAmount;
        Decimal shippingCost;
        System.runAs(user) {
            osf_hk_TaxCalculation hkTaxCalculation = new osf_hk_TaxCalculation();
            ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id LIMIT 1];
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.cc_hk_TaxCalculation.PARAM_CARTID => cart.Id,
                ccrz.cc_hk_TaxCalculation.PARAM_SHIPADDR => new ccrz.cc_bean_MockContactAddress()
            };
            totalTaxAmount = hkTaxCalculation.getTaxAmount(inputData);
            cart = [SELECT ccrz__ShipAmount__c FROM ccrz__E_Cart__c WHERE Id = :cart.Id];
            shippingCost = cart.ccrz__ShipAmount__c;
        }
        System.assertEquals(true, totalTaxAmount > 0);
        System.assertEquals(100, totalTaxAmount);
        System.assertEquals(0, shippingCost);
    }
}