/**
 * File:        osf_ctrl_footer.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 10, 2020
 * Created By:  Cansu Aslı Aşcı
  ************************************************************************
 * Description: Controller class for footer page.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 * March,20             Oguz Alp                Removed the session cache partion since not essential
 *                                              Modified the getter methods.
 */
public with sharing class osf_ctrl_footer {
    
    private  osf_Abacus_B2B_config__c config;
    private Contact currContact;

    public osf_ctrl_footer(){
        if(config == null){
        	config = osf_Abacus_B2B_config__c.getOrgDefaults();    
        }
    }
    
    public String getServer(){
        return config.Server__c;
    }
    
    
    public String getLicense(){
        return config.License__c;
    }
    
    public Boolean getIsAdmin(){
        try {
            if(ccrz.cc_CallContext.isGuest) return false;
            if(currContact == NULL){
                currContact = [SELECT osf_role__c FROM Contact WHERE Id =: ccrz.cc_CallContext.currContact.Id];
            }
            return (currContact.osf_role__c == osf_constant_strings.ACCOUNT_ADMIN);            
        } catch (Exception ex) {
            return false;            
        }
    }
	
    public String getSitekey(){
        return config.Site_key__c;
    }

}