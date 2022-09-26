@isTest
public class osf_ccServiceProduct_test {
	@isTest
	private static void testGetFieldsMap() {
		osf_ccServiceProduct service = new osf_ccServiceProduct();
		Test.startTest();
		Map<String, Object> resultMap = service.getFieldsMap(new Map<String, Object> {
			ccrz.ccAPI.SIZING => new Map<String, Object> {
				service.entityName => new Map<String, Object> {
					ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
				}
			}
		});
		Test.stopTest();
		String fields = (String) resultMap.get(ccrz.ccService.OBJECTFIELDS);
		System.assert(fields.length() > 0);
		for(String field : osf_ccServiceProduct.FIELDS_TO_ADD) {
			System.assert(fields.contains(field));
		}
	}

	/**********************************************************************************************
    * @Name         : testGetSubQueryMap
    * @Description  : test GetSubQueryMapp on pdp  page
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 14, 2020
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
	@isTest
	private static void testGetSubQueryMap() {
		osf_ccServiceProduct service = new osf_ccServiceProduct();
		ccrz__E_Product__c parentProduct = osf_testUtility.createCCProduct('parentSKU', 'Parent Product');
		parentProduct.ccrz__ProductType__c = osf_testUtility.PRODUCT_TYPE_AGGREGATED;
		ccrz__E_Product__c childProduct = osf_testUtility.createCCProduct('childSKU', 'Child Product');
		insert new List<ccrz__E_Product__c> {childProduct, parentProduct};
		ccrz__E_CompositeProduct__c compositeProduct = osf_testUtility.createCompositeProduct(parentProduct, childProduct);
        insert compositeProduct;
		ccrz.cc_CallContext.currPageName = osf_constant_strings.PDP_PAGE;
		Test.startTest();
		Map<String, Object> subQueryMap = service.getSubQueryMap(new Map<String, Object> {
			ccrz.ccAPI.SIZING => new Map<String, Object> {
				service.entityName => new Map<String, Object> {
					ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
				}
			}
		});
		Test.stopTest();
		System.assertNotEquals(null, subQueryMap);
	}
}