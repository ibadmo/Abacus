public class OSF_TruncateUtilityClass {
    public static void truncateOrderFields(Map<String, String> truncationMap, list<Sobject> sObjList, Integer truncateLength, List<String> fieldsToTruncate) {
        for(Sobject o: sObjList) {
            for(String f : fieldsToTruncate) {
                if(o.get(f) != null && String.valueOf(o.get(f)).length() > truncateLength) {
                    TruncationMap.put(o.Id + '-' + f, String.valueOf(o.get(f)));
                }
            }
        }
        
        for(Sobject o : sObjList) {
            for(String f : fieldsToTruncate) {
                system.debug(f+':::::'+TruncationMap.get(o.Id + '-' + f));
                system.debug('truncateLength'+truncateLength);
                if(TruncationMap.get(o.Id + '-' + f)!=null) {
                    o.put(f, TruncationMap.get(o.Id + '-' + f).left(truncateLength));
                } else {
                    if(f == 'Shipping_Address_Text__c' && TruncationMap.get(o.Id + '-' + f)!=null) {
                        o.put('ShippingCity', TruncationMap.get(o.Id + '-' + f).left(truncateLength));
                    } else if(f == 'Billing_Address_Text__c' && TruncationMap.get(o.Id + '-' + f)!=null) {
                        o.put('BillingCity', TruncationMap.get(o.Id + '-' + f).left(truncateLength));
                    }
                }
            }
        }
    }
}