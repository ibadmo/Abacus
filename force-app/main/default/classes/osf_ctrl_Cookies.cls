/**
 * File:        osf_ctrl_Cookies.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 31, 2020
 * Created By:  Cansu Asli Asci
  ************************************************************************
 * Description:
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_ctrl_Cookies {
          

   @RemoteAction
   global static ccrz.cc_RemoteActionResult checkShowCookies(ccrz.cc_RemoteActionContext context) {
       ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
       Map<String, Object> data = new Map<String, Object> ();
       result.data = data;
       try {
           Boolean showCookies;
           if(!ccrz.cc_CallContext.isGuest) {
                Cache.SessionPartition sessionPartition = Cache.Session.getPartition('osfabacus');

                showCookies = (Boolean) sessionPartition.get('showCookies');
                if(showCookies == null) {
                   User currentUser = [SELECT osf_accepted_cookies__c FROM User WHERE Id = :ccrz.cc_CallContext.currUserId];
                   showCookies = !currentUser.osf_accepted_cookies__c;
                   sessionPartition.put('showCookies', showCookies);
                }
           }
            
           data.put('showCookies', showCookies);
           result.success = true;
       } catch (Exception ex) {
           result.success = false;
           result.messages.add(osf_utility.createBeanMessage(ex));
       } finally {
           ccrz.ccLog.close(result);
       }
       return result;
   }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult acceptCookies(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        try {
            if(!ccrz.cc_CallContext.isGuest) {
                Cache.SessionPartition sessionPartition = Cache.Session.getPartition('osfabacus');
                sessionPartition.put('showCookies', false);
                update new User(
                    Id = ccrz.cc_CallContext.currUserId,
                    osf_accepted_cookies__c = true
                );
            }
            result.success = true;
        } catch (Exception ex) {
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(ex));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}