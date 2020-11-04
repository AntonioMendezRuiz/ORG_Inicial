@isTest
public class EmailMessageTest {
   @TestSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    @isTest 
    public static void assignCaseTypeCase(){
        List<Campana__c> campaings = TestDataFactory.createCampaigns('Lead', 1, 'En progreso'); 
        List<EmailMessage> emails = TestDataFactory.createEmailMessageAndCases();

        Test.startTest();
        EmailMessageHelper.assignCaseType(emails);
        delete emails;
        undelete emails;
        Test.stopTest();
    }
}