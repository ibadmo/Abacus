public without sharing class osf_Cart_TriggerHandler {
    @TestVisible private static Boolean isEnabled = true;
    
    public static void doAfterUpdate(Map<Id, ccrz__E_Cart__c> newMap, Map<Id, ccrz__E_Cart__c> oldMap) {
        if(!isEnabled) {
            return;
        }
        createCartForUserWithNoActiveCart(newMap.values());
    }

    public static void doAfterDelete(List<ccrz__E_Cart__c> oldList) {
        if(!isEnabled) {
            return;
        }
        createCartForUserWithNoActiveCart(oldList);
    }

    private static void createCartForUserWithNoActiveCart(List<ccrz__E_Cart__c> cartList) {
        Set<String> userIdSet = fetchUsersWithoutActiveCart(cartList);
        if(!userIdSet.isEmpty()) {
            createCartsForUsers(userIdSet);
        }
    }

    private static Set<String> fetchUsersWithoutActiveCart(List<ccrz__E_Cart__c> cartList) {
        Set<String> userIdSet = new Set<String> ();
        Set<String> userWithCartSet = new Set<String> ();
        for(ccrz__E_Cart__c cart : cartList) {
            if(!cart.ccrz__AnonymousId__c) {
                userIdSet.add(cart.OwnerId);
            }
        }
        for(ccrz__E_Cart__c cart : [SELECT Id, OwnerId FROM ccrz__E_Cart__c WHERE ccrz__ActiveCart__c = true AND ccrz__CartStatus__c = :osf_constant_strings.CART_STATUS_OPEN AND ccrz__CartType__c = :osf_constant_strings.CART_TYPE_CART AND OwnerId IN :userIdSet]) {
            userWithCartSet.add(cart.OwnerId);
        }
        userIdSet.removeAll(userWithCartSet);
        return userIdSet;
    }

    private static void createCartsForUsers(Set<String> userIdSet) {
        List<ccrz__E_Cart__c> cartList = new List<ccrz__E_Cart__c> ();
        List<User> userList = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id IN :userIdSet];
        if(userList.isEmpty()) {
            return;
        }
        List<ccrz__E_Cart__c> cartListToActivate = new List<ccrz__E_Cart__c> ();
        Map<Id, ccrz__E_Cart__c> mapUserIdCarts = osf_CartSharingHelper.getEmptyOpenCarts(userIdSet);
        for(User user : userList) {
            if (mapUserIdCarts.containsKey(user.Id)) {
                cartListToActivate.add(mapUserIdCarts.get(user.Id));
            } else {
                cartList.add(new ccrz__E_Cart__c(
                    ccrz__ActiveCart__c = true,
                    ccrz__CartStatus__c = osf_constant_strings.CART_STATUS_OPEN,
                    ccrz__Storefront__c = osf_constant_strings.DEFAULT_STORE,
                    ccrz__Name__c = osf_constant_strings.NEW_CART,
                    ccrz__CartType__c = osf_constant_strings.CART_TYPE_CART,
                    ccrz__CurrencyISOCode__c = osf_constant_strings.CURRENCY_EUR,
                    ccrz__User__c = user.Id,
                    OwnerId = user.Id,
                    ccrz__Contact__c = user.ContactId,
                    ccrz__Account__c = user.Contact.AccountId
                ));
            }
        }
        if(!cartList.isEmpty()) {
            insert cartList;
        }
        for (ccrz__E_Cart__c cart : cartListToActivate) {
            cart.ccrz__ActiveCart__c = true;
        }
        if (!cartListToActivate.isEmpty()) {
            update cartListToActivate;
        }
    }


}