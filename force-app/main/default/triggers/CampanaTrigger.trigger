trigger CampanaTrigger on Campana__c ( before insert, after insert,
                             			before update, after update,
                             			before delete, after delete,
                             			after undelete) {
	TriggerFactory.createTriggerDispatcher(Campana__c.sObjectType);
}