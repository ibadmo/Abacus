global class osf_ctrl_FileNotFound{
    
    global osf_ctrl_FileNotFound() {
        PageReference currentPage = ApexPages.currentPage();
        String url = currentPage.getUrl();
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'osf:ctrl:filenotFound:url', url);
        System.debug('url -----> ' + url);
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'osf:ctrl:filenotFound:params', currentPage.getParameters());
        System.debug('params -----> ' + currentPage.getParameters());
    }
}