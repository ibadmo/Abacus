/**
* File:        osf_CCAddressBook_TriggerHandler.cls
* Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
* Date:        June 26, 2020
* Created By:  Alina Craciunel
************************************************************************
* Description: Trigger handler for osf_CCAddressBook_Trigger
************************************************************************
* History:
*/
public without sharing class osf_CCAddressBook_TriggerHandler {
    public static Boolean isFirstTime = true;
    
    /* 
    * @description  : default address book logic
    * @author       : Alina Craciunel
    * @createdDate  : Jun 26, 2020
    * @param        : Map<Id, ccrz__E_AccountAddressBook__c> addressBookMap
    * @return       : 
    */
    public static void afterInsertUpdate(Map<Id, ccrz__E_AccountAddressBook__c> addressBookMap) {  
        Set<Id> setAccIds = new Set<Id>();
        List<ccrz__E_AccountAddressBook__c> lstAddressesToUpdate = new List<ccrz__E_AccountAddressBook__c>();
        Boolean setDefaultShipping = false;
        Boolean setDefaultBilling = false;    
        try {
            for (ccrz__E_AccountAddressBook__c addr : addressBookMap.values()) {
                if (addr.ccrz__Default__c) {
                    if (addr.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_SHIPPING) {
                        setDefaultShipping = true;
                        setAccIds.add(addr.ccrz__Account__c);
                    } else if (addr.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_BILLING) {
                        setDefaultBilling = true;
                        setAccIds.add(addr.ccrz__Account__c);
                    }
                }             
            }
            if (!setAccIds.isEmpty()) {
                for (ccrz__E_AccountAddressBook__c oldAddr : [SELECT Id, ccrz__AddressType__c, ccrz__Account__c, ccrz__Default__c FROM ccrz__E_AccountAddressBook__c WHERE Id NOT IN :addressBookMap.keySet() AND ccrz__Account__c IN :setAccIds AND ccrz__Default__c = true]) {
                    if ((setDefaultShipping && oldAddr.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_SHIPPING)
                        || (setDefaultBilling && oldAddr.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_BILLING)) {
                            oldAddr.ccrz__Default__c = false;
                            lstAddressesToUpdate.add(oldAddr);
                        }            
                }
                if (!lstAddressesToUpdate.isEmpty()) {
                    update lstAddressesToUpdate;
                } 
            }
        } catch(Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:CCAddressBook:TriggerHandler.afterInsertUpdate:Error', e.getMessage() + 'in line number: ' + e.getLineNumber());      
        }        
    }    
}