@isTest
public class OSF_OpportunityProduct_Handler_Test {
    @isTest static void createOpportunityRecords() {
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
            
            list<Product2> prList = new list<Product2>();
            prList.add(new Product2(Name = 'CLE Littérature Progressive AVA 2E/Cor Cle 9782090351828', ProductCode = '0885094.33', Description = 'Fa anys, a la vall de Gudbrandsdalen van néixer unesbessones que, del maluc cap avall, eren una. De grans, van treballar de tapisseres i, de les seves obres,es deia que predeien el futur. Quan van morir, el seupare va fer fondre dues campanes en memòria seva que, pel seu repic poderós, van convertir Butangen en unpunt de referència, fins l’any 1880. Aleshores, elsnous temps van arribar al poble i tres destins es vancreuar: el d’un jove pastor, el d’un il·lustrador destavkirke alemany i el de l’Astrid, una minyona de la granja Hekne, on les bessones havien nascut seglesenrere. Aquest és el primer llibre d’una trilogia.', Renglo__c = '05 FICCIO',OSF_External_Prod_Id__c = '0885094.33', Source_Absis__c = True));
            prList.add(new Product2(Name = 'CLE Littérature Progressive AVA 2E/Cor Cle 9782090351828', ProductCode = '0885094.32', Description = 'Fa anys, a la vall de Gudbrandsdalen van néixer unesbessones que, del maluc cap avall, eren una. De grans, van treballar de tapisseres i, de les seves obres,es deia que predeien el futur. Quan van morir, el seupare va fer fondre dues campanes en memòria seva que, pel seu repic poderós, van convertir Butangen en unpunt de referència, fins l’any 1880. Aleshores, elsnous temps van arribar al poble i tres destins es vancreuar: el d’un jove pastor, el d’un il·lustrador destavkirke alemany i el de l’Astrid, una minyona de la granja Hekne, on les bessones havien nascut seglesenrere. Aquest és el primer llibre d’una trilogia.', Renglo__c = '05 FICCIO',OSF_External_Prod_Id__c = '0885094.32', Source_Absis__c = True));
            insert prList;
            list<Pricebook2> pbList = new list<Pricebook2>();
            
            pbList.add(new Pricebook2(Name = 'Diferit', pricebook_external_id__c = 'Diferit'));
            pbList.add(new Pricebook2(Name = 'No Socio', pricebook_external_id__c = 'No Socio'));
            insert pbList;
            
            list<PricebookEntry> pbeList = new list<PricebookEntry>();
            pbeList.add(new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prList[0].Id, UnitPrice = 7.05, IsActive = true, OSF_External_PBE_ID__c = pbList[0].pricebook_external_id__c+'-'+prList[0].productCode));
            pbeList.add(new PricebookEntry(Pricebook2Id = pbList[1].Id, Product2Id = prList[1].Id, UnitPrice = 7.05, IsActive = true, OSF_External_PBE_ID__c = pbList[1].pricebook_external_id__c+'-'+prList[1].productCode));
            insert pbeList;  
            RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
            Account act = new Account(firstName = 'Steve', lastName = 'Smith', recordTypeId = recordType.Id, SAP_ID__c = '73218390', SFCC_Customer_Number__pc = '00012006');
            insert act;
            
            test.startTest();
            insert new opportunityLineItem(PricebookEntryId = pbeList[0].Id, Product2Id = prList[0].Id, Quantity = 3, UnitPrice = pbeList[0].UnitPrice, ServiceDate = system.Date.today(), Description = 'Pintem! Primeres paraules català/anglès', OpportunityLineItem_External_Id__c = 'ff301c9733ebe9342d422f29b2-0885094.33', Product_List_Id__c = 'ff301c9733ebe9342d422f29b2', Opportunity_Name__c = 'Abandoned Cart-ff301c9733ebe9342d422f29b2', Opportunity_Record_Type__c = 'Abandoned Cart', Opportunity_Stage__c = 'Closed Lost', Customer_Number__c = '00012006', Pricebook_Id__c = pbList[0].pricebook_external_id__c, Product_Code__c = '0885094.33', basket_id__c = '964f4eecdcfae6e674ae900598', Last_Modified__c = system.DateTime.now());
            insert new opportunityLineItem(PricebookEntryId = pbeList[1].Id, Product2Id = prList[1].Id, Quantity = 3, UnitPrice = pbeList[1].UnitPrice, ServiceDate = system.Date.today(), Description = 'Pintem! Primeres paraules català/anglès', OpportunityLineItem_External_Id__c = 'a4dc49b4ae646fc781cd3f46cd-0885094.32', Viewed_Date__c = system.Date.today(), Product_List_Id__c = 'a4dc49b4ae646fc781cd3f46cd', Opportunity_Name__c = 'Viewed Products-a4dc49b4ae646fc781cd3f46cd', Opportunity_Record_Type__c = 'Viewed Products', Opportunity_Stage__c = 'Closed Lost', Customer_Number__c = '00012006', Pricebook_Id__c = pbList[1].pricebook_external_id__c, Product_Code__c = '0885094.32', Last_Modified__c = system.DateTime.now());
            test.stopTest();
        }
    }
}