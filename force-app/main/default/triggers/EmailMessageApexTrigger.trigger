trigger EmailMessageApexTrigger on EmailMessage ( before insert, after insert,
                              					  before update, after update,
                              					  before delete, after delete,
                              					  after undelete) {
	TriggerFactory.createTriggerDispatcher(EmailMessage.sObjectType);
}