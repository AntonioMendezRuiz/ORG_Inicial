public class TriggerFactory {
    
    public static void createTriggerDispatcher(Schema.sObjectType objectType) {
		TriggerDispatcher dispatcher = getTriggerDispatcher(objectType);
        if(dispatcher != null && dispatcher.isEnabled()) {
            execute(dispatcher);
        }
    }
    
    private static TriggerDispatcher getTriggerDispatcher(Schema.SObjectType objectType) {
        String originalTypeName = objectType.getDescribe().getName();
        String dispatcherTypeName = null;
        TriggerDispatcher dispatcher;
        
        if (originalTypeName.toLowerCase().endsWith('__c')) {
            Integer index = originalTypeName.toLowerCase().indexOf('__c');
            dispatcherTypeName = originalTypeName.substring(0, index) + 'TriggerDispatcher';
        } else {
            dispatcherTypeName = originalTypeName + 'TriggerDispatcher';
        }
		
        Type sObjectType = Type.forName(dispatcherTypeName);
        dispatcher = (sObjectType == null) ? null : (TriggerDispatcher) sObjectType.newInstance();
        
        return dispatcher;
    }    
    
    private static void execute(TriggerDispatcher dispatcher) {
 		dispatcher.bulkBefore();
        if(Trigger.isBefore) {
            if(Trigger.isInsert)
                dispatcher.beforeInsert();
            else if (Trigger.isUpdate)
                dispatcher.beforeUpdate();
            else if (Trigger.isDelete)
                dispatcher.beforeDelete();
        } else if(Trigger.isAfter) {
            if(Trigger.isInsert)
                dispatcher.afterInsert();
            else if (Trigger.isUpdate)
                dispatcher.afterUpdate();
            else if (Trigger.isDelete)
                dispatcher.afterDelete();
            else if (Trigger.isUndelete)
                dispatcher.afterUndelete();
        }
		dispatcher.bulkAfter();
        dispatcher.andFinally();
    }
}