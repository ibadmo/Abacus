/**
 * @File Name          : osf_hk_UserInterface.cls
 * @Description        : 
 * @Author             : oguz.alp
 * @Group              : 
 * @Last Modified By   : mehmet.tunc
 * @Last Modified On   : 1/17/2020, 2:51:31 PM
 * @Modification Log   : 
 * Ver       Date            Author         Modification
 * 1.0    1/13/2020          oguz.alp       Initial Version
 * 1.1    1/13/2020          oguz.alp           Added
 * 1.2    2/18/2020          mehmet.tunc        Added
**/
global with sharing class osf_hk_UserInterface extends ccrz.cc_hk_UserInterface.v004 {
    
    public static final String OSF_THEME_RESOURCE = 'B2B_Abacus_Theme';
    public static final String MAIN_JS_PATH = 'js/main.js';
    public static final String SLICK_JS_PATH = 'js/slick-1.8.1/slick.min.js';
    public static final String RXP_JS_PATH = 'js/rxp.js';

    
    /**
    * @put the main.js to the end of the all pages 
    * @author oguz.alp | 1/13/2020 
    * @param inpData 
    * @return virtual Map<String,Object>
    **/
    global virtual override Map<String,Object> endContent(Map<String,Object> inpData) {
        
        Map<String,Object> outPut = super.endContent(inpData);
        String pageKey = ccrz.cc_CallContext.currPageName;
        ccrz.cclog.log('OSF:endContentJS:pageKey',pageKey);
        String endContents= '';
        try{
            if(pageKey == osf_constant_strings.PDP_PAGE){
                endContents = '<script type="text/javascript" src="' + resourcePath( OSF_THEME_RESOURCE, SLICK_JS_PATH )+'"></script>\n';
            }
            if(pageKey == osf_constant_strings.CHECKOUT_PAGE){
                endContents = '<script type="text/javascript" src="' + resourcePath( OSF_THEME_RESOURCE, RXP_JS_PATH )+'"></script>\n';
            }
            endContents += '<script type="text/javascript" src="' + resourcePath( OSF_THEME_RESOURCE, MAIN_JS_PATH) + '"></script>\n';    
            String retContent = (String)outPut.get(EOB_CONTENT);
            retContent +=  endContents;
            outPut.put(EOB_CONTENT, retContent);
            return outPut;
        }catch(Exception ex){
            return outPut;
        }      
    }

    /**
     * @put recaptha script in head tag
     * @author cansu.asci
     * @return virtual String
     */
    global virtual override String metaContent(){
        String link = '';
        try{
            link = super.metaContent();
            link =+ '<script src="https://www.google.com/recaptcha/api.js" async defer></script>';
            return link;
        }catch(Exception ex){
            return link;
        }
    }
     
}