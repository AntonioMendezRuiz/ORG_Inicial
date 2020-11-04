trigger AccountTrigger on Account ( before insert, after insert,
                             		before update, after update,
                             		before delete, after delete,
                             		after undelete) {
	TriggerFactory.createTriggerDispatcher(Account.sObjectType);
}

    /* after insert/ before update - REMOVE BY 30th may if still commented.
	Account tmpAcc = new Account();
    
    
    if(Trigger.isInsert) {
        System.debug('INSERT :: ' + Trigger.New);
        
        for(Account acc: Trigger.New) {
        if(acc.TECH_CampaignExternalId__pc <> null && acc.TECH_CampaignExternalId__pc <> '#') {
            SubscripcionACampana__c cam = new SubscripcionACampana__c();
            cam.Campana__r = new Campana__c(ExternalId__c=acc.TECH_CampaignExternalId__pc);
            cam.Cuenta__c = acc.id;
            cam.PrioridadDeCampana__c = 'a023O000000yuLFQAY';
            cam.PrioridadIndividual__c = 0;
            cam.CorreoDelTitularDelContrato__c=acc.firstname + '@test.com';
            insert cam;
            
            tmpAcc.id = acc.id;
            tmpAcc.TECH_CampaignExternalId__pc = '#';
            update tmpAcc;
        }
    }
        
    }
    
    if(Trigger.isUpdate) {
        System.debug('UPDATE :: ' + Trigger.New);
        for(Account acc: Trigger.New) {
            if(acc.TECH_CampaignExternalId__pc <> null && acc.TECH_CampaignExternalId__pc <> '#') {
                SubscripcionACampana__c cam = new SubscripcionACampana__c();
                cam.Campana__r = new Campana__c(ExternalId__c=acc.TECH_CampaignExternalId__pc);
                cam.Cuenta__c = acc.id;
                cam.PrioridadDeCampana__c = 'a023O000000yuLFQAY';
                cam.PrioridadIndividual__c = 0;
                cam.CorreoDelTitularDelContrato__c=acc.firstname + '@test.com';
                insert cam;
                
                acc.TECH_CampaignExternalId__pc = '#';
            }
    	}
    }
    

    */