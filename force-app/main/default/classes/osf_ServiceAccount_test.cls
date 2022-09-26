@isTest
private with sharing class osf_ServiceAccount_test {
    @IsTest
    public static void testGetFieldsMap() {
        osf_ServiceAccount serviceAccount = new osf_ServiceAccount();
        Test.startTest();
		Map<String, Object> resultMap = serviceAccount.getFieldsMap(new Map<String, Object> {
			ccrz.ccAPI.SIZING => new Map<String, Object> {
				serviceAccount.entityName => new Map<String, Object> {
					ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
				}
            },
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
		});
		Test.stopTest();
		String fields = (String) resultMap.get(ccrz.ccService.OBJECTFIELDS);
		System.assert(fields.length() > 0);
		for(String field : osf_ServiceAccount.FIELD_LIST) {
			System.assert(fields.contains(field));
		}
    }

    @IsTest
    public static void testPrepReturnMyAccount() {
        List<osf_province_list__c> testprovincelist = new List<osf_province_list__c>();
        testprovincelist.add(new osf_province_list__c(Name ='province1'));
        testprovincelist.add(new osf_province_list__c(Name ='province2'));
        insert testprovincelist;

        Account account = osf_testUtility.createAccount('Test Company');
        insert account;
        
        ccrz.cc_CallContext.currPageName = osf_constant_strings.MY_ACCOUNT_PAGE;
        
        osf_ServiceAccount serviceAcc = new osf_ServiceAccount();

        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccApiAccount.ACCOUNTS => new List<Map<String, Object>> {new Map<String, Object> {
                osf_constant_strings.ACCOUNT_PROVINCE_LIST => testprovincelist
            }}
        };
        Map<String, Object> outputData = serviceAcc.prepReturn(inputData);
        Test.stopTest();

        List<Map<String, Object>> accountMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccApiAccount.ACCOUNTS);
        Map<String, Object> accountMap = accountMapList[0];
        System.assertNotEquals(null,accountMap.get(osf_constant_strings.ACCOUNT_PROVINCE_LIST));
        
    }
}