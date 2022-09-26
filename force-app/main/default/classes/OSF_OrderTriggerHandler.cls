/**
 * File:        OSF_OrderTriggerHandler.cls
 * Project:     Abacus
 * Date:        March 30, 2021
 * Created By:  Fahad Farrukh
 * *************************************************************************
 * Description:  Order Trigger
 * *************************************************************************
 * History:
 * Date:        June 6, 2021         Modified By:  Fahad Farrukh           Description:
 *              July 20, 2021                      Ali Ozdemir
 */
public class OSF_OrderTriggerHandler{
	private static final Integer parPercentage = 50;
	private static final String TieOrNone = 'Multibotiga';
	/**
	 * @author Ali Ozdemir
	 * @date  July 20, 2021
	 * @name doRollUpsOnAccount
	 * @description Calculate KPIs on Account
	 * @return void
	 */
	public static void doRollUpsOnAccount(List<Account> accList, Map<String, List<Order>> ordersMap, Set<Id> accIds){
		//try {
		Map<String, AccountKPIWrapper> mapAggregateResults = new Map<String, AccountKPIWrapper>();
		for (Account a : accList){
			AccountKPIWrapper wrapper = new AccountKPIWrapper(a, !accIds.contains(a.Id));
			if (!accIds.contains(a.Id)){
				a.Last_purchase_date__c = null;
			}
			for (Order o : ordersMap.get(a.Id)){
				wrapper.countThisYearOrdersOnAccount = o.isOrderthisyear__c == 1 ? wrapper.countThisYearOrdersOnAccount + 1 : wrapper.countThisYearOrdersOnAccount;
				wrapper.countThisYearTotalAmountOfOrdersOnAccount = (o.TotalAmount != null && o.isOrderthisyear__c == 1) ? wrapper.countThisYearTotalAmountOfOrdersOnAccount + o.TotalAmount : wrapper.countThisYearTotalAmountOfOrdersOnAccount;
				if (o.TotalAmount != null){
					wrapper.countTotalAmountOfOrdersOnAccount += o.TotalAmount;
					wrapper.countOrdersOnAccount += 1;
				}
				if (wrapper.effectiveDate == null){
					wrapper.effectiveDate = o.EffectiveDate;
				} else if (wrapper.effectiveDate < o.EffectiveDate){
					wrapper.effectiveDate = o.EffectiveDate;
				}
			}
			//Numeric values
			a.Nr_of_Orders__c = wrapper.countOrdersOnAccount;
			a.Total_Amount_Orders__c = wrapper.countTotalAmountOfOrdersOnAccount;
			a.Nr_of_Orders_this_year__c = wrapper.countThisYearOrdersOnAccount;
			a.Total_sum_of_Orders_this_year__c = wrapper.countThisYearTotalAmountOfOrdersOnAccount;
			// Dates
			a.Last_purchase_date__c = a.Last_purchase_date__c != null && a.Last_purchase_date__c > wrapper.effectiveDate ? a.Last_purchase_date__c : wrapper.effectiveDate;
		}
		accList = updateStorePurchaseOnAccount(accList, ordersMap, accIds);
		accList = updateStoreDeliveryOnAccount(accList, ordersMap, accIds);
		if (accList.size() > 0){
			Database.SaveResult[] updateResult = database.update(accList, true);
			for (Database.SaveResult r : updateResult){
				if (!r.isSuccess()){
					for (Database.Error e : r.getErrors()){
						throw new DMLException(e.getMessage());
					}
				}
			}
		}
		/*} catch (Exception e) {
		 System.debug('Error '+e.getMessage());
		 }*/
	}

