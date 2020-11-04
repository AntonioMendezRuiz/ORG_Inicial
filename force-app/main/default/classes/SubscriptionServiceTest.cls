@isTest
public class SubscriptionServiceTest {
    private static final String CAMPAIGN_EXTERNAL_ID = 'BLACKBIRDTEST';
    private static final String REQUEST_URI = 'apexrest/v1/Subscriptions/'+CAMPAIGN_EXTERNAL_ID;
    
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
    
    /*
    @isTest
    public static void malformedURLCase(){
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri ='https://ganaenergia--dev002.my.salesforce.com/services/apexrest/v1/Subscriptions/BLACKBIRDTEST';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('[{"PersonEmail":"joan.laporta@test.com", PersonMailingStateCode":"C","PersonMailingCountryCode":"ES","PersonMailingCountry":"Spain", "RecordTypeId":"0125J000000LQLTQA4"}]');
		
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
		SubscriptionService.postSubscribers();
        Test.stopTest();
        
        SubscriptionService.ResponseBody responseBody = (SubscriptionService.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService.ResponseBody.class);
        System.assertEquals(401, responseBody.statusCode);
        System.assertEquals('MALFORMED_URL_ERROR', responseBody.errorMessage);
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
		SubscriptionService.postSubscribers();
        Test.stopTest();
        
        SubscriptionService.ResponseBody responseBody = (SubscriptionService.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService.ResponseBody.class);
        System.assertEquals(402, responseBody.statusCode);
        System.assertEquals('MALFORMED_BODY_ERROR', responseBody.errorMessage);
    }
    
    @isTest
    public static void idSpecifiedCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('[ { "Id": "0013O00000GctQKQAZ", "Firstname": "Test", "Lastname":"API", "PersonMobilePhone": "600000000", "PersonEmail": "api@testapi.com", "PersonMailingStateCode": "C", "PersonMailingCountry": "Spain", "TECH_currentElectricalCompany__pc": "Endesa", "TECH_electricityPermanence__pc": "2021-07-12" }, { "Firstname": "Test", "Lastname": "API 2", "PersonMobilePhone": "89321732", "PersonEmail": "api@testapi2.com", "PersonMailingState": "Barcelona", "PersonMailingCountry": "Spain", "TECH_currentGasCompany__pc": "Repsol", "TECH_electricityPermanence__pc": "2021-07-12", "TECH_Lot__pc": 3.7 } ]');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService.postSubscribers();
        Test.stopTest();
        
        SubscriptionService.ResponseBody responseBody = (SubscriptionService.ResponseBody) JSON.deserialize(response.responseBody.toString(), SubscriptionService.ResponseBody.class);
        System.assertEquals(407, responseBody.statusCode);
        System.assertEquals('ID_SPECIFIED_ERROR', responseBody.errorMessage);
    }
    */
    @isTest
    public static void postSubscribersCase(){        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = REQUEST_URI;
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof('[ {   } ]');
		
        RestContext.request = request;
        RestContext.response = response;
		
        Test.startTest();
		SubscriptionService.postSubscribers();
        Test.stopTest();
    }
}