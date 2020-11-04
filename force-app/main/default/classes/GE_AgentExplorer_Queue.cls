public with sharing class GE_AgentExplorer_Queue {
    public class ExplorerException extends Exception {}
    
    public static SubscripcionACampana__c getSubscription() {
        Datetime now =  System.now();
        
        Id currentUserId = UserInfo.getUserId();
        
        List<SubscripcionACampana__c> subscriptionList = [SELECT id, Cuenta__c, Cuenta__r.Name, Cuenta__r.IsPersonAccount, Cuenta__r.PersonEmail, Cuenta__r.PersonHomePhone, 
                                                          Cuenta__r.PersonMailingState, Cuenta__r.PersonMailingStateCode, Cuenta__r.PersonMobilePhone, Campana__c, Campana__r.Estado__c,
                                                		  PrioridadDeCampana__r.Name, PermanenciaGas__c, PermanenciaLuz__c, CUPSGas__c, CUPSLuz__c, 
                                                		  Cuenta__r.lastname, Cuenta__r.firstname, Cuenta__r.middlename, Campana__r.name,
                                                		  CompaniaActualGas__c, CompaniaActualLuz__c, Potencia__c, PrioridadDeCampana__c, Caso__c,
                                                		  Tramo__c, Descripcion__c,  PrioridadTotal__c, PrioridadDeLaCampana__c, EnCola__c, convertido__c,
                                                		  AplazadoA__c, MotivoInvalido__c, FechaHoraAplazamiento__c, MotivoDePerdida__c, CorreoDelTitularDelContrato__c, OtherElectricCompany__c,
                                                          OtherGasCompany__c, Cuenta__r.TECH_otherElectricityCompany__pc, Cuenta__r.TECH_otherGasCompany__pc 
                                                FROM SubscripcionACampana__c
                                                WHERE Convertido__c = false AND EnCola__c = true 
                                                  AND PrioridadDeCampana__r.cerrado__c = false
                                                  AND Campana__r.Estado__c = 'En progreso' AND
                                                ((FechaHoraAplazamiento__c = null AND AplazadoA__c = null)                                OR 
                                                 (FechaHoraAplazamiento__c = null AND AplazadoA__c = :currentUserId)                        OR  
                                                 (FechaHoraAplazamiento__c <= :now AND AplazadoA__c = null)              OR
                                                 (FechaHoraAplazamiento__c <= :now AND AplazadoA__c = :currentUserId))
                                                ORDER BY PrioridadTotal__c DESC NULLS LAST, PrioridadDeLaCampana__c DESC NULLS LAST, FechaHoraAplazamiento__c DESC NULLS LAST,  CreatedDate DESC LIMIT 1];
        return subscriptionList.isEmpty() ? null : subscriptionList[0];
    }
    
    
    public static void blockSubscription(SubscripcionACampana__c subscription) {
        if(subscription <> null && subscription.id <> null) {
            SubscripcionACampana__c sub = new SubscripcionACampana__c(id=subscription.id);
            sub.EnCola__c = false;
            update sub;
        }
    }
    

    public static void setSubscription(Account subscriberAccount, SubscripcionACampana__c subscription, Case subscriberCase) {
        Map<Id, PrioridadDeCampana__c> prioritiesById;
        PrioridadDeCampana__c campaignPriority;
		Contract subscriberContract;
        Datetime postponeDatetime;
        
        if(subscription <> null && subscription.PrioridadDeCampana__c <> null) {
            prioritiesById = SubscripcionACampanaHelper.getSubscriptionAvailablePrioritiesById(subscription);
            
        	if(prioritiesById <> null && prioritiesById.containsKey(subscription.PrioridadDeCampana__c)) {
        		campaignPriority = prioritiesById.get(subscription.PrioridadDeCampana__c);
                
                if(campaignPriority.PostponeMinutes__c <> null)
					postponeDatetime = Datetime.now().addMinutes(Integer.valueOf(campaignPriority.PostponeMinutes__c));
                
                if(campaignPriority.Name.equalsIgnoreCase('NUEVO'))
                    throw new IllegalArgumentException('El nuevo estado del subscriptor no puede ser "nuevo"');
				// Set the subscription back to the queue according to its state.
        		subscription.convertido__c = campaignPriority.Cerrado__c && campaignPriority.Contrata__c;
        		subscription.EnCola__c = !campaignPriority.Cerrado__c;
                
                if(!campaignPriority.Name.containsIgnoreCase('APLAZADO')) {
                    subscription.FechaHoraAplazamiento__c = postponeDatetime;
                }
                
                // If engaged, create related contract.
                if(campaignPriority.Contrata__c) {
                    subscriberContract = createContract(subscription);
                }
                
           	}
            update subscription;
            
            // Grant user access to the campaign.
            if(!String.isEmpty(subscription.aplazadoA__c) && !String.isEmpty(subscription.campana__c))
            	grantAccessToCampaign(subscription.aplazadoA__c, subscription.campana__c);
        }	
        
        if(subscriberContract <> null)  insert subscriberContract;
        if(subscriberCase <> null)		update subscriberCase;
        if(subscriberAccount <> null) {
            // Copy subscription fields to account
            subscriberAccount.TECH_currentGasCompany__pc = subscription.CompaniaActualGas__c;
            subscriberAccount.TECH_currentElectricalCompany__pc = subscription.CompaniaActualLuz__c;
            subscriberAccount.TECH_gasCUPS__pc = subscription.CUPSGas__c;
            subscriberAccount.TECH_electricityCUPS__pc = subscription.CUPSLuz__c;
            subscriberAccount.TECH_gasPermanence__pc = subscription.PermanenciaGas__c;
            subscriberAccount.TECH_electricityPermanence__pc = subscription.PermanenciaLuz__c;
            subscriberAccount.TECH_Power__pc = subscription.Potencia__c;
            subscriberAccount.TECH_Lot__pc = subscription.Tramo__c;
            subscriberAccount.TECH_Campaign__pc = subscription.Campana__r.name;
			subscriberAccount.TECH_CampaignStatus__pc = campaignPriority.name;
            subscriberAccount.TECH_LossReason__pc = subscription.MotivoDePerdida__c;
            subscriberAccount.TECH_otherElectricityCompany__pc = subscription.OtherElectricCompany__c;
            subscriberAccount.TECH_otherGasCompany__pc = subscription.OtherGasCompany__c;
            /* TO BE CONFIRMED 
            subscriberAccount.TECH_otherElectricityCompany__c = subscription.Campana__r.name;
            subscriberAccount.TECH_otherGasCompany__c = subscription.Campana__r.name;
            */
            update subscriberAccount;
        }
    }
    
    private static void grantAccessToCampaign(Id postponeUserId, Id campaignId) {
    	Campana__share cs = new Campana__share();
        cs.ParentId = campaignId;
        cs.UserOrGroupId = postponeUserId;
        cs.AccessLevel = 'Edit';
        
        Database.SaveResult sr = Database.insert(cs,false);
    }
    
    private static Contract createContract(SubscripcionACampana__c subscription) {
        Contract subscriberContract = new Contract();
        subscriberContract.accountId = subscription.Cuenta__c;
        subscriberContract.Status = 'Draft';
        subscriberContract.StartDate = Date.today();
        subscriberContract.ContractTerm = 12;
        subscriberContract.CorreoDelTitularDelContrato__c = subscription.CorreoDelTitularDelContrato__c;
        return subscriberContract;
    }
}