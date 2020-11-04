trigger HistoricoDeSubscriptorTrigger on HistoricoDeSubscriptor__c ( before insert, after insert,
                             										 before update, after update,
                             										 before delete, after delete,
                             										 after undelete) {
	TriggerFactory.createTriggerDispatcher(HistoricoDeSubscriptor__c.sObjectType);
                                                                         
}