public class HistoricoDeSubscriptorTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('HistoricoDeSubscriptor (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('HistoricoDeSubscriptor (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('HistoricoDeSubscriptor (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('HistoricoDeSubscriptor (Before Insert)');
    }
    
    public static void beforeUpdate() {
        System.debug('HistoricoDeSubscriptor (Before Update)');
    }
    
    public static void beforeDelete() {
        System.debug('HistoricoDeSubscriptor (Before Delete)');
    }
    
    public static void afterInsert() {
        System.debug('HistoricoDeSubscriptor (After Insert)');
        try {
            HistoricoDeSubscriptorTriggerHelper.updateSubscriptorStatus(Trigger.new);
        } catch(Exception e) {
            System.debug('Exception occurred at HistoricoDeSubscriptor Trigger :: ' + e.getMessage() + ' (Line: ' + e.getLineNumber() + ')');
        }
        
    }
    
    public static void afterUpdate() {
        System.debug('HistoricoDeSubscriptor (After Update)');
    }
    
    public static void afterDelete() {
        System.debug('HistoricoDeSubscriptor (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('HistoricoDeSubscriptor (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.HistoricoDeSubscriptorApexTrigger__c);
    }
}