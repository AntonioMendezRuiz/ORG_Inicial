trigger SubscripcionACampanaTrigger on SubscripcionACampana__c ( before insert, after insert,
                             									 before update, after update,
                             									 before delete, after delete,
                             									 after undelete) {
	TriggerFactory.createTriggerDispatcher(SubscripcionACampana__c.sObjectType);
}