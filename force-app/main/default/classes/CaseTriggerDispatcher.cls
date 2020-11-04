public class CaseTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('Case (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('Case (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('Case (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('Case (Before Insert)');
    }
    
    public static void beforeUpdate() {
        System.debug('Case (Before Update)');
    }
    
    public static void beforeDelete() {
        System.debug('Case (Before Delete)');
    }
    
    public static void afterInsert() {
        System.debug('Case (After Insert)');
        //CaseHelper.assignCaseType(Trigger.new);
    }
    
    public static void afterUpdate() {
        System.debug('Case (After Update)');
        CaseHelper.upsertCaseSubscription(trigger.new, (Map<Id, Case>)trigger.oldMap);
    }
    
    public static void afterDelete() {
        System.debug('Case (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('Case (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.CaseApexTrigger__c);
    }
}