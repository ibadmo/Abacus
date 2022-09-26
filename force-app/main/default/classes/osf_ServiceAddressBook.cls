global with sharing class osf_ServiceAddressBook extends ccrz.ccServiceAddressBook {

    @TestVisible private static final String ACCOUNT_FILTER = 'Account__c = :ccAPIAddressBook.ACCOUNTID';
    
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFilterMap(inputData);
        outputData.put(ccrz.ccAPIAddressBook.ACCOUNTID, ACCOUNT_FILTER);
        return outputData;
    }
}