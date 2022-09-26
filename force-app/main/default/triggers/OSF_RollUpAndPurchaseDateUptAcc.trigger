/**
* File:        OSF_OrderRollUpsOnAccount.Trigger
* Project:     Abacus
* Date:        March 30, 2021
* Created By:  Fahad Farrukh
* *************************************************************************
* Description:  Order Rollups on Account when an order is created, updated or deleted
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
trigger OSF_RollUpAndPurchaseDateUptAcc on Order (after update,after delete) {
    if(Trigger.isAfter){
        OSF_RollUpAndPurchaseDateUptAccCntrl.doRollUpsOnAccount(Trigger.IsUpdate,Trigger.IsDelete,Trigger.newMap,Trigger.oldMap);
        OSF_RollUpAndPurchaseDateUptAccCntrl.updateLastPurchaseDateOnAccount(Trigger.IsUpdate,Trigger.IsDelete,Trigger.newMap,Trigger.oldMap);
    }
    
}