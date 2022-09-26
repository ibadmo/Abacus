/**
* File:        OSF_OpportunityProduct_Handler.cls
* Project:     ABACUS
* Date:        May 30, 2021
* Created By:  Ali Ozdemir
* *************************************************************************
* Description:  Opportunity Product trigger handler to create parent 
* Opportunities
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
public class OSF_OpportunityProduct_Handler {
    
    /**
* @author Ali Ozdemir
* @date May 30, 2021
* @name populateExternalId
* @description popoulate account external id field
* @param  List<Account>
* @return void
*/
    public static void processLineItems(List<OpportunityLineItem> olisList) {
        try {
            Map<String, List<String>> idsMap = new Map<String, List<String>>(); 
            List<String> tempIdsList = new List<String>();
            for(OpportunityLineItem oli : olisList) {
                if(!idsMap.containsKey('Opportunity')) {
                    tempIdsList = new List<String>{'\''+oli.Product_List_Id__c+'\''};     
                        idsMap.put('Opportunity', tempIdsList);               
                } else {
                    tempIdsList = idsMap.get('Opportunity');
                    if(!tempIdsList.contains('\''+oli.Product_List_Id__c+'\'')) {
                        tempIdsList.add('\''+oli.Product_List_Id__c+'\'');
                        idsMap.put('Opportunity', tempIdsList);
                    } 
                }                
                if(!idsMap.containsKey('Account')) {
                    tempIdsList = new List<String>{'\''+oli.Customer_Number__c+'\''};
                        idsMap.put('Account', tempIdsList);                    
                } else {
                    tempIdsList = idsMap.get('Account');
                    if(!tempIdsList.contains('\''+oli.Customer_Number__c+'\'')) {
                        tempIdsList.add('\''+oli.Customer_Number__c+'\'');
                        idsMap.put('Account', tempIdsList);
                    } 
                }
                if(!idsMap.containsKey('RecordType')) {
                    tempIdsList = new List<String>{oli.Opportunity_Record_Type__c}; 
                        idsMap.put('RecordType', tempIdsList);                   
                } else {
                    tempIdsList = idsMap.get('RecordType');
                    if(!tempIdsList.contains(oli.Opportunity_Record_Type__c)) {
                        tempIdsList.add(oli.Opportunity_Record_Type__c);
                        idsMap.put('RecordType', tempIdsList);
                    } 
                }
                if(!idsMap.containsKey('Product2')) {
                    tempIdsList = new List<String>{'\''+oli.Product_Code__c+'\''}; 
                        idsMap.put('Product2', tempIdsList);                   
                } else {
                    tempIdsList = idsMap.get('Product2');
                    if(!tempIdsList.contains('\''+oli.Product_Code__c+'\'')) {
                        tempIdsList.add('\''+oli.Product_Code__c+'\'');
                        idsMap.put('Product2', tempIdsList);
                    } 
                }
                if(!idsMap.containsKey('PricebookEntry')) {
                    tempIdsList = new List<String>{'\''+oli.Pricebook_Id__c+'-'+oli.Product_Code__c+'\''}; 
                        idsMap.put('PricebookEntry', tempIdsList);                   
                } else {
                    tempIdsList = idsMap.get('PricebookEntry');
                    if(!tempIdsList.contains('\''+oli.Pricebook_Id__c+'-'+oli.Product_Code__c+'\'')) {
                        tempIdsList.add('\''+oli.Pricebook_Id__c+'-'+oli.Product_Code__c+'\'');
                        idsMap.put('PricebookEntry', tempIdsList);
                    } 
                }
            }
            List<Opportunity> listToUpsert = new List<Opportunity>();
            Map<String, Opportunity> existingOpportunities = new Map<String, Opportunity>();
            existingOpportunities = getExistingOpportunitiesMap(idsMap.get('Opportunity'), existingOpportunities);
            Map<String, Account> customersMap = new Map<String, Account>();
            customersMap = getAccountsMap(idsMap.get('Account'), customersMap);
            Map<String, RecordType> rtsMap = new Map<String, RecordType>();
            rtsMap = getRtsMap(idsMap.get('RecordType'), rtsMap);
            Map<String, Product2> prodsMap = new Map<String, Product2>();
            prodsMap = getProductsMap(idsMap.get('Product2'), prodsMap);
            Map<String, PricebookEntry> pbesMap = new Map<String, PricebookEntry>();
            pbesMap = getPricebookEntrisMap(idsMap.get('PricebookEntry'), pbesMap);
            Id abRT = getAbandonedCartRecordTypeId('Abandoned Cart');
            Id vpRT = getAbandonedCartRecordTypeId('Viewed Products'); 
            for(OpportunityLineItem oli : olisList) {
                if(existingOpportunities.containsKey(oli.Product_List_Id__c)) {
                    oli.OpportunityId = existingOpportunities.get(oli.Product_List_Id__c).Id;
                } else {              
                    System.debug('AO -- customersMap '+customersMap);
                    System.debug('AO -- rtsMap '+rtsMap);
                    Pricebook2 pb = new Pricebook2(pricebook_external_id__c = oli.Pricebook_Id__c);
                    Opportunity opp;
                    List<String> oppName = oli.Opportunity_Name__c.split('-');
                    
                    if(customersMap.containsKey(oli.Customer_Number__c)) {
                        if(abRT == rtsMap.get(oli.Opportunity_Record_Type__c).Id) {
                            
                            //System.debug('AO -- get(oli.Customer_Number__c) '+customersMap.containsKey(oli.Customer_Number__c));
                            opp = new Opportunity(ProductList_ID__c = oli.Product_List_Id__c,Basket_ID__c = oli.basket_id__c, Name = oppName[0], 
                                                  AccountId = customersMap.get(oli.Customer_Number__c).Id,
                                                  RecordTypeId = rtsMap.get(oli.Opportunity_Record_Type__c).Id, 
                                                  StageName = oli.Opportunity_Stage__c,
                                                  CloseDate = oli.ServiceDate,
                                                  Creation_Date__c = oli.ServiceDate,
                                                  Last_Modified__c = oli.Last_Modified__c,
                                                  Pricebook2 = pb,
                                                  Abandoned_Cart_Recovery_Link__c=oli.Abandoned_Cart_Recovery_Link__c);
                                
                        } else if(vpRT == rtsMap.get(oli.Opportunity_Record_Type__c).Id) {
                            //system.debug('oli:'+oli);
                            opp = new Opportunity(ProductList_ID__c = oli.Product_List_Id__c, Name = oppName[0], 
                                                  AccountId = customersMap.get(oli.Customer_Number__c).Id,
                                                  RecordTypeId = rtsMap.get(oli.Opportunity_Record_Type__c).Id, 
                                                  StageName = oli.Opportunity_Stage__c,
                                                  CloseDate = oli.ServiceDate,
                                                  Creation_Date__c = oli.ServiceDate,
                                                  Last_Modified__c = oli.Last_Modified__c,
                                                  Pricebook2 = pb);
                        }
                    }
                    if(!listToUpsert.contains(opp)  && opp != null) {
                        listToUpsert.add(opp);
                    }
                }
                system.debug('pbesMap.containsKey'+oli.Pricebook_Id__c+'-'+oli.Product_Code__c);
                if(pbesMap.containsKey(oli.Pricebook_Id__c+'-'+oli.Product_Code__c)) { 
                    oli.PricebookEntryId = pbesMap.get(oli.Pricebook_Id__c+'-'+oli.Product_Code__c).Id;
                    oli.UnitPrice = pbesMap.get(oli.Pricebook_Id__c+'-'+oli.Product_Code__c).UnitPrice;
                    //oli.TotalPrice = pbesMap.get(oli.Pricebook_Id__c+'-'+oli.Product_Code__c).UnitPrice * oli.Quantity;
                }
                // oli.Product2Id = prodsMap.get(oli.Product_Code__c).Id;
                System.debug('AO -- oli '+oli);
                System.debug('AO -- pbesMap '+pbesMap);

            }
            if(!listToUpsert.isEmpty()) {
                Database.insert(listToUpsert);
                System.debug('AO -- listToUpsert '+listToUpsert);
                existingOpportunities = getExistingOpportunitiesMap(idsMap.get('Opportunity'), existingOpportunities);
                System.debug('AO -- existingOpportunities '+existingOpportunities);
                for(OpportunityLineItem oli : olisList) {
                    if(existingOpportunities.containsKey(oli.Product_List_Id__c)) {
                        oli.OpportunityId = existingOpportunities.get(oli.Product_List_Id__c).Id;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error '+e.getMessage());
        }
    }
    public static Id getAbandonedCartRecordTypeId(string name)
    {
        
        return [SELECT Id, Name, SobjectType, IsActive FROM RecordType where SobjectType = 'Opportunity' and Name=:name].Id;
    }
    private static Map<String, Opportunity> getExistingOpportunitiesMap(List<String> idsList, Map<String, Opportunity> returnMap) { 
        List<Opportunity> oppsList = Database.query(parseQuery(idsList, new List<String> {'Id, ProductList_ID__c'}, 'Opportunity', 'ProductList_ID__c'));
        for(Opportunity opp : oppsList) {
            returnMap.put(opp.ProductList_ID__c, opp);
        }
        return returnMap;
    }
    
    private static Map<String, Account> getAccountsMap(List<String> idsList, Map<String, Account> returnMap) { 
        List<Account> accList = Database.query(parseQuery(idsList, new List<String> {'Id, SFCC_Customer_Number__pc'}, 'Account', 'SFCC_Customer_Number__pc'));
        for(Account acc : accList) {
            returnMap.put(acc.SFCC_Customer_Number__pc, acc);
        }
        return returnMap;
    }
    
    private static Map<String, RecordType> getRtsMap(List<String> idsList, Map<String, RecordType> returnMap) { 
        List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE Name IN :idsList];
        for(RecordType rt : rts) {
            returnMap.put(rt.Name, rt);
        }
        return returnMap;
    }
    
    private static Map<String, Product2> getProductsMap(List<String> idsList, Map<String, Product2> returnMap) { 
        List<Product2> prodList = Database.query(parseQuery(idsList, new List<String> {'Id, OSF_External_Prod_Id__c'}, 'Product2', 'OSF_External_Prod_Id__c'));
        for(Product2 prod : prodList) {
            returnMap.put(prod.OSF_External_Prod_Id__c, prod);
        }
        return returnMap;
    }
    
    private static Map<String, PricebookEntry> getPricebookEntrisMap(List<String> idsList, Map<String, PricebookEntry> returnMap) { 
        List<PricebookEntry> pbeList = Database.query(parseQuery(idsList, new List<String> {'Id, OSF_External_PBE_ID__c,UnitPrice'}, 'PricebookEntry', 'OSF_External_PBE_ID__c'));
        for(PricebookEntry pbe : pbeList) {
            returnMap.put(pbe.OSF_External_PBE_ID__c, pbe);
        }
        return returnMap;
    }
    
    private static String parseQuery(List<String> idsList, List<String> fields, String objectType, String queryField) {
        return 'SELECT '+String.join(fields, ',')+' FROM '+objectType+' WHERE '+queryField+' IN ('+String.join(idsList, ',')+')';
    }
}