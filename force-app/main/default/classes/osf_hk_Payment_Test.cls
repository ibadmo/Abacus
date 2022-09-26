@IsTest
public class osf_hk_Payment_Test {
    @IsTest
    public static void getApplicablePaymentMethodsReturnsBasedOnAccountsValidPaymentTypes(){
        SetupData setup = new SetupData();
        setup.createAccountUserContact('Credit Card;No Payment');

        Map<String, Object> result;
        System.runAs(setup.User){
            osf_hk_Payment payment = new osf_hk_Payment();
            result = payment.getApplicablePaymentTypes(new Map<String, Object>());
        }

        System.assertNotEquals(null, result);
        String paymentResult = (String)result.get(ccrz.cc_hk_Payment.PARAM_APPL_PAYMENT_TYPES);
        System.assertEquals('cc,np', paymentResult);
    }

    @IsTest
    public static void getApplicablePaymentTypesReturnsEmptyIfNoneSpecifiedAtAccount(){
        SetupData setup = new SetupData();
        setup.createAccountUserContact(null);

        Map<String, Object> result;
        System.runAs(setup.User){
            osf_hk_Payment payment = new osf_hk_Payment();
            result = payment.getApplicablePaymentTypes(new Map<String, Object>());
        }

        System.assertNotEquals(null, result);
        String paymentResult = (String)result.get(ccrz.cc_hk_Payment.PARAM_APPL_PAYMENT_TYPES);
        System.assert(String.isEmpty(paymentResult));
    }

    private class SetupData{
        private Account Account;
        private Contact Contact;
        private User User;

        private void createAccountUserContact(String validPaymentTypes){
            Account = new Account(
                Name = 'TestAccount',
                osf_validPaymentTypes__c = validPaymentTypes
            );
            insert account;
            Contact = osf_testUtility.createContact('First', 'Last', account, 'test@test.com');
            insert contact;
            User = osf_testUtility.createCommunityUser(contact);
            insert user;
        }
    }
}