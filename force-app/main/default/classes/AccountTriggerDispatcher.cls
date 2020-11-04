public class AccountTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('Account (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('Account (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('Account (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('Account (Before Insert)');
        //SubscripcionACampanaHelper.checkDuplicatedRecordHistoricalEntry(trigger.new);
    }
    
    public static void beforeUpdate() {
        System.debug('Account (Before Update)');
        AccountHelper.createSubscriptions(Trigger.New, (Trigger.isAfter && Trigger.isInsert));
    }
    
    public static void beforeDelete() {
        System.debug('Account (Before Delete)');
        AccountHelper.removeSubscriptions(Trigger.old);
    }
    
    public static void afterInsert() {
        System.debug('Account (After Insert)');
        AccountHelper.createSubscriptions(Trigger.New, (Trigger.isAfter && Trigger.isInsert));
    }
    
    public static void afterUpdate() {
        System.debug('Account (After Update)');
    }
    
    public static void afterDelete() {
        System.debug('Account (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('Account (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.AccountApexTrigger__c);
    }
}