/**
 * File:        OSF_ProductTrigger_Handler.cls
 * Project:     ABACUS
 * Date:        May 3, 2021
 * Created By:  Ali Ozdemir
 * *************************************************************************
 * Description:  Product trigger handler to create standard pricebooks on 
 * historical data import
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
public class OSF_ProductTrigger_Handler  {

    /**
     * @author Ali Ozdemir
     * @date November 9, 2020
     * @name populateExternalId
     * @description popoulate account external id field
     * @param  List<Account>
     * @return void
     */
    public static void createStandardPricebookEntries(List<Product2> products) {
        try {
            List<PricebookEntry> pbeToUpsert = new List<PricebookEntry>();
            Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            system.debug('products'+products);
            for(Product2 prod : products) {      
                if(prod.Source_Absis__c != null && prod.Source_Absis__c) {
                    pbeToUpsert.add(new PricebookEntry(Pricebook2Id = pb.Id,
                                                       Product2Id = prod.Id,
                                                       IsActive = true,
                                                       UnitPrice = 0,
                                                       OSF_External_PBE_ID__c = 'standard-prices-'+prod.ProductCode));
                }
            }
            System.debug('ErpbeToUpsertror '+pbeToUpsert);
            if(!pbeToUpsert.isEmpty()) {
            	Database.upsert(pbeToUpsert, PricebookEntry.Fields.OSF_External_PBE_ID__c, false);
            }
        } catch (Exception e) {
            System.debug('Error '+e.getMessage());
        }
    }
}