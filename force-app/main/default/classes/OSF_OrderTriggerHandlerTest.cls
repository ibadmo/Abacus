@isTest
public class OSF_OrderTriggerHandlerTest {
    @isTest static void createOrderRecordsWithAccount() {
        Id id1 = [select id, name from profile where name = 'SCC Integration User'].id;
        user u = new user (lastName = 'Test RollUps',profileId = id1,Alias = 'uscci',
                           Email = 'abacus-pj+test@osf.digital',
                           UserName = 'abacus-pj+test@osf.digital',
                           EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Chicago');
        system.RunAs(u) {
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                pricebook_external_id__c = 'Standard Price Book',
                IsActive = true
            );
            
            Update standardPricebook;
            //Insert Product
            list<Product2> prList = new list<Product2>();
            prList.add(new Product2(Name = 'CLE Littérature Progressive AVA 2E/Cor Cle 9782090351828', ProductCode = '1326798.78', Description = 'Fa anys, a la vall de Gudbrandsdalen van néixer unesbessones que, del maluc cap avall, eren una. De grans, van treballar de tapisseres i, de les seves obres,es deia que predeien el futur. Quan van morir, el seupare va fer fondre dues campanes en memòria seva que, pel seu repic poderós, van convertir Butangen en unpunt de referència, fins l’any 1880. Aleshores, elsnous temps van arribar al poble i tres destins es vancreuar: el d’un jove pastor, el d’un il·lustrador destavkirke alemany i el de l’Astrid, una minyona de la granja Hekne, on les bessones havien nascut seglesenrere. Aquest és el primer llibre d’una trilogia.', Renglo__c = '05 FICCIO', Source_Absis__c = True));
            insert prList;
            //Insert Pricebook
            list<Pricebook2> pbList = new list<Pricebook2>();
            pbList.add(new Pricebook2(Name = 'Diferit', pricebook_external_id__c = 'Diferit'));
            insert pbList;
            //Insert pricebook entry
            list<PricebookEntry> pbeList = new list<PricebookEntry>();
            pbeList.add(new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prList[0].Id, UnitPrice = 7.05, IsActive = true));
            insert pbeList;  
            //
            Test.startTest();
            RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
            Account act = new Account(firstName = 'Steve', lastName = 'Smith', recordTypeId = recordType.Id, SAP_ID__c = '73218390');
            insert act;
            list<Order> ordList = new list<Order>();
            list<OrderItem> ordItemList = new list<OrderItem>();
            ordList.add(new order (Pricebook2Id = pbList[0].Id, effectiveDate = system.today()-265 , Store_Purchase__c = 'B001_Balmes', Status = 'Entregat_client', SFCC_Order_Total__c = 18.19, Order_SCCSync_Status__c = 'Synchronised', SFCC_Order_Number__c = '00000101', accountId = act.Id));
            ordList.add(new order (Pricebook2Id = pbList[0].Id, effectiveDate = system.today()-263 , Store_Purchase__c = 'B018_Baixa', Status = 'Entregat_client', SFCC_Order_Total__c = 12.19, Order_SCCSync_Status__c = 'Synchronised', SFCC_Order_Number__c = '00000102', accountId = act.Id));
            insert ordList;
            ordList[0].SFCC_Order_Total__c += ordList[0].SFCC_Order_Total__c;
            update ordList;
            
            ordItemList.add(new OrderItem(orderId = ordList[0].Id, PricebookEntryId = pbeList[0].Id, UnitPrice = 7.05, Quantity = 2));
            insert ordItemList;
            delete ordItemList;
            delete ordList[0];
            Test.stopTest();
        }
        
    }
}