trigger Account on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    AccountHandler handler = new AccountHandler(Trigger.isExecuting);
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new); 
        }
        if(Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap); 
        }
        if(Trigger.isDelete) {
            handler.onBeforeDelete(Trigger.old, Trigger.oldMap); 
        }
    } else {
        if(Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new, Trigger.newMap); 
        }
        if(Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap); 
        }
        if(Trigger.isDelete) {
            handler.onAfterDelete(Trigger.old, Trigger.oldMap); 
        }
        if(Trigger.isUndelete) {
            handler.onAfterUndelete(Trigger.new); 
        }  
    }
}