@isTest
public class TestDataFactory {
    public static void createTestData() {
        User supervisor = createSupervisorUser('Supervisor');
        User testUser1 = createAgentUser('TestUser1');
        User testUser2 = createAgentUser('TestUser2');
        createAutomationParameters();
        System.runAs(supervisor) {

            List<Account> accounts = createPersonAccounts(25);
            List<Campana__c> campaignsUser1 = createCampaigns('Lead', 2, 'Planificada');
            List<Campana__Share> campaignsShareUser1 = shareCampaignsWithUser(campaignsUser1, testUser1);
            List<Campana__c> campaignsUser2 = createCampaigns('Lead', 2, 'Planificada');
            List<Campana__Share> campaignsShareUser2 = shareCampaignsWithUser(campaignsUser2, testUser2);
            
            List<Campana__c> caseCampaignsUser1 = createCampaigns('Caso', 2, 'Planificada');
            List<Campana__Share> caseCampaignsShareUser1 = shareCampaignsWithUser(caseCampaignsUser1, testUser1);
            
            List<Campana__c> campaignsFromBothUsers = new List<Campana__c>();
            campaignsFromBothUsers.addAll(campaignsUser1);
            campaignsFromBothUsers.addAll(campaignsUser2);
            
            List<PrioridadDeCampana__c> campaignPriorities = updateCampaignPrioritiesRandomly(campaignsFromBothUsers);
            List<SubscripcionACampana__c> campaignSubscriptions = createCampaignSubscriptions(accounts, campaignsFromBothUsers,
                                                                      						  campaignPriorities,
                                                                      						  1, 3);
            List<HistoricoDeSubscriptor__c> subscriptionsHistoricals = createSubscriptionHistoricals(campaignSubscriptions, 'Otro', 1, 1);
            List<PrioridadDeCampana__c> caseCampaignPriorities = updateCampaignPrioritiesRandomly(caseCampaignsUser1);
            List<SubscripcionACampana__c> caseCampaignSubscriptions = createCampaignSubscriptions(accounts, caseCampaignsUser1,
                                                                      						  	  caseCampaignPriorities,
                                                                      						      1, 3);
            
            List<Case> caseSubscriptions = createCaseSubscriptions(caseCampaignSubscriptions, 'Abierto', 'Web');
            List<Contract> subscriptionContracts = createContracts(campaignSubscriptions);
        }
    }
    
    public static List<Campana__Share> shareCampaignsWithUser(List<Campana__c> campaignsId, User user) {
        List<Campana__Share> campaignShares = new List<Campana__Share>();
        Campana__Share share;
        for(Campana__c campana: campaignsId) {
            share = new Campana__Share();
            share.parentId = campana.id;
            share.UserOrGroupId = user.id;
            share.accessLevel = 'edit';
            share.RowCause = 'Manual';
            campaignShares.add(share);
        }
        insert campaignShares;
        return campaignShares;
    }
    
    public static User createSupervisorUser(String lastname) {
        Profile supervisorProfile = [SELECT id 
                                FROM profile
                                WHERE name = 'Supervisor' LIMIT 1];
        User usr = new User(
            Alias = lastname.left(3), 
            Email= lastname + '@supervisoruser.com', 
            EmailEncodingKey='UTF-8', 
            LastName= lastname,
            LanguageLocaleKey='en_US', 
            LocaleSidKey='es_ES', 
            ProfileId = supervisorProfile.Id, 
            TimeZoneSidKey='Europe/Paris', 
            UserName=lastname+'@supervisoruser.com');
            
        insert usr;
        return usr;
    }
    
    public static List<CampaignMember> createCampaignmembers(List<Contact> contacts, Campaign campaign) {
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        CampaignMember campaignMember;
        
        for(Contact contact: contacts) {
            campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.id;
            campaignMember.contactId = contact.id;
            campaignMembers.add(campaignMember);
        }
        
        insert campaignMembers;
        return campaignMembers;
    }
    
    public static User createAgentUser(String lastname) {
        Profile agentProfile = [SELECT id 
                                FROM profile
                                WHERE name = 'Agente' LIMIT 1];
        User usr = new User(
            Alias = lastname.left(3), 
            Email= lastname + '@agentuser.com', 
            EmailEncodingKey='UTF-8', 
            LastName= lastname,
            LanguageLocaleKey='en_US', 
            LocaleSidKey='es_ES', 
            ProfileId = agentProfile.Id, 
            TimeZoneSidKey='Europe/Paris', 
            UserName=lastname+'@agentuser.com');
            
        insert usr;
        return usr;
    }
    
