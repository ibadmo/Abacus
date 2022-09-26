/**
* File:        OSF_OrderProductTriggerHandlerTest.cls
* Project:     Abacus
* Date:        July 29, 2021
* Created By:  Ugurcan Erkal
* *************************************************************************
* Description:  OSF_OrderProductTriggerHandler Test Class
* *************************************************************************
* History:
* Date:                 Modified By:      Description:
* July 29, 2021         Ugurcan Erkal     Created
*/
@isTest
private class OSF_OrderProductTriggerHandlerTest{
	@isTest
	private static void testOrderItemCreation(){
		Account a = new Account();
		a.Name = 'Test Account';
		insert a;

		// Insert Product
		Product2 p = new Product2();
		p.Name = ' Test Product ';
		p.Description = 'Test Product Entry 1';
		p.productCode = 'ABC';
		p.isActive = true;
        p.Renglo__c = '05 FICCIO';        
		insert p;


		Id pricebookId = Test.getStandardPricebookId();

		// Insert PricebookEntry
		PricebookEntry standardPrice = new PricebookEntry();
		standardPrice.Pricebook2Id = pricebookId;
		standardPrice.Product2Id = p.Id;
		standardPrice.UnitPrice = 1;
		standardPrice.IsActive = true;
		standardPrice.UseStandardPrice = false;
		insert standardPrice;

		// Insert Order
		Order o = new Order();
		o.Name = 'Test Order ';
		o.Status = 'Draft';
		o.EffectiveDate = system.today();
		o.EndDate = system.today()+4;
		o.AccountId = a.id;
		o.Pricebook2Id = pricebookId;

		insert o;

		// Insert Order Item
		OrderItem i = new OrderItem();
		i.OrderId = o.id;
		i.Quantity = 24;
		i.UnitPrice = 240;
		i.Product2id = p.id;
		i.PricebookEntryId = standardPrice.id;
		insert i;

        List<Account> accList = new List<Account>();
        accList.add(a);

        OSF_OrderProductTriggerHandler.updateInterestAsPurschaseOnAccount(accList);
	}
}