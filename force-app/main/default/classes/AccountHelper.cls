public class AccountHelper {   
    public static Map<Id, Set<String>> accountsAndCampaignSubscriptions = new Map<Id, Set<String>>();
    
    public static Map<String, Id> getAccountIdsByPersonEmail(List<Account> accounts) {
        Map<String, Id> accountIdByEmail = new Map<String, Id>();
        Set<String> accountEmails = new Set<String>();
        for(Account account: accounts) {
            if(!String.isBlank(account.personEmail))
                accountEmails.add(account.personEmail);
        }
        
        for(Account account: [SELECT id, personEmail FROM account WHERE personEmail IN :accountEmails]){
            accountIdByEmail.put(account.personEmail, account.id);
        }
        return accountIdByEmail;
    }
    
    public static Map<String, Id> getAccountIdsByPersonHomePhone(List<Account> accounts) {
        Map<String, Id> accountIdByPersonHomePhone = new Map<String, Id>();
        Set<String> accountPhones = new Set<String>();
        for(Account account: accounts) {
            if(!String.isBlank(account.personHomePhone))
                accountPhones.add(account.personHomePhone);
        }
        
        for(Account account: [SELECT id, personHomePhone FROM account WHERE personHomePhone IN :accountPhones]){
            accountIdByPersonHomePhone.put(account.personHomePhone, account.id);
        }
        return accountIdByPersonHomePhone;
    }
    
    public static Map<String, Id> getAccountIdsByPersonMobilePhone(List<Account> accounts) {
        Map<String, Id> accountIdByPersonMobilePhone = new Map<String, Id>();
        Set<String> accountPhones = new Set<String>();
        for(Account account: accounts) {
            if(!String.isBlank(account.personMobilePhone))
                accountPhones.add(account.personMobilePhone);
        }
        
        for(Account account: [SELECT id, personMobilePhone FROM account WHERE personMobilePhone IN :accountPhones]){
            accountIdByPersonMobilePhone.put(account.personMobilePhone, account.id);
        }
        return accountIdByPersonMobilePhone;
    }
    
    public static Map<String, Id> getAccountIdsByPersonOtherPhone(List<Account> accounts) {
        Map<String, Id> accountIdByPersonOtherPhone = new Map<String, Id>();
        Set<String> accountPhones = new Set<String>();
        for(Account account: accounts) {
            if(!String.isBlank(account.personOtherPhone))
                accountPhones.add(account.personOtherPhone);
        }
        
        for(Account account: [SELECT id, personOtherPhone FROM account WHERE personOtherPhone IN :accountPhones]){
            accountIdByPersonOtherPhone.put(account.personOtherPhone, account.id);
        }
        return accountIdByPersonOtherPhone;
    }
    
    private static Set<String> getCampaignExternalIdsBySet(List<Account> accountList) {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Set<String> campaignExternalIds = new Set<String>();
        for(Account acc: accountList) { 
            if(acc.recordTypeId == personAccountRecordTypeId && acc.TECH_CampaignExternalId__pc <> null && acc.TECH_CampaignExternalId__pc <> '[[Unknown]]') {
                campaignExternalIds.add(acc.TECH_CampaignExternalId__pc.toUpperCase());
            }
        }
        System.debug('campaignExternalIds :: ' + campaignExternalIds);
        return campaignExternalIds;
    }
    
    public static void createSubscriptions(List<Account> accountList, Boolean clearAccountsCampaignId) {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        List<SubscripcionACampana__c> subscriptions = new List<SubscripcionACampana__c>();
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Map<String, Id>> statusByCampanaIdStatusName;
        Map<String, Campana__c> campaignByExternalId;
        Set<String> campaignExternalIds;
        Set<Id> campaignIds;
        
        Campana__c campaign;
        Account accountCopy;
        
        campaignExternalIds = getCampaignExternalIdsBySet(accountList);
        campaignByExternalId = CampanaHelper.getCampaignsByExternalId(campaignExternalIds);
        campaignIds = CampanaHelper.getCampanaIdSet(campaignExternalIds);
        statusByCampanaIdStatusName = CampanaHelper.getCampanaAvailableStatus(campaignIds);
        
        for(Account acc: accountList) { 
            
            // Last clause is using record overlap avoidment.
            if(acc.recordTypeId == personAccountRecordTypeId && acc.TECH_CampaignExternalId__pc <> null && acc.TECH_CampaignExternalId__pc <> '[[Unknown]]' && 
               campaignByExternalId.containsKey(acc.TECH_CampaignExternalId__pc.toUpperCase()) && /* Not in previous execution */
               (!accountsAndCampaignSubscriptions.containsKey(acc.id) || (accountsAndCampaignSubscriptions.containsKey(acc.id) && !accountsAndCampaignSubscriptions.get(acc.id).contains(acc.TECH_CampaignExternalId__pc.toUpperCase())))) {
                   campaign = campaignByExternalId.get(acc.TECH_CampaignExternalId__pc.toUpperCase());
                   
                   // Create subscription
                   SubscripcionACampana__c subscription = new SubscripcionACampana__c();
                   subscription.Campana__c = campaign.id;
                   subscription.Cuenta__c = acc.id;
                   
                   // Rellenar campos subscripción con contenido campos TECH
                   subscription.PrioridadIndividual__c = 0;
                   subscription.Potencia__c = acc.TECH_power__pc;
                   subscription.CompaniaActualGas__c = acc.TECH_currentGasCompany__pc;
                   subscription.CompaniaActualLuz__c = acc.TECH_currentElectricalCompany__pc;
                   subscription.Tramo__c = acc.TECH_Lot__pc;
                   subscription.PermanenciaGas__c = acc.TECH_gasPermanence__pc;
                   subscription.CUPSGas__c = acc.TECH_gasCUPS__pc;
                   subscription.PermanenciaLuz__c = acc.TECH_electricityPermanence__pc;
                   subscription.CUPSLuz__c = acc.TECH_electricityCUPS__pc;
                   subscription.PrioridadDeCampana__c = statusByCampanaIdStatusName.get(campaign.id).get('NUEVO');
                   
                   subscriptions.add(subscription);
                   
                   // PATCH START
                   // This code portion is to avoid duplicates on Before Update / After Insert execution overlap.
                   // Excludes subscriptions by account/campaign external id per execution
                   
                   if(Trigger.isExecuting) {
                       if(!accountsAndCampaignSubscriptions.containsKey(acc.id))
                           accountsAndCampaignSubscriptions.put(acc.id, new Set<String>());
                       
                       campaignExternalIds = accountsAndCampaignSubscriptions.get(acc.id);
                       campaignExternalIds.add(acc.TECH_CampaignExternalId__pc.toUpperCase());
                   }
                   
                   // PATCH END
                   
                   // Update account ExternalId field
                   accountCopy = new Account();
                   accountCopy.id = acc.id;
                   accountCopy.TECH_CampaignExternalId__pc = '[[Unknown]]';
                   if(!Test.isRunningTest()) accountsToUpdate.add(accountCopy);
               }
        }
        
        if(!Test.isRunningTest()) insert subscriptions;
        
        if(clearAccountsCampaignId && !Test.isRunningTest()) update accountsToUpdate;
    }
    
    public static void removeSubscriptions(List<Account> accountList) {
        Set<Id> accountIds = new Set<Id>();
        List<SubscripcionACampana__c> subscriptions;
        
        for(Account account: accountList) {
            accountIds.add(account.id);
        }
        
        subscriptions = [SELECT Id 
                         FROM SubscripcionACampana__c 
                         WHERE Cuenta__c IN :accountIds];
        
        delete subscriptions;
    }
}