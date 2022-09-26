global class osf_URLRewriter implements Site.UrlRewriter {
    
    // global ccrz.cc_FriendlyUrlRewriter ccUrlRewriter;
    // global osf_URLRewriter() {
    //     ccUrlRewriter = new ccrz.cc_FriendlyUrlRewriter();
    // }

    global List<PageReference> generateUrlFor(List<PageReference> pageReferenceList) {
        return new ccrz.cc_FriendlyUrlRewriter().generateUrlFor(pageReferenceList);
    }

    global PageReference mapRequestUrl(PageReference pageReference) {
        pageReference = new ccrz.cc_FriendlyUrlRewriter().mapRequestUrl(pageReference);
        String url = pageReference.getUrl();
        ccrz.cclog.log(LoggingLevel.DEBUG, 'osf:urlRewriter:mapRequestUrl:url', url);
        System.debug('url is -----> ' + url);
        return pageReference;        
    }
}