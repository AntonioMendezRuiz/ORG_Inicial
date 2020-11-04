public class LogRegistrationHelper {
	
    private static String getHeadersAsString(Map<String, String> headers) {
        String headerString = '{\n';
        for(String key: headers.keySet()) {
            headerString += key + ':' + headers.get(key) + ',\n';
        }
        headerString = headerString.removeEnd(',\n');
        headerString+= '\n}';
        return headerString;
    }
    public static void insertSubscriptionServiceLogs(RestRequest restRequest, RestResponse restResponse, SubscriptionService2.ResponseBody responseBody, String externalLeadId, Account account, SubscriptionService2.SubscriptionOperationResult subscriptionOperationResult, String campaignExternalId) {
        LogRegistration__c log = new LogRegistration__c();
        
        log.Origin__c = 'API SUBSCRIPTORES';
        if(!String.isBlank(campaignExternalId) && responseBody.errorCode <> 406)
            log.Campaign__r = new Campana__c(ExternalId__c = campaignExternalId);
        
        if(account <> null) {
            log.Email__c = account.PersonEmail;
        	log.PersonMobilePhone__c = account.PersonMobilePhone;
        	log.Account__c = account.id;
        }
        
        if(subscriptionOperationResult <> null && subscriptionOperationResult.getRecord() <> null) {
            log.CampaignSubscription__c = subscriptionOperationResult.getRecord().id;
        }
        
		log.HTTPMethod__c = restRequest.httpMethod;
        log.StatusCode__c = restResponse.statusCode;
        log.ErrorCode__c = responseBody == null ? null : responseBody.errorCode;
        log.LeadExternalId__c = externalLeadId;
        
        log.Description__c = responseBody == null ? null : responseBody.message;
        log.Status__c = restResponse.statusCode == 200 ? 'Solved' : 'Pending';
        
        log.RequestEndpoint__c = restRequest.requestURI;
        log.RequestHeader__c = String.valueOf(getHeadersAsString(restRequest.headers));
        LOG.RequestBody__c = restRequest.requestBody.toString();        
        
        
        insert log;
    }
}