@isTest
public class GE_AgentExplorer_QueueTest {
	@testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    
    @isTest 
    public static void getNullSubscriptionCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        SubscripcionACampana__c subscription;
        
        System.runAs(agentUser) {
            Test.startTest();
        	subscription = GE_AgentExplorer_Queue.getSubscription();
            Test.stopTest();
        }
        System.assertEquals(null, subscription);
    }
    
    @isTest 
    public static void getSingleSubscriptionCase() {
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
        	subscription = GE_AgentExplorer_Queue.getSubscription();
            Test.stopTest();
        }
        
        System.assertNotEquals(null, subscription);
        System.assertEquals(campaignSubscriptions[0].id, subscription.id);
    }
    
    @isTest 
    public static void getMultipleSubscriptionCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        SubscripcionACampana__c highestSubscription;
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
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,5, 5);
        }
        
        System.runAs(agentUser) {
            highestSubscription = [SELECT id
                				   FROM SubscripcionACampana__c
                                   WHERE Convertido__c = false AND EnCola__c = true AND 
                                         Campana__r.Estado__c = 'En progreso' 
                                   ORDER BY FechaHoraAplazamiento__c DESC NULLS LAST, PrioridadTotal__c DESC NULLS LAST, PrioridadDeLaCampana__c DESC NULLS LAST, CreatedDate ASC LIMIT 1];
            Test.startTest();
        	subscription = GE_AgentExplorer_Queue.getSubscription();
            Test.stopTest();
        }
    }
    
    @isTest 
    public static void blockSubscriptionCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<PrioridadDeCampana__c> campaignPriorities;
        Boolean pass;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            try {
                GE_AgentExplorer_Queue.blockSubscription(campaignSubscriptions[0]);
                pass = true;
            } catch(Exception e) {
                pass = false;
            }
            Test.stopTest();
        }
        
        System.assertEquals(true, pass);
    }
    
    @isTest 
    public static void blockNullSubscriptionCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];  
        Boolean pass;
        
        System.runAs(agentUser) {
            Test.startTest();
            try {
                GE_AgentExplorer_Queue.blockSubscription(null);
                GE_AgentExplorer_Queue.blockSubscription(new SubscripcionACampana__c());
                pass = true;
            } catch(Exception e) {
                pass = false;
            }
            Test.stopTest();
        }
        
        System.assertEquals(true, pass);
    }
    
    @isTest 
    public static void setSubscriptionWithSubscriptionAndAccountCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscriptionToAssert;
        Account accountToAssert;
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
            campaignPriorities[4].Name = 'Aplazado';
            update campaignPriorities;
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {
            // Update account fields
            accounts[0].firstname = 'Jorge';
            accounts[0].middlename = 'García';
            accounts[0].lastname = 'López';
            accounts[0].personemail = 'jgl@test.com';
            accounts[0].personHomePhone = '93333333';
            accounts[0].phone = '911111111';
            
            // Update subscription fields
            campaignSubscriptions[0].Descripcion__c = 'Test description';
            campaignSubscriptions[0].PrioridadDeCampana__c = campaignPriorities[4].id;
            campaignSubscriptions[0].CorreoDelTitularDelContrato__c = 'testtitular@test.com';
            
            Test.startTest();
        	GE_AgentExplorer_Queue.setSubscription(accounts[0], campaignSubscriptions[0], null);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        accountToAssert = [SELECT id, firstname, middlename, lastname, personemail, personHomePhone, phone, personMailingState
                                FROM Account
                                WHERE id = :accounts[0].id];
        
        // Assert subscription fields to validate the update.
        System.assertEquals(campaignSubscriptions[0].id, subscriptionToAssert.id);
        System.assertEquals(campaignSubscriptions[0].descripcion__c, subscriptionToAssert.descripcion__c);
        System.assertEquals(campaignSubscriptions[0].PrioridadDeCampana__c, subscriptionToAssert.PrioridadDeCampana__c);
        System.assertEquals(campaignSubscriptions[0].CorreoDelTitularDelContrato__c, subscriptionToAssert.CorreoDelTitularDelContrato__c);
        
        // Assert account fields to validate the update.
        System.assertEquals(accounts[0].id, accountToAssert.id);
        System.assertEquals(accounts[0].firstname, accountToAssert.firstname);
        System.assertEquals(accounts[0].middlename, accountToAssert.middlename);
        System.assertEquals(accounts[0].lastname, accountToAssert.lastname);
    }
    
    @isTest 
    public static void setSubscriptionWithSubscriptionAndCaseCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscriptionToAssert;
        Case caseToAssert;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<Case> caseCampaignSubscriptions;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Caso', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignPriorities[4].Name = 'Aplazado';
            update campaignPriorities;
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            caseCampaignSubscriptions = TestDataFactory.createCaseSubscriptions(campaignSubscriptions, 'Abierto', 'Web');
        }
        
        System.runAs(agentUser) {            
            // Update subscription fields
            campaignSubscriptions[0].Descripcion__c = 'Test description';
            campaignSubscriptions[0].PrioridadDeCampana__c = campaignPriorities[4].id;
            campaignSubscriptions[0].CorreoDelTitularDelContrato__c = 'testtitular@test.com';
            
            // Update case fields
            caseCampaignSubscriptions[0].Status = 'Cerrado';
            
            Test.startTest();
        	GE_AgentExplorer_Queue.setSubscription(null, campaignSubscriptions[0], caseCampaignSubscriptions[0]);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        caseToAssert = [SELECT id, Status
                        FROM Case
                        WHERE id = :caseCampaignSubscriptions[0].id];
        
        // Assert subscription fields to validate the update.
        System.assertEquals(campaignSubscriptions[0].id, subscriptionToAssert.id);
        System.assertEquals(campaignSubscriptions[0].descripcion__c, subscriptionToAssert.descripcion__c);
        System.assertEquals(campaignSubscriptions[0].PrioridadDeCampana__c, subscriptionToAssert.PrioridadDeCampana__c);
        System.assertEquals(campaignSubscriptions[0].CorreoDelTitularDelContrato__c, subscriptionToAssert.CorreoDelTitularDelContrato__c);
        
        // Assert case fields to validate the update.
        System.assertEquals(caseCampaignSubscriptions[0].status, caseToAssert.status);
    }
    
    @isTest 
    public static void setSubscriptionAsClosedLostCase() {
		User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscriptionToAssert;
        List<Contract> contractsToAssert;
        Account accountToAssert;
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
            
            // Update campaign priority to as closed lost.
            campaignPriorities[4].Cerrado__c = true;
            campaignPriorities[4].Contrata__c = false;
            campaignPriorities[4].Name = 'Aplazado';
            update campaignPriorities;
        }
        
        System.runAs(agentUser) {            
            // Update subscription priority field
            campaignSubscriptions[0].PrioridadDeCampana__c = campaignPriorities[4].id;
            campaignSubscriptions[0].CorreoDelTitularDelContrato__c = 'setsubscriptionasclosedlostcase@test.com';
            update campaignSubscriptions;
            
            Test.startTest();
        	GE_AgentExplorer_Queue.setSubscription(accounts[0], campaignSubscriptions[0], null);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, cuenta__c, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        // Assert subscription fields to validate the update.
        System.assertEquals(campaignSubscriptions[0].id, subscriptionToAssert.id);
        System.assertEquals(campaignSubscriptions[0].PrioridadDeCampana__c, subscriptionToAssert.PrioridadDeCampana__c);
        System.assertEquals(campaignSubscriptions[0].CorreoDelTitularDelContrato__c, subscriptionToAssert.CorreoDelTitularDelContrato__c);
        
        // Assert account fields to validate the update.
        contractsToAssert = [SELECT id, AccountId, CorreoDelTitularDelContrato__c 
                            FROM Contract
                            WHERE CorreoDelTitularDelContrato__c = 'setSubscriptionAsClosedLostCase@test.com'];
        System.assertEquals(0, contractsToAssert.size());
    }
    
    
    
    @isTest 
    public static void setSubscriptionAsClosedWonCase() {
		User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscriptionToAssert;
        List<Contract> contractsToAssert;
        Account accountToAssert;
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
            
            // Update campaign priority to as closed lost.
            campaignPriorities[4].Cerrado__c = true;
            campaignPriorities[4].Contrata__c = true;
            campaignPriorities[4].Name = 'Aplazado';
            update campaignPriorities;
        }
        
        System.runAs(agentUser) {            
            // Update subscription priority field
            campaignSubscriptions[0].PrioridadDeCampana__c = campaignPriorities[4].id;
            campaignSubscriptions[0].CorreoDelTitularDelContrato__c = 'setsubscriptionasclosedlostcase@test.com';
            update campaignSubscriptions;
            
            Test.startTest();
        	GE_AgentExplorer_Queue.setSubscription(accounts[0], campaignSubscriptions[0], null);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, cuenta__c, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        // Assert subscription fields to validate the update.
        System.assertEquals(campaignSubscriptions[0].id, subscriptionToAssert.id);
        System.assertEquals(campaignSubscriptions[0].PrioridadDeCampana__c, subscriptionToAssert.PrioridadDeCampana__c);
        System.assertEquals(campaignSubscriptions[0].CorreoDelTitularDelContrato__c, subscriptionToAssert.CorreoDelTitularDelContrato__c);
        
        // Assert account fields to validate the update.
        contractsToAssert = [SELECT id, AccountId, CorreoDelTitularDelContrato__c 
                            FROM Contract
                            WHERE CorreoDelTitularDelContrato__c = 'setsubscriptionasclosedlostcase@test.com'];
        
        System.assertEquals(1, contractsToAssert.size());
    }
}