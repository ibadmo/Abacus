@IsTest
public class osf_LogicCartGetActive_Test {
    
    @IsTest
    public static void testFetchActive() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        Map<String, Object> outputData = new Map<String, Object> ();
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            osf_LogicCartGetActive logicCartGetActive = new osf_LogicCartGetActive();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccAPI.SIZING => new Map<String, Object> {
                    new osf_ServiceCart().ENTITYNAME => new Map<String, Object> {
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                    }
                },
                ccrz.ccAPICart.CART_ID => cart.Id,
                ccrz.ccAPICart.CART_ENCID => cart.ccrz__EncryptedId__c,
                ccrz.ccAPICart.BYSTOREFRONT => osf_testUtility.STOREFRONT,
                ccrz.ccAPICart.BYOWNER => user.Id,
                ccrz.ccAPICart.CARTSTATUS => osf_constant_strings.CART_STATUS_OPEN,
                ccrz.ccAPICart.GETACTIVE_UPDATE => true,
                ccrz.ccAPICart.CURRCODE => osf_testUtility.CURRENCY_ISO_CODE,
                osf_constant_strings.GAC_CART_ID_LIST => new Set<String> {cart.Id},
                osf_constant_strings.GAC_CART_ENCRYPTED_ID_LIST => new Set<String> {cart.ccrz__EncryptedId__c}
            };
            outputData = logicCartGetActive.fetchActive(inputData);
        }
        System.assert(! (Boolean) outputData.get(ccrz.ccAPICart.GETACTIVE_UPDATE));
    }

    @IsTest
    public static void testFetchActiveWithoutCart() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        Map<String, Object> outputData = new Map<String, Object> ();
        System.runAs(user) {
            osf_LogicCartGetActive logicCartGetActive = new osf_LogicCartGetActive();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccAPI.SIZING => new Map<String, Object> {
                    new osf_ServiceCart().ENTITYNAME => new Map<String, Object> {
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                    }
                },
                ccrz.ccAPICart.BYSTOREFRONT => osf_testUtility.STOREFRONT,
                ccrz.ccAPICart.BYOWNER => user.Id,
                ccrz.ccAPICart.CARTSTATUS => osf_constant_strings.CART_STATUS_OPEN,
                ccrz.ccAPICart.GETACTIVE_UPDATE => true,
                ccrz.ccAPICart.CURRCODE => osf_testUtility.CURRENCY_ISO_CODE
            };
            outputData = logicCartGetActive.fetchActive(inputData);
        }
        System.assert(! (Boolean) outputData.get(ccrz.ccAPICart.GETACTIVE_UPDATE));
    }
}