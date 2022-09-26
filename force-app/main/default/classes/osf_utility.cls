/**
 * File:        osf_utility.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 06, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Contains Utility methods for whole the project.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

public inherited sharing class osf_utility {

    /* 
    * @description  : Create Message to add Remote Action Result in error
    * @author       : Ozgun Eser
    * @createdDate  : Jan 6, 2020
    * @param        : Exception e
    * @return       : ccrz.cc_bean_Message message
    */

    public static ccrz.cc_bean_Message createBeanMessage(Exception e) {
        return new ccrz.cc_bean_Message(e.getTypeName() + osf_constant_strings.COLON + osf_constant_strings.EMPTY_SPACE + e.getMessage() + osf_constant_strings.ERROR_STACKTRACE + e.getStacktraceString(), ccrz.cc_bean_Message.MessageSeverity.ERROR);
    }

    /* 
    * @description  : Create Message to add Remote Action Result in error
    * @author       : Cansu Asci
    * @createdDate  : Apr 8, 2020
    * @param        : Exception e
    * @return       : void
    */
    public static void createDebugMessage(Exception e){
        System.debug(e.getTypeName() + osf_constant_strings.COLON + osf_constant_strings.EMPTY_SPACE + e.getMessage() + osf_constant_strings.ERROR_STACKTRACE + e.getStacktraceString());
    }

    /* 
    * @description  : Return List of Prominent Products by Type, by the given limit. If given limit is null than return number will not be limited.
    * @author       : Ozgun Eser
    * @createdDate  : Jan 6, 2020
    * @param        : String type, type of prominency
    * @param        : Integer returnLimit, limit of return number
    * @return       : List<osf_prominent_product__c>
    */
    public static List<osf_prominent_product__c> getPromintnProductsByType(String type, Integer returnLimit) {
        String query = osf_constant_strings.PROMINENT_PRODUCT_QUERY_BEGIN + osf_constant_strings.SINGLE_QUOTE + type + osf_constant_strings.SINGLE_QUOTE + osf_constant_strings.CLOSE_PARANTHESIS;
        System.debug('query -----> ' + query);
        if(returnLimit != null && returnLimit > 0) {
            query += osf_constant_strings.QUERY_LIMIT + returnLimit;
        }
        return Database.query(query);        
    }

    /* 
    * @description  : Return Negotiated Discount for the Current Product 
    * @author       : Ozgun Eser
    * @createdDate  : Jan 20, 2020
    * @param        : Set<String> productIdSet
    * @return       : Map<String, Decimal> product Id to Negotiated Discount Map
    */
    public static Map<String, Decimal> getNegotiatedDiscountByProduct(Set<String> productIdSet) {
        Map<String, Decimal> productIdToDiscountMap = new Map<String, Decimal> ();
        for(osf_negotiated_discount__c negotiatedDiscount : [SELECT Id, osf_product__c, osf_discount_rate__c FROM osf_negotiated_discount__c WHERE osf_product__c IN :productIdSet AND osf_account__c = :ccrz.cc_CallContext.currAccountId AND osf_active__c = true AND osf_discount_rate__c != null ORDER BY osf_start_date__c DESC NULLS LAST, osf_discount_rate__c ASC NULLS LAST]) {
            if(!productIdToDiscountMap.containsKey(negotiatedDiscount.osf_product__c)) {
                productIdToDiscountMap.put(negotiatedDiscount.osf_product__c, negotiatedDiscount.osf_discount_rate__c); 
            }
        }
        return productIdToDiscountMap;
    }

    /* 
    * @description  : Return Negotiated Discount for the Product's Catalog 
    * @author       : Ozgun Eser
    * @createdDate  : Jan 20, 2020
    * @param        : Set<String> catalogIdSet
    * @return       : Map<String, Decimal> catalog Id to Negotiated Discount Map
    */
    public static Map<String, Decimal> getNegotiatedDiscountByCatalog(Set<String> catalogIdSet) {
        Map<String, Decimal> catalogIdToDiscountMap = new Map<String, Decimal> ();
        for(osf_negotiated_discount__c negotiatedDiscount : [SELECT Id, osf_catalog_id__c, osf_discount_rate__c FROM osf_negotiated_discount__c WHERE osf_catalog_id__c IN :catalogIdSet AND osf_account__c = :ccrz.cc_CallContext.currAccountId AND osf_active__c = true AND osf_discount_rate__c != null ORDER BY osf_start_date__c DESC NULLS LAST, osf_discount_rate__c ASC NULLS LAST]) {
            if(!catalogIdToDiscountMap.containsKey(negotiatedDiscount.osf_catalog_id__c)) {
                catalogIdToDiscountMap.put(negotiatedDiscount.osf_catalog_id__c, negotiatedDiscount.osf_discount_rate__c);
            }
        }
        return catalogIdToDiscountMap;
    }

    /* 
    * @description  : Return Negotiated Coupon for the Product
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Set<String> productIdSet
    * @return       : String couponCode
    */    
    public static String getNegotiatedCouponByProduct(Set<String> productIdSet) {
        ccrz.ccLog.log(loggingLevel.DEBUG, 'osf:utility.getNegotiatedCouponByProduct:productIdSet', productIdSet);
        String couponCode = osf_constant_strings.EMPTY_STRING;
        List<osf_negotiated_discount__c> negotiatedDiscountList = [SELECT Id, osf_product__c, osf_coupon__c, osf_coupon__r.ccrz__CouponCode__c FROM osf_negotiated_discount__c WHERE osf_account__c = :ccrz.cc_CallContext.currAccountId AND osf_product__c IN :productIdSet AND osf_active__c = true AND osf_coupon__c != null ORDER BY osf_start_date__c DESC NULLS LAST LIMIT 1];
        ccrz.ccLog.log(loggingLevel.DEBUG, 'osf:utility.getNegotiatedCouponByProduct:negotiatedDiscountList', negotiatedDiscountList);
        if(!negotiatedDiscountList.isEmpty()) {
            couponCode = negotiatedDiscountList[0].osf_coupon__r.ccrz__CouponCode__c;
            ccrz.ccLog.log(loggingLevel.DEBUG, 'osf:utility.getNegotiatedCouponByProduct:couponCode', couponCode);
        }
        return couponCode;
    }

    /* 
    * @description  : Return Negotiated Coupon for the Catalog
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Set<String> catalogIdSet
    * @return       : String couponCode
    */ 
    public static String getNegotiatedCouponByCatalog(Set<String> catalogIdSet) {
        String couponCode = osf_constant_strings.EMPTY_STRING;
        List<osf_negotiated_discount__c> negotiatedDiscountList = [SELECT Id, osf_catalog_id__c, osf_coupon__c, osf_coupon__r.ccrz__CouponCode__c FROM osf_negotiated_discount__c WHERE osf_account__c = :ccrz.cc_CallContext.currAccountId AND osf_catalog_id__c IN :catalogIdSet AND osf_active__c = true AND osf_coupon__c != null ORDER BY osf_start_date__c DESC NULLS LAST LIMIT 1];
        if(!negotiatedDiscountList.isEmpty()) {
            couponCode = negotiatedDiscountList[0].osf_coupon__r.ccrz__CouponCode__c;
        }
        return couponCode;
    }

    /*
    * @description  : Add product to cart with given sku and quantity
    * @author       : Cansu Asli Asci
    * @createdDate  : Jan 21, 2020
    * @param        : String sku, sku of product
    * @param        : Decimal qty, quantity per unit of product
    * @param        : String cartSfid, cart Id of current cart
    * @return       : Map<String, Object>
    */
    public static Map<String, Object> addToCart(String sku, Decimal qty, String cartSfid){
        
        ccrz.ccApiCart.LineData newLine = new ccrz.ccApiCart.LineData();
        newLine.sku = sku;
        newLine.quantity = qty;
            
            
        List<ccrz.ccApiCart.LineData> newLines = new List<ccrz.ccApiCart.LineData>();
        newLines.add( newLine );
        
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => cartSfid,
            ccrz.ccApiCart.LINE_DATA => newLines
        });
        return addResults;
    }

    /*
    * @description  : Create case for sales representatives
    * @author       : Cansu Asli Asci
    * @createdDate  : Jan 29, 2020
    * @param        : String description, description of info request
    * @param        : String productId, product info
    * @return       : void
    */
    public static void createCaseProdInfoReq(String productId, Map<String,Object> formData){
            String name = formData.containsKey(osf_constant_strings.MYUSERS_NAME) ? (String) formData.get(osf_constant_strings.MYUSERS_NAME) : osf_constant_strings.EMPTY_STRING;
            String email = formData.containsKey(osf_constant_strings.EMAIL) ? (String) formData.get(osf_constant_strings.EMAIL) : osf_constant_strings.EMPTY_STRING;
            String phone = formData.containsKey(osf_constant_strings.PHONE) ? (String) formData.get(osf_constant_strings.PHONE) : osf_constant_strings.EMPTY_STRING;
            String comment = formData.containsKey(osf_constant_strings.COMMENT) ? (String) formData.get(osf_constant_strings.COMMENT) : osf_constant_strings.EMPTY_STRING;
            String company = formData.containsKey(osf_constant_strings.COMPANY) ? (String) formData.get(osf_constant_strings.COMPANY) : osf_constant_strings.EMPTY_STRING; 
            Case newCase = new Case();
            newCase.Status = osf_constant_strings.CASE_STATUS_NEW;
            newCase.Origin = osf_constant_strings.CASE_ORIGIN_WEB;
            newCase.Subject = osf_constant_strings.PRODUCT_INFO_REQUEST;
            newCase.Description = comment;
            if (ccrz.cc_CallContext.currContact != null) {
                newCase.ContactId = ccrz.cc_CallContext.currContact.Id;
            }
            newCase.osf_is_guest_user__c = ccrz.cc_CallContext.isGuest;
            newCase.osf_name__c = name;
            newCase.osf_email__c = email;
            newCase.osf_phone__c = phone;
            newCase.osf_company__c = company;
            newCase.osf_cc_product__c = productId;
            insert newCase;
    }
    
    /* 
    * @description  : format the months, days, minutes and seconds integer as string
    * @author       : Alina Craciunel
    * @createdDate  : Feb 18, 2020
    * @param        : the integer number to process 
    * @return       : the integer given as parameter converted to string
    */
    private static String formatNumber(Integer intToProcess) {
        return (intToProcess < 10 ? '0' : '') + String.valueOf(intToProcess);
    }

    /* 
    * @description  : format the request timestammp
    * @author       : Alina Craciunel
    * @createdDate  : Feb 18, 2020
    * @param        : DateTime field 
    * @return       : the formatted timestamp as string
    */
    private static String getTimeStamp(DateTime requestDateTime) {
        return String.valueOf(requestDateTime.year()) + formatNumber(requestDateTime.month()) + formatNumber(requestDateTime.day()) + formatNumber(requestDateTime.hour()) + formatNumber(requestDateTime.minute()) + formatNumber(requestDateTime.second());
    }

    /* 
    * @description  : format the request timestammp
    * @author       : Alina Craciunel
    * @createdDate  : Feb 18, 2020
    * @param        : Datetime requestDateTime
    * @param        : PaymentModel model
    * @param        : osf_Abacus_B2B_config__c config
    * @return       : encrypted sha as string
    */
    private static string getEncryptedSHA(Datetime requestDateTime, osf_ctrl_creditCardpayment.PaymentModel model, osf_Abacus_B2B_config__c config) {
        String stringForEncrypt = getTimeStamp(requestDateTime) + '.' + config.AddonPayment_Merchant_Id__c + '.' + model.orderNo + '.' + model.amount + '.' + model.orderCurrency + '.' + model.cardNumber;
        String hashedFirst = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(stringForEncrypt)));
        return EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(hashedFirst + '.' + config.AddonPayment_Shared_Secret__c)));
    }

    /* 
    * @description  : format the amount
    * @author       : Alina Craciunel
    * @createdDate  : Feb 18, 2020
    * @param        : Decimal amount
    * @return       : formatted decimal as string without decimals
    */
    public static String formatDecimal(Decimal amount) {
        List<String> splitString = String.valueOf(amount).split('\\.');
        return splitString.get(0); 
    }

    /* 
    * @description  : create the addonpayment xml request
    * @author       : Alina Craciunel
    * @createdDate  : Feb 18, 2020
    * @param        : String merchantId
    * @param        : PaymentModel model
    * @param        : String sha1hash
    * @return       : th request as string
    */
    public static String getXmlRequest(osf_Abacus_B2B_config__c config, osf_ctrl_creditCardpayment.PaymentModel model) {
        Datetime requestDateTime = Datetime.now();
        model.orderNo += System.now().year() + System.now().month() + System.now().day() + System.now().hour() + System.now().minute() + System.now().second();
        String request =     
            '<?xml version=\'1.0\' encoding=\'UTF-8\'?>' + 
            '<request type=\'auth\' timestamp=\'' + getTimeStamp(requestDateTime) + '\'>' + 
                '<merchantid>' + config.AddonPayment_Merchant_Id__c + '</merchantid>' + 
                '<account>' + osf_constant_strings.ADDON_PAYMENT_ACCOUNT + '</account>' + 
                '<channel>' + osf_constant_strings.ADDON_PAYMENT_CHANNEL + '</channel>' + 
                '<orderid>' + model.orderNo +  '</orderid>' + 
                '<amount currency=\'' + model.orderCurrency + '\'>' + model.amount + '</amount>' + 
                '<card>' + 
                    '<number>' + model.cardNumber + '</number>' + 
                    '<expdate>' + model.expDate + '</expdate>' + 
                    '<chname>' + model.name + '</chname>' + 
                    '<type>' + model.cardType + '</type>' + 
                    '<cvn>' + 
                        '<number>' + model.cvn + '</number>' + 
                        '<presind>1</presind>' + 
                    '</cvn>' + 
                '</card>' + 
                '<autosettle flag=\'1\'/>' + 
                '<sha1hash>' + getEncryptedSHA(requestDateTime, model, config) + '</sha1hash>' + 
            '</request>';
            return request;
    }

    /* 
    * @description  : Calculate Shipping Cost For The Cart
    * @author       : Ozgun Eser
    * @createdDate  : Feb 25, 2020
    * @param        : Id cartId,
    * @param        : Decimal taxAmount
    * @return       : Decimal shippingCost
    */
    public static Decimal calculateShippingCost (Id cartId, Decimal taxAmount) {
        try {
            ccrz__E_Cart__c ccCart = [SELECT Id, ccrz__ShipAmount__c, ccrz__ShipTo__r.osf_free_shipping_limit__c, ccrz__ShipTo__r.osf_shipping_cost__c, ccrz__Account__r.osf_free_shipment__c, ccrz__SubtotalAmount__c FROM ccrz__E_Cart__c WHERE Id = :cartId];
            Decimal totalAmount = ccCart.ccrz__SubtotalAmount__c + taxAmount;
            ccCart.ccrz__ShipAmount__c = ccCart.ccrz__Account__r.osf_free_shipment__c || totalAmount >= ccCart.ccrz__ShipTo__r.osf_free_shipping_limit__c ? 0 : ccCart.ccrz__ShipTo__r.osf_shipping_cost__c;
            update ccCart;
            return ccCart.ccrz__ShipAmount__c;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:utility:calculateShippingCost:Error', e);
            return 0;
        }
    }

    /* 
    * @description  : Calculate Shipping Cost For The Cart
    * @author       : Ozgun Eser
    * @createdDate  : Feb 25, 2020
    * @param        : String cartEncryptedId,
    * @param        : Decimal taxAmount
    * @return       : Decimal shippingCost
    */
    public static Decimal calculateShippingCost (String cartEncryptedId, Decimal taxAmount, Id shippingAddressId) {
        try {
            ccrz__E_Cart__c ccCart = [SELECT Id, ccrz__ShipAmount__c, ccrz__Account__r.osf_free_shipment__c, ccrz__SubtotalAmount__c, ccrz__ShipTo__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartEncryptedId];
            ccrz__E_ContactAddr__c shippingAddress = [SELECT osf_free_shipping_limit__c, osf_shipping_cost__c FROM ccrz__E_ContactAddr__c WHERE Id = :shippingAddressId];
            Decimal totalAmount = ccCart.ccrz__SubtotalAmount__c + taxAmount;
            ccCart.ccrz__ShipTo__c = shippingAddressId;
            return ccCart.ccrz__Account__r.osf_free_shipment__c || totalAmount >= shippingAddress.osf_free_shipping_limit__c ? 0 : shippingAddress.osf_shipping_cost__c;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:utility:calculateShippingCost:Error', e);
            return 0;
        }
    }

    /* 
    * @description  : Fetch Products
    * @author       : Ozgun Eser
    * @createdDate  : March 3, 2020
    * @param        : Set<String> productIdSet
    * @param        : Boolean includePricing
    * @param        : Boolean includeBlocked
    * @return       : Map<String, Object> outputData, containing product data
    */
    public static Map<String, Object> fetchProducts(Set<String> productIdSet, Boolean includePricing, Boolean includeBlocked) {
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPI.SIZING => new Map<String, Object> {
                new osf_ccServiceProduct().ENTITYNAME => new Map<String, Object> {
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
            },
            ccrz.ccAPIProduct.PRODUCTIDLIST => productIdSet,
            ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => includePricing,
            ccrz.ccAPIProduct.INCLUDE_ATTRIBUTE_PRICING => false,
            ccrz.ccAPIProduct.PARAM_INCLUDE_SELLERS => false,
            ccrz.ccAPIProduct.PARAM_INCLUDE_BLOCKED => includeBlocked,
            ccrz.ccAPIProduct.MEDIAFILTER => new Set<String> {osf_constant_strings.PRODUCT_IMAGE_THUMBNAIL},
            ccrz.ccAPIProduct.DATEFILTER => !includeBlocked,
            ccrz.ccAPIProduct.TYPES => new Set<String> {osf_constant_strings.PRODUCT_TYPE_PRODUCT, osf_constant_strings.PRODUCT_TYPE_COUPON},
            ccrz.ccApiProduct.PRODUCTLOCALE => ccrz.cc_CallContext.userLocale
        };
        return ccrz.ccAPIProduct.fetch(inputData);
    }

    /*
    * @description  : Add products to cart with given sku and quantity
    * @author       : Alina Craciunel
    * @createdDate  : Mar 09, 2020
    * @param        : map of skues and quantities
    * @param        : String cartSfid, cart Id of current cart
    * @return       : Map<String, Object>
    */
    public static Map<String, Object> addToCart(Map<String, Object> mapSkuQuantities, String cartSfid){
        List<ccrz.ccApiCart.LineData> newLines = new List<ccrz.ccApiCart.LineData>();
        for (String sku : mapSkuQuantities.keySet()) {
            ccrz.ccApiCart.LineData newLine = new ccrz.ccApiCart.LineData();
            newLine.sku = sku.replaceAll('\r\n|\n|\r', '').deleteWhitespace();
            newLine.quantity = Integer.valueof(mapSkuQuantities.get(sku));
            newLines.add( newLine );
        }
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => cartSfid,
            ccrz.ccApiCart.LINE_DATA => newLines
        });
        return addResults;
    }

    /* 
    * @description  : Fetch Products
    * @author       : Alina Craciunel
    * @createdDate  : March 11, 2020
    * @param        : String productId
    * @return       : Map<String, Object> outputData, containing product data
    */
    public static Map<String, Object> fetchProducts(String productId) {
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccAPI.SIZING => new Map<String, Object> {
                    new osf_ccServiceProduct().ENTITYNAME => new Map<String, Object> {
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S
                            }
                },
                ccrz.ccAPIProduct.PRODUCTIDLIST => new Set<String>{productId},
                ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
                ccrz.ccAPIProduct.DATEFILTER => true
        };
        return  ccrz.ccAPIProduct.fetch(inputData);
    }

    /* 
    * @description  : check stock info
    * @author       : Cansu Asli Asci 
    * @createdDate  : Feb 24, 2020
    * @param        : Map<String, Integer> productSKUQuantityMap
    * @return       : Map<String, Boolean> sku - in stock map
    */
    public static Map<String, Boolean> callStockCheckWS(Map<String, Integer> productSKUQuantityMap){
        Map<String, Boolean> sku_instock_map = new Map<String, Boolean>();
        try {
            String [] skuList = new List<String>();
            for(String sku : productSKUQuantityMap.keySet()){
                skuList.add(sku);
            }
            absis.ArticleWSPort port = new absis.ArticleWSPort();
            String codiCentre = 'CD01';
            String[] llistaCodisArticles = skuList;
            absis.estocCL[] responseitems = port.consultarEstocCentreDistribucioB2BSalesforce(codiCentre, llistaCodisArticles);
            Integer quantity;
            for(absis.estocCL item : responseitems){
                quantity = productSKUQuantityMap.get(item.codiArticle);
                if(item.unitats >= quantity){
                    sku_instock_map.put(item.codiArticle, true);
                }else{
                    sku_instock_map.put(item.codiArticle, false);
                }
            }
            return sku_instock_map;
        }catch(Exception ex){
            return sku_instock_map;
        }
    }

    /* 
    * @description  : update stock info on product
    * @author       : Cansu Asli Asci 
    * @createdDate  : Feb 24, 2020
    * @param        : Map<Id, Decimal> productIdQuantityMap
    * @param        : Map<Id,String> productIdSKUMap
    * @return       : 
    */
    public static void updateStock(Map<Id, Decimal> productIdQuantityMap, Map<Id,String> productIdSKUMap){
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        Boolean instock = true;
        
        //send productSKUQuantityMap
        Map<String, Integer> productSKUQuantityMap = new Map<String, Integer>();
        for(Id prodId : productIdQuantityMap.keySet()){
            productSKUQuantityMap.put(productIdSKUMap.get(prodId), Integer.valueOf(productIdQuantityMap.get(prodId)));
        }
       
        //return productSKUInStockMap
        Map<String, Boolean> productSKUInStockMap = callStockCheckWS(productSKUQuantityMap);
        //check if sku was retrieved from WebService
        for (Id prodId : productIdSKUMap.keySet()) {
            if (productSKUInStockMap.get(productIdSKUMap.get(prodId)) == null) {
                productSKUInStockMap.put(productIdSKUMap.get(prodId), false);
            }
        }
        //convert map
        Map<String,Id> productSKUIdMap = new Map<String,Id>();
        for(Id prodId : productIdSKUMap.keySet()){
            productSKUIdMap.put(productIdSKUMap.get(prodId),prodId);
        }
        //update products
        for(String sku : productSKUInStockMap.keySet()){
            Id productId = productSKUIdMap.get(sku);
            instock = productSKUInStockMap.get(sku);
            products.add(new ccrz__E_Product__c(Id=productId, osf_in_stock_checkout__c = instock));
        }
        update products;
    }

    /* 
    * @description  : return the in stock map: sku - is in stock
    * @author       : Alina Craciunel
    * @createdDate  : Mar 16, 2020
    * @param        : Map<Id, Decimal> productIdQuantityMap
    * @param        : Map<Id,String> productIdSKUMap
    * @return       : Map<String, Boolean> mapInStock
    */
    public static Map<String, Boolean> getStockInfo(Map<Id, Decimal> productIdQuantityMap, Map<Id,String> productIdSKUMap){
        Map<String, Integer> productSKUQuantityMap = new Map<String, Integer>();
        for(Id prodId : productIdQuantityMap.keySet()){
            productSKUQuantityMap.put(productIdSKUMap.get(prodId), Integer.valueOf(productIdQuantityMap.get(prodId)));
        }
        Map<String, Boolean> mapInStock = callStockCheckWS(productSKUQuantityMap);
        for (Id prodId : productIdSKUMap.keySet()) {
            if (mapInStock.get(productIdSKUMap.get(prodId)) == null) {
                mapInStock.put(productIdSKUMap.get(prodId), false);
            }
        }
        return mapInStock;
    }

    public static List<Map<String, String>> fetchDeliveryTime(Map<String, Integer> productSKUQuantityMap){
        List<Map<String, String>> productDeliveryTimeMapList = new List<Map<String, String>>();
        Map<String, String> productOutOfStockMap = new Map<String, String>();
        Map<String, Boolean> productSKUStockMap = callStockCheckWS(productSKUQuantityMap);
        //for query
        Set<String> outofstockList = new Set<String>();
        for(String sku : productSKUStockMap.keySet()){
            if(productSKUStockMap.get(sku) == false){
                 outofstockList.add(sku);
            }       
        }
        List<ccrz__E_Product__c> productsOutOfStock = [SELECT ccrz__SKU__c, osf_provider_delivery_time__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN: outofstockList];
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        for(ccrz__E_Product__c prod : productsOutOfStock){
            prod.osf_provider_delivery_time__c = prod.osf_provider_delivery_time__c + config.osf_providertime_plus__c;
            productOutOfStockMap.put(prod.ccrz__SKU__c, String.valueOf(prod.osf_provider_delivery_time__c));
        }

        String standardDelivery = osf_constant_strings.STANDARD_DELIVERY_TIME_CHECKOUT + osf_constant_strings.EMPTY_STRING + osf_constant_strings.DELIVERY_TIME_IN_HOURS;
        for(String sku : productSKUStockMap.keySet()){
            Map<String, String> prodTimeMap = new Map<String, String>();
            prodTimeMap.put(osf_constant_strings.SKU, sku);
            if(productSKUStockMap.get(sku) == false){
                prodTimeMap.put(osf_constant_strings.DELIVERY_TIME, productOutOfStockMap.get(sku));
            }else{
                prodTimeMap.put(osf_constant_strings.DELIVERY_TIME, standardDelivery);
            }   
            productDeliveryTimeMapList.add(prodTimeMap);    
        }
        return productDeliveryTimeMapList;
    }
    /*
    * @description  : Create case from contact us form
    * @author       : Alina Craciunel
    * @createdDate  : Mar 16, 2020
    * @param        : Map<String, Object> formData
    * @return       : void
    */
    public static void createCaseFromContactForm(Map<String, Object> formData){
        String name = formData.containsKey(osf_constant_strings.MYUSERS_NAME) ? (String) formData.get(osf_constant_strings.MYUSERS_NAME) : osf_constant_strings.EMPTY_STRING;
        String email = formData.containsKey(osf_constant_strings.EMAIL) ? (String) formData.get(osf_constant_strings.EMAIL) : osf_constant_strings.EMPTY_STRING;
        String phone = formData.containsKey(osf_constant_strings.PHONE) ? (String) formData.get(osf_constant_strings.PHONE) : osf_constant_strings.EMPTY_STRING;
        String comment = formData.containsKey(osf_constant_strings.COMMENT) ? (String) formData.get(osf_constant_strings.COMMENT) : osf_constant_strings.EMPTY_STRING;
        Case newCase = new Case();
        newCase.Status = osf_constant_strings.CASE_STATUS_NEW;
        newCase.Origin = osf_constant_strings.CASE_ORIGIN_WEB;
        newCase.Subject = osf_constant_strings.GENERAL_INQUIRY;
        newCase.Description = comment;
        if (ccrz.cc_CallContext.currContact != null) {
            newCase.ContactId = ccrz.cc_CallContext.currContact.Id;
        }
        newCase.osf_is_guest_user__c = ccrz.cc_CallContext.isGuest;
        newCase.osf_name__c = name;
        newCase.osf_email__c = email;
        newCase.osf_phone__c = phone;
        insert newCase;
    }

    /* 
    * @description  : Creates a map of product Id to decimal and returns it to specify which product will get how much (%) discount
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Set<String> ccProductIdSet, productIdSet that discounts will apply
    * @return       : Map<String, Decimal> product Id to discount rate map
    */
    public static Map<String, Decimal> getDiscountByProduct(Set<String> ccProductIdSet) {
        Set<String> ccProductIdSetForCatalog = new Set<String> ();
        Set<String> catalogIdSet = new Set<String> ();
        Map<String, Decimal> ccProductIdToDiscountRateMap = getNegotiatedDiscountByProduct(ccProductIdSet);
        for(String ccProductId : ccProductIdSet) {
            if(!ccProductIdToDiscountRateMap.containsKey(ccProductId)) {
                ccProductIdSetForCatalog.add(ccProductId);
            }
        }
        List<ccrz__E_Product__c> ccProductList = [SELECT Id, osf_catalog_id__c FROM ccrz__E_Product__c WHERE Id IN :ccProductIdSetForCatalog];
        for(ccrz__E_Product__c ccProduct : ccProductList) {
            if(String.isNotBlank(ccProduct.osf_catalog_id__c)) {
                catalogIdSet.add(ccProduct.osf_catalog_id__c.substringBefore(osf_constant_strings.LINE));
            }
        }
        Map<String, Decimal> catalogIdToDiscountRateMap = getNegotiatedDiscountByCatalog(catalogIdSet);
        for(ccrz__E_Product__c ccProduct : ccProductList) {
            if(String.isNotBlank(ccProduct.osf_catalog_id__c) && catalogIdToDiscountRateMap.containsKey(ccProduct.osf_catalog_id__c.substringBefore(osf_constant_strings.LINE)) && !ccProductIdToDiscountRateMap.containsKey(ccProduct.Id)) {
                ccProductIdToDiscountRateMap.put(ccProduct.Id, catalogIdToDiscountRateMap.get(ccProduct.osf_catalog_id__c.substringBefore(osf_constant_strings.LINE)));
            }                
        }
        return ccProductIdToDiscountRateMap;
    }
}