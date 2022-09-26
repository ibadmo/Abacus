global class osf_ccServiceProduct extends ccrz.ccServiceProduct{
	global static final List<String> FIELDS_TO_ADD = new List<String> {'osf_Allow_Add_to_Cart__c', 'osf_delivery_time__c', 'osf_tax_rate__c', 'osf_in_stock__c', 'osf_in_stock_checkout__c'};
	@TestVisible private static final String SELECT_COMPOSITE = 'SELECT Component__r.Name, Component__r.osf_tax_rate__c, Component__r.osf_delivery_time__c, osf_color_picker__c, Component__r.osf_Allow_Add_to_Cart__c, ';
    
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
		Map<String, Object> outputData = super.getFieldsMap(inputData);
		String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
		for(String field : FIELDS_TO_ADD) {
			fields += ', ' + field;
		}
		outputData.put(ccrz.ccService.OBJECTFIELDS, fields);
		return outputData;
	} 

	/**********************************************************************************************
    * @Name         : getSubQueryMap
    * @Description  : add new fields to CompositeProducts__r subquery
    * @Created By   : Alina Craciunel
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
	global virtual override Map<String, Object> getSubQueryMap(Map<String, Object> inputData) {
	
		if(ccrz.cc_CallContext.currPageName!=NULL && ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.PDP_PAGE)) {
			Map<String,Object> subQueryMap = super.getSubQueryMap(inputData);
			if(Test.isRunningTest()) {
				subQueryMap.put(osf_constant_strings.COMPOSITE_PRODUCTS, '(SELECT Id FROM ccrz__E_CompositeProduct__r)');
			}
			if (subQueryMap.get(osf_constant_strings.COMPOSITE_PRODUCTS) == null) {
				return subQueryMap;
			}
			String newSubquery = ((String)subQueryMap.get(osf_constant_strings.COMPOSITE_PRODUCTS)).replace(osf_constant_strings.SELECT_KEYWORD, SELECT_COMPOSITE);
			subQueryMap.put(osf_constant_strings.COMPOSITE_PRODUCTS, newSubquery);
			return subQueryMap;
		}
		return super.getSubQueryMap(inputData);
    }
}