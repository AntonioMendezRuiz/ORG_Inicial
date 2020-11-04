@isTest
public class HistoricoDeSubscriptorTest {
    @testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }

    @isTest
    public static void HistoricoDeSubscriptorTriggerHelperCase(){
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<HistoricoDeSubscriptor__c> subscriptionsHistoricals;
        List<HistoricoDeSubscriptor__c> subscriptionHistoricals;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            subscriptionsHistoricals = TestDataFactory.createSubscriptionHistoricals(campaignSubscriptions, 'Llamada', 8, 8);
        }
        
        
        delete subscriptionsHistoricals;
        undelete subscriptionsHistoricals;
            
        
    }
    @isTest
    public static void TestDMLOperations(){
        Test.startTest();
        HistoricoDeSubscriptorTriggerDispatcher.beforeUpdate();
        HistoricoDeSubscriptorTriggerDispatcher.beforeDelete();
        HistoricoDeSubscriptorTriggerDispatcher.afterUpdate();
        HistoricoDeSubscriptorTriggerDispatcher.afterDelete();
        HistoricoDeSubscriptorTriggerDispatcher.afterUndelete();
        Test.stopTest();
    }
}