    public static List<Account> createPersonAccounts(Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        Account tmpAccount;
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        for(Integer i = 0; i < numberOfAccounts; i++) {
            Integer random = Integer.valueof((Math.random() * 568394));
            tmpAccount = new Account();
            tmpAccount.recordTypeId = personAccountRecordTypeId;
            tmpAccount.lastname = 'Test account ' + random;
            tmpAccount.personemail = 'testaccount'+random+'@testaccount.com';
            tmpAccount.Phone = String.valueOf(random);
            tmpAccount.PersonHomePhone = String.valueOf(random);
            accounts.add(tmpAccount);
        }
        
        insert accounts;
        return accounts;
    }
    
    public static List<Account> createPersonAccountsToCampaign(Integer numberOfAccounts, String externalCampaignId) {
        List<Account> accounts = new List<Account>();
        Account tmpAccount;
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        for(Integer i = 0; i < numberOfAccounts; i++) {
            Integer random = Integer.valueof((Math.random() * 568394));
            tmpAccount = new Account();
            tmpAccount.recordTypeId = personAccountRecordTypeId;
            tmpAccount.lastname = 'Test account ' + random;
            tmpAccount.personemail = 'testaccount'+random+'@testaccount.com';
            tmpAccount.Phone = String.valueOf(random);
            tmpAccount.PersonHomePhone = String.valueOf(random);
            tmpAccount.TECH_CampaignExternalId__pc = externalCampaignId;
            accounts.add(tmpAccount);
        }
        
        return accounts;
    }
    
    public static List<Campana__c> createCampaigns(String campaignType, Integer numberOfCampaigns, String campaignStatus) {
        List<Campana__c> campaigns = new List<Campana__c>();
        Campana__c tmpCampaign;
        
        for(Integer i = 0; i < numberOfCampaigns; i++) {
            tmpCampaign = new Campana__c();
			tmpCampaign.name = 'Test Campaign ' + 1;
            tmpCampaign.Tipo__c = campaignType;
            if(tmpCampaign.Tipo__c=='Caso')tmpCampaign.TipoDeCaso__c='Clientes';
            tmpCampaign.Estado__c = campaignStatus;
            tmpCampaign.PrioridadDeCapana__c = Math.floor(Math.random() * 200);
            campaigns.add(tmpCampaign);
        }
        
        insert campaigns;
        return campaigns;
    }

    public static List<Campana__c> createCaseCampaigns(String campaignStatus) {
        List<Campana__c> campaigns = new List<Campana__c>();
        Campana__c tmpCampaign;
        List<String> caseTypes = new List<String>{'Clientes','Facturación','Incidencias','Info'};
        
        for(Integer i = 0; i < caseTypes.size(); i++) {
            tmpCampaign = new Campana__c();
			tmpCampaign.name = 'Test Campaign ' + 1;
            tmpCampaign.Tipo__c = 'Caso';
            tmpCampaign.TipoDeCaso__c = caseTypes[i];
            tmpCampaign.Estado__c = campaignStatus;
            tmpCampaign.PrioridadDeCapana__c = Math.floor(Math.random() * 200);
            campaigns.add(tmpCampaign);
        }
        
        insert campaigns;
        return campaigns;
    }
    public static AutomationParameters__c createAutomationParameters(){
        AutomationParameters__c setting = new AutomationParameters__c();
        setting.SetupOwnerId = [SELECT  Id FROM Organization].id;
        setting.ETCClientesEmail__c = 'clientes@email.com';
        setting.ETCFacturacionEmail__c='facturacion@email.com';
        setting.ETCIncidenciasEmail__c='incidencias@email.com';
        setting.ETCInfoEmail__c='info@email.com';
        setting.FailedCallsUnreachable__c = 7;
        insert setting;
        return setting;
    }

