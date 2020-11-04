@RestResource(urlMapping='/v1/Subscriptions/*')
global without sharing class SubscriptionService
{

    /*
        @testVisible private class ResponseBody {
        @testVisible Integer statusCode;
        @testVisible String errorMessage;
        
        public ResponseBody(Integer statusCode, String errorMessage) {
            this.statusCode = statusCode;
            this.errorMessage = errorMessage;
        }
    }

    
    private static void insertSubscriptionForDuplicatedAccounts(List<Account> accountsToInsert, Database.SaveResult[] srList) {
        Map<String, Id> accountIdsByPersonEmail = AccountHelper.getAccountIdsByPersonEmail(accountsToInsert);
        Map<String, Id> accountIdsByPersonHomePhone = AccountHelper.getAccountIdsByPersonHomePhone(accountsToInsert);
        Map<String, Id> accountIdsByPersonOtherPhone = AccountHelper.getAccountIdsByPersonOtherPhone(accountsToInsert);
        Map<String, Id> accountIdsByPersonMobilePhone = AccountHelper.getAccountIdsByPersonMobilePhone(accountsToInsert);
        
        Database.SaveResult saveResult;
        List<Account> accountsToCreateSubscription = new List<Account>();
        Account accountToCreateSubscription;
        List<Database.Error> errors;
        Integer i;
        
        for(i = 0; i < srList.size(); i++) {
            saveResult = srList[i];
            accountToCreateSubscription = (Account)((sObject) accountsToInsert[i]).clone(false, true, false, false);
            
            if(!saveResult.isSuccess()) {
               	errors = saveResult.getErrors();
                for(Database.Error error: errors) {
                    if(error.getMessage().containsIgnoreCase('Ya existe un registro con este email / teléfono.')) {
                        if(!String.isBlank(accountToCreateSubscription.PersonEmail) && accountIdsByPersonEmail.containsKey(accountToCreateSubscription.PersonEmail))
                            accountToCreateSubscription.id = accountIdsByPersonEmail.get(accountToCreateSubscription.PersonEmail);
                        else if(!String.isBlank(accountToCreateSubscription.personHomePhone) && accountIdsByPersonHomePhone.containsKey(accountToCreateSubscription.personHomePhone))
                            accountToCreateSubscription.id = accountIdsByPersonHomePhone.get(accountToCreateSubscription.personHomePhone);
                        else if(!String.isBlank(accountToCreateSubscription.personOtherPhone) && accountIdsByPersonOtherPhone.containsKey(accountToCreateSubscription.personOtherPhone))
                            accountToCreateSubscription.id = accountIdsByPersonOtherPhone.get(accountToCreateSubscription.personOtherPhone);
                        else if(!String.isBlank(accountToCreateSubscription.personMobilePhone) && accountIdsByPersonMobilePhone.containsKey(accountToCreateSubscription.personMobilePhone))
                            accountToCreateSubscription.id = accountIdsByPersonMobilePhone.get(accountToCreateSubscription.personMobilePhone);
                        
                        if(accountToCreateSubscription.id <> null)
                        	accountsToCreateSubscription.add(accountToCreateSubscription);
                        
                    } else {
                        throw new DMLException(error.getMessage());
                    }
                }
            }
        }
		
        if(!accountsToCreateSubscription.isEmpty())
        	AccountHelper.createSubscriptions(accountsToCreateSubscription, false);
    }
    
    @Future 
    public static void removeDuplicatedAccounts(Set<String> accountNames) {
        Map<Id, Account> insertedAccounts = new Map<Id, Account>();
        Map<Id, Account> deletableAccounts = new Map<Id, Account>();
        
        if(accountNames.size() == 1) {
             insertedAccounts = new Map<Id, Account>([SELECT id, createdDate FROM Account Where Name IN :accountNames ]);
             deletableAccounts = new Map<Id, Account>([SELECT id, createdDate FROM Account Where Id IN :insertedAccounts.keySet() Order By CreatedDate DESC LIMIT :(insertedAccounts.size() - 1)]);
        	
            System.debug('insertedAccounts size :: ' + insertedAccounts.size());
            System.debug('deletableAccounts size :: ' + deletableAccounts.size());
            
            System.debug('insertedAccounts :: ' + insertedAccounts);
            System.debug('deletableAccounts :: ' + deletableAccounts);
            
            delete deletableAccounts.values();
        }

    }
    
    private static void insertAccounts(List<Account> accountsToInsert, String campaignExternalId) {
        Map<String, Account> accountMapToInsert = new Map<String, Account>();
        Set<String> accountNames = new Set<String>();
        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount').getRecordTypeId();
        for(Account accountToInsert: accountsToInsert) {
            accountToInsert.TECH_CampaignExternalId__pc = campaignExternalId;
            accountToInsert.RecordTypeId = personAccountRecordTypeId;
            if(validateRequiredFields(accountToInsert)){
                throw new DMLException('Required fields are missing: ' + '[PersonMobilePhone], [firstname] or [lastname]');
            }
            
            // Reducing multiple accounts to a single using mandatory fields as key
            accountMapToInsert.put(accountToInsert.firstName+accountToInsert.LastName+accountToInsert.PersonMobilePhone, accountToInsert);
            accountNames.add(accountToInsert.firstName + ' ' + accountToInsert.LastName);
            //removeDuplicatedAccounts(accountNames);
        }
		
        Database.SaveResult[] srList = Database.insert(accountMapToInsert.values(), false);
        insertSubscriptionForDuplicatedAccounts(accountMapToInsert.values(), srList);
        
    }
    
    private static boolean validateExternalId(String externalId) {
        List<Campana__c> campaigns = [SELECT id FROM Campana__c WHERE ExternalId__c =: externalId];
        return !campaigns.isEmpty();
    }
    
    private static boolean validateRequiredFields(Account account) {
        return String.isBlank(account.PersonMobilePhone) || String.isBlank(account.lastname);
    }
    
    private static void insertLogs(System.RestRequest restRequest, System.RestResponse restResponse, ResponseBody responseBody, String campaignExternalId, Boolean campaignFound, List<Account> accountsToInsert, Exception e) {
        LogRegistration__c log = new LogRegistration__c();
        if(!String.isBlank(campaignExternalId) && campaignFound)
            log.Campaign__r = new Campana__c(ExternalId__c = campaignExternalId);
        log.HTTPMethod__c = restRequest.httpMethod;
        log.StatusCode__c = restResponse.statusCode;
        log.ErrorCode__c = responseBody == null ? null : responseBody.statusCode;
        log.Description__c = responseBody == null ? null : responseBody.errorMessage;
        log.Status__c = restResponse.statusCode == 200 ? 'Solved' : 'Pending';
        log.ErrorCause__c = (e == null) ? '' : e.getTypeName();
        log.RequestEndpoint__c = restRequest.requestURI;
        log.RequestHeader__c = String.valueOf(restRequest.headers);
        LOG.RequestBody__c = restRequest.requestBody.toString();
        insert log;
    }

    @HttpPost
    global static void postSubscribers(){
        
        /*System.debug('POST SUBSCRIBERS!');
        List<Account> accountsToInsert;
        Exception exceptionThrown;
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        ResponseBody responseBody;
        String requestBody = restRequest.requestBody.toString();
        List<String> splittedUrl = restRequest.requestURI.split('/');
        String campaignExternalId;
        Boolean campaignFound = false;
        if(splittedUrl.size() <> 4) {
            responseBody = new ResponseBody(401, 'MALFORMED_URL_ERROR');
            restResponse.statusCode = 400;
        } else {
            campaignExternalId = splittedUrl[splittedUrl.size() - 1];
            campaignFound = validateExternalId(campaignExternalId);
            if(campaignFound) {
                try {
                    accountsToInsert = (List<Account>) JSON.deserialize(requestBody, List<Account>.class);
                    insertAccounts(accountsToInsert, campaignExternalId);
                    restResponse.statusCode = 200;
                } catch(JSONException e) {
                    exceptionThrown = e;
                    responseBody = new ResponseBody(402, 'MALFORMED_BODY_ERROR');
                    restResponse.statusCode = 400;
                } catch(DMLException e) {
                    exceptionThrown = e;
                    if(e.getMessage().containsIgnoreCase('cannot specify Id in an insert call')) {
                        responseBody = new ResponseBody(407, 'ID_SPECIFIED_ERROR');
                        restResponse.statusCode = 400;
                    } else if(e.getMessage().containsIgnoreCase('The existing country/territory') && e.getMessage().containsIgnoreCase('recognize the')) {
                        responseBody = new ResponseBody(408, 'MISMATCHED_ISO_CODES_ERROR');
                        restResponse.statusCode = 400;
                    } else if(e.getMessage().containsIgnoreCase('Required fields are missing')) {
                        responseBody = new ResponseBody(403, 'REQUIRED_FIELD_ERROR: ' + e.getMessage().substring(e.getMessage().indexOf('Required fields are missing: ')));
                        restResponse.statusCode = 400;
                    } else if(e.getMessage().containsIgnoreCase('not found for field ExternalId__c in entity Campana__c')) {
                        responseBody = new ResponseBody(406, 'NOT_FOUND_ERROR');
                        restResponse.statusCode = 400;
                    } else {
                        responseBody = new ResponseBody(402, e.getMessage());
                        restResponse.statusCode = 400;
                    }
                }   
            } else {
                responseBody = new ResponseBody(406, 'NOT_FOUND_ERROR');
                restResponse.statusCode = 400;
            }
        }
        
        
        if(responseBody <> null)
            restResponse.responseBody = Blob.valueOf(JSON.serialize(responseBody));

        insertLogs(restRequest, restResponse, responseBody, campaignExternalId, campaignFound, accountsToInsert, exceptionThrown);
	
        
        
        
    }
    */
    
    @HttpPost
    global static void postSubscribers() {
        // Conversion from multiple to single account...
    	RestRequest restRequest = RestContext.request;
        try {
            String requestBody = restRequest.requestBody == null ? '' : restRequest.requestBody.toString();
        	List<Account> accounts = (List<Account>) JSON.deserialize(requestBody, List<Account>.class);
        	restRequest.requestBody = Blob.valueOf(JSON.serialize(accounts[0]));
        } catch(Exception e) {
            restRequest.requestBody = Blob.valueOf('');
        }
        
        SubscriptionService2.postSubscribers();
    }
}