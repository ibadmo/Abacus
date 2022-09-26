/**
* File:        OSF_OrderRollUpsOnAccountController.cls
* Project:     Abacus
* Date:        March 30, 2021
* Created By:  Fahad Farrukh
* *************************************************************************
* Description:  Order Rollups on Account
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
public class OSF_RollUpAndPurchaseDateUptAccCntrl {
    /**
* @author Fahad Farrukh
* @date  March 31, 2021
* @name doRollUpsOnAccount
* @description RollUp Completed orders totals amount and count on their respective Accounts
* @return void
*/
    public static void doRollUpsOnAccount(Boolean IsUpdate,Boolean IsDelete,Map<id,Order> OrdListNewMap,Map<id,Order> OrdListOldMap) {
        Set<id> accountIds = new Set<id>();
        List<Account> accList;
        if (IsUpdate) {
            for (Id id1 : OrdListNewMap.keySet()) {
                if(!String.isBlank(OrdListNewMap.get(id1).AccountId))
                    accountIds.add(OrdListNewMap.get(id1).AccountId);
            }
        } else if (IsDelete) {
            for (Id id1: OrdListOldMap.keySet()) {
                if (!String.isBlank(OrdListOldMap.get(id1).AccountId))
                    accountIds.add(OrdListOldMap.get(id1).AccountId);
            }
        }
        accList = [SELECT id, Nr_of_Orders__c, Total_Amount_Orders__c,(SELECT id, TotalAmount, isOrderthisyear__c  FROM Orders WHERE status != 'Draft') FROM Account WHERE id IN : accountIds];
        Integer countOrdersOnAccount, countThisYearOrdersOnAccount;
        Decimal countTotalAmountOfOrdersOnAccount, countThisYearTotalAmountOfOrdersOnAccount;
        for (Account a : accList) {
            countOrdersOnAccount = 0;
            countTotalAmountOfOrdersOnAccount = 0;
            countThisYearOrdersOnAccount = 0;
            countThisYearTotalAmountOfOrdersOnAccount = 0;
            for (Order o : a.orders) {
                if (o.isOrderthisyear__c == 1) {
                    countThisYearOrdersOnAccount += 1;
                    if(o.TotalAmount!=null)
                    countThisYearTotalAmountOfOrdersOnAccount += o.TotalAmount;
                }
                if(o.TotalAmount!=null)
                countTotalAmountOfOrdersOnAccount += o.TotalAmount;
                countOrdersOnAccount+=1;   
            }
            a.Nr_of_Orders__c = countOrdersOnAccount;
            a.Total_Amount_Orders__c = countTotalAmountOfOrdersOnAccount;
            a.Nr_of_Orders_this_year__c = countThisYearOrdersOnAccount;
            a.Total_sum_of_Orders_this_year__c = countThisYearTotalAmountOfOrdersOnAccount;
        }
        if (accList.size() > 0)
            database.update(accList, false);  
    }
    /**
* @author Fahad Farrukh
* @date  March 31, 2021
* @name updateLastPurchaseDateOnAccount
* @description Update Last Purchase Date on Account
* @return void
*/   
    public static void updateLastPurchaseDateOnAccount(Boolean IsUpdate, Boolean IsDelete, Map<id,Order> OrdListNewMap, Map<id,Order> OrdListOldMap) {
        Set<id> accountIds = new Set<id>();
        List<Account> accList;
        if (IsUpdate) {
            for (Id id1 : OrdListNewMap.keySet()) {
                if (!String.isBlank(OrdListNewMap.get(id1).AccountId))
                    accountIds.add(OrdListNewMap.get(id1).AccountId);
            }
        } else if (IsDelete) {
            for (Id id1: OrdListOldMap.keySet()) {
                if (!String.isBlank(OrdListOldMap.get(id1).AccountId))
                    accountIds.add(OrdListOldMap.get(id1).AccountId);
            }
        }
        accList = [SELECT id, Last_purchase_date__c, (SELECT id, EffectiveDate FROM Orders) FROM Account WHERE id IN : accountIds];
        for (Account a : accList) {
            a.Last_purchase_date__c=NULL;
            for (Order o : a.orders) {
                if (a.Last_purchase_date__c == NULL) {
                    a.Last_purchase_date__c = o.EffectiveDate;
                } else if (a.Last_purchase_date__c < o.EffectiveDate) {
                    a.Last_purchase_date__c = o.EffectiveDate;
                }
            }
        }
        if (accList.size() > 0)
            database.update(accList, false);
    }
}