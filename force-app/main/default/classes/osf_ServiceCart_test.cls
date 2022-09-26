@IsTest
global with sharing class osf_ServiceCart_test implements WebServiceMock {

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        absis.consultarEstocCentreDistribucioB2BSalesforceResponse resultat = new absis.consultarEstocCentreDistribucioB2BSalesforceResponse();
        absis.estocCL[] lstStock = new absis.estocCL[]{};
        absis.estocCL stock = new absis.estocCL();
        stock.codiArticle = '123SKU';
        stock.unitats = 100;
        lstStock.add(stock);
        resultat.llistaEstoc = lstStock;
        response.put('response_x', resultat); 
   }

    @IsTest
    public static void testGetFieldsMap() {
        osf_ServiceCart serviceCart = new osf_ServiceCart();
        Test.startTest();
		Map<String, Object> resultMap = serviceCart.getFieldsMap(new Map<String, Object> {
			ccrz.ccAPI.SIZING => new Map<String, Object> {
				serviceCart.entityName => new Map<String, Object> {
					ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
				}
            },
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
		});
		Test.stopTest();
		String fields = (String) resultMap.get(ccrz.ccService.OBJECTFIELDS);
		System.assert(fields.length() > 0);
		for(String field : osf_ServiceCart.FIELD_LIST) {
			System.assert(fields.contains(field));
		}
    }
    
    @IsTest
    public static void testGetFilterMap() {
        osf_ServiceCart serviceCart = new osf_ServiceCart();
        Test.startTest();
        ccrz.cc_CallContext.currPageName = osf_constant_strings.MY_ACCOUNT_PAGE;
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccService.BASEFIELDSMAP => new Map<String, Object> {
                ccrz.ccAPI.SZ_M => 'Id,OwnerId,Name,EncryptedId__c,ActiveCart__c,ShipStructure__c,ValidationStatus__c,CartStatus__c,CartType__c,LastModifiedDate,SubtotalAmount__c,Name__c'
            },
            ccrz.ccAPICart.ACTIVECART => false,
            ccrz.ccAPICart.BYSTOREFRONT => osf_testUtility.STOREFRONT,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                serviceCart.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            },
            ccrz.ccAPICart.CARTSTATUS => osf_constant_strings.CART_STATUS_OPEN,
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = serviceCart.getFilterMap(inputData);
        Test.stopTest();
        System.assert(!outputData.containsKey(ccrz.ccAPICart.BYOWNER));
        System.assert(!outputData.containsKey(ccrz.ccAPICart.CARTSTATUS));
    }

    @IsTest
    public static void testPrepReturnCheckout() {
        ccrz.cc_CallContext.currPageName = osf_constant_strings.CHECKOUT_PAGE;
        osf_ServiceCart serviceCart = new osf_ServiceCart();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPICart.CART_OBJLIST => new List<Map<String, Object>> {new Map<String, Object> {
                osf_constant_strings.SUBTOTAL_AMOUNT => 1000,
                osf_constant_strings.CART_ITEMS => new List<Map<String, Object>> {
                    new Map<String, Object> {osf_constant_strings.OSF_VAT_RATE_TOTAL => 10}, 
                    new Map<String, Object> {osf_constant_strings.OSF_VAT_RATE_TOTAL => 20}
                }
            }},
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = serviceCart.prepReturn(inputData);
        Test.stopTest();
        List<Map<String, Object>> cartMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
        Map<String, Object> cartMap = cartMapList[0];
        System.assertEquals(1030, (Decimal) cartMap.get(osf_constant_strings.TOTAL_AMOUNT));
        System.assertEquals(30, (Decimal) cartMap.get(osf_constant_strings.TAX));
    }

    @IsTest
    public static void testPrepReturnMyCarts() {
        Account account = osf_testUtility.createAccount('Test Company');
        insert account;
        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;
        ccrz.cc_CallContext.currPageName = osf_constant_strings.MY_ACCOUNT_PAGE;
        ccrz.cc_CallContext.currContact = contact;
        osf_ServiceCart serviceCart = new osf_ServiceCart();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPICart.CART_OBJLIST => new List<Map<String, Object>> {new Map<String, Object> {
                osf_constant_strings.IS_SUBMITTED => true
            }}
        };
        Map<String, Object> outputData = serviceCart.prepReturn(inputData);
        Test.stopTest();
        List<Map<String, Object>> cartMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
        Map<String, Object> cartMap = cartMapList[0];
        System.assert((Boolean) cartMap.get(osf_constant_strings.DISABLE_BUTTONS));
    }

    /**********************************************************************************************
    * @Name         : testPrepReturnCartPage
    * @Description  : test prepReturn on Cart page
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 14, 2020
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
    @IsTest
    private static void testPrepReturnCartPage() {
        insert new osf_Abacus_B2B_config__c (Standard_delivery_time__c = 48, osf_providertime_plus__c = 72);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('123SKU', 'Test Product');
        product.osf_provider_delivery_time__c = 6;
        insert product;
        ccrz.cc_CallContext.currPageName = osf_constant_strings.CART_PAGE;
        osf_ServiceCart serviceCart = new osf_ServiceCart();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_ServiceCart_test());
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPICart.CART_OBJLIST => new List<Map<String, Object>> {new Map<String, Object> {
                osf_constant_strings.SUBTOTAL_AMOUNT => 1000,
                osf_constant_strings.CART_ITEMS => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        osf_constant_strings.PRODUCT_RELATIONSHIP => new Map<String, Object> {
                            osf_constant_strings.SFID => product.Id,
                            osf_constant_strings.SKU => '123SKU'
                        },
                        osf_constant_strings.QUANTITY => 10,
                        osf_constant_strings.PROVIDER_DELIVERY => 6
                    }
                }
            }},
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = serviceCart.prepReturn(inputData);
        Test.stopTest();
        List<Map<String, Object>> cartMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
        Map<String, Object> cartMap = cartMapList[0];
        for(Map<String, Object> cartItemMap : (List<Map<String, Object>>) cartMap.get(osf_constant_strings.CART_ITEMS)) {
            system.assertEquals('48 h', (String)cartItemMap.get(osf_constant_strings.IN_STOCK));
        }
    }
}