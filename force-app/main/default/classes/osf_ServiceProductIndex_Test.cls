@IsTest
public class osf_ServiceProductIndex_Test {
    
    @isTest
    public static void testGetFilterMap() {
        osf_ServiceProductIndex service = new osf_ServiceProductIndex();
        
        Test.startTest();
        Map<String, Object> resultMap = service.getFilterMap(new Map<String, Object>{
            ccrz.ccAPI.SIZING => new Map<String, Object>{
                service.ENTITYNAME => new Map<String, Object>{
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S
                }
            }
        });
        Test.stopTest();
    }

    @isTest
    public static void testBuildSearchQuery() {
        osf_ServiceProductIndex service = new osf_ServiceProductIndex();
        
        Test.startTest();
        Map<String, Object> resultMap = service.buildSearchQuery(new Map<String, Object>{
            ccrz.ccAPI.SIZING => new Map<String, Object>{
                service.ENTITYNAME => new Map<String, Object>{
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S
                }
            }
        });
        Test.stopTest();
    }
}