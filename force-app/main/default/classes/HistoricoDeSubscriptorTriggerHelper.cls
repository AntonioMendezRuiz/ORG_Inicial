public class HistoricoDeSubscriptorTriggerHelper {
    
   	/**
   	* Updates SubscripcionACampana__c priority to 'ILOCALIZABLE' in case there are 7 or more
	* missed calls in the related historical.
   	* @param List<HistoricoDeSubscriptor__c> List of historicals.
   	* @return void
   	*/
    public static void updateSubscriptorStatus(List<HistoricoDeSubscriptor__c> historicalList){
        Integer failedCallsLimit = Integer.valueOf(PAD.automationParameters.FailedCallsUnreachable__c);
        Set<Id> subscripcionACampanaIdSet = new Set<Id>();
        Set<Id> campanaIdSet = new Set<Id>();
        Map<Id, Map<String, Id>> campanaAvailableStatus;
        Map<Id, SubscripcionACampana__c> subscripcionACampanaToUpdateMap;
        SubscripcionACampana__c campanaSubscription;
        Id priorityId;
        
        for(HistoricoDeSubscriptor__c historyEntry: historicalList) {
            subscripcionACampanaIdSet.add(historyEntry.subscripcionACampana__c);
            campanaIdSet.add(historyEntry.campanaId__c);
        }
        
        campanaAvailableStatus = CampanaHelper.getCampanaAvailableStatus(campanaIdSet);
        subscripcionACampanaToUpdateMap = new Map<Id, SubscripcionACampana__c>([SELECT id, PrioridadDeCampana__c, Campana__c 
                                                                                FROM SubscripcionACampana__c
                                                                                WHERE id IN :subscripcionACampanaIdSet
                                                                                FOR UPDATE]);
        
        for(AggregateResult ar: [SELECT subscripcionACampana__c, Count(id) 
                                 FROM HistoricoDeSubscriptor__c 
                                 WHERE TipoDeInteraccion__c = 'Llamada' AND ResultadoInteraccion__c = 'No contesta' AND
                                 subscripcionACampana__c IN :subscripcionACampanaIdSet
                                 GROUP BY subscripcionACampana__c 
                                 HAVING Count(id) >= :failedCallsLimit]) {
        	campanaSubscription = subscripcionACampanaToUpdateMap.get((Id)ar.get('SubscripcionACampana__c'));

            // Check if does exists any 'ILOCALIZABLE' status in the campaign and assigns it in case it does.
            if(campanaAvailableStatus.containsKey(campanaSubscription.campana__c) && 
            	campanaAvailableStatus.get(campanaSubscription.campana__c).containsKey('ILOCALIZABLE')){
                priorityId = campanaAvailableStatus.get(campanaSubscription.campana__c).get('ILOCALIZABLE');
                campanaSubscription.PrioridadDeCampana__c = priorityId;
            }                
        }      
        update subscripcionACampanaToUpdateMap.values();
    }
    
}