@isTest
public class CampaignMemberSubmissionTest {
    private static final string SUBMISSION_FORM_BODY_POSITIVE = '{"email":"fullprospect@frompardot.com","Pardot_Compa_a_luz_actual_Otros":"","Pardot_Compa_a_actual_gas_Otros":"","Pardot_CUPS_luz":"cups luz","Pardot_CUPS_gas":"","Pardot_Potencia":"9876543456","Custom_ltima_subscripci_n_Tramo":"","pi_preferredContactTime":"","Campaign_External_Id":"test"}';
    private static final string SUBMISSION_FORM_BODY_NEGATIVE = '{"email":"fulltesting456@frompardot.com","Pardot_Compa_a_luz_actual_Otros":"","Pardot_Compa_a_actual_gas_Otros":"","Pardot_CUPS_luz":"cups luz","Pardot_CUPS_gas":"","Pardot_Potencia":"9876543456","Custom_ltima_subscripci_n_Tramo":"","pi_preferredContactTime":"","Campaign_External_Id":"error"}';

   
    static testMethod void postSubmissionPositive(){
        
        Account testAccount = TestDataFactory.createPersonAccounts(1)[0];
        testAccount.PersonEmail = 'fullprospect@frompardot.com';
        update testAccount;
        insert createCampaign();
        Test.setMock(HttpCalloutMock.class, new CampaignMemberSubmissionMock(true));        
        Test.StartTest();
        
        RestRequest request = new RestRequest(); 
 		RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response; 
        
        request.requestURI = '/services/apexrest/pardot/campaign-members';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(SUBMISSION_FORM_BODY_POSITIVE);
        RestContext.request = request;
        Pardot_CampaignMemberSubmission.postFormSubmission();
        Test.stopTest();
        String testBlob = response.responseBody.toString();



    }
    
    static testMethod void postSubmissionNegative(){
        
        FormSubmission__c testFormSubmission = new FormSubmission__c();
        testFormSubmission.Email__c = 'fulltesting456@frompardot.com';
        testFormSubmission.CampaignId__c = 'error';
        insert testFormSubmission;
        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.LastName = 'Test LastName';
        testAccount.PersonEmail = 'fulltesting456@frompardot.com';
        testAccount.RecordTypeId = personAccountRecordTypeId;
        insert testAccount;
        
        insert createCampaign();

        Test.setMock(HttpCalloutMock.class, new CampaignMemberSubmissionMock(false));        
        Test.StartTest();
        RestRequest request = new RestRequest(); 
 		RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestURI = '/services/apexrest/pardot/campaign-members';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(SUBMISSION_FORM_BODY_NEGATIVE);
        
		
        Pardot_CampaignMemberSubmission.postFormSubmission();
        Test.stopTest();
        String testBlob = response.responseBody.toString();



    }    
    
    static Campana__c createCampaign(){
        return new Campana__c(Name = 'Test Campaign', Estado__c = 'Planificada', Tipo__c='Caso', PrioridadDeCapana__c =1, ExternalId__c='error');
    }
    
    
    public with sharing class CampaignMemberSubmissionMock implements HttpCalloutMock{
        private Boolean isSuccess;
        private Integer code;
        
        public CampaignMemberSubmissionMock(Boolean isSuccess) {
            this.isSuccess = isSuccess;
            this.code = this.isSuccess ? 200 : 401;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse myResponse = new HttpResponse();
            myResponse.setHeader('Content-Type', 'application/json');
            myResponse.setStatusCode(this.code);
            String json = '[{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wPUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"email","FieldValue__c":"fullprospect@frompardot.com","Id":"a0U3O000000Q2wPUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wQUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Pardot_Compa_a_luz_actual_Otros","FieldValue__c":"","Id":"a0U3O000000Q2wQUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wRUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Pardot_Compa_a_actual_gas_Otros","FieldValue__c":"","Id":"a0U3O000000Q2wRUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wSUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Pardot_CUPS_luz","FieldValue__c":"cups luz","Id":"a0U3O000000Q2wSUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wTUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Pardot_CUPS_gas","FieldValue__c":"","Id":"a0U3O000000Q2wTUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wUUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Pardot_Potencia","FieldValue__c":"9876543456","Id":"a0U3O000000Q2wUUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wVUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Custom_ltima_subscripci_n_Tramo","FieldValue__c":"","Id":"a0U3O000000Q2wVUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wWUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"pi_preferredContactTime","FieldValue__c":"","Id":"a0U3O000000Q2wWUAS"},{"attributes":{"type":"FormSubmissionItem__c","url":"/services/data/v49.0/sobjects/FormSubmissionItem__c/a0U3O000000Q2wXUAS"},"FormSubmission__c":"a0T3O0000002zKbUAI","FieldName__c":"Campaign_External_Id","FieldValue__c":"test","Id":"a0U3O000000Q2wXUAS"}]'; 
            myResponse.setBody(json);
            
            return myResponse;
        }
    }
}