@isTest
public class OSF_UpdateInactivePricebooks_Test {

    @TestSetup
    static void setUp(){
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        //insert a new product
        Product2 p = new product2(name='x');
        insert p;
        
        Product2 p2 = new product2(name='y');
        insert p2;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Pricebook_External_Id__c = 'Test4321',
            IsActive = true
        );
        Update standardPricebook;
        
        //define the standart price for the product
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id,unitprice=1.0, isActive=false);
        
        Pricebook2 pb = new pricebook2(name='test', Pricebook_External_Id__c = 'Test43214');
        insert pb;
        
    }
    
    @isTest
    private static void testScheduled(){
        SchedulableContext sc = null;
        OSF_UpdateInactivePricebooks_Scheduled tsc = new OSF_UpdateInactivePricebooks_Scheduled();
        tsc.execute(sc);
    }
}