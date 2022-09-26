global with sharing class osf_ctrl_header {
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getAccountInfo(ccrz.cc_RemoteActionContext ctx){
       ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

       Map<String, Object> data = new Map<String, Object>();
       res.data = data;

        try{ 
            if(!ccrz.cc_CallContext.isGuest) {
                List<Account> accs = [Select Type , osf_logo__c FROM Account Where Id =: ccrz.cc_CallContext.currAccountId];
            
                Map<String, Object> outputDataAccount;
                if(accs.size() > 0){
                    outputDataAccount = osf_ctrl_header.transformAccount(accs[0]);
                }
    
                data.put(osf_constant_strings.ACCOUNT,outputDataAccount);
            }
            res.success = true;
        }catch(Exception ex){
            res.success = false;
            res.messages.add(osf_utility.createBeanMessage(ex));  
        }
     return res;
   }

   private static Map<String, Object> transformAccount(Account account) {
        Map<String, Object> accountData = new Map<String, Object>();
        if (account == null) return accountData;

        accountData.put(osf_constant_strings.ACCOUNT_TYPE, account.Type);
        accountData.put(osf_constant_strings.ACCOUNT_LOGO, account.osf_logo__c);

        return accountData;
    }

}