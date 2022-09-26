trigger SCCSyncCustomerAccountTrigger on Account (before insert, before update) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result;
    try{	
        if(trigger.IsUpdate){
            List<Account> newAccounts = trigger.new;
            List<Account> oldAccounts = trigger.old;
            List<Account_Export__mdt> accFields = [SELECT Id, Field_API_Name__c FROM Account_Export__mdt]; // SABAS-11
            Map<String, Object> patchDataMap = new Map<String, Object>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap(); 
            for(Integer i = 0; i < newAccounts.size(); i++) {
                Account newAcc = newAccounts.get(i);
                Account oldAcc = oldAccounts.get(i);
                //start calculate actual state
                for(Account acc : newAccounts){
                    acc.PersonHasOptedOutOfEmail = !acc.RGPD__pc;
                }
                if((newAcc.Nr_of_Orders__c != oldAcc.Nr_of_Orders__c) || (newAcc.Nr_of_Orders_this_year__c != oldAcc.Nr_of_Orders_this_year__c)) {

                    if(oldAcc.Actual_state__c == 'Old Customer' && newAcc.Nr_of_Orders_this_year__c > 0) {
                        newAcc.Actual_State__c = 'Recovered';
                    }
                    else {
                        if(newAcc.Nr_of_Orders_this_year__c > 1) {
                            newAcc.Actual_State__c = 'Customer';
                        }
                        if(newAcc.Nr_of_Orders_this_year__c == 0 && newAcc.Nr_of_Orders__c > 0) {
                            newAcc.Actual_State__c = 'Old Customer';                    
                        }
                        if(newAcc.Nr_of_Orders__c == 1 && newAcc.Nr_of_Orders_before_this_year__c == 0) {
                            newAcc.Actual_State__c = 'New Customer';                    
                        }
                    }
                }
                //system.debug('oldAcc.Loyalty__c'+oldAcc.Loyalty__c);
               // system.debug('newAcc.Loyalty__c'+newAcc.Loyalty__c);   
               //  system.debug('oldAcc.Value__c'+oldAcc.Value__c);
               // system.debug('newAcc.Value__c'+newAcc.Value__c);   
                Map<String, Integer> loyalityMap = new Map<String, Integer> {'Very loyal'=>3, 'Loyal'=>2, 'Not loyal'=>1};
                        if(loyalityMap.containsKey(newAcc.Loyalty__c) && loyalityMap.containsKey(oldAcc.Loyalty__c))
                            if(oldAcc.High_loyalty__c != null && loyalityMap.get(newAcc.Loyalty__c) > loyalityMap.get(oldAcc.High_loyalty__c) ) {
                                newAcc.High_loyalty__c = newAcc.Loyalty__c;
                            } 
                        else if(oldAcc.High_loyalty__c == null){
                            newAcc.High_loyalty__c = newAcc.Loyalty__c;
                        }

                Map<String, Integer> valueMap = new Map<String, Integer> {'Heavy'=>3, 'Medium'=>2, 'Low'=>1};
                    //if(oldAcc.Value__c != newAcc.Value__c) {
                       // if(valueMap.containsKey(newAcc.Value__c) && valueMap.containsKey(oldAcc.Value__c))
                         //   system.debug('newAcc.Value__c:'+newAcc.Value__c);
                        //system.debug('oldAcc.Value__c:'+oldAcc.Value__c);
                        if(oldAcc.Maximum_value__c != null && valueMap.get(newAcc.Value__c) > valueMap.get(oldAcc.Maximum_value__c) ) {
                            newAcc.Maximum_value__c = newAcc.Value__c;
                        }
                        else if(oldAcc.Maximum_value__c == null){
                            newAcc.Maximum_value__c = newAcc.Value__c;
                        }
                   // }
                // end caluclate high value
                
                // this is avoid calling future method when object updated by webservice from CC.
                if(!newAcc.SFCC_update__c && !system.isBatch()) {
                    for (String str : fieldMap.keyset()) {
                        system.debug('SCCSyncCustomerAccountTrigger.IsUpdate'+ 'Field name: '+str +'. New value: ' + newAcc.get(str) +'. Old value: '+oldAcc.get(str));
                        //logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Field name: '+str +'. New value: ' + newAcc.get(str) +'. Old value: '+oldAcc.get(str));
                        if(newAcc.get(str) != oldAcc.get(str)){
                            //logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Patching commerce cloud for field '+ str);
                            system.debug('SCCSyncCustomerAccountTrigger.IsUpdate' + 'Patching commerce cloud for field '+ str);
                            patchDataMap.put(str, newAcc.get(str)); 
                        }
                    }
                    if(!patchDataMap.isEmpty()){
                        //Call Commerce Cloud patch
                        result = SCCAccountImpl.patchCustProfile(patchDataMap, newAcc);                      
                    } 
                }
                newAcc.SFCC_update__c = false;
                // SABAS-11
                newAcc.AccountShouldExport__c = false;
                for(Account_Export__mdt accMdt : accFields) {
                    if(newAcc.get(accMdt.Field_API_Name__c) <> oldAcc.get(accMdt.Field_API_Name__c)) {
                        newAcc.AccountShouldExport__c = true;
                        break;
                    }
                }
                // SABAS-11
            }        
        }
    }catch(Exception e){
        logger.error('SCCSyncCustomerAccountTrigger', 'Exception message : '
                     + e.getMessage() + ' StackTrack '+ e.getStackTraceString());   		
    }finally{
        logger.flush();
    } 
}