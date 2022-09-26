@IsTest
private with sharing class osf_ApplicationRouter_test {

    private static ccrz.cc_FriendlyUrlRewriter ccrzFriendlyUrlRewriter;

    private static Site.UrlRewriter urlRewriter;

    private static void setUp() {

        Application_Router__c applicationRouterSetting = new Application_Router__c();
        applicationRouterSetting.Name = 'RouterSetting';
        applicationRouterSetting.Old_Site_URL__c = '/foo/bar/baz';
        applicationRouterSetting.New_Site_URL__c = '/ccrz__Cart';
        insert applicationRouterSetting;

        urlRewriter = new osf_ApplicationRouter();
        ccrzFriendlyUrlRewriter = new ccrz.cc_FriendlyUrlRewriter();
    }

    @IsTest
    private static void testMapRequestUrlForIndexedShopPage() {

        setUp();

        PageReference sourcePage = new PageReference('/foo/bar/baz');
        PageReference targetPage = new PageReference('/ccrz__Cart');

        System.assertEquals(
            ccrzFriendlyUrlRewriter.mapRequestUrl(targetPage),
            urlRewriter.mapRequestUrl(sourcePage)
        );
    }

    @IsTest
    private static void testMapStartUrlParameterForIndexedShopPage() {

        setUp();

        PageReference sourcePage = new PageReference('/login/page?startURL=/foo/bar/baz');
        PageReference targetPage = new PageReference('/ccrz__Cart');

        System.assertEquals(
            ccrzFriendlyUrlRewriter.mapRequestUrl(targetPage),
            urlRewriter.mapRequestUrl(sourcePage)
        );
    }


    @IsTest
    private static void testMapRequestUrlForNonIndexedShopPage()  {

        setUp();

        PageReference expectedPage = new PageReference('ccrz__HomePage');
        expectedPage.setRedirect(true);
        expectedPage.setRedirectCode(301);

        PageReference nonIndexedPage = new PageReference('/non/indexed');
        PageReference actualPage = urlRewriter.mapRequestUrl(nonIndexedPage);

        System.assertEquals(expectedPage.getUrl(), actualPage.getUrl());
        System.assertEquals(expectedPage.getRedirect(), actualPage.getRedirect());
        System.assertEquals(expectedPage.getRedirectCode(), actualPage.getRedirectCode());
    }


    @IsTest
    private static void testGenerateUrlForPageReferences() {

        setUp();

        PageReference page = new PageReference('ccrz__HomePage');
        List<PageReference> pages = new List<PageReference> { page };

        System.assertEquals(
            ccrzFriendlyUrlRewriter.generateUrlFor(pages),
            urlRewriter.generateUrlFor(pages)
        );
    }
}