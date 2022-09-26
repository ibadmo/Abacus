global without sharing class osf_ctrl_myaccount_myusers {
    /* 
    * @description  : getContacts 
    * @author       : Cansu Asli Asci
    * @createdDate  : Feb 28, 2020
    * @param        : ccrz.cc_RemoteActionContext context, 
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getContacts(ccrz.cc_RemoteActionContext ctx, String isAdmin) {
        
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try{
            String contactId = osf_constant_strings.EMPTY_STRING;
            List<Contact> notAdminContacts = new List<Contact>();

            if(Boolean.valueOf(isAdmin)){
                notAdminContacts = [SELECT Id, AccountId, osf_role__c, Name, osf_allow_checkout__c, osf_supervisor__c, osf_supervisor_2__c FROM Contact WHERE AccountId = :ccrz.cc_CallContext.currAccountId];
            }
            data.put(osf_constant_strings.MYUSERS_CONTACTS, transformContacts(notAdminContacts));
            result.success = true;
        }catch(Exception ex){
        
            result.success = false;
           result.messages.add(osf_utility.createBeanMessage(ex));
        }
        return result;
    } 

    private static List<Map<String, Object>> transformContacts(List<Contact> contacts){
        List<Map<String, Object>> data = new List<Map<String, Object>> ();
        String supervisorName = osf_constant_strings.EMPTY_STRING;
        String supervisor2Name = osf_constant_strings.EMPTY_STRING;

        for(Contact cnt : contacts){
           
            if(String.isNotBlank(cnt.osf_supervisor__c)){
                supervisorName = [SELECT Name FROM Contact WHERE Id =: cnt.osf_supervisor__c].Name;
            }else{
                supervisorName = osf_constant_strings.EMPTY_STRING;
            }

            if(String.isNotBlank(cnt.osf_supervisor_2__c)){
                supervisor2Name = [SELECT Name FROM Contact WHERE Id =: cnt.osf_supervisor_2__c].Name;
            }else{
                supervisor2Name = osf_constant_strings.EMPTY_STRING;
            }

            data.add(
                new Map<String, Object>{
                    osf_constant_strings.MYUSERS_NAME => cnt.Name,
                    osf_constant_strings.MYUSERS_ROLE => cnt.osf_role__c,
                    osf_constant_strings.MYUSERS_ALLOW_CHECKOUT => cnt.osf_allow_checkout__c,
                    osf_constant_strings.MYUSERS_SUPERVISOR => supervisorName,
                    osf_constant_strings.MYUSERS_SUPERVISOR_2 =>supervisor2Name
                }
            );
        }

        return data;
    }
}