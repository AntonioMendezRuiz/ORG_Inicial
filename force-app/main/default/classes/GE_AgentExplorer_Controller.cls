public with sharing class GE_AgentExplorer_Controller {    
    @testVisible private SubscripcionACampana__c  					subscriber;
    @testVisible private Account					  				subscriberAccount;
    @testVisible private Case						  				subscriberCase;
    
    transient public  User											currentUser;
    transient private List<HistoricoDeSubscriptor__c> 				historical;
    transient private List<SubscripcionACampana__c> 				accountHistorical;
    transient private List<Case> 									accountCaseHistorical;
    transient private List<Contract> 								accountContractHistorical;
    transient private Map<String, Integer> 							interactions;
    
    transient public List<SelectOption> 							templates;
    transient private List<SelectOption> 							priorities;
    transient private List<SelectOption>							stateList;
    transient private List<SelectOption>							caseTypeList;

    public GE_AgentExplorer_controller () {
        this.subscriber = GE_AgentExplorer_Queue.getSubscription();    
    }
    
    public User getCurrentUser() {
        if(this.currentUser == null) {
            this.currentUser = [SELECT id, name 
                                FROM User 
                                WHERE id = :UserInfo.getUserId()];
        }
        
        return this.currentUser;
    }
    
    public String getCurrentUserJSON() {
        return JSON.serialize(getCurrentUser());
    }
    
    
    public List<SelectOption> getTemplates() {
        if(this.templates == null) {
            this.templates = new List<SelectOption>(); 
            
            for(ApexPage p: [SELECT Id, Name, MasterLabel 
                             FROM ApexPage 
                             WHERE Name 
                             LIKE 'GE_ET_%'
                             ORDER BY MasterLabel ASC]) {
                this.templates.add(new SelectOption(p.id, p.MasterLabel));
            }
        }
        return this.templates;
    }
    
    public List<SelectOption> getStateList() {
        if(this.stateList == null && this.subscriber != null) {
            this.stateList = new List<SelectOption>();            
            Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe(); 
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
            this.stateList.add(new SelectOption('', ''));
            for( Schema.PicklistEntry f : ple) { 
                this.stateList.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            
        }
        return this.stateList;
    }
    
    public List<SelectOption> getCaseTypeList() {
        if(this.caseTypeList == null && this.subscriber != null && this.subscriber.caso__c != null) {
            this.caseTypeList = new List<SelectOption>();            
            Schema.DescribeFieldResult fieldResult = Case.Tipo__c.getDescribe(); 
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
            
            for( Schema.PicklistEntry f : ple) { 
                this.caseTypeList.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            
        }
        return this.caseTypeList;
    }
    
    public SubscripcionACampana__c getSubscriber() {
        return this.subscriber;
    }
    
    public String getSubscriberJSON() {
        return JSON.serialize(getSubscriber());
    }
    
    public Account getSubscriberAccount() {
       HistoricoDeSubscriptor__c historicalToInsert;
       if(this.subscriber <> null && this.subscriberAccount == null) {
           this.subscriberAccount = new Account();
           this.subscriberAccount.id = this.subscriber.cuenta__c;
           this.subscriberAccount.firstname = this.subscriber.cuenta__r.firstname;
           this.subscriberAccount.middlename = this.subscriber.cuenta__r.middlename;
           this.subscriberAccount.lastname = this.subscriber.cuenta__r.lastname;
           this.subscriberAccount.personEmail = this.subscriber.cuenta__r.personEmail;
           this.subscriberAccount.PersonHomePhone = this.subscriber.cuenta__r.PersonHomePhone;
           this.subscriberAccount.PersonMobilePhone = this.subscriber.Cuenta__r.PersonMobilePhone;
           this.subscriberAccount.PersonMailingStateCode = this.subscriber.Cuenta__r.PersonMailingStateCode;
            /*
            User u = [SELECT id, extension__c FROM User WHERE id = :UserInfo.getUserId()];
        	if(this.subscriber.cuenta__r.personmobilephone <> null){
                CTI3CX.call(Integer.valueOf(this.subscriber.cuenta__r.personmobilephone), Integer.valueOf(u.extension__c));
            	historicalToInsert = new HistoricoDeSubscriptor__c();
                historicalToInsert.SubscripcionACampana__c = this.subscriber.id;
                historicalToInsert.FechaHoraInteraccion__c = Datetime.now();
                historicalToInsert.TipoDeInteraccion__c = 'Llamada';
                insert historicalToInsert;   
            }*/
       }
       return this.subscriberAccount;
    }
    
        
    @RemoteAction 
    public static SendEmailDTO sendEmail(String subscriberId, Id emailTemplateId, String name, String lastname, String email, 
                                         String personPhone, String personHomePhone, String personState, String campaign, 
                                         String postponePersonField, String postponeDatetimeField, String nonEngagedReasonField, 
                                         String invalidReasonField, String holderEmail, String electricalCompanySelect, 
                                         String otherElectricalCompany, String electricalCUPS, String electricalPower, 
                                         String electricalPermanence, String otherGasCompany, String gasCUPS, String gasCompanySelect, 
                                         String gasLot, String gasPermanence) {
                                             
        HistoricoDeSubscriptor__c historicalToInsert;
        PageReference template;
        String subject;
        Boolean valid = true;
        SendEmailDTO emailDTO = new SendEmailDTO();
        
        List<ApexPage> emailTemplate = [SELECT Id, Name, MasterLabel FROM ApexPage WHERE id = :emailTemplateId LIMIT 1];
        
        if(!emailTemplate.isEmpty()) {
            template = new PageReference('/apex/'+emailTemplate[0].name); 
            subject = emailTemplate[0].masterLabel;
            
            
            if(!String.isBlank(name)) template.getParameters().put('name', name);
            if(!String.isBlank(lastname)) template.getParameters().put('lastname', lastname);
            if(!String.isBlank(email)) template.getParameters().put('email', email);
            if(!String.isBlank(personPhone)) template.getParameters().put('personPhone', personPhone);
            if(!String.isBlank(personHomePhone)) template.getParameters().put('personHomePhone', personHomePhone);
            if(!String.isBlank(personState)) template.getParameters().put('personState', personState);
            if(!String.isBlank(campaign)) template.getParameters().put('campaign', campaign);
            if(!String.isBlank(postponePersonField)) template.getParameters().put('postponePersonField', postponePersonField);
            if(!String.isBlank(postponeDatetimeField)) template.getParameters().put('postponeDatetimeField', postponeDatetimeField);
            if(!String.isBlank(nonEngagedReasonField)) template.getParameters().put('nonEngagedReasonField', nonEngagedReasonField);
            if(!String.isBlank(invalidReasonField)) template.getParameters().put('invalidReasonField', invalidReasonField);
            if(!String.isBlank(holderEmail)) template.getParameters().put('holderEmail', holderEmail);
            if(!String.isBlank(electricalCompanySelect)) template.getParameters().put('electricalCompanySelect', electricalCompanySelect);
            if(!String.isBlank(otherElectricalCompany)) template.getParameters().put('otherElectricalCompany', otherElectricalCompany);
            if(!String.isBlank(electricalCUPS)) template.getParameters().put('electricalCUPS', electricalCUPS);
            if(!String.isBlank(electricalPower)) template.getParameters().put('electricalPower', electricalPower);
            if(!String.isBlank(electricalPermanence)) template.getParameters().put('electricalPermanence', electricalPermanence);
            if(!String.isBlank(otherGasCompany)) template.getParameters().put('otherGasCompany', otherGasCompany);
            if(!String.isBlank(gasCUPS)) template.getParameters().put('gasCUPS', gasCUPS);
            if(!String.isBlank(gasCompanySelect)) template.getParameters().put('gasCompanySelect', gasCompanySelect);
            if(!String.isBlank(gasLot)) template.getParameters().put('gasLot', gasLot);
            if(!String.isBlank(gasPermanence)) template.getParameters().put('gasPermanence', gasPermanence);
            
        } else {
            valid = false;
        }
        /*
        switch on emailTemplate {
            when 'GE_template1' {
                template = Page.GE_template1;
                subject = 'Información sobre la empresa';
            }
            when 'GE_template2' {
                template = Page.GE_template2;
                subject = 'Solicitud de datos para realizar el contrato';
            }
            when 'GE_template3' {
                template = Page.GE_template3;
                subject = 'No te hemos podido localizar';
            }
            when 'GE_template4' {
                template = Page.GE_template4;
                subject = 'Solicitud de factura para estudio/comparativa';
            }
            when 'GE_template5' {
                template = Page.GE_template5;
                subject = 'Cambio de domiciliación bancaria';
            }
            when 'GE_template6' {
                template = Page.GE_template6;
                subject = 'Cambio de titular';
            }
            when 'GE_template7' {
                template = Page.GE_template7;
                subject = 'Confirmar precio y conformidad del cambio de potencia';
            }
            when else {
                valid = false;
            }
        }
        */
        if(valid) {
            historicalToInsert = new HistoricoDeSubscriptor__c();
            historicalToInsert.SubscripcionACampana__c = subscriberId;
            historicalToInsert.FechaHoraInteraccion__c = Datetime.now();
            historicalToInsert.TipoDeInteraccion__c = 'Email';
            historicalToInsert.ResultadoInteraccion__c = 'Enviado';        
            
            emailDTO.subject = subject;
            if(!Test.isRunningTest()) emailDTO.body = template.getContent().toString().unescapeHtml4().substringAfter('<div id="emailTemplate">').substringBefore('</div>');
            System.debug(emailDTO.body);
            emailDTO.emailTo = email;
            
            insert historicalToInsert;
        }
        
        
        return emailDTO;
    }
    
    @RemoteAction 
    public static void performCall(String subscriberId, String phoneNumber){
        System.debug('subscriberId :: ' + subscriberId);
        System.debug('phoneNumber :: ' + phoneNumber);
        User u = [SELECT id, extension__c FROM User WHERE id = :UserInfo.getUserId()];
        HistoricoDeSubscriptor__c historicalToInsert;
        
        if(!String.isEmpty(phoneNumber)) {
            CTI3CX.call(Integer.valueOf(phoneNumber), Integer.valueOf(u.extension__c));
            historicalToInsert = new HistoricoDeSubscriptor__c();
            historicalToInsert.SubscripcionACampana__c = subscriberId;
            historicalToInsert.FechaHoraInteraccion__c = Datetime.now();
            historicalToInsert.TipoDeInteraccion__c = 'Llamada';
            insert historicalToInsert;        
        }
    }
    
    public String getSubscriberAccountJSON() {
        return JSON.serialize(getSubscriberAccount());
    }
    
    public List<SelectOption> getPriorities() {
        if(this.priorities == null && this.subscriber != null) {
           this.priorities = new List<SelectOption>();
            
           for(PrioridadDeCampana__c priority: SubscripcionACampanaHelper.getSubscriptionAvailablePrioritiesById(this.subscriber).values()) {
				this.priorities.add(new SelectOption(priority.id, priority.name));                                   
           }
    	}
        return this.priorities;
    }
    public List<HistoricoDeSubscriptor__c> getHistorical() {
        if(this.historical == null && this.subscriber != null) {
           this.historical = [SELECT id, TipoDeInteraccion__c, FechaHoraInteraccion__c 
                         FROM HistoricoDeSubscriptor__c 
                         WHERE SubscripcionACampana__c =: this.subscriber.id 
                         ORDER BY FechaHoraInteraccion__c DESC];
        }
        return this.historical;
    }
    
    public List<SubscripcionACampana__c> getAccountHistorical() {
        if(this.accountHistorical == null && this.subscriber != null) {
           this.accountHistorical = [SELECT LastModifiedDate, Campana__r.Name, PrioridadDeCampana__r.Name, MotivoDePerdida__c
                         FROM SubscripcionACampana__c 
                         WHERE Cuenta__c =: this.subscriber.Cuenta__c 
                         ORDER BY LastModifiedDate DESC];
        }
        return this.accountHistorical;
    }
    
    public Map<String, Integer> getInteractions() {
        if(this.interactions == null && this.subscriber != null) {
           	this.interactions = new Map<String, Integer>();
            
           	//Retrieve Interaction types from GlobalValueSet
       	   	Schema.DescribeFieldResult interactionTypesFieldResult = HistoricoDeSubscriptor__c.TipoDeInteraccion__c.getDescribe();
		   	Schema.sObjectField interactionField = interactionTypesFieldResult.getSObjectField();
			List<PicklistEntry> entries = interactionField.getDescribe().getPicklistValues();
            
            for(PicklistEntry entry: entries) {
                this.interactions.put(entry.label, 0);
            }
            
           	for(AggregateResult ar: [SELECT TipoDeInteraccion__c, COUNT(id) Total 
                            		 FROM HistoricoDeSubscriptor__c 
                            		 WHERE SubscripcionACampana__c =: this.subscriber.id 
                            		 GROUP BY TipoDeInteraccion__c 
                                     ORDER BY TipoDeInteraccion__c]) {
            	this.interactions.put(String.valueOf(ar.get('TipoDeInteraccion__c')), Integer.valueOf(ar.get('Total')));             
            }
        }
        return this.interactions;
    }
    
    public List<Case> getAccountCaseHistorical() {
        if(this.accountCaseHistorical == null && this.subscriber != null) {
            this.accountCaseHistorical =  [SELECT id, CaseNumber, Origin, Tipo__c, CreatedDate, ClosedDate, Status, Subject, Description
                                      FROM Case 
                                      WHERE accountId = :this.subscriber.Cuenta__c
                                      Order By ClosedDate DESC];
        }
        return this.accountCaseHistorical;
    }
    
    public List<Contract> getAccountContractHistorical() {
        if(this.accountContractHistorical == null && this.subscriber != null) {
            this.accountContractHistorical =  [SELECT Id, StartDate, EndDate, AccountId 
                                               FROM Contract
                                               WHERE AccountID = :this.subscriber.Cuenta__c];
        }
        return this.accountContractHistorical;
    }
    
    public Case getSubscriberCase() {
        if(this.subscriberCase == null && this.subscriber != null && this.subscriber.Caso__c != null) {
            this.subscriberCase = [SELECT id, CaseNumber, Origin, Tipo__c, CreatedDate, ClosedDate, Status, Subject, Description
                                   FROM Case 
                                   WHERE id = :this.subscriber.Caso__c];
        }
        return this.subscriberCase;
    }
    
    public String getSubscriberCaseJSON() {
        return JSON.serialize(getSubscriberCase());
    }
    
    private void increaseNextCounterPerUser() {
    	Id userId = UserInfo.getUserId();
        Date today = Date.today();
        List<UserActivityLog__c> userActivityLogs = [SELECT id, NextClicks__c 
                                                     FROM UserActivityLog__c 
                                                     WHERE CreatedById = : userId AND CreatedDate = TODAY];
        
        UserActivityLog__c userActivityLog = userActivityLogs.isEmpty() ? new UserActivityLog__c() : userActivityLogs[0];
        
        userActivityLog.NextClicks__c = (userActivityLog.NextClicks__c == 0 || userActivityLog.NextClicks__c == null) ? 
            							1 : userActivityLog.NextClicks__c + 1;
        
        upsert userActivityLog;
    }
    
    public PageReference next() {
        PageReference nextPage;
        try {
            GE_AgentExplorer_Queue.setSubscription(this.subscriberAccount, this.subscriber, this.subscriberCase);
            increaseNextCounterPerUser();
        	nextPage = Page.GE_AgentExplorer;
        	nextPage.setRedirect(true);
        } catch(Exception e) {
            ApexPages.addMessages(e);
			nextPage = null;
        }
		return nextPage;
    }
    
    @RemoteAction 
    public static void blockSubscriber(SubscripcionACampana__c subscription){
    	GE_AgentExplorer_Queue.blockSubscription(subscription);
    }
    
    public PageReference cancel() {
        PageReference startPage;
        try {
        	startPage = Page.GE_AgentExplorer_Landing;
        	GE_AgentExplorer_Queue.setSubscription(this.subscriberAccount, this.subscriber, this.subscriberCase); 
        } catch(Exception e) {
            ApexPages.addMessages(e);
			startPage = null;
        }
        return startPage;
    }
    
    public class SendEmailDTO {
        public String emailTo;
        public String subject;
        public string body;
    }
}