    public static List<EmailMessage> createEmailMessageAndCases(){
        List<EmailMessage> emails = new List<EmailMessage>();
        EmailMessage email;
        List<String> emailTypes= new List<String>{PAD.automationParameters.ETCInfoEmail__c.toUpperCase(),
            PAD.automationParameters.ETCIncidenciasEmail__c.toUpperCase(),
            PAD.automationParameters.ETCFacturacionEmail__c.toUpperCase(),
            PAD.automationParameters.ETCClientesEmail__c.toUpperCase(),
            'test@test.com'
        };

        for(Integer i = 0; i < emailTypes.size(); i++){
            Case c = new Case();
            c.Subject = 'Om Test';  
            c.Status ='New';
            c.Priority = 'Medium';
            c.Origin = 'Email';
            insert c;

            email = new EmailMessage();
            email.FromAddress = 'test@test.com';
            email.Incoming = True;
            email.ToAddress= emailTypes[i];
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = c.Id; 
            emails.add(email);
        }
         
        insert emails;
        return emails;
    }
    
    public static List<PrioridadDeCampana__c> updateCampaignPrioritiesRandomly(List<Campana__c> campaigns) {
        List<PrioridadDeCampana__c> priorities;
        Set<Id> campaignIds = new Set<Id>();
        
        for(Campana__c campaign: campaigns) {
            campaignIds.add(campaign.id);
        }
        priorities = [SELECT id, name, cerrado__c, contrata__c, puntuacion__c, campana__c
                      FROM PrioridadDeCampana__c
                      WHERE campana__c IN :campaignIds];
        for(PrioridadDeCampana__c priority: priorities){
            priority.cerrado__c = priority.name.containsIgnoreCase('CONTRATA');
            priority.contrata__c = priority.name.containsIgnoreCase('SÍ CONTRATA') || 
                				   priority.name.containsIgnoreCase('SI CONTRATA');
            priority.Puntuacion__c = priority.cerrado__c ? 0 : Math.floor(Math.random() * (400 - 150)) + 150;
        }
        
        update priorities;
        return priorities;
    }
    
    public static List<SubscripcionACampana__c> createCampaignSubscriptions(List<Account> accounts, List<Campana__c> campaigns,
                                                                            List<PrioridadDeCampana__c> campaignPriorities,
                                                                            Integer minimumSubsriptionsPerCampaign, 
                                                                            Integer maximumSubscriptionsPerCampaign) {
                                                                                
        List<SubscripcionACampana__c> subscriptions = new List<SubscripcionACampana__c>();
        Map<Id, Map<String, PrioridadDeCampana__c>> campaignPrioritiesByCampaignAndName = new Map<Id, Map<String, PrioridadDeCampana__c>>();
        Map<String, PrioridadDeCampana__c> campaignPrioritiesByName;                                                                        
        List<Id> accountIds = new List<Id>();
        Set<Id> unavailableAccountIds;
        SubscripcionACampana__c subscription;
        Integer numberOfSubscriptions;
        Integer accountIndex;                
        
       	for(Account account: accounts) {
       		accountIds.add(account.id);
        }
                                                                                
        for(PrioridadDeCampana__c priority: campaignPriorities) {
        	if(!campaignPrioritiesByCampaignAndName.containsKey(priority.campana__c))
                campaignPrioritiesByCampaignAndName.put(priority.campana__c, new Map<String, PrioridadDeCampana__c>());
            campaignPrioritiesByName = campaignPrioritiesByCampaignAndName.get(priority.campana__c);
            campaignPrioritiesByName.put(priority.name.toUpperCase(), priority);
        }
                                                                                
        for(Campana__c campaign: campaigns) {
            numberOfSubscriptions = Integer.valueOf(Math.floor(Math.random() * (maximumSubscriptionsPerCampaign - minimumSubsriptionsPerCampaign))
                                                    + minimumSubsriptionsPerCampaign);
            unavailableAccountIds = new Set<Id>();
            for(Integer i = 0; i < numberOfSubscriptions; i++) {
                subscription = new SubscripcionACampana__c();
                
                // Assign random 'Non previously assigned' account
                do {
                	accountIndex = Integer.valueOf(Math.floor(Math.random() * (accountIds.size() - 1)));   
                } while(unavailableAccountIds.contains(accountIds.get(accountIndex)));
                
                subscription.Cuenta__c = accountIds.get(accountIndex);
                subscription.Campana__c = campaign.id;
                subscription.PrioridadIndividual__c = Math.floor(Math.random() * (400 - 150)) + 150;
                subscription.CorreoDelTitularDelContrato__c = 'test'+Math.floor(Math.random() * (400 - 150)) + 150+'@test.com';
                if(campaignPrioritiesByCampaignAndName.containsKey(campaign.id) && campaignPrioritiesByCampaignAndName.get(campaign.id).containsKey('NUEVO'))
                	subscription.prioridadDeCampana__c = campaignPrioritiesByCampaignAndName.get(campaign.id).get('NUEVO').id;
                subscriptions.add(subscription);
            }
        }
        insert subscriptions;
        return subscriptions;
    }
    
    
    public static List<Case> createCaseSubscriptions(List<SubscripcionACampana__c> campaignSubscriptions, String caseStatus, String caseOrigin) {
		List<Case> caseSubscriptions = new List<Case>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Case> casesByAccountId = new Map<Id, Case>();
        Case caseSubscription;
        
        for(SubscripcionACampana__c subscription: campaignSubscriptions) {
            if(subscription.Cuenta__c <> null) 
                accountIds.add(subscription.Cuenta__c);
        }
        
        for(Id accountId: accountIds) {
            caseSubscription = new Case();
            
            caseSubscription.AccountId = accountId;
            caseSubscription.Status = caseStatus;
            caseSubscription.Origin = caseOrigin;
            if(caseOrigin=='Email')caseSubscription.Tipo__c = 'Clientes';
            caseSubscriptions.add(caseSubscription);
        }
        
        insert caseSubscriptions;
        for(Case caseSubscriptionTmp: caseSubscriptions){
            casesByAccountId.put(caseSubscriptionTmp.accountid, caseSubscriptionTmp);
        }
        
        for(SubscripcionACampana__c subscription: campaignSubscriptions) {
            if(subscription.Cuenta__c <> null && casesByAccountId.containsKey(subscription.Cuenta__c))
                subscription.Caso__c = casesByAccountId.get(subscription.Cuenta__c).id;
        }
        
        // link cases to subscriptions
        Database.update(campaignSubscriptions, false);
        
        return caseSubscriptions;
    }
    
