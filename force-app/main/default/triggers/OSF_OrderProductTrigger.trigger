/**
 * File:        OSF_OrderTrigger.Trigger
 * Project:     Abacus
 * Date:        June 8, 2021
 * Created By:  Fahad Farrukh
 * *************************************************************************
 * Description:  Order Rollups on Account when an order is created, updated or deleted
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
trigger OSF_OrderProductTrigger on OrderItem (before insert, after insert, after update, after delete){
	if (Trigger.isBefore){
		if (Trigger.isInsert){
			OSF_OrderProductTriggerHandler.handleOrderItemExternalId(Trigger.new);
		}
	}
}