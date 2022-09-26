global with sharing class osf_hk_Payment extends ccrz.cc_hk_Payment {
    /**
     * Returns the valid payment types defined on the current Account object
     * @param  inputData The parameters sent via pubsub 
     * @return Comma seperated values of valid payment type codes
     */
    global virtual override Map<String,Object> getApplicablePaymentTypes(Map<String,Object> inputData){
        Map<String, Object> outputData = super.getApplicablePaymentTypes(inputData);
        try{
            Account account = [SELECT osf_validPaymentTypes__c FROM Account WHERE Id = :ccrz.cc_CallContext.currAccountId];
            String validPaymentCsv = osf_constant_strings.EMPTY_STRING;
            if(String.isNotBlank(account.osf_validPaymentTypes__c)){
                List<String> validPaymentTypes = account.osf_validPaymentTypes__c.split(osf_constant_strings.SEMI_COLON);
                List<String> validPaymentTypeCodes = new List<String>();
                for(String payment : validPaymentTypes){
                    validPaymentTypeCodes.add(osf_constant_strings.PAYMENT_TYPE_MAP.get(payment));
                }
                validPaymentCsv = String.join(validPaymentTypeCodes, osf_constant_strings.COMMA);
            }
            outputData.put(ccrz.cc_hk_Payment.PARAM_APPL_PAYMENT_TYPES, validPaymentCsv);
        } catch(Exception ex){
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:osf_hk_payment:getApplicablePaymentTypes:Error', ex);
        }
        return outputData;
    }
}