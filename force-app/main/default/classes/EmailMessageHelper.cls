public class EmailMessageHelper {
	static final String customersEmail = PAD.automationParameters.ETCClientesEmail__c.toUpperCase();
    static final String billingEmail = PAD.automationParameters.ETCFacturacionEmail__c.toUpperCase();
    static final String incidencesEmail = PAD.automationParameters.ETCIncidenciasEmail__c.toUpperCase();
    static final String infoEmail = PAD.automationParameters.ETCInfoEmail__c.toUpperCase();
    
    public static void assignCaseType(List<EmailMessage> emailMessages){

        Set<Id> casesIdSet = new Set<Id>();
        Map<Id,Case> casesToUpdateMap;
        Case caseToUpdate;
        String toAddress;
        
        for(EmailMessage em: emailMessages) {
            if(em.ParentId <> null && em.parentId.getSobjectType() == Case.getSObjectType()){
                casesIdSet.add(em.parentId);
            }
        }
        
		casesToUpdateMap = new Map<Id,Case>([SELECT id, tipo__c FROM Case WHERE id IN :casesIdSet AND tipo__c = null AND origin = 'Email']);
        
        for(EmailMessage em: emailMessages) {
            if(em.ParentId <> null && em.parentId.getSobjectType() == Case.getSObjectType() 
               && casesToUpdateMap.containsKey(em.parentId)){
               caseToUpdate = casesToUpdateMap.get(em.parentId);
               
               toAddress = em.toAddress.toUpperCase();
                if(toAddress.equalsIgnoreCase(infoEmail))
                    caseToUpdate.tipo__c = 'Info';
                else if (toAddress.equalsIgnoreCase(incidencesEmail))
                    caseToUpdate.tipo__c = 'Incidencias';
                else if (toAddress.equalsIgnoreCase(billingEmail))
                    caseToUpdate.tipo__c = 'Facturación';
                else if (toAddress.equalsIgnoreCase(customersEmail))
                    caseToUpdate.tipo__c = 'Clientes';
                else
                    continue;
            }
        }
        
        update casesToUpdateMap.values();
    }
}