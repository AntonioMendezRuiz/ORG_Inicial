public class SubscripcionACampanaTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('SubscripcionACampana (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('SubscripcionACampana (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('SubscripcionACampana (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('SubscripcionACampana (Before Insert)');
        SubscripcionACampanaHelper.setDefaultCampaignValues(trigger.new);
        SubscripcionACampanaHelper.checkDuplicatedRecordHistoricalEntry(trigger.new);
    }
    
    public static void beforeUpdate() {
        System.debug('SubscripcionACampana (Before Update)');
        //SubscripcionACampanaHelper.subscriberValidations((List<SubscripcionACampana__c>)trigger.new, (Map<Id, SubscripcionACampana__c>) Trigger.oldMap);
    }
    
    public static void beforeDelete() {
        System.debug('SubscripcionACampana (Before Delete)');
        SubscripcionACampanaHelper.removeSubscriptionsHistoricals(Trigger.old);
    }
    
    public static void afterInsert() {
        System.debug('SubscripcionACampana (After Insert)');
        //SubscripcionACampanaHelper.notifyCampanaSupervisor(Trigger.new);
        SubscripcionACampanaHelper.updateCaseStatus(Trigger.new);
        
    }
    
    public static void afterUpdate() {
        System.debug('HistoricoDeSubscriptor (After Update)');
        //SubscripcionACampanaHelper.notifyCampanaSupervisor(Trigger.new);
        SubscripcionACampanaHelper.updateCaseStatus(Trigger.new);
    }
    
    public static void afterDelete() {
        System.debug('HistoricoDeSubscriptor (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('HistoricoDeSubscriptor (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.SubscripcionACampanaApexTrigger__c);
    }
}