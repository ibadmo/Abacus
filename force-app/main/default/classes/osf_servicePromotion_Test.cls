@IsTest
public class osf_servicePromotion_Test {

    @TestSetup
    public static void createTestData() {
        Account account = osf_testUtility.createAccount('Test Company');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;
    }
    
    @IsTest
    public static void testGetFilterMapWithoutAccountSpecificPromotion() {
        User user = [SELECT Id FROM User WHERE Username = 'test@email.com'];
        osf_servicePromotion servicePromotion = new osf_servicePromotion();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                servicePromotion.entityName => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = new Map<String, Object> ();
        System.runAs(user) {
            Test.startTest();
            outputData = servicePromotion.getFilterMap(inputData);
            Test.stopTest();
        }
        System.assertEquals(osf_constant_strings.ACCOUNT_PROMOTION_DEFAULT_FILTER, (String) outputData.get(osf_constant_strings.DEFAULT_PROMOTIONS));
    }

    @IsTest
    public static void testGetFilterMapWithAccountSpecificPromotion() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Company'];
        User user = [SELECT Id FROM User WHERE Username = 'test@email.com'];
        
        ccrz__E_Promo__c promotion = osf_testUtility.createPromotion(false);
        insert promotion;

        osf_account_promotion__c accountPromotion = osf_testUtility.createAccountPromotion(account, promotion);
        insert accountPromotion;
        
        osf_servicePromotion servicePromotion = new osf_servicePromotion();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                servicePromotion.entityName => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = new Map<String, Object> ();
        System.runAs(user) {
            Test.startTest();
            outputData = servicePromotion.getFilterMap(inputData);
            Test.stopTest();
        }
        System.assert(outputData.containsKey(osf_constant_strings.ACCOUNT_SPECIFIC_PROMOTIONS));
    }

    @IsTest
    public static void testGetFilterMapCatchBlock() {
        osf_servicePromotion servicePromotion = new osf_servicePromotion();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                servicePromotion.entityName => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Test.startTest();
        Map<String, Object> outputData = servicePromotion.getFilterMap(inputData);
        Test.stopTest();
        System.assert(!outputData.containsKey(osf_constant_strings.DEFAULT_PROMOTIONS));
        System.assert(!outputData.containsKey(osf_constant_strings.ACCOUNT_SPECIFIC_PROMOTIONS));
    }
}