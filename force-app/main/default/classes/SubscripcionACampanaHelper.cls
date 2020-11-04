public class SubscripcionACampanaHelper {
    
    public static void setDefaultCampaignValues(List<SubscripcionACampana__c> subscriptions) {
   		List<Campana__c> pardotCampaigns = [SELECT id 
                                            FROM Campana__c
                                            WHERE externalId__c = 'Pardot'];
        Map<Id, Map<String, PrioridadDeCampana__c>> campaignStatus;
        
        if(!pardotCampaigns.isEmpty())
        	campaignStatus = getSubscriptionsAvailablePrioritiesByCampaignAndName(new Set<Id> {pardotCampaigns[0].id});
        
        for(SubscripcionACampana__c subscription: subscriptions) {
            if(String.isEmpty(subscription.campana__c) && !pardotCampaigns.isEmpty()) {
                subscription.campana__c = pardotCampaigns[0].id;
                subscription.PrioridadDeCampana__c = campaignStatus.get(pardotCampaigns[0].id).get('NUEVO').id;
            }
        }        
    }
    
	public static Map<Id, PrioridadDeCampana__c> getSubscriptionAvailablePrioritiesById(SubscripcionACampana__c subscription) {
        return new Map<Id, PrioridadDeCampana__c>( [SELECT id, name, cerrado__c, contrata__c, PostponeMinutes__c 
                          							FROM PrioridadDeCampana__c 
                          							WHERE Campana__c =: subscription.campana__c 
                                                	ORDER By Name]);

    }
    
        public static Map<Id, Map<String, PrioridadDeCampana__c>> getSubscriptionsAvailablePrioritiesByCampaignAndName(Set<Id> campanaIdSet) {
        Map<Id, Map<String, PrioridadDeCampana__c>> prioritiesByCampaignAndName = new Map<Id, Map<String, PrioridadDeCampana__c>>();
        Map<String, PrioridadDeCampana__c> prioritiesByName = new Map<String, PrioridadDeCampana__c>();
        
        
        for(PrioridadDeCampana__c priority: [SELECT id, name, cerrado__c, contrata__c, campana__c
                          					 FROM PrioridadDeCampana__c 
                          					 WHERE Campana__c =: campanaIdSet 
                                             ORDER By Name]) {
			if(!prioritiesByCampaignAndName.containsKey(priority.Campana__c))
                prioritiesByCampaignAndName.put(priority.Campana__c, new Map<String, PrioridadDeCampana__c>());
            prioritiesByName = prioritiesByCampaignAndName.get(priority.Campana__c);
            prioritiesByName.put(priority.Name.toUpperCase(), priority);
        }
        return prioritiesByCampaignAndName;
    }

    public static Map<Id, Map<String, PrioridadDeCampana__c>> getSubscriptionsAvailablePrioritiesByCampaignAndName(List<SubscripcionACampana__c> subscriptions) {
        Set<Id> campanaIds = new Set<Id>();
        Map<Id, Map<String, PrioridadDeCampana__c>> prioritiesByCampaignAndName = new Map<Id, Map<String, PrioridadDeCampana__c>>();
        Map<String, PrioridadDeCampana__c> prioritiesByName = new Map<String, PrioridadDeCampana__c>();
        
        for(SubscripcionACampana__c subscription: subscriptions){
            campanaIds.add(subscription.campana__c);
        }
        
        for(PrioridadDeCampana__c priority: [SELECT id, name, cerrado__c, contrata__c, campana__c
                          					 FROM PrioridadDeCampana__c 
                          					 WHERE Campana__c =: campanaIds 
                                             ORDER By Name]) {
			if(!prioritiesByCampaignAndName.containsKey(priority.Campana__c))
                prioritiesByCampaignAndName.put(priority.Campana__c, new Map<String, PrioridadDeCampana__c>());
            prioritiesByName = prioritiesByCampaignAndName.get(priority.Campana__c);
            prioritiesByName.put(priority.Name.toUpperCase(), priority);
        }
        return prioritiesByCampaignAndName;
    }
    
        /*
    public static void notifyCampanaSupervisor(List<SubscripcionACampana__c> subscriptionList) {
        Decimal supervisorNotificationThreshold = PAD.automationParameters.SupervisorNotificationThreshold__c;
		Set<Id> campanaIdSet = new Set<Id>();
        List<Campana__c> campanaList;
        List<FeedItem> FeedItemList = New List<FeedItem>();
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail;
        
        for(SubscripcionACampana__c subscription: subscriptionList) {
            campanaIdSet.add(subscription.campana__c);
        }
        
        campanaList = [SELECT id, name, supervisor__c, supervisor__r.Email, CandidatosConvertidosEnCampanaPercent__c 
                       FROM Campana__c
                       WHERE Estado__c = 'En progreso' AND CandidatosConvertidosEnCampanaPercent__c >= :supervisorNotificationThreshold ];
        
        for(Campana__c campana: campanaList){
            if(campana.supervisor__c <> null) {
                mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new String[] {campana.supervisor__r.Email});
                mail.setSubject('La campaña ' + campana.name + 'supera el umbral de convertidos.');
				mail.setPlainTextBody('La campaña ' + campana.name + ' (' + campana.id + ') supera el umbral de convertidos (' + supervisorNotificationThreshold * 100  + ').');
				emailList.add(mail);
                
                FeedItem post = new FeedItem();
                post.ParentId = campana.supervisor__c;
                post.Body = 'Esta camapaña tiene un porcentaje de candidatos convertidos superior al definido. ';
                post.Title = 'Notificación de Campaña';
                post.LinkUrl = '/lightning/r/Campana__c/' + campana.id + '/view';
                
                
            }
        }
        Messaging.sendEmail(emailList);

        //insert FeedItemList;
    }
    */
    
    /*
    public static void notifyCampanaSupervisor(List<SubscripcionACampana__c> subscriptionList) {
        Decimal supervisorNotificationThreshold = PAD.automationParameters.SupervisorNotificationThreshold__c;
		Set<Id> campanaIdSet = new Set<Id>();
        List<Campana__c> campanaList;
        List<FeedItem> FeedItemList = New List<FeedItem>();
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail;
        
        for(SubscripcionACampana__c subscription: subscriptionList) {
            campanaIdSet.add(subscription.campana__c);
        }
        
        campanaList = [SELECT id, name, supervisor__c, supervisor__r.Email, CandidatosConvertidosEnCampanaPercent__c 
                       FROM Campana__c
                       WHERE Estado__c = 'En progreso' AND CandidatosConvertidosEnCampanaPercent__c >= :supervisorNotificationThreshold ];
        
        for(Campana__c campana: campanaList){
            if(campana.supervisor__c <> null) {
                mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new String[] {campana.supervisor__r.Email});
                mail.setSubject('La campaña ' + campana.name + 'supera el umbral de convertidos.');
				mail.setPlainTextBody('La campaña ' + campana.name + ' (' + campana.id + ') supera el umbral de convertidos (' + supervisorNotificationThreshold * 100  + ').');
				emailList.add(mail);
                
                FeedItem post = new FeedItem();
                post.ParentId = campana.supervisor__c;
                post.Body = 'Esta camapaña tiene un porcentaje de candidatos convertidos superior al definido. ';
                post.Title = 'Notificación de Campaña';
                post.LinkUrl = '/lightning/r/Campana__c/' + campana.id + '/view';
                
                
            }
        }
        Messaging.sendEmail(emailList);

        //insert FeedItemList;
    }
    */
    
    public static void updateCaseStatus(List<SubscripcionACampana__c> subscriptionList) {
        Map<Id, Id> caseIdPriorityId = new Map<Id, Id>();
        Map<Id, PrioridadDeCampana__c> subscriberPrioritiesByPriorityId;
        List<Case> casesToUpdate = new List<Case>();
        PrioridadDeCampana__c campaignPriority;
        Case caseToUpdate;
        
        for(SubscripcionACampana__c subscription: subscriptionList) {
            if(subscription.PrioridadDeCampana__c <> null && subscription.caso__c <> null) {
                caseIdPriorityId.put(subscription.caso__c, subscription.PrioridadDeCampana__c);
            }
        }
        
        subscriberPrioritiesByPriorityId = new Map<Id, PrioridadDeCampana__c>([SELECT id, cerrado__c FROM PrioridadDeCampana__c WHERE id IN :caseIdPriorityId.values()]);
        
        for(Id i: caseIdPriorityId.keySet()) {
            if(subscriberPrioritiesByPriorityId.containsKey(caseIdPriorityId.get(i))) {
                campaignPriority = subscriberPrioritiesByPriorityId.get(caseIdPriorityId.get(i));
                caseToUpdate = new Case();
            	caseToUpdate.id = i;
            	caseToUpdate.Status = campaignPriority.cerrado__c ? 'Cerrado' : 'Abierto';
            	casesToUpdate.add(caseToUpdate);
            }
        }
        
        update casesToUpdate;
    }
    
    public static void checkDuplicatedRecordHistoricalEntry(List<SubscripcionACampana__c> subscriptionList) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> subsIdSet = new Set<Id>();
        Map<Id, SubscripcionACampana__c> activeSubscriptionsByAccountId = new Map<Id, SubscripcionACampana__c>();
		SubscripcionACampana__c activeSubscription;
        List<HistoricoDeSubscriptor__c> subscriptionHistoricals = new List<HistoricoDeSubscriptor__c>();
        HistoricoDeSubscriptor__c subscriptionHistorical;
		List<SubscripcionACampana__c> duplicatedSubscriptions = new List<SubscripcionACampana__c>();
        //Se obtiene el mapa de prioridades de las campañas con mapa del tipo de priorirdad y las campañas a las que aplica
        Map<Id, Map<String, PrioridadDeCampana__c>> prioritiesByCampaignAndName = getSubscriptionsAvailablePrioritiesByCampaignAndName(subscriptionList);
        Set<Id> setPrioridesAsociadasASubscripciones = new Set<Id>();
        
        
        //Si la campaña tiene asociada una cuenta pero NO CASO se añade el Id de la cuenta y el de ID de la subscripción
        for(SubscripcionACampana__c subscription: subscriptionList) {
            if(subscription.Cuenta__c <> null && subscription.caso__c == null){
                accountIdSet.add(subscription.Cuenta__c);
                subsIdSet.add(subscription.id);
                setPrioridesAsociadasASubscripciones.add(subscription.PrioridadDeCampana__c);
            }
        }
        
        //Obtenemos los nombres de las prioridades  relacionadas con las subscripciones para luego comparar el nombre 
        Map<Id,PrioridadDeCampana__c> mapaPrioridadesExisntentes = new Map<Id,PrioridadDeCampana__c>();
         //Se obtienen aquellas subscripciones de campañas cuya prioridad no esté cerrada y el ID no sea el de los elementos con los que trabajamos
        for(PrioridadDeCampana__c prioridad: [SELECT id, Name
                                                   FROM PrioridadDeCampana__c
                                                   WHERE Id IN :setPrioridesAsociadasASubscripciones]) {
        	mapaPrioridadesExisntentes.put(prioridad.Id, prioridad);   
        }
        
        //Se obtienen aquellas subscripciones de campañas cuya prioridad no esté cerrada y el ID no sea el de los elementos con los que trabajamos
        for(SubscripcionACampana__c subscription: [SELECT id, Cuenta__c, PrioridadDeCampana__r.cerrado__c, PrioridadDeCampana__r.Campana__c, PrioridadDeCampana__r.Name
                                                   FROM SubscripcionACampana__c
                                                   WHERE PrioridadDeCampana__r.cerrado__c = false AND id NOT IN :subsIdSet AND Caso__c = null]) {
        	activeSubscriptionsByAccountId.put(subscription.Cuenta__c, subscription);                                 
        }
        
        for(SubscripcionACampana__c subscription: subscriptionList) {
            //Comprobamos si existe cuenta asociada a la subcripción y si es así, creamos un historico
            if(subscription.Cuenta__c <> null && activeSubscriptionsByAccountId.containsKey(subscription.cuenta__c)) {
                activeSubscription = activeSubscriptionsByAccountId.get(subscription.cuenta__c);
                subscriptionHistorical = new HistoricoDeSubscriptor__c();
                subscriptionHistorical.TipoDeInteraccion__c = 'Otro';
                subscriptionHistorical.SubscripcionACampana__c = activeSubscription.id;
                subscriptionHistorical.SubtipoDeInteraccion__c = 'Resubscripción a campaña';
                subscriptionHistorical.CampanaDeResubscripcion__c = subscription.campana__c;
                subscriptionHistoricals.add(subscriptionHistorical);
                
                
                //Set subscription as inactive and outside of the explorer queue.
                subscription.EnCola__c = false;
                Boolean duplicadoEnCampania = false;
                if(subscription.PrioridadDeCampana__c != null && mapaPrioridadesExisntentes.containsKey(subscription.PrioridadDeCampana__c)){                    
                	PrioridadDeCampana__c prioridadAsociada = mapaPrioridadesExisntentes.get(subscription.PrioridadDeCampana__c);
                    if(prioridadAsociada.Name.equals(Constantes.DUPLICADO_OTRA_CAMPANIA)){
                        duplicadoEnCampania = true;
                    } 
                }
                System.debug('duplicadoEnCampania:::::::::::'+duplicadoEnCampania);
                //GZP - 10-08-2020 Si el estado de la prioridad de campaña es distinto de duplicado a otra campaña, se establece a inactivo
                if(!duplicadoEnCampania){
                    if(prioritiesByCampaignAndName.containsKey(subscription.campana__c) &&  prioritiesByCampaignAndName.get(subscription.campana__c).containskey('INACTIVO')) {
                           subscription.PrioridadDeCampana__c = prioritiesByCampaignAndName.get(subscription.campana__c).get('INACTIVO').id;
                    }
                }
                
            }
        }
        
        Database.insert(subscriptionHistoricals);
    }
    
    /*
    public static void subscriberValidations(List<SubscripcionACampana__c> newSubscriptionList, Map<Id, SubscripcionACampana__c> oldSubscriptionMap) {
        Map<Id, Map<String, PrioridadDeCampana__c>> priorities;
        Set<Id> campanaIdSet = new Set<Id>();
        SubscripcionACampana__c oldSubscription, newSubscription;
        PrioridadDeCampana__c campaignPriority;
        
        for(SubscripcionACampana__c subscription: newSubscriptionList) {
        	if(subscription.Campana__c <> null)
                campanaIdSet.add(subscription.Campana__c);
        }
        
        priorities = getSubscriptionsAvailablePrioritiesByCampaignAndName(campanaIdSet);
        
        for(SubscripcionACampana__c subscription: newSubscriptionList) {
            oldSubscription = oldSubscriptionMap.get(subscription.id);
            campaignPriority = priorities.get(subscription.campana__c).get('NUEVO');
            
            if(oldSubscription <> null) {
                if(subscription.PrioridadDeCampana__c == oldSubscription.PrioridadDeCampana__c && 
                   subscription.PrioridadDeCampana__c == campaignPriority.id &&
                   campaignPriority.Name.equalsIgnoreCase('NUEVO')) {
                    subscription.addError('El nuevo estado del subscriptor no puede ser "nuevo"');
                }
            }
        }
    }
    */
    public static void removeSubscriptionsHistoricals(List<SubscripcionACampana__c> subscriptions) {        
        Set<Id> subscriptionsIds = new Set<Id>();
        List<HistoricoDeSubscriptor__c> subscriptionHistoricals;
        
        for(SubscripcionACampana__c subscription: subscriptions) {
        	subscriptionsIds.add(subscription.id);
        }
        
        subscriptionHistoricals = [SELECT Id 
                                   FROM HistoricoDeSubscriptor__c 
                                   WHERE SubscripcionACampana__c IN :subscriptionsIds];
        
        delete subscriptionHistoricals;
    }
}