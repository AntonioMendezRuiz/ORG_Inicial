@isTest
public class AccountHelperTest {
	@testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    
    @isTest
    public static void createSubscriptionsTest() {
		User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;

        
        campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
        campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
        campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
        
        campaigns[0].ExternalId__c = 'SUBSCRIPTIONSTEST';
        update campaigns;
        
        Test.startTest();
        accounts = TestDataFactory.createPersonAccountsToCampaign(1, 'SUBSCRIPTIONSTEST');
        insert accounts;
        Test.stopTest();

    }
    
        @isTest
    public static void deleteSubscriptionsTest() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {
            Test.startTest();
        	AccountHelper.removeSubscriptions(accounts);
            Test.stopTest();
        }
    }
    
    
        @isTest
    public static void getAccountsTest() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {
            Test.startTest();
        	AccountHelper.getAccountIdsByPersonOtherPhone(accounts);
            AccountHelper.getAccountIdsByPersonMobilePhone(accounts);
            AccountHelper.getAccountIdsByPersonHomePhone(accounts);
            AccountHelper.getAccountIdsByPersonEmail(accounts);
            Test.stopTest();
        }
    }
}