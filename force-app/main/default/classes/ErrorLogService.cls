public inherited sharing class ErrorLogService {

    private static final Integer FIELD_LENGTH_MESSAGE = 255;

    public static ErrorLog__c logError(Exception e) {
        ErrorLog__c errorLog = new ErrorLog__c(
            Message__c = e.getMessage(),
            StackTrace__c = e.getStackTraceString(),
            RequestBody__c = RestContext.request.requestBody.toString()
        ); 
        insert errorLog;
        return errorLog;
    }

    public static ErrorLog__c generateLogRecord(Database.SaveResult saveResult) {
        String errorDetails = '';
        String errorMessage;
        for (Database.Error error : saveResult.getErrors()) {
            errorDetails += error.getMessage() + '\r\n';
        }
        if (errorDetails.length() >= FIELD_LENGTH_MESSAGE) {
            errorMessage = errorDetails.substring(0, FIELD_LENGTH_MESSAGE - 1);
        } else {
            errorMessage = errorDetails;
        }
        return new ErrorLog__c(
            Details__c = errorDetails,
            Message__c = errorMessage
        );
    }
}