/**
 * File:        osf_ctrl_pdp.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Jan 10, 2020
 * Created By:  Cansu Aslı Aşcı
  ************************************************************************
 * Description: Controller class for PDP.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
global with sharing class osf_ctrl_pdp {

    private static final String DEFAULT_LOCALE = 'ca_ES';
    private static final String SPANISH_LOCALE = 'es_ES';
    private static final String COMPOSITE_PRODUCTS = 'compositeProductsS';
    private static final String COMPONENT_ID = 'component';
    private static final String COMPONENT_MAP = 'componentR';
    private static final String SFDC_NAME = 'sfdcName';

    /* 
    * @description  : Add product to current cart
    * @author       : Cansu Aslı Aşcı
    * @createdDate  : Jan 6, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : Product Quantity to add to cart
    * @param        : Product SKU
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
   @RemoteAction
   global static ccrz.cc_RemoteActionResult addToCart_relatedProducts(ccrz.cc_RemoteActionContext ctx, String qty, String sku){
      ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
      
      try{
            ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =: ctx.currentCartId];
            Decimal quantity = Decimal.valueOf(String.valueOf(qty));
            String  CartSFID = cart.Id;
            
            Map<String, Object> addResults = osf_Utility.addToCart(sku, quantity, CartSFID);
        	result.success = (Boolean)addResults.get(ccrz.ccApi.SUCCESS);

      }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
      }
      return result;
   }

   /* 
    * @description  : Create case with type of Product Info Request
    * @author       : Cansu Aslı Aşcı
    * @createdDate  : Jan 29, 2020
    * @param        : String description, description of the request
    * @param        : String contactId, the contact that is creating request
    * @param        : String productId, the product that the request is about
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
   @RemoteAction
   global static ccrz.cc_RemoteActionResult createProductInfoRequest(ccrz.cc_RemoteActionContext ctx, Map<String, Object> formData, String productId){
       ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
       try{
            String email = formData.containsKey(osf_constant_strings.GUEST_EMAIL) ? (String) formData.get(osf_constant_strings.GUEST_EMAIL) : osf_constant_strings.EMPTY_STRING;
            String phone = formData.containsKey(osf_constant_strings.PHONE) ? (String) formData.get(osf_constant_strings.PHONE) : osf_constant_strings.EMPTY_STRING;
            String comment = formData.containsKey(osf_constant_strings.GUEST_COMMENT) ? (String) formData.get(osf_constant_strings.GUEST_COMMENT) : osf_constant_strings.EMPTY_STRING; 
            String firstname = formData.containsKey(osf_constant_strings.FIRSTNAME) ? (String) formData.get(osf_constant_strings.FIRSTNAME) : osf_constant_strings.EMPTY_STRING;
            String lastname = formData.containsKey(osf_constant_strings.LASTNAME) ? (String) formData.get(osf_constant_strings.LASTNAME) : osf_constant_strings.EMPTY_STRING;
            String name = firstname + osf_constant_strings.EMPTY_SPACE + lastname;
            String company = formData.containsKey(osf_constant_strings.COMPANY) ? (String) formData.get(osf_constant_strings.COMPANY) : osf_constant_strings.EMPTY_STRING;

            Map<String,Object> newformData = new Map<String,Object>{
                osf_constant_strings.MYUSERS_NAME => name,
                osf_constant_strings.PHONE => phone,
                osf_constant_strings.EMAIL => email,
                osf_constant_strings.COMMENT => comment,
                osf_constant_strings.COMPANY => company
            };

            osf_utility.createCaseProdInfoReq(productId, newformData);

            result.success = true;
       }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
       }
       return result;
   }

   /**
    * @description : get site key for recaptcha
    * @author       : Cansu Aslı Aşcı
    * @createdDate  : Feb 14, 2020
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getSiteKey(ccrz.cc_RemoteActionContext ctx){
         ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
         Map<String, Object> data = new Map<String, Object> ();
         result.data = data;
          try{
            osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
            if(String.isNotBlank(config.site_key__c)){
               data.put(osf_constant_strings.RECAPTCHA_SITE_KEY, config.site_key__c);
            }
            result.success = true;
          }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
          }
          return result;
    }

    /* 
    * @description  : Add multiple products to the cart
    * @author       : Alina Craciunel
    * @createdDate  : Mar 09, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : String productsToAdd
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult addToCart_compositeProducts(ccrz.cc_RemoteActionContext ctx, String productsToAdd) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        try {
            Map<String, Object> mapSkuQuantities = (Map<String, Object>)JSON.deserializeUntyped(productsToAdd);
            List<ccrz__E_Cart__c> lstCarts = new List<ccrz__E_Cart__c>([SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =: ctx.currentCartId]);
            String  cartSFID = lstCarts.isEmpty() ? null : lstCarts[0].Id;
            Map<String, Object> addResults = osf_Utility.addToCart(mapSkuQuantities, cartSFID);
            result.success = (Boolean)addResults.get(ccrz.ccApi.SUCCESS);
            result.data = new Map<String, Object>{osf_constant_strings.CART_ENC_ID => addResults.get(ccrz.ccApiCart.CART_ENCID)};
        } catch (Exception e) {
            result.success=  false;
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : get all the composite products based on aggregated product id, from a composite product pdp
    * @author       : Alina Craciunel
    * @createdDate  : Mar 10, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : String productId
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getCompositeProductsFromVariation(ccrz.cc_RemoteActionContext ctx, String productId) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_Product__c product = [SELECT Id, (SELECT Id, ccrz__Composite__c, ccrz__Composite__r.ccrz__ShortDescRT__c FROM ccrz__Composite_Products__r) FROM ccrz__E_Product__c WHERE Id =: productId];
            if (product.ccrz__Composite_Products__r == null || product.ccrz__Composite_Products__r.isEmpty()) {
                result.success = true;
                return result;
            }
            Map<String, Object> resultMap = new Map<String, Object>();
            List<ccrz__E_ProductMedia__c> lstProductMedias = new List<ccrz__E_ProductMedia__c>([SELECT Id, ccrz__MediaType__c, ccrz__URI__c FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c = :product.ccrz__Composite_Products__r[0].ccrz__Composite__c AND ccrz__MediaType__c  = :osf_constant_strings.PRODUCT_IMAGE]);
            if (!lstProductMedias.isEmpty()) {
                resultMap.put(osf_constant_strings.PRODUCT_IMAGE_KEY, lstProductMedias[0].ccrz__URI__c);
            }
            Map<String, Object> response = osf_utility.fetchProducts(product.ccrz__Composite_Products__r[0].ccrz__Composite__c);
            resultMap.put(osf_constant_strings.PRODUCT_LIST, response.get(osf_constant_strings.PRODUCT_LIST));
            String userLocale = ccrz.cc_CallContext.userLocale;
            if(userLocale != DEFAULT_LOCALE) {
                Set<String> compositeProductIdSet = new Set<String> ();
                Map<String, String> productIdToLocaleNameMap = new Map<String, String> ();
                List<Map<String, Object>> productMapList = (List<Map<String, Object>>) response.get(osf_constant_strings.PRODUCT_LIST);
                for(Map<String, Object> productMap : productMapList) {
                    List<Map<String, Object>> compositeMapList = (List<Map<String, Object>>) productMap.get(COMPOSITE_PRODUCTS);
                    for(Map<String, Object> compositeMap : compositeMapList) {
                        compositeProductIdSet.add((String) compositeMap.get(COMPONENT_ID));
                    }
                }

                for(ccrz__E_ProductItemI18N__c productItemLocale : [SELECT Name, ccrz__Product__c FROM ccrz__E_ProductItemI18N__c WHERE ccrz__Product__c IN :compositeProductIdSet AND ccrz__Locale__c = :userLocale]) {
                    productIdToLocaleNameMap.put(productItemLocale.ccrz__Product__c, productItemLocale.Name);
                }

                for(Map<String, Object> productMap : productMapList) {
                    List<Map<String, Object>> compositeMapList = (List<Map<String, Object>>) productMap.get(COMPOSITE_PRODUCTS);
                    for(Map<String, Object> compositeMap : compositeMapList) {
                        String componentId = (String) compositeMap.get(COMPONENT_ID);
                        if(productIdToLocaleNameMap.containsKey(componentId)) {
                            String localeName = productIdToLocaleNameMap.get(componentId);
                            Map<String, Object> componentMap = (Map<String, Object>) compositeMap.get(COMPONENT_MAP);
                            componentMap.put(SFDC_NAME, localeName);
                        }
                    }
                }
            }
            resultMap.put(osf_constant_strings.PARENT_SHORT_DESC, product.ccrz__Composite_Products__r[0].ccrz__Composite__r.ccrz__ShortDescRT__c);
            result.data = resultMap;
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(e));
            System.debug('Exception is -----> ' + e.getMessage() + '\nStacktrace: ' + e.getStackTraceString());
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}