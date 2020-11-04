public class CampanaTriggerDispatcher implements TriggerDispatcher{
    public static void bulkBefore() {
        System.debug('Campana (Bulk Before)');
    }
    public static void bulkAfter() {
        System.debug('Campana (Bulk After)');
    }
    
    public static void andFinally() {
        System.debug('Campana (Finally)');
    }
    
    public static void beforeInsert() {
        System.debug('Campana (Before Insert)');
    }
    
    public static void beforeUpdate() {
        System.debug('Campana (Before Update)');
    }
    
    public static void beforeDelete() {
        System.debug('Campana (Before Delete)');
    }
    
    public static void afterInsert() {
        System.debug('Campana (After Insert)');
        CampanaHelper.createPrioridadesCampana(Trigger.new);
    }
    
    public static void afterUpdate() {
        System.debug('Campana (After Update)');
    }
    
    public static void afterDelete() {
        System.debug('Campana (After Delete)');
    }
    
    public static void afterUndelete() {
		System.debug('Campana (After Undelete)');        
    }
    
    public static boolean isEnabled() {
        Bypass__c csBypass = Bypass__c.getInstance();
        return !(csBypass.ApexTriggers__c || csBypass.CampanaApexTrigger__c);
    }
}