	/**
	 * @author Ali Ozdemir
	 * @date  July 20, 2021
	 * @name updateLastPurchaseDateOnAccount
	 * @description Update Most Store Purchased on Account
	 * @return List<Account>
	 */
	private static List<Account> updateStorePurchaseOnAccount(List<Account> accList, Map<String, List<Order>> ordersMap, Set<Id> accIds){
		Map<String, Integer> mapToCountStorePurchase = new Map<String, Integer>();
		for (Account a : accList){
            Integer orderSize = 0;
			if (accIds.contains(a.Id)){
				mapToCountStorePurchase = a.Reference_Store_Cache__c != null && a.Reference_Store_Cache__c != '' ? (Map<String, Integer>)JSON.deserialize(a.Reference_Store_Cache__c, Map<String, Integer>.class) : new Map<String, Integer>();
				for (String key : mapToCountStorePurchase.keySet()){
                    orderSize = orderSize + mapToCountStorePurchase.get(key);
                }
			}

			for (Order o : ordersMap.get(a.Id)){
				if (o.Store_Purchase__c != null && o.Status == 'Entregat_client' && o.isOrderthisyear__c == 1){
					if (mapToCountStorePurchase.containsKey(o.Store_Purchase__c)){
						mapToCountStorePurchase.put(o.Store_Purchase__c, mapToCountStorePurchase.get(o.Store_Purchase__c)+1);
                        orderSize = orderSize + 1;
					} else{
						mapToCountStorePurchase.put(o.Store_Purchase__c, 1);
                        orderSize = orderSize + 1;
					}
				}
			}

			List<String> parStoresList = new List<String>();
			if (!mapToCountStorePurchase.keySet().isEmpty()){
				for (String key : mapToCountStorePurchase.keySet()){
					Integer countOfStorePurchased = mapToCountStorePurchase.get(key);
					if (orderSize > 0){
						Double percentage = ((Double)countOfStorePurchased / orderSize) * 100;
						Long percentageL = percentage.round();
						if (percentageL > parPercentage){
							parStoresList.add(key);
						}
					}
				}
			}
			if ((parStoresList.isEmpty()) && mapToCountStorePurchase.size() > 0){
				a.Reference_store__c = TieOrNone;
			} else if (parStoresList.size() == 1){
				a.Reference_store__c = parStoresList[0];
			} else{
				a.Reference_store__c = '';
			}
			a.Reference_Store_Cache__c = JSON.serialize(mapToCountStorePurchase);
			mapToCountStorePurchase.clear();
		}
		return accList;
	}

	/**
	 * @author Ali Ozdemir
	 * @date  July 20, 2021
	 * @name updateStoreDeliveryOnAccount
	 * @description Update Store Delivery on Account
	 * @return List<Account>
	 */
	private static List<Account> updateStoreDeliveryOnAccount(List<Account> accList, Map<String, List<Order>> ordersMap, Set<Id> accIds){
		Map<String, Integer> mapToCountStoreDelivery = new Map<String, Integer>();
		String storeUsualDeliveryTemp = '';
		for (Account a : accList){
			if (accIds.contains(a.Id)){
				mapToCountStoreDelivery = a.Store_Delivery_Cache__c != null && a.Store_Delivery_Cache__c != '' ? (Map<String, Integer>)JSON.deserialize(a.Store_Delivery_Cache__c, Map<String, Integer>.class) : new Map<String, Integer>();
			}

			for (Order o : ordersMap.get(a.Id)){
				if (o.Store_Delivery__c != null && o.Store_Delivery__c != '' && o.In_Store_Order__c == 'Web'){
					if (mapToCountStoreDelivery.containsKey(o.Store_Delivery__c)){
						mapToCountStoreDelivery.put(o.Store_Delivery__c, mapToCountStoreDelivery.get(o.Store_Delivery__c)+1);
					} else{
						mapToCountStoreDelivery.put(o.Store_Delivery__c, 1);
					}
				}
			}

			a.Store_usual_delivery__c = findStoreDelivery(mapToCountStoreDelivery);
			a.Store_Delivery_Cache__c = JSON.serialize(mapToCountStoreDelivery);
			mapToCountStoreDelivery.clear();
			storeUsualDeliveryTemp = '';
		}

		return accList;
	}

	/**
	 * @author Ali Ozdemir
	 * @date  August 4, 2021
	 * @name findStoreDelivery
	 * @description Finds the store delivery
	 * @return Integer
	 */
	public static String findStoreDelivery(Map<String, Integer> mapToCount) {
		Integer max = 0, temp = 0;
		String delivery = '';
		for (String key : mapToCount.keySet()) {
			temp = mapToCount.get(key); 
			if(temp > max) {
				max = temp;
				delivery = key;
			} else if (temp == max) {
				delivery = delivery + ',' + key;
			}
		}
		return delivery;
	}

	public class AccountKPIWrapper{
		Decimal countOrdersOnAccount = 0;
		Decimal countThisYearOrdersOnAccount = 0;
		Decimal countTotalAmountOfOrdersOnAccount = 0;
		Decimal countThisYearTotalAmountOfOrdersOnAccount = 0;
		Date effectiveDate;
		public AccountKPIWrapper(Account a, Boolean isFirst){
			if (!isFirst){
				countOrdersOnAccount = a.Nr_of_Orders__c != 0 && a.Nr_of_Orders__c != null ? a.Nr_of_Orders__c : 0;
				countTotalAmountOfOrdersOnAccount = a.Total_Amount_Orders__c != 0 && a.Total_Amount_Orders__c != null ? a.Total_Amount_Orders__c : 0;
				countThisYearOrdersOnAccount = a.Nr_of_Orders_this_year__c != 0 && a.Nr_of_Orders_this_year__c != null ? a.Nr_of_Orders_this_year__c : 0;
				countThisYearTotalAmountOfOrdersOnAccount = a.Total_sum_of_Orders_this_year__c != 0 && a.Total_sum_of_Orders_this_year__c != null ? a.Total_sum_of_Orders_this_year__c : 0;
			}
		}
	}
}