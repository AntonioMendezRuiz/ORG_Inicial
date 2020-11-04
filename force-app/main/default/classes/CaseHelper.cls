public class CaseHelper {
    
    public static void upsertCaseSubscription(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        List<SubscripcionACampana__c> subscriptionList = new List<SubscripcionACampana__c>();
        Map<Id, Map<String, Id>> campanaStatuses;
        SubscripcionACampana__c subscription;
        Map<String, Id> caseCampaigns = CampanaHelper.getCaseCampaigns();
        Set<Id> caseCampaignsIdSet = new Set<Id>(caseCampaigns.values());
        Map<Id, Map<String, Id>> campanaStatus = CampanaHelper.getCampanaAvailableStatus(caseCampaignsIdSet);
        Map<Id, Id> caseSubscriptionMap = new Map<Id, Id>();
        List<SubscripcionACampana__c> existingSubscriptionList;
        Id campanaId;
        
        // Retrieve cases which already have a subscription.
        existingSubscriptionList = [SELECT id, caso__c FROM SubscripcionACampana__c WHERE caso__c IN :oldCaseMap.keySet() ];
        for(SubscripcionACampana__c subs: existingSubscriptionList) {
            caseSubscriptionMap.put(subs.caso__c, subs.id);
        }
        
        // Create or update cases (already existing) with the correct lookup/master detail assignment.
        for(Case newCase: newCaseList) {                      
            if(newCase.Origin == 'Email' && 
               newCase.AccountId <> null && 
               newCase.tipo__c <> null && 
               newCase.tipo__c <> oldCaseMap.get(newCase.id).Tipo__c &&
               caseCampaigns.containsKey(newCase.tipo__c.toUpperCase())) {
                   campanaId = caseCampaigns.get(newCase.Tipo__c.toUpperCase());
                   system.debug('P1 ::');
                   // If does exist a campaign with a priority status 'NUEVO' linked, creates the Campaign Subscription.
                   if(campanaId <> null && campanaStatus.containsKey(campanaId) && campanaStatus.get(campanaId).containsKey('NUEVO')) {
                       subscription = new SubscripcionACampana__c();
                       
                       subscription.Campana__c = campanaId;
                       subscription.Caso__c = newCase.id;
                       subscription.Cuenta__c = newCase.AccountId;
                       subscription.PrioridadDeCampana__c = campanaStatus.get(subscription.Campana__c).get('NUEVO');
                       
                       subscriptionList.add(subscription);
                   }
                   
                   
               }
        }
        upsert subscriptionList;
    }
    
    
}