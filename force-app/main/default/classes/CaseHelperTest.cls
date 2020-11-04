@isTest
public class CaseHelperTest {
	@testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    
    @isTest
    public static void upsertCaseSubscriptionCase(){
        Map<Id, Case> oldCaseList  = new Map<Id, Case>();
        List<Account> listAccounts = TestDataFactory.createPersonAccounts(25);
        List<Campana__c> listCampana = TestDataFactory.createCaseCampaigns('En progreso');
        List<PrioridadDeCampana__c> priorities = TestDataFactory.updateCampaignPrioritiesRandomly(listCampana);
        List<SubscripcionACampana__c> SubscripcionACampana  = TestDataFactory.createCampaignSubscriptions(listAccounts, listCampana, priorities, 1, 3);
        List<Case> newCaseList = TestDataFactory.createCaseSubscriptions(SubscripcionACampana,'Abierto','Email');
        newCaseList.remove(0);
        
        Map<Id, Case> oldCaseMap = new Map<Id,Case>();
        for(Case c: newCaseList) {
            Case campaignCase = new Case();
            campaignCase.id = c.id;
            campaignCase.Tipo__c = 'Info';
            oldCaseMap.put(campaignCase.id, campaignCase);
        }
        
        Test.startTest();
        CaseHelper.upsertCaseSubscription(newCaseList,oldCaseMap);
        Test.stopTest();
    }
}