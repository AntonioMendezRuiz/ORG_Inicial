@isTest
public class GE_AgentExplorer_ControllerTest {
    @testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
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
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            
            subscription = explorerController.getSubscriber();
            Test.stopTest();
        }
        
        System.assertNotEquals(null, subscription);
        System.assertEquals(campaignSubscriptions[0].id, subscription.id);
    }
    
    @isTest 
    public static void getNullStateListCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<SelectOption> states;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            states = explorerController.getStateList();
            Test.stopTest();
        }
        
        System.assertEquals(null, states);
    }
    
    @isTest 
    public static void getStateListCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<SelectOption> states;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            states = explorerController.getStateList();
            Test.stopTest();
        }        
    }
    
    @isTest 
    public static void getNullCaseTypeListCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<SelectOption> states;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            states = explorerController.getCaseTypeList();
            Test.stopTest();
        }
        
        System.assertEquals(null, states);
    }
    
    @isTest 
    public static void getCaseTypeListCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<SelectOption> caseTypes;
        List<Case> caseCampaignSubscriptions;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            caseCampaignSubscriptions = TestDataFactory.createCaseSubscriptions(campaignSubscriptions, 'Abierto', 'Web');
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            caseTypes = explorerController.getCaseTypeList();
            Test.stopTest();
        }
        
        Schema.DescribeFieldResult fieldResult = Case.Tipo__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        
        // Assert size
        System.assertEquals(ple.size(), caseTypes.size());

        // Assert value & label
        for(Integer i = 0; i < ple.size(); i++) {
            System.assertEquals(ple[i].getValue(), caseTypes[i].getValue());
            System.assertEquals(ple[i].getLabel(), caseTypes[i].getLabel());
        }
        
    }
    
    @isTest 
    public static void getSubscriberJSONCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        SubscripcionACampana__c subscription;
        String subscriptionJSON;
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
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriptionJSON = explorerController.getSubscriberJSON();
            Test.stopTest();
        }
        // Remove attributes key to be able to cast it to Subscription
        subscriptionJSON = subscriptionJSON.replaceAll('"attributes":\\{(.*?)\\},', '');
        subscription = (SubscripcionACampana__c) JSON.deserialize(subscriptionJSON, SubscripcionACampana__c.class);
        
        
        System.assertNotEquals(null, subscription);
        System.assertEquals(campaignSubscriptions[0].id, subscription.id);
        System.assertEquals(campaignSubscriptions[0].cuenta__c, subscription.cuenta__c);
        System.assertEquals(campaignSubscriptions[0].campana__c, subscription.campana__c);
    }
    
    @isTest 
    public static void getNullSubscriberJSONCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        String subscriptionJSON;
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriptionJSON = explorerController.getSubscriberJSON();
            Test.stopTest();
        }        
        
        System.assertEquals('null', subscriptionJSON);
    }
    
    @isTest 
    public static void getAccountSubscriptionCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        Account subscriberAccount;
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
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            
            subscriberAccount = explorerController.getSubscriberAccount();
            Test.stopTest();
        }
        
        System.assertNotEquals(null, subscriberAccount);
        System.assertEquals(accounts[0].id, subscriberAccount.id);
        System.assertEquals(accounts[0].firstname, subscriberAccount.firstname);
        System.assertEquals(accounts[0].middlename, subscriberAccount.middlename);
        System.assertEquals(accounts[0].lastname, subscriberAccount.lastname);
    }
    
    @isTest 
    public static void getNullSubscriberAccountCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        Account subscriberAccount;
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriberAccount = explorerController.getSubscriberAccount();
            Test.stopTest();
        }        
        
        System.assertEquals(null, subscriberAccount);
    }
    
    @isTest 
    public static void getSubscriberAccountJSONCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        Account subscriberAccount;
        String subscriberAccountJSON;
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
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriberAccountJSON = explorerController.getSubscriberAccountJSON();
            Test.stopTest();
        }
        // Remove attributes key to be able to cast it to Subscription
        subscriberAccountJSON = subscriberAccountJSON.replaceAll('"attributes":\\{(.*?)\\},', '');
        subscriberAccount = (Account) JSON.deserialize(subscriberAccountJSON, Account.class);
        
        
        System.assertNotEquals(null, subscriberAccount);
        System.assertEquals(accounts[0].id, subscriberAccount.id);
        System.assertEquals(accounts[0].firstName, subscriberAccount.firstName);
        System.assertEquals(accounts[0].middleName, subscriberAccount.middleName);
        System.assertEquals(accounts[0].lastName, subscriberAccount.lastName);
    }
    
    @isTest 
    public static void getNullSubscriberAccountJSONCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        String subscriberAccountJSON;
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriberAccountJSON = explorerController.getSubscriberAccountJSON();
            Test.stopTest();
        }        
        
        System.assertEquals('null', subscriberAccountJSON);
    }
    
    @isTest 
    public static void getNullPrioritiesCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<SelectOption> priorities;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            priorities = explorerController.getPriorities();
            Test.stopTest();
        }
        
        System.assertEquals(null, priorities);
    }
    
        @isTest 
    public static void getPrioritiesCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        Map<Id, PrioridadDeCampana__c> campaignPrioritiesMap;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<SelectOption> priorities;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            priorities = explorerController.getPriorities();
            Test.stopTest();
        }
        campaignPrioritiesMap = new Map<Id, PrioridadDeCampana__c>(campaignPriorities);
        // Assert size
        System.assertEquals(campaignPriorities.size(), priorities.size());
        // Assert value & label
        for(Integer i = 0; i < priorities.size(); i++) {
            System.assertEquals(true, campaignPrioritiesMap.containsKey(priorities[i].getValue()));
            System.assertEquals(campaignPrioritiesMap.get(priorities[i].getValue()).id, priorities[i].getValue());
            System.assertEquals(campaignPrioritiesMap.get(priorities[i].getValue()).name, priorities[i].getLabel());
        }
    }
    
    @isTest 
    public static void getNullSubscriptionHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<HistoricoDeSubscriptor__c> historical;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            historical = explorerController.getHistorical();
            Test.stopTest();
        }
        
        System.assertEquals(null, historical);
    }
    
        @isTest 
    public static void getSubscriptionHistoricalCase() {
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
            subscriptionsHistoricals = TestDataFactory.createSubscriptionHistoricals(campaignSubscriptions, 'Otro', 1, 1);
        }
        
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriptionHistoricals = explorerController.getHistorical();
            Test.stopTest();
        }
        // Assert size
        System.assertEquals(subscriptionsHistoricals.size(), subscriptionHistoricals.size());
        
        System.assertEquals(subscriptionsHistoricals[0].id, subscriptionHistoricals[0].id);
        System.assertEquals(subscriptionsHistoricals[0].tipoDeInteraccion__c, subscriptionHistoricals[0].tipoDeInteraccion__c);
        System.assertEquals(subscriptionsHistoricals[0].FechaHoraInteraccion__c, subscriptionHistoricals[0].FechaHoraInteraccion__c);
    }
    
    @isTest 
    public static void getNullAccountHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<SubscripcionACampana__c> accountHistorical;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            accountHistorical = explorerController.getAccountHistorical();
            Test.stopTest();
        }
        
        System.assertEquals(null, accountHistorical);
    }
    
        @isTest 
    public static void getAccountHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<SubscripcionACampana__c> accountHistoricals;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            accountHistoricals = explorerController.getAccountHistorical();
            Test.stopTest();
        }
        // Assert size
        System.assertEquals(campaignSubscriptions.size(), accountHistoricals.size());
        
        System.assertEquals(campaignSubscriptions[0].id, accountHistoricals[0].id);
    }
    
    @isTest 
    public static void getNullInteractionsCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        Map<String, Integer> interactions;
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            interactions = explorerController.getInteractions();
            Test.stopTest();
        }
        
        System.assertEquals(null, interactions);
    }
    
        @isTest 
    public static void getInteractionsCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<HistoricoDeSubscriptor__c> subscriptionsHistoricals;
        Map<String, Integer> interactions;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            subscriptionsHistoricals = TestDataFactory.createSubscriptionHistoricals(campaignSubscriptions, 'Otro', 1, 1);
        }
        
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            interactions = explorerController.getInteractions();
            Test.stopTest();
        }
        
        //Retrieve Interaction types from GlobalValueSet
       	Schema.DescribeFieldResult interactionTypesFieldResult = HistoricoDeSubscriptor__c.TipoDeInteraccion__c.getDescribe();
		Schema.sObjectField interactionField = interactionTypesFieldResult.getSObjectField();
		List<PicklistEntry> entries = interactionField.getDescribe().getPicklistValues();
        
        // Assert size (Expected 1 for every type.)
        System.assertEquals(entries.size(), interactions.size());
        for(PicklistEntry entry: entries) {
            if(entry.label == 'Otro')
            	System.assertEquals(subscriptionsHistoricals.size(), interactions.get(entry.label));
            else
            	System.assertEquals(0, interactions.get(entry.label));
        }        
    }
    
    @isTest 
    public static void getNullCaseHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        List<Case> accountCases;
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            accountCases = explorerController.getAccountCaseHistorical();
            Test.stopTest();
        }
        
        // Assert size
        System.assertEquals(null, accountCases);
    }
    
    @isTest 
    public static void getCaseHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<SelectOption> caseTypes;
        List<Case> caseCampaignSubscriptions;
        List<Case> accountCases;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            caseCampaignSubscriptions = TestDataFactory.createCaseSubscriptions(campaignSubscriptions, 'Abierto', 'Web');
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            accountCases = explorerController.getAccountCaseHistorical();
            Test.stopTest();
        }
        
        // Assert size
        System.assertNotEquals(null, accountCases);
        System.assertEquals(caseCampaignSubscriptions.size(), accountCases.size());
        System.assertEquals(caseCampaignSubscriptions[0].id, accountCases[0].id);
        System.assertEquals(caseCampaignSubscriptions[0].Origin, accountCases[0].Origin);
        System.assertEquals(caseCampaignSubscriptions[0].Tipo__c, accountCases[0].Tipo__c);
        System.assertEquals(caseCampaignSubscriptions[0].Status, accountCases[0].Status);
    }
    
    @isTest 
    public static void blockSubscriberCase() {
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
            	GE_AgentExplorer_Controller.blockSubscriber(campaignSubscriptions[0]);
                pass = true;
            } catch(Exception e) {
                pass = false;
            }
            Test.stopTest();
        }
        campaignSubscriptions = [SELECT id, EnCola__c FROM SubscripcionACampana__c WHERE id = :campaignSubscriptions[0].id];
        System.assertEquals(true, pass);
        System.assertEquals(false, campaignSubscriptions[0].EnCola__c);
    }
    
    @isTest 
    public static void blockNullSubscriberCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];  
        Boolean pass;
        
        System.runAs(agentUser) {
            Test.startTest();
            try {
                GE_AgentExplorer_Controller.blockSubscriber(null);
                pass = true;
            } catch(Exception e) {
                pass = false;
            }
            Test.stopTest();
        }
        
        System.assertEquals(true, pass);
    }
    
    @isTest 
    public static void nextWithSubscriptionAndAccountCase() {
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
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {            
            Test.startTest();
        	GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            // Update subscription fields
            explorerController.subscriber.Descripcion__c = 'Test description';
            explorerController.subscriber.PrioridadDeCampana__c = campaignPriorities[4].id;
            explorerController.subscriber.CorreoDelTitularDelContrato__c = 'testtitular@test.com';
            
            // Initialize the subscriber account
            explorerController.getSubscriberAccount();
            
            // Update account fields
            explorerController.subscriberAccount.firstname = 'Jorge';
            explorerController.subscriberAccount.middlename = 'García';
            explorerController.subscriberAccount.lastname = 'López';
            explorerController.subscriberAccount.personemail = 'jgl@test.com';
            explorerController.subscriberAccount.personHomePhone = '93333333';
            explorerController.subscriberAccount.phone = '911111111';
            explorerController.subscriberAccount.personMailingStateCode = 'B';
            

            
            explorerController.next();
            accounts.add(0,explorerController.subscriberAccount);
            campaignSubscriptions.add(0,explorerController.subscriber);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        accountToAssert = [SELECT id, firstname, middlename, lastname, personemail, personHomePhone, phone, personMailingStateCode
                                FROM Account
                                WHERE id = :accounts[0].id];
        
    }
    
    @isTest 
    public static void sendEmailCase() {
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
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {            
            Test.startTest();
            for(ApexPage p: [SELECT Id, Name, MasterLabel 
                             FROM ApexPage 
                             WHERE Name 
                             LIKE 'GE_ET_%'
                             ORDER BY MasterLabel ASC]) {
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, p.id, 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
                             }
            /*GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_2', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_3', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_4', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_5', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_6', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            GE_AgentExplorer_Controller.sendEmail(campaignSubscriptions[0].id, 'GE_ET_7', 'Test', '123123123', 'testEmail@test.com', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
            */
            
            Test.stopTest();
        }        
    }
    
    @isTest 
    public static void getTemplatesCase() {
        List<SelectOption> templates;
        GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
        
        Test.startTest();
         templates = explorerController.getTemplates();
        Test.stopTest();
        
        System.assertNotEquals(0, templates.size());
    }
    
    @isTest 
    public static void getCurrentUserCase() {
        GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
        
        Test.startTest();
        explorerController.getCurrentUser();
        Test.stopTest();
    }
    
    @isTest 
    public static void cancelWithSubscriptionAndAccountCase() {
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
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
        }
        
        System.runAs(agentUser) {            
            Test.startTest();
        	GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            // Update subscription fields
            explorerController.subscriber.Descripcion__c = 'Test description';
            explorerController.subscriber.PrioridadDeCampana__c = campaignPriorities[4].id;
            explorerController.subscriber.CorreoDelTitularDelContrato__c = 'testtitular@test.com';
            
            // Initialize the subscriber account
            explorerController.getSubscriberAccount();
            
            // Update account fields
            explorerController.subscriberAccount.firstname = 'Jorge';
            explorerController.subscriberAccount.middlename = 'García';
            explorerController.subscriberAccount.lastname = 'López';
            explorerController.subscriberAccount.personemail = 'jgl@test.com';
            explorerController.subscriberAccount.personHomePhone = '93333333';
            explorerController.subscriberAccount.phone = '911111111';
            explorerController.subscriberAccount.personMailingStateCode = 'B';
            

            
            explorerController.cancel();
            accounts.add(0,explorerController.subscriberAccount);
            campaignSubscriptions.add(0,explorerController.subscriber);
            Test.stopTest();
        }
        subscriptionToAssert  = [SELECT id, descripcion__c, PrioridadDeCampana__c, CorreoDelTitularDelContrato__c
                                 FROM SubscripcionACampana__c
                                 WHERE id = :campaignSubscriptions[0].id];
        
        accountToAssert = [SELECT id, firstname, middlename, lastname, personemail, personHomePhone, phone, personMailingStateCode
                                FROM Account
                                WHERE id = :accounts[0].id];
        
    }
    
    @isTest 
    public static void getCaseCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        Case caseToAssert;
        List<Case> caseCampaignSubscriptions;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            caseCampaignSubscriptions = TestDataFactory.createCaseSubscriptions(campaignSubscriptions, 'Abierto', 'Web');
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            caseToAssert = explorerController.getSubscriberCase();
            Test.stopTest();
        }       
        
        // Assert case fields to validate a correct get.
        System.assertEquals(caseCampaignSubscriptions[0].id, caseToAssert.id);
        System.assertEquals(caseCampaignSubscriptions[0].status, caseToAssert.status);
        System.assertEquals(caseCampaignSubscriptions[0].origin, caseToAssert.origin);
    }
    
    @isTest 
    public static void getNullCaseCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        Case caseToAssert;
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            caseToAssert = explorerController.getSubscriberCase();
            Test.stopTest();
        }       
        
        // Assert case fields to validate a correct get.
        System.assertEquals(null, caseToAssert);
    }
    
    @isTest 
    public static void getCaseJSONCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        Case caseToAssert;
        String caseJSON;
        List<Case> caseCampaignSubscriptions;
        
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            caseCampaignSubscriptions = TestDataFactory.createCaseSubscriptions(campaignSubscriptions, 'Abierto', 'Web');
        }
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            caseJSON = explorerController.getSubscriberCaseJSON();
            Test.stopTest();
        }       
        
        // Remove attributes key to be able to cast it to Subscription
        caseJSON = caseJSON.replaceAll('"attributes":\\{(.*?)\\},', '');
        caseToAssert = (Case) JSON.deserialize(caseJSON, Case.class);
        
        
        // Assert case fields to validate a correct get.
        System.assertEquals(caseCampaignSubscriptions[0].id, caseToAssert.id);
        System.assertEquals(caseCampaignSubscriptions[0].status, caseToAssert.status);
        System.assertEquals(caseCampaignSubscriptions[0].origin, caseToAssert.origin);
    }
    
    @isTest 
    public static void getContractHistoricalCase() {
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1']; 
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Account> accounts;
        List<Campana__c> campaigns;
        List<Campana__Share> campaignsShare;
        List<PrioridadDeCampana__c> campaignPriorities;
        List<SubscripcionACampana__c> campaignSubscriptions;
        List<Contract> subscriptionContractsToAssert;
        List<Contract> subscriptionContracts;
            
        System.runAs(supervisorUser) {
            accounts = TestDataFactory.createPersonAccounts(1);
            campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(campaigns, agentUser);
            campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
            campaignSubscriptions = TestDataFactory.createCampaignSubscriptions(accounts, campaigns,campaignPriorities,1, 1);
            subscriptionContracts = TestDataFactory.createContracts(campaignSubscriptions);
        }
        
        
        
        System.runAs(agentUser) {
            Test.startTest();
            GE_AgentExplorer_Controller explorerController = new GE_AgentExplorer_Controller();
            subscriptionContractsToAssert = explorerController.getAccountContractHistorical();
            Test.stopTest();
        }
        
        // Assert nullness
        System.assertNotEquals(null, subscriptionContractsToAssert);
    }
}