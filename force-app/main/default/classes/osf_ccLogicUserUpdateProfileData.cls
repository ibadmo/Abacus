/**
 * File:        osf_ccLogicUserUpdateProfileData.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 17, 2020
 * Created By:  Oguz A.
  ************************************************************************
 * Description: Extension of ccLogicUserUpdateProfileData. It fixes the 
 * JIRA BUG : ABCS-492 (https://dev.osf-global.com/jira/browse/ABCS-492)
  ************************************************************************
 */
global virtual with sharing class osf_ccLogicUserUpdateProfileData extends ccrz.ccLogicUserUpdateProfileData {
 
    // Fixes the userUpdate Locale issue on My Account page
    global override Map<String,Object> decorateUser(Map<String, Object> inputData) {
        // run the default implementation
        super.decorateUser(inputData);
        // replace the information
        Map<String, Object> userData = (Map<String, Object>)inputData.get(ccrz.ccApiUser.USER_DATA_MAP);
    
        String localeKey = (String)userData.get('localeSidKey');
        String languageKey= (String)userData.get('languageLocaleKey');
        
        if((localeKey == 'ca_ES' || localeKey == 'es_ES') && String.isBlank(languageKey)){
            userData.put('languageLocaleKey','es');
        }
 
        return inputData;
    }
 
}