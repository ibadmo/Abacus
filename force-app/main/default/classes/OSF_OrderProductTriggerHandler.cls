/**
* File:        OSF_OrderProductTriggerHandler.cls
* Project:     Abacus
* Date:        July 22, 2021
* Created By:  Ali Ozdemir
* *************************************************************************
* Description:  Order Product Trigger handler
* *************************************************************************
* History:
* Date:                 Modified By:      Description:
* July 22, 2021         Ali Ozdemir
*/
public class OSF_OrderProductTriggerHandler {
    public static Map<String, String> interestAsPurchaseMapping = new Map<String, String> {'05 FICCIO' => 'Comprador_Llibres_Ficció', 
                                                                                '07 PRÀCTIC-TÈCNIC' => 'Comprador_Llibres_Pràctic', 
                                                                                '14 IDIOMES' => 'Comprador_Llibres_Idiomes',
                                                                                '08 HUMANITATS'=>'Comprador_Llibres_Humanitats',
                                                                                '09 INFANTIL I JUVENIL'=>'Comprador_Llibres_Infantils_Juvenils',
                                                                                '06 TEXT'=>'Comprador_Llibres_Text',
                                                                                '01 PAPERERIA'=>'Comprador_Papereria',
                                                                                '02 JOGUINES'=>'Comprador_Joguines',
                                                                                '03 TECNO i MULTIMEDIA'=>'Comprador_Tecnologia',
                                                                                '13 MANUALITATS'=>'Comprador_Manualitats',
                                                                                '11 REGAL - IMPULS'=>'Comprador_Regal',
                                                                                '10 DIVERSIFICACIÓ'=>'Comprador_Diversificació',
                                                                                '12 PUERICULTURA'=>'Comprador_puericultura','17 MOBILIARI'=>'Comprador_Mobiliari'};

    /**
    * @author Ugurcan Erkal
    * @date  July 29, 2021
    * @name handleOrderItemExternalId
    * @description create the Unique External Id for the Order Item. 
    * @return void
    */   
    public static void handleOrderItemExternalId(List<OrderItem> orderItems){
		try{
            Set<Id> productIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();

            for(OrderItem oItem : orderItems){
                productIds.add(oItem.Product2Id);
                orderIds.add(oItem.OrderId);
            }
            
            // Get product and order related with the order item.
            Map<ID, Product2> products = new Map<ID, Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id in :productIds]);
            Map<ID, Order> orders = new Map<ID, Order>([SELECT Id, OrderNumber FROM Order WHERE Id in :orderIds]);

            for(OrderItem oItem : orderItems){

                Product2 product = products.get(oItem.Product2Id);
                Order order = orders.get(oItem.OrderId);

                if(product == null){
                    oItem.addError(Label.OSF_OrderItemMissingProduct);
                }else if(order == null){
                    oItem.addError(Label.OSF_OrderItemMissingOrder);
                }

                // Generate the External Order Item Id with the related Product Code and Order Number.
                if(oItem.OSF_External_OrderItem_Id__c == null && product.ProductCode != null && order.OrderNumber != null){
                    oItem.OSF_External_OrderItem_Id__c = product.ProductCode + order.OrderNumber;
                }else if(product.ProductCode == null){
                    oItem.addError(Label.OSF_InvalidProductCode);
                }else if(order.OrderNumber == null){
                    oItem.addError(Label.OSF_InvalidOrderNumber);
                }
            }
			
		} catch (Exception ex){
            system.debug('OSF_OrderItemTriggerHandler.handleOrderItemExternalId exception : ' + ex.getMessage());
		}
	}        

    /**
    * @author Ali Ozdemir
    * @date  June 8, 2021
    * @name updateInterestAsPurschaseOnAccount
    * @description Update InterestAsPurschas Field on Account based on order product Renglos
    * @return void
    */   
    public static void updateInterestAsPurschaseOnAccount(List<Account> accList) {
        Map<String, AccountRengloWrapper> wrappersList = new Map<String, AccountRengloWrapper>();
        for(AggregateResult aggRes : [SELECT Count(Id) sumOfAmounts, Product2.Renglo__c renglo, Order.AccountId accId FROM OrderItem WHERE Order.AccountId IN :accList AND Product2.Renglo__c != null GROUP BY Product2.Renglo__c, Order.AccountId]) {                
            String accId = (String) aggRes.get('accId');
            String renglo = aggRes.get('renglo') != null ? (String) aggRes.get('renglo') : '';
            Decimal sumOfAmounts = (Decimal) aggRes.get('sumOfAmounts');
            if(renglo != '' && interestAsPurchaseMapping.containsKey(renglo)) {
                String val = interestAsPurchaseMapping.get(renglo);
                Map<String, Decimal> rengloMap;
                if(!wrappersList.containsKey(accId)) {
                    AccountRengloWrapper wrapper = new AccountRengloWrapper();  
                    rengloMap = new Map<String, Decimal>();                    
                    rengloMap.put(val, sumOfAmounts);
                    wrapper.accountId = accId;
                    wrapper.renglosMapping = rengloMap;
                    wrappersList.put(accId, wrapper);
                } else {
                    AccountRengloWrapper wrapper = wrappersList.get(accId);
                    rengloMap = wrapper.renglosMapping;
                    rengloMap.put(val, sumOfAmounts);
                    wrapper.renglosMapping = rengloMap;
                    wrappersList.put(accId, wrapper);
                }
            }
        }
        if(!wrappersList.isEmpty()) {
            for(Account acc : accList) {
                if(wrappersList.containsKey(acc.Id)) {
                    List<String> renglos = defineRenglo(wrappersList.get(acc.Id).renglosMapping);
                    acc.Interests_as_purchases__c = checkSpecialCase(renglos) ? 'Comprador_Llibres' : String.join(renglos, ',');
                }
            }

            if(!accList.isEmpty()) {
                database.update(accList, false);
            }            
        }
    }

    /**
    * @author Fahad Farrukh
    * @date  June 8, 2021
    * @name defineRenglo
    * @description define renglo
    * @return Boolean
    */  
    private static List<String> defineRenglo(Map<String, Decimal> rengloMap) {
        List<String> rengloList = new List<String>();
        Decimal maxValue = 0;
        for(String key : rengloMap.keySet()) {
            Decimal tempCount = rengloMap.get(key);
            if(tempCount > maxValue) {
                rengloList = new List<String>{key};
                maxValue = tempCount;
            }else if(tempCount == maxValue) {
                rengloList.add(key);
                maxValue = tempCount;
            }
        }
        
        return rengloList;
    }
    
    public class AccountRengloWrapper {
        String accountId;
        Map<String, Decimal> renglosMapping;
    }

    /**
    * @author Fahad Farrukh
    * @date  June 8, 2021
    * @name checkSpecialCase
    * @description Check if Renglos=05,07,08
    * @return Boolean
    */   
    private static Boolean checkSpecialCase(List<String> specialCase) {
        Boolean isSpecialCase = false;
        if(specialCase.size() >= 3) {
            for(String special : specialCase) {
                if(special.equalsIgnoreCase('Comprador_Llibres_Humanitats') || 
                    special.equalsIgnoreCase('Comprador_Llibres_Ficció') || special.equalsIgnoreCase('Comprador_Llibres_Pràctic')) {
                    isSpecialCase = true;
                } else {
                    isSpecialCase = false;
                    break;
                }
            }
        }
        return isSpecialCase;
    }
}