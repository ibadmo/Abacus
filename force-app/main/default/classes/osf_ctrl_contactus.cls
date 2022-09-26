/**
 * File:        osf_ctrl_contactus.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 16, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Controller class for osf_contactus Subscriber page.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_ctrl_contactus {
    
    /**********************************************************************************************
    * @Name         : createCase
    * @Description  : The method will be called when submit form button is clicked and will create a case
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 16, 2020
    * @Param        : ccrz.cc_RemoteActionContext ctx, Map<String, Object> formData
    * @Return       : ccrz.cc_RemoteActionResult
     
    *********************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult createCase(ccrz.cc_RemoteActionContext ctx, Map<String, Object> formData) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        try {
            osf_Utility.createCaseFromContactForm(formData);
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}