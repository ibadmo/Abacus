/**
 * This UrlRewriter implementation takes into account that some old, not shop related URL paths
 * have to be redirected to the new shop related ones without neglecting the existing CCRZ friendly URL rewriter
 */
global class osf_ApplicationRouter implements Site.UrlRewriter {

    private static final String DEFAULT_PAGE = 'ccrz__HomePage';

    private static final String SHOP_URL_ROOT_PATH = '/abacusb2b';

    private static final String DEFAULT_UI_PATH = '/_ui';

    private static final String EXTERNAL_IDENTITY_PATH = '/_nc_external/identity';

    private static final String START_URL_QUERY_PARAMETER = 'startURL';

    private static Map<String, String> configuredUrlRoutes = new Map<String, String>();

    private ccrz.cc_FriendlyUrlRewriter ccrzFriendlyUrlRewriter;


    public osf_ApplicationRouter() {

        ccrzFriendlyUrlRewriter = new ccrz.cc_FriendlyUrlRewriter();

        if (configuredUrlRoutes.isEmpty()) {
            configuredUrlRoutes = loadUrlRoutes();
        }
    }


    private Map<String, String> loadUrlRoutes() {

        Map<String, Application_Router__c> applicationRouterSettings = Application_Router__c.getAll();
        Map<String, String> configuredRoutes = new Map<String, String>();

        for (Application_Router__c applicationRouterSetting : applicationRouterSettings.values()) {
            configuredRoutes.put(
                applicationRouterSetting.Old_Site_URL__c,
                applicationRouterSetting.New_Site_URL__c
            );
        }

        return configuredRoutes;
    }


    global PageReference mapRequestUrl(PageReference pageReference) {

        // no redirects for /_ui paths - community admin pages, change/forgot password pages start with an /_ui path
        if (pageReference.getUrl().startsWith(DEFAULT_UI_PATH) || pageReference.getUrl().startsWith(EXTERNAL_IDENTITY_PATH)) {

            return ccrzFriendlyUrlRewriter.mapRequestUrl(pageReference);
        }

        // Checking the startURL parameter in case the the request has been redirected to the ccrz__CCSiteLogin page before
        if (hasStartUrlParameter(pageReference) && isMappedStartUrl(pageReference)) {
            PageReference startPageReference = getStartPageReference(pageReference);
            return mapRequestUrl(startPageReference);
        }

        String sourceUrl = pageReference.getUrl();
        String targetUrl = getTargetUrl(sourceUrl);

        Map<String, Object> ccrzSiteIndex = getCcrzSiteIndex(targetUrl);

        if (isFriendlyShopUrl(ccrzSiteIndex, targetUrl)) {

            PageReference targetPage = new PageReference(targetUrl);
            targetPage.setRedirect(true);
            targetPage.setRedirectCode(301);

            // If this is not a real redirect the standard ccrz rewriter should be used
            return sourceUrl == targetUrl
                ? ccrzFriendlyUrlRewriter.mapRequestUrl(targetPage)
                : targetPage;
        }

        if (!isIndexedShopSite(ccrzSiteIndex)) {

            PageReference defaultRedirectPage = new PageReference(DEFAULT_PAGE);
            defaultRedirectPage.setRedirect(true);
            defaultRedirectPage.setRedirectCode(301);

            return defaultRedirectPage;
        }

        return ccrzFriendlyUrlRewriter.mapRequestUrl(pageReference);
    }


    private Boolean hasStartUrlParameter(PageReference pageReference) {

        Map<String, String> pageUrlQueryParameters = pageReference.getParameters();

        return pageUrlQueryParameters.containsKey(START_URL_QUERY_PARAMETER);
    }


    private Boolean isMappedStartUrl(PageReference pageReference) {

        Map<String, String> pageUrlQueryParameters = pageReference.getParameters();
        String startUrl = pageUrlQueryParameters.get(START_URL_QUERY_PARAMETER);
        String originalUrl = startUrl.removeStart(SHOP_URL_ROOT_PATH);

        return configuredUrlRoutes.containsKey(originalUrl);
    }


    private PageReference getStartPageReference(PageReference pageReference) {

        Map<String, String> pageUrlQueryParameters = pageReference.getParameters();
        String startUrl = pageUrlQueryParameters.get(START_URL_QUERY_PARAMETER);
        String originalUrl = startUrl.removeStart(SHOP_URL_ROOT_PATH);

        return new PageReference(originalUrl);
    }


    private String getTargetUrl(String sourceUrl) {

        if (configuredUrlRoutes.containsKey(sourceUrl)) {
            return configuredUrlRoutes.get(sourceUrl);
        }

        return sourceUrl;
    }


    private Map<String, Object> getCcrzSiteIndex(String pageUrl) {

        return ccrz.ccAPISiteIndex.mapUrl(new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccAPISiteIndex.FULL_URL => pageUrl
        });
    }


    private Boolean isFriendlyShopUrl(Map<String, Object> ccrzSiteIndex, String targetUrl) {

        return ccrz.ccUtil.isKeyValued(ccrzSiteIndex, ccrz.ccAPISiteIndex.MAPPED_URL)
            && (String) ccrzSiteIndex.get(ccrz.ccAPISiteIndex.FULL_URL) == targetUrl;
    }


    private Boolean isIndexedShopSite(Map<String, Object> ccrzSiteIndex) {

        Boolean hasMappedUrl = ccrz.ccUtil.isKeyValued(ccrzSiteIndex, ccrz.ccAPISiteIndex.MAPPED_URL);

        List<String> siteUrlHashList = (List<String>) ccrzSiteIndex.get(ccrz.ccAPISiteIndex.URL_HASH_LIST);
        Boolean isShopSite = siteUrlHashList.size() == 2 && siteUrlHashList.get(1) == '0';

        return hasMappedUrl || isShopSite;
    }

    global List<PageReference> generateUrlFor(List<PageReference> salesforceUrls) {

        return ccrzFriendlyUrlRewriter.generateUrlFor(salesforceUrls);
    }
}