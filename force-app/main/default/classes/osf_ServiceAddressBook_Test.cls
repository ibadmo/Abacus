@IsTest
public class osf_ServiceAddressBook_Test {
    
    @IsTest
    public static void testGetFilterMap() {
        osf_ServiceAddressBook service = new osf_ServiceAddressBook();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                service.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            }
        };
        Map<String, Object> outputData = service.getFilterMap(inputData);
        Test.stopTest();
        System.assertEquals(osf_ServiceAddressBook.ACCOUNT_FILTER, (String) outputData.get(ccrz.ccAPIAddressBook.ACCOUNTID));
    }
}