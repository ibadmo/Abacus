/**
 * File:        osf_ctrl_Login.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        March 12, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class for osf_login Apex Component.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

 // It is without sharing since it will query User's to check if there is a duplicate one.
global without sharing class osf_ctrl_Login {
    
    /* 
    * @description  : Checks if there is any user with the same email that user has entered
    * @author       : Ozgun Eser
    * @createdDate  : Mar 12, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : String email
    * @return       : ccrz.cc_RemoteActionResult result, containing boolean data (true if duplicate found, otherwise false)
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult checkDuplicateUser(ccrz.cc_RemoteActionContext context, String email) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try {
            List<User> userList = [SELECT Id FROM User WHERE Username = :email OR CommunityNickname = :email OR Email = :email LIMIT 1];
            data.put(osf_constant_strings.DUPLICATE_USERNAME, !userList.isEmpty());
            result.success = true;
        } catch (Exception e) {
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}