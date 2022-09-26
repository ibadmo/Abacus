@isTest
public class OSF_UpdateAccountKPIs_Scheduled_Test {
	
    @testSetup
    static void setup(){
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);  
    }
    
    @isTest
    private static void testScheduled(){
        SchedulableContext sc = null;
        OSF_UpdateAccountKPIs_Scheduled tsc = new OSF_UpdateAccountKPIs_Scheduled();
        tsc.execute(sc);
    }
}