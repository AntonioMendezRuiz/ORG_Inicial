public class CampanaHelper {
    public static final Map<String, Id> caseCampaigns = new Map<String, Id>();
    
    public static Map<Id, Campaign> getCampaigns(Set<Id> standardCampaignIds) {
        Map<Id,Campaign> standardCustomCampaignMap = new Map<Id, Campaign>();
        
        for(Campaign campaign: [SELECT id, Campana__c, recordtypeid
                                FROM Campaign 
                                WHERE id IN :standardCampaignIds]) {
            standardCustomCampaignMap.put(campaign.id, campaign);
        }
        return standardCustomCampaignMap;
    }
    
    public static Map<String, Campana__c> getCampaignsByExternalId(Set<String> externalIds) {
        Map<String, Campana__c> campaignsByExternalId = new Map<String, Campana__c>();
        for(Campana__c campaign: [SELECT id, ExternalId__c
                                  FROM Campana__c 
                                  WHERE ExternalId__c IN :externalIds AND ExternalId__c <> null]) {
        	campaignsByExternalId.put(campaign.ExternalId__c.toUpperCase(), campaign);                              
        }
        return campaignsByExternalId;
    }
    
    public static Map<String, Id> getCaseCampaigns() {
        if(CampanaHelper.caseCampaigns.isEmpty()) {
            for(Campana__c campaign: [SELECT id, TipoDeCaso__c FROM Campana__c WHERE tipo__c = 'Caso' AND TipoDeCaso__c <> null]){
                caseCampaigns.put(campaign.TipoDeCaso__c.toUpperCase(), campaign.id);
            }
        }
        
        return CampanaHelper.caseCampaigns;
    }
    
    public static Map<String, Id> getStatusByNameByCampaignExternalId(String campaignExternalId) {
        Map<String, Id> statusByName = new Map<String, Id>();
        
        for(PrioridadDeCampana__c priority : [SELECT id, campana__c, name 
                                              FROM PrioridadDeCampana__c
                                              WHERE campana__r.ExternalId__c = :campaignExternalId
                                             ]) {
			statusByName.put(priority.name.toUpperCase(), priority.id);                                                               
        }
        return statusByName;
    }
    
    public static Map<Id, Map<String, Id>> getCampanaAvailableStatus(Set<Id> campanaIdSet) {
        Map<Id, Map<String, Id>> statusByCampanaIdStatusName = new Map<Id, Map<String, Id>>();
        Map<String, Id> statusNameMap;
        for(PrioridadDeCampana__c priority : [SELECT id, campana__c, name 
                                              FROM PrioridadDeCampana__c
                                              WHERE campana__c IN :campanaIdSet
                                             ]) {
                                                 if(!statusByCampanaIdStatusName.containsKey(priority.campana__c))
                                                     statusByCampanaIdStatusName.put(priority.campana__c, new Map<String, Id>());
                                                 statusNameMap = statusByCampanaIdStatusName.get(priority.campana__c);
                                                 statusNameMap.put(priority.name.toUpperCase(), priority.id);                                                               
        }
        return statusByCampanaIdStatusName;
    }
    
    public static Set<Id> getCampanaIdSet(Set<String> externalIds) {
        Set<Id> campanaIdSet = new Set<Id>();
        
        for(Campana__c campana: [SELECT id 
                                 FROM Campana__c
                                 WHERE ExternalId__c IN :externalIds 
                                   AND ExternalId__c <> null]) {
        	campanaIdSet.add(campana.id); 
        }
        return campanaIdSet;
    }
    
    public static void createPrioridadesCampana(List<Campana__c> newList) {
        List<PrioridadDeCampana__c> prioridadCampanaList = new List<PrioridadDeCampana__c>();
        PrioridadDeCampana__c prioridadDeCampana;
        
        //Retrieve priority types from GlobalValueSet
        Schema.DescribeFieldResult estadoFieldResult = PrioridadDeCampana__c.TECH_Estado__c.getDescribe();
        Schema.sObjectField estadoField = estadoFieldResult.getSObjectField();
        List<PicklistEntry> entries = estadoField.getDescribe().getPicklistValues();
        
        //For every campaign, create a every linked PrioridadDeCampana__c.
        for(Campana__c campana: newList) {
            for(PicklistEntry e: entries) {
                prioridadDeCampana = new PrioridadDeCampana__c();
                prioridadDeCampana.Campana__c = campana.id;
                prioridadDeCampana.Name = e.value;
                prioridadDeCampana.Puntuacion__c = 0;
                if(e.value.equalsIgnoreCase('INACTIVO') || e.value.equalsIgnoreCase('SÍ CONTRATA') ||
                   e.value.equalsIgnoreCase('NO CONTRATA') || e.value.equalsIgnoreCase('NO VÁLIDO') || 
                   e.value.containsIgnoreCase('DUPLICADO'))
                    prioridadDeCampana.Cerrado__c = true;
                
                if(e.value.equalsIgnoreCase('SÍ CONTRATA')) {
                    prioridadDeCampana.Contrata__c = true;
                }
                
                prioridadCampanaList.add(prioridadDeCampana);
            }
        }
        
        insert prioridadCampanaList;
        
    }
    
}