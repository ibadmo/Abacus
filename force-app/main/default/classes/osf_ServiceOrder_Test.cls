@IsTest
public class osf_ServiceOrder_Test {

    @IsTest
    public static void testGetFieldsMap() {
        osf_ServiceOrder serviceOrder = new osf_ServiceOrder();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                serviceOrder.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = serviceOrder.getFieldsMap(inputData);
        Test.stopTest();
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        for(String field : osf_ServiceOrder.FIELD_LIST) {
            System.assert(fields.contains(field));
        }
    }
    
    @IsTest
    public static void testGetFilterMap() {
        osf_ServiceOrder serviceOrder = new osf_ServiceOrder();
        Test.startTest();
        ccrz.cc_CallContext.currPageName = osf_constant_strings.MY_ACCOUNT_PAGE;
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccService.BASEFIELDSMAP => new Map<String, Object> {
                ccrz.ccAPI.SZ_M => 'Id,OwnerId,Name,EncryptedId__c,LastModifiedDate'
            },
            ccrz.ccAPICart.BYSTOREFRONT => osf_testUtility.STOREFRONT,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                serviceOrder.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            },
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = serviceOrder.getFilterMap(inputData);
        Test.stopTest();
        System.assert(!outputData.containsKey(ccrz.ccAPICart.BYOWNER));
    }
}