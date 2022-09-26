/**
 * File:        osf_ServiceOrderItem_Test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Apr 30, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test calss for osf_ServiceOrderItem
  ************************************************************************
 * History:
 */
@IsTest
public class osf_ServiceOrderItem_Test {
    
    @IsTest
    public static void testGetFieldsMap() {
        osf_ServiceOrderItem serviceOrderItem = new osf_ServiceOrderItem();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                serviceOrderItem.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = serviceOrderItem.getFieldsMap(inputData);
        Test.stopTest();
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        for(String field : osf_ServiceOrderItem.FIELD_LIST) {
            System.assert(fields.contains(field));
        }
    }
}