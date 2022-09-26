@IsTest
public class osf_ServiceCartItem_Test {
    
    @IsTest
    public static void testGetFieldsMap() {
        osf_ServiceCartItem serviceCartItem = new osf_ServiceCartItem();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                serviceCartItem.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = serviceCartItem.getFieldsMap(inputData);
        Test.stopTest();
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        for(String field : osf_ServiceCartItem.FIELD_LIST) {
            System.assert(fields.contains(field));
        }
    }
}