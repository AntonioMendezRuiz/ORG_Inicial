public with sharing class AccountHandler {

    private static Set<Id> processedIds;

    private Boolean isExecuting;
    private Map<String, Account> newEmailAddresses;
    private Map<String, Id> campaignIdByExternalId;

    public AccountHandler(Boolean isExecuting){
        this.isExecuting = isExecuting;
        this.newEmailAddresses = new Map<String, Account>();
        if(processedIds == null){
            processedIds = new Set<Id>();
        }  
    }

    public void onBeforeInsert(List<Account> triggerNew) {
    }

    public void onBeforeUpdate(List<Account> triggerOld , List<Account> triggerNew , Map<Id,Account> triggerOldMap , Map<Id,Account> triggerNewMap){
        if(mustBeExecuted(triggerNewMap.keySet())) {
        }
    }

    public void onBeforeDelete(List<Account> triggerOld , Map<Id,Account> triggerOldMap){
    }

    public void onAfterInsert(List<Account> triggerNew , Map<Id,Account> triggerNewMap) {
        
        for (Account account : triggerNew) {
            if (hasNewEmail(account, null)) {
                newEmailAddresses.put(account.PersonEmail, account);
            }
        }
        createCampaignMembersFromFormSubmissions();
    }

    public void onAfterUpdate(List<Account> triggerOld , List<Account> triggerNew , Map<Id,Account> triggerOldMap , Map<Id,Account> triggerNewMap){
        if(mustBeExecuted(triggerNewMap.keySet())) {
            for (Account account : triggerNew) {
                if (hasNewEmail(account, triggerOldMap.get(account.Id))) {
                    newEmailAddresses.put(account.PersonEmail, account);
                }
            }
            createCampaignMembersFromFormSubmissions();
        }
    }

    public void onAfterDelete(List<Account> triggerOld , Map<Id,Account> triggerOldMap){
    }

    public void onAfterUndelete(List<Account> triggerNew){
    }

    private Boolean mustBeExecuted(Set<Id> ids){
        if (Trigger.isBefore) {
            if (processedIds.containsAll(ids)) {
                return false;  
            } else {
                return true;
            } 
        } else {
            if (!processedIds.containsAll(ids)) {
                processedIds.addAll(ids); 
                return true;  
            } else {
                return false;
            }
        } 
    }

    public enum TriggerCont {isINSERT,isUPDATE,isDELETE,isUNDELETE}

    private Boolean hasNewEmail(Account newVersion, Account oldVersion) {
        return String.isNotBlank(newVersion.PersonEmail) && (oldVersion == null || newVersion.PersonEmail != oldVersion.PersonEmail);
    }

    private void createCampaignMembersFromFormSubmissions() {
        if (!newEmailAddresses.isEmpty()) {
            List<FormSubmission__c> unmatchedForms = getUnmatchedFormsByEmail();
            List<Database.SaveResult> insertResults = Database.insert(createNewCampaignMembers(unmatchedForms), false);
            parentSubmissionForms(insertResults, unmatchedForms);
        }
    }

    private List<FormSubmission__c> getUnmatchedFormsByEmail() {
        return [
            SELECT 
                Id, Email__c, SubscripcionACampana__c, CampaignId__c, 
                (SELECT Id, FieldName__c, FieldValue__c FROM FormSubmissionItems__r)
            FROM
                FormSubmission__c
            WHERE
                Email__c IN :newEmailAddresses.keySet()
            AND
                Email__c != null
            AND 
                SubscripcionACampana__c = null
        ];
    }

    private List<SubscripcionACampana__c> createNewCampaignMembers(List<FormSubmission__c> unmatchedForms) {
        List<SubscripcionACampana__c> newCampaignMembers = new List<SubscripcionACampana__c>();
        CampaignMemberCreator campaignMemberCreator;
        this.campaignIdByExternalId = getCampaignIdByExternalId(unmatchedForms);
        for (FormSubmission__c formSubmission : unmatchedForms) {
            campaignMemberCreator = new CampaignMemberCreator(newEmailAddresses.get(formSubmission.Email__c), formSubmission, campaignIdByExternalId.get(formSubmission.CampaignId__c));
            newCampaignMembers.add(campaignMemberCreator.generateCampaignMember());
        }
        return newCampaignMembers;
    }

    private Map<String, Id> getCampaignIdByExternalId(List<FormSubmission__c> unmatchedForms) {
        Set<String> externalIds = new Set<String>();
        for (FormSubmission__c formSubmission : unmatchedForms) {
            if (!String.isBlank(formSubmission.CampaignId__c) || formSubmission.CampaignId__c != null) {
                externalIds.add(formSubmission.CampaignId__c);
            }
        }
        Map<String, Id> campaignIdByExternalId = new Map<String, Id>();
        List<Campana__c> campaigns = new List<Campana__c>();

        campaigns.addAll([
            SELECT Id, ExternalId__c
            FROM Campana__c
            WHERE ExternalId__c IN: externalIds
        ]);
        for (Campana__c campaign : campaigns) {
            campaignIdByExternalId.put(campaign.ExternalId__c, campaign.Id);
        }
        return campaignIdByExternalId;
    }

    private void parentSubmissionForms(List<Database.SaveResult> insertResults, List<FormSubmission__c> formSubmissions) {
        List<ErrorLog__c> errors = new List<ErrorLog__c>();
        for (Integer i = 0; i < insertResults.size(); i++) {
            if (insertResults[i].isSuccess()) {
                formSubmissions[i].SubscripcionACampana__c = insertResults[i].getId();
            } else {
                errors.add(ErrorLogService.generateLogRecord(insertResults[i]));
            }
        }
        update formSubmissions;
        insert errors;
    }
}