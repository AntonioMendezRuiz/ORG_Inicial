@isTest
public class CaseTriggerTest {
    @testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    @isTest
    public static void checkTriggerDMLCase(){
        Map<Id, Case> oldCaseList  = new Map<Id, Case>();
        List<Account> listAccounts = TestDataFactory.createPersonAccounts(25);
        List<Campana__c> listCampana = TestDataFactory.createCampaigns('Caso', 1, 'En progreso');
        List<PrioridadDeCampana__c> priorities = TestDataFactory.updateCampaignPrioritiesRandomly(listCampana);
        List<SubscripcionACampana__c> SubscripcionACampana  = TestDataFactory.createCampaignSubscriptions(listAccounts, listCampana, priorities, 1, 3);
        Test.startTest();
        List<Case> newCaseList = TestDataFactory.createCaseSubscriptions(SubscripcionACampana,'Clientes','Email');
        delete newCaseList;
        undelete newCaseList;
        Test.stopTest();
        
    }
}