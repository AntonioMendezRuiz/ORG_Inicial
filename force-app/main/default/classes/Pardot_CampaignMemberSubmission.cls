@RestResource(urlMapping='/pardot/campaign-members')
global without sharing class Pardot_CampaignMemberSubmission {

    private static final String PARDOT_FIELD_NAME_EMAIL = 'email';
    private static final String PARDOT_FIELD_NAME_CAMPAIGN = 'Campaign_External_Id';

    @HttpPost
    global static void postFormSubmission() {
        try {
            FormSubmissionCreator formCreator = new FormSubmissionCreator(
                (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString())
            );
            formCreator.createForm();
            if (formCreator.findAccountsByPersonContactEmail()) {
                try {
                    formCreator.createCampaignMember();
                } catch(Exception e) {
                    ErrorLogService.logError(e);
                }
            }
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(formCreator.items));
        } catch(Exception e) {

            ErrorLogService.logError(e);
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    private class FormSubmissionCreator {

        private Map<String, Object> untypedForm;
        private FormSubmission__c formSubmission;
        private List<FormSubmissionItem__c> items;
        private Account account;
        private Id campaignId;

        private FormSubmissionCreator(Map<String, Object> untypedForm) {
            this.untypedForm = untypedForm;
            this.items = new List<FormSubmissionItem__c>();
        }

        private void createForm() {
            this.formSubmission = createFormSubmissionRecord();
            createFormSubmissionItems();
            this.campaignId = findCampaignByExternalId();
        }

        private FormSubmission__c createFormSubmissionRecord() {
            system.debug(String.valueOf(untypedForm.get(PARDOT_FIELD_NAME_CAMPAIGN)));
            FormSubmission__c formSubmission = new FormSubmission__c(
                Email__c = String.valueOf(untypedForm.get(PARDOT_FIELD_NAME_EMAIL)),
                CampaignId__c =  String.valueOf(untypedForm.get(PARDOT_FIELD_NAME_CAMPAIGN))
            );
            insert formSubmission;
            return formSubmission;    
        }

        private void createFormSubmissionItems() {
            for (String fieldName : untypedForm.keySet()) {
                this.items.add(new FormSubmissionItem__c(
                    FormSubmission__c = this.formSubmission.Id,
                    FieldName__c = fieldName,
                    FieldValue__c = String.valueOf(untypedForm.get(fieldName))
                ));
            }
            insert this.items;
        }

        private Boolean findAccountsByPersonContactEmail() {
            List<Account> accounts = [SELECT Id FROM Account WHERE PersonEmail = :formSubmission.Email__c
                    AND PersonEmail != null LIMIT 1];
            if (!accounts.isEmpty()) {
                this.account = accounts[0];
            }
            return this.account != null;
        }

        private Id findCampaignByExternalId(){
            system.debug(this.formSubmission.CampaignId__c);
            if (this.formSubmission.CampaignId__c == null || this.formSubmission.CampaignId__c == '' || String.isBlank(this.formSubmission.CampaignId__c)) {
                return null;
            }else{
                system.debug(this.formSubmission.CampaignId__c);
                return [SELECT Id FROM Campana__c WHERE ExternalId__c =:this.formSubmission.CampaignId__c].Id;
            }
        }

        private void createCampaignMember() {

            CampaignMemberCreator campaignMemberCreator = new CampaignMemberCreator(this.account, this.formSubmission, this.items, this.campaignId);
            campaignMemberCreator.generateCampaignMember();
            campaignMemberCreator.insertCampaignMember();
        }
    }
}