    public static List<HistoricoDeSubscriptor__c> createSubscriptionHistoricals(List<SubscripcionACampana__c> campaignSubscriptions, 
                                                                                String interactionType,
                                                                                Integer minimumHistoricalsPerSubscription, 
                                                                                Integer maximumHistoricalsPerSubscription) {
		List<HistoricoDeSubscriptor__c> subscriptionHistoricals = new List<HistoricoDeSubscriptor__c>();
        HistoricoDeSubscriptor__c historicalEntry;
        Integer numberOfHistoricalEntries;
                                                                                    
        for(SubscripcionACampana__c campaignSubscription: campaignSubscriptions) {
            numberOfHistoricalEntries = Integer.valueOf(Math.floor(Math.random() * (maximumHistoricalsPerSubscription - minimumHistoricalsPerSubscription))
                                                    + minimumHistoricalsPerSubscription);
            for(Integer i = 0; i<numberOfHistoricalEntries; i++) {
                historicalEntry = new HistoricoDeSubscriptor__c();
                historicalEntry.FechaHoraInteraccion__c = Datetime.now();
                historicalEntry.TipoDeInteraccion__c = interactionType;
                if(historicalEntry.TipoDeInteraccion__c == 'Llamada'){historicalEntry.ResultadoInteraccion__c = 'No contesta';}
                historicalEntry.SubscripcionACampana__c = campaignSubscription.id;
            	subscriptionHistoricals.add(historicalEntry);
            }
        }
                                                                                    
        insert subscriptionHistoricals;
        return subscriptionHistoricals;
    }
    
    public static List<Contract> createContracts(List<SubscripcionACampana__c> subscriptions) {
        List<Contract> contracts = new List<Contract>();
        Contract subscriberContract;
        for(SubscripcionACampana__c subscription: subscriptions) {
            subscriberContract = new Contract();
        	subscriberContract.accountId = subscription.Cuenta__c;
        	subscriberContract.Status = 'Draft';
        	subscriberContract.StartDate = Date.today();
        	subscriberContract.ContractTerm = 12;
        	subscriberContract.CorreoDelTitularDelContrato__c = subscription.CorreoDelTitularDelContrato__c;
            contracts.add(subscriberContract);
        }
        
        
        insert contracts;
        return contracts;
    }
}