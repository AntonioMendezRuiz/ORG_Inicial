public class EmailMessageTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('EmailMessage (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('EmailMessage (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('EmailMessage (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('EmailMessage (Before Insert)');
    }
    
    public static void beforeUpdate() {
        System.debug('EmailMessage (Before Update)');
    }
    
    public static void beforeDelete() {
        System.debug('EmailMessage (Before Delete)');
    }
    
    public static void afterInsert() {
        System.debug('EmailMessage (After Insert)');
        EmailMessageHelper.assignCaseType(Trigger.new);
    }
    
    public static void afterUpdate() {
        System.debug('EmailMessage (After Update)');
    }
    
    public static void afterDelete() {
        System.debug('EmailMessage (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('EmailMessage (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.CaseApexTrigger__c);
    }
}