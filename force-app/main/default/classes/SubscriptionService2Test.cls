@isTest
public class SubscriptionService2Test {
    private static final String CAMPAIGN_EXTERNAL_ID = 'BLACKBIRDTEST';
    private static final String REQUEST_URI = 'apexrest/v1/Subscriptions/'+CAMPAIGN_EXTERNAL_ID;
    private static final String INVALID_REQUEST_URI = 'apexrest/v1/Subscriptions/INVALID';
    
	@testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        
        List<Campana__c> campaigns;
        List<PrioridadDeCampana__c> campaignPriorities;

        campaigns = TestDataFactory.createCampaigns('Lead', 1, 'En progreso');
        campaignPriorities = TestDataFactory.updateCampaignPrioritiesRandomly(campaigns);
		campaigns[0].ExternalId__c = CAMPAIGN_EXTERNAL_ID;
        update campaigns;
        Test.stopTest();
    }
    
    @isTest
    public static void malformedURLCase(){
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri ='https://ganaenergia--dev002.my.salesforce.com/services/apexrest/v3/Subscriptions/BLACKBIRDTEST/sdasdsa/asdad';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('[{"PersonEmail":"joan.laporta@test.com", PersonMailingStateCode":"C","PersonMailingCountryCode":"ES","PersonMailingCountry":"Spain", "RecordTypeId":"0125J000000LQLTQA4"}]');
		
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
		SubscriptionService2.postSubscribers();
        Test.stopTest();
        
        SubscriptionService2.ResponseBody responseBody = (SubscriptionService2.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService2.ResponseBody.class);
    }
    
    @isTest
    public static void malformedBodyCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('sonMailingCountryCode":"ES","PersonMailingCountry":"Spain", "RecordTypeId":"0125J000000LQLTQA4"}]');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService2.postSubscribers();
        Test.stopTest();
        
        SubscriptionService2.ResponseBody responseBody = (SubscriptionService2.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService2.ResponseBody.class);
    }
    
    @isTest
    public static void invalidCampaignCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = INVALID_REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('sonMailingCountryCode":"ES","PersonMailingCountry":"Spain", "RecordTypeId":"0125J000000LQLTQA4"}]');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService2.postSubscribers();
        Test.stopTest();
        
        SubscriptionService2.ResponseBody responseBody = (SubscriptionService2.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService2.ResponseBody.class);
    }
    
	@isTest
    public static void missingFieldCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(' { "Firstname": "Test", "Lastname":"API", "PersonMobilePhone": "600000000", "PersonEmail": "api@testapi.com", "PersonMailingStateCode": "C", "PersonMailingCountry": "Spain", "TECH_currentElectricalCompany__pc": "Endesa", "TECH_electricityPermanence__pc": "2021-07-12" }');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService2.postSubscribers();
        Test.stopTest();
        
    }    
    
    @isTest
    public static void postSubscribersCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(' { "TECH_ExternalLeadId__pc": "TestField1", "Firstname": "Test", "Lastname":"API", "PersonMobilePhone": "600000000", "PersonEmail": "api@testapi.com", "PersonMailingStateCode": "C", "PersonMailingCountry": "Spain", "TECH_currentElectricalCompany__pc": "Endesa", "TECH_electricityPermanence__pc": "2021-07-12" }');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService2.postSubscribers();
        Test.stopTest();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(' { "TECH_ExternalLeadId__pc": "TestField3", "Firstname": "Test", "Lastname":"API", "PersonMobilePhone": "600000000", "PersonEmail": "api@testapi.com", "PersonMailingStateCode": "C", "PersonMailingCountry": "Spain", "TECH_currentElectricalCompany__pc": "Endesa", "TECH_electricityPermanence__pc": "2021-07-12" }');
		
        RestContext.request = request;
        RestContext.response = response;
        
        SubscriptionService2.postSubscribers();
        /*
        
        List<SubscripcionACampana__c> listSubscripconActiva = [Select id, Campana__r.ExternalId__c, Cuenta__c  From SubscripcionACampana__c limit 1]; 
        SubscripcionACampana__c subscripconActiva = listSubscripconActiva[0];
        Account acc = new Account();
        acc.Id = subscripconActiva.Cuenta__c;
        
        SubscriptionService2.createSubscriptionAsDuplicated(subscripconActiva.Campana__r.ExternalId__c,'0011', acc, listSubscripconActiva );*/
        
    }
}