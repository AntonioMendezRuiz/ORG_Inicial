@RestResource(urlMapping='/v2/Subscriptions/*')
global without sharing class SubscriptionService2
{
    
    public static final string CLASE = 'SubscriptionService2';
    public class MissingFieldException extends Exception {}
    public class CampaignException extends Exception {}
    public class URLException extends Exception {}
    
    public class ResponseBody {
        public Integer statusCode;
        public Integer errorCode;
        public String message;
        public String recordId;
        
        public ResponseBody(Integer statusCode, Integer errorCode, String message) {
            this.statusCode = statusCode;
            this.errorCode = errorCode;
            this.message = message;
        }
        
        public ResponseBody(Integer statusCode, Integer errorCode, SubscriptionOperationResult subscriptionOperationResult) {
            this.statusCode = statusCode;
            this.errorCode = errorCode;
            
            if(statusCode == 200 && errorCode == 0) {
                this.message = subscriptionOperationResult.getSuccessMessage();
                switch on (this.message) {
                    when 'NUEVO' {
                        this.message = 'LEAD CREADO ACTIVO.';
                    }
                    when 'INACTIVO' {
                        this.message = 'LEAD CREADO DUPLICADO MISMA CAMPAÑA.';
                    }
                    when 'DUPLICADO OTRA CAMPAÑA' {
                        this.message = 'LEAD CREADO DUPLICADO OTRA CAMPAÑA.'; 
                    }
                }
                
            }
            
            if(subscriptionOperationResult <> null)
            	this.recordId = subscriptionOperationResult.getRecord().id;
        }
        
        public RestResponse formatAsRestResponse() {
            RestResponse restResponse = RestContext.response;
            
            restResponse.statusCode = statusCode;
            restResponse.responseBody = Blob.valueOf(JSON.serialize(this));
            
            return restResponse;
        }
    }
    
    private class AccountValidation extends Validation {}
	private class URIValidation extends Validation {}
    private class CampaignValidation extends Validation {}
    
    public class SubscriptionOperationResult extends OperationResult {}
    
    private static Account upsertAccount(Account account) {
        
    	string metodo = ' -- upsertAccount -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        
        List<Account> accounts = [SELECT id 
                                  FROM Account 
                                  WHERE //(FirstName = :account.FirstName AND LastName = :account.LastName) AND 
                                        (account.PersonEmail <> null AND PersonEmail = :account.PersonEmail) OR
                                 	     (account.personHomePhone <> null AND personHomePhone = :account.personHomePhone) OR
                                 	     (account.personOtherPhone <> null AND personOtherPhone = :account.personOtherPhone) OR 
                                 	     (account.personMobilePhone <> null AND personMobilePhone = :account.personMobilePhone) ];
        
        if(!accounts.isEmpty()) {
            account.id = accounts[0].id;
        } else {
            account.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        }        
        
        
        upsert account;     
        System.debug(CLASE+metodo+'FIN');
        
        return account;
    }
    
    private static SubscripcionACampana__c createSubscriptionObject(String campaignExternalId, String externalLeadId, Account account) {
        
        
    	string metodo = ' -- createSubscriptionObject -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        SubscripcionACampana__c subscription = new SubscripcionACampana__c();
        
        subscription.Cuenta__c = account.id;
        subscription.Campana__r = new Campana__c(ExternalId__c = campaignExternalId);
        subscription.ExternalId__c = externalLeadId;
        
        // Rellenar campos subscripción con contenido campos TECH
        subscription.PrioridadIndividual__c = 0;
        subscription.Potencia__c = account.TECH_power__pc;
        subscription.CompaniaActualGas__c = account.TECH_currentGasCompany__pc;
        subscription.CompaniaActualLuz__c = account.TECH_currentElectricalCompany__pc;
        subscription.Tramo__c = account.TECH_Lot__pc;
        subscription.PermanenciaGas__c = account.TECH_gasPermanence__pc;
        subscription.CUPSGas__c = account.TECH_gasCUPS__pc;
        subscription.PermanenciaLuz__c = account.TECH_electricityPermanence__pc;
        subscription.CUPSLuz__c = account.TECH_electricityCUPS__pc;
        //Se añade el campo Fecha APlazamiento
        subscription.FechaHoraAplazamiento__c = account.TECH_llamadaAplazamiento__c;
        
        
        System.debug(CLASE+metodo+'FIN');
        
        return subscription;
    }
    
    public static ResultadoActualizarSubscripcionCerrada actualizaSubscripcionCerrada(String campaignExternalId, String externalLeadId, Account account){
        
        string metodo = ' -- actualizaSubscripcionCerrada -- ';
        System.debug(CLASE+metodo+'INICIO'); 
        ResultadoActualizarSubscripcionCerrada rasc = new ResultadoActualizarSubscripcionCerrada();
        rasc.resultado = false;

        Set<String> statusCerrados = new Set<String>();
        statusCerrados.add('Sí contrata');
        statusCerrados.add('No Contrata');
        statusCerrados.add('Ilocalizable');
        statusCerrados.add('No valido');
        //INACTIVO NO SE TIENE EN CUENTA PUES PUEDE HABER VARIOS
        
        
        List<SubscripcionACampana__c> noClosedSubscriptionsCurrentCampaign = [SELECT id,LastModifiedDate   
                                                       				  	    FROM   SubscripcionACampana__c
                                                       				  		WHERE  Cuenta__c = :account.id AND
                                                      		  				 	   Campana__r.ExternalId__c = :campaignExternalId AND
                                                                     		 	   PrioridadDeCampana__r.Name IN : statusCerrados 
                                                                               	   ORDER BY LastModifiedDate DESC LIMIT 1];
        //Comprobamos si no hay subscripciones CERRADAS, si la hay, la actualizamos, si no, creamos una nueva
        if(!noClosedSubscriptionsCurrentCampaign.isEmpty()){  
            rasc.resultado = true;  
        	rasc.subscripcion = noClosedSubscriptionsCurrentCampaign[0];
            
        }
        System.debug(CLASE+metodo+'FIN'); 
        return rasc;
    }
    
    public class ResultadoActualizarSubscripcionCerrada{
        public boolean resultado; 
        public SubscripcionACampana__c subscripcion;
    }
        
    private static SubscriptionOperationResult createSubscriptionAsNew(String campaignExternalId, String externalLeadId, Account account) {        
        
    	string metodo = ' -- createSubscriptionAsNew -- ';
        System.debug(CLASE+metodo+'INICIO');        
            
        Map<String, Id> statusByName = CampanaHelper.getStatusByNameByCampaignExternalId(campaignExternalId);
        SubscriptionOperationResult subscriptionOperationResult = new SubscriptionOperationResult();
        SubscripcionACampana__c resultSusbription = new SubscripcionACampana__c();
        
        SubscripcionACampana__c subscription = createSubscriptionObject(campaignExternalId, externalLeadId, account);    
        subscription.PrioridadDeCampana__c = statusByName.get('NUEVO');
        subscription.EnCola__c = true;
        insert subscription;
        resultSusbription = subscription;        
        
        subscriptionOperationResult.setSuccess('NUEVO');
        subscriptionOperationResult.setRecord(resultSusbription);
        
        
        //COMPROBAMOS QUE NO EXISTA NINGUNA SUBSCRIPCIONA  CERRADA, si la HAY ACTUALIZAMOS para que quede reflejada en la fecha de ultima modificación
        ResultadoActualizarSubscripcionCerrada compruebaSubscripcionCerrada = actualizaSubscripcionCerrada(campaignExternalId,externalLeadId,account);
        if(compruebaSubscripcionCerrada.resultado){   
            //Obtenemos la subscripcion cerrada y la actualizamos
            SubscripcionACampana__c subscripcionCerrada = compruebaSubscripcionCerrada.subscripcion;
            update subscripcionCerrada;
        }        
        
        
        System.debug(CLASE+metodo+'FIN');
        return subscriptionOperationResult;
    }
    
    private static SubscriptionOperationResult createSubscriptionAsInactive(String campaignExternalId, String externalLeadId, Account account) {
        
        
        string metodo = ' -- createSubscriptionAsInactive -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        Map<String, Id> statusByName = CampanaHelper.getStatusByNameByCampaignExternalId(campaignExternalId);
        SubscriptionOperationResult subscriptionOperationResult = new SubscriptionOperationResult();
        SubscripcionACampana__c subscription = createSubscriptionObject(campaignExternalId, externalLeadId, account);        
        
        //Comprobamos Si hay subscripciones ACTIVAS y sí es así, las actualizamos:
        Boolean subscripcionesActivas = actualizaEstadoAbiertoSuscripcion(subscription);
        if(subscripcionesActivas){
              
            subscription.PrioridadDeCampana__c = statusByName.get('INACTIVO');
            subscription.EnCola__c = false;
            
            //INSERTAMOS LA SUBSCRIPCION INACTIVA
            insert subscription;       
            
            subscriptionOperationResult.setSuccess('INACTIVO');
        }else{
            //COMPROBAMOS QUE NO EXISTA NINGUNA SUBSCRIPCIONA  CERRADA, si la HAY ACTUALIZAMOS, En caso contrario es que ya existe en otra campaña como abierto, asique se inserta como duplicado
            ResultadoActualizarSubscripcionCerrada compruebaSubscripcionCerrada = actualizaSubscripcionCerrada(campaignExternalId,externalLeadId,account);        
            if(compruebaSubscripcionCerrada.resultado){   
                
                subscription.PrioridadDeCampana__c = statusByName.get('NUEVO');     
                insert subscription;
                
                subscriptionOperationResult.setSuccess('NUEVO');
            }else{
        		subscription.PrioridadDeCampana__c = statusByName.get('DUPLICADO OTRA CAMPAÑA');
                subscription.EnCola__c = false;

                //INSERTAMOS LA SUBSCRIPCION DUPLICADA
                insert subscription;                   

        		subscriptionOperationResult.setSuccess('DUPLICADO OTRA CAMPAÑA');
            }
        }
        
            subscriptionOperationResult.setRecord(subscription);
            
        System.debug(CLASE+metodo+'FIN');
        return subscriptionOperationResult;
    }
    
    public static boolean actualizaEstadoAbiertoSuscripcion(SubscripcionACampana__c sub){
        
        string metodo = ' -- actualizaEstadoAbiertoSuscripcion -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        
        Set<String> statusAbiertos = new Set<String>();
        statusAbiertos.add('Aplazado');
        statusAbiertos.add('Aplazado Urgente');
        statusAbiertos.add('Contactado');
        statusAbiertos.add('No contactado');
        statusAbiertos.add('Nuevo');
        
        boolean resultado = false;
        
        List<SubscripcionACampana__c> listaSubscripconesActivas = [Select id, PrioridadDeCampana__r.Name, PrioridadIndividual__c, Campana__r.ExternalId__c From SubscripcionACampana__c
                                          		Where Cuenta__c =: sub.Cuenta__c 
                                                      AND Campana__r.ExternalId__c =: sub.Campana__r.ExternalId__c 
                                                      AND PrioridadDeCampana__r.Name IN : statusAbiertos limit 1];            
        
        
        if(!listaSubscripconesActivas.isEmpty()){
            
            SubscripcionACampana__c subAux = listaSubscripconesActivas[0];
        	Map<String, Id> statusByName = CampanaHelper.getStatusByNameByCampaignExternalId(subAux.Campana__r.ExternalId__c);
             
            PrioridadIndividual__mdt prioridad = [SELECT PuntosDePrioridad__c FROM PrioridadIndividual__mdt WHERE DeveloperName =:'PrioridadIndividual' LIMIT 1];
            
            if(subAux.PrioridadDeCampana__r.Name.equals('Nuevo')){            
                subAux.FechaHoraAplazamiento__c = System.now();
                subAux.PrioridadIndividual__c +=  prioridad.PuntosDePrioridad__c;
            }else if(subAux.PrioridadDeCampana__r.Name.equals('No contactado')){
                subAux.PrioridadDeCampana__c = statusByName.get('NUEVO');     
                subAux.FechaHoraAplazamiento__c = System.now();
                subAux.PrioridadIndividual__c +=  prioridad.PuntosDePrioridad__c;
            }else if(subAux.PrioridadDeCampana__r.Name.equals('Aplazado')){
                subAux.FechaHoraAplazamiento__c = System.now();    
                subAux.AplazadoA__c = null;
                subAux.PrioridadIndividual__c +=  prioridad.PuntosDePrioridad__c;
            }
            
            update subAux;
            System.debug(CLASE+metodo+'FIN');
            
            resultado = true;
        }
       
        return resultado;
        

    }
    
    private static SubscriptionOperationResult createSubscriptionAsDuplicated(String campaignExternalId, String externalLeadId, Account account, List<SubscripcionACampana__c> activeSubscriptionsOtherCampaigns) {
        
        
    	string metodo = ' -- createSubscriptionAsDuplicated -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        
        Map<String, Id> statusByName = CampanaHelper.getStatusByNameByCampaignExternalId(campaignExternalId);
        SubscriptionOperationResult subscriptionOperationResult = new SubscriptionOperationResult();
        
        //Actualizamos la subscripción existente de la otra campaña a activa a Estado nuevo y Agente Todos:
        
        SubscripcionACampana__c subExistente = activeSubscriptionsOtherCampaigns[0];        
        Boolean actualizaRelacionado = actualizaEstadoAbiertoSuscripcion(subExistente);
        System.debug('Actualiza el lead asociado abierto en la otra campaña');
        
        
        //Creamos la subscripción asociada a la nueva campaña con el valor "DUPLICADO OTRA CAMPAÑA"
        SubscripcionACampana__c subscription = createSubscriptionObject(campaignExternalId, externalLeadId, account);
           
        //COMPROBAR SI HAY MAS Leads asociados a la nueva campaña duplicados, para mostrar mensaje distinto
        List<SubscripcionACampana__c> listaSubscripconesActivas = [Select id From SubscripcionACampana__c
                                          		Where Cuenta__c =: account.Id 
                                                      AND Campana__r.ExternalId__c =: campaignExternalId
                                                      AND PrioridadDeCampana__r.Name =: Constantes.DUPLICADO_OTRA_CAMPANIA limit 1];    
        String resultado = '';
        //Si la lista de Subscripciones Duplicadas en Campaña no es vacío, devolvemos el valor INACTIVO en la respuesta del WS 
        //En caso contrario el Lead es la primera que se inserta en esa campaña y ya está en otra Acivo, asique se inserta coo duplicado OTRA CAMPAÑA
        if(!listaSubscripconesActivas.isEmpty()){   resultado = 'INACTIVO'; }
        else{  resultado = 'DUPLICADO OTRA CAMPAÑA';}
        
        System.debug('RESULTADOOO::: '+resultado);
             
        subscription.PrioridadDeCampana__c = statusByName.get(resultado);
        subscription.EnCola__c = false;
        insert subscription;
        System.debug('ha insertado la nueva subscripción');
        

        subscriptionOperationResult.setSuccess(resultado);        
        subscriptionOperationResult.setRecord(subscription);        
        
                

        System.debug(CLASE+metodo+'FIN');
        
        return subscriptionOperationResult;
    }
    
    private static void insertSubscriptionHistorical(String campaignExternalId, SubscripcionACampana__c activeSubscription) {
        
        
    	string metodo = ' -- insertSubscriptionHistorical -- ';
        System.debug(CLASE+metodo+'INICIO');
        
    	HistoricoDeSubscriptor__c subscriptionHistorical = new HistoricoDeSubscriptor__c();
        
        subscriptionHistorical.TipoDeInteraccion__c = 'Otro';
        subscriptionHistorical.SubscripcionACampana__c = activeSubscription.id;
        subscriptionHistorical.SubtipoDeInteraccion__c = 'Resubscripción a campaña';
        subscriptionHistorical.CampanaDeResubscripcion__r = new Campana__c(ExternalId__c=campaignExternalId);
        
        insert subscriptionHistorical;
        
        
        System.debug(CLASE+metodo+'FIN');
        
    }
    
    private static SubscriptionOperationResult insertSubscription(String campaignExternalId, String externalLeadId, Account account) {
        
        
    	string metodo = ' -- insertSubscription -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        SubscriptionOperationResult subscriptionOperationResult;
        
        List<SubscripcionACampana__c> activeSubscriptionsCurrentCampaign = [SELECT id 
                                                       				  	    FROM   SubscripcionACampana__c
                                                       				  		WHERE  Cuenta__c = :account.id AND
                                                      		  				 	   Campana__r.ExternalId__c = :campaignExternalId AND
                                                                     		 	   PrioridadDeCampana__r.Cerrado__c = False];
        
        List<SubscripcionACampana__c> duplicatedSubscriptionsCurrentCampaign = [SELECT id 
                                                       				  			FROM   SubscripcionACampana__c
                                                       				  			WHERE  Cuenta__c = :account.id AND
                                                      		  				 		   Campana__r.ExternalId__c = :campaignExternalId AND
                                                                     		  		   PrioridadDeCampana__r.Name Like '%Duplicado%'];
        
        List<SubscripcionACampana__c> activeSubscriptionsOtherCampaigns = [SELECT id, Campana__r.ExternalId__c ,Cuenta__c
                                                       				 	   FROM   SubscripcionACampana__c
                                                       				 	   WHERE  Cuenta__c = :account.id AND
                                                      		  					  Campana__r.ExternalId__c != :campaignExternalId AND
                                                                    	    	  PrioridadDeCampana__r.Cerrado__c = False];
        System.debug('Procede a realizar comprobaciones');
        // No hay subscripciones activas.
        System.debug('activeSubscriptionsCurrentCampaign: '+activeSubscriptionsCurrentCampaign);
        if(activeSubscriptionsCurrentCampaign.isEmpty() && activeSubscriptionsOtherCampaigns.isEmpty()) {
            System.debug('No hay subscripciones activas.');
            subscriptionOperationResult = createSubscriptionAsNew(campaignExternalId, externalLeadId, account);
        } else {
            System.debug('Entra en el else de insertSubscription');
            // Hay subscripciones activas en otra campaña.
            if(activeSubscriptionsCurrentCampaign.isEmpty() && !activeSubscriptionsOtherCampaigns.isEmpty()) {
            System.debug('Hay subscripciones activas en otra campaña');
                System.debug(activeSubscriptionsOtherCampaigns);
                subscriptionOperationResult = createSubscriptionAsDuplicated(campaignExternalId, externalLeadId, account,activeSubscriptionsOtherCampaigns);
            	insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsOtherCampaigns[0]);
                
            // Hay duplicados en campaña actual y hay activos en otras.
            } else if(!duplicatedSubscriptionsCurrentCampaign.isEmpty() && !activeSubscriptionsOtherCampaigns.isEmpty()) {
            System.debug('Hay duplicados en campaña actual y hay activos en otras.');
                subscriptionOperationResult = createSubscriptionAsInactive(campaignExternalId, externalLeadId, account);
                insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsOtherCampaigns[0]);
            // En cualquier otro caso, crear como inactiva.
            } else {
            System.debug('En cualquier otro caso, crear como inactiva.');
                subscriptionOperationResult = createSubscriptionAsInactive(campaignExternalId, externalLeadId, account);
                insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsCurrentCampaign[0]);
            }
            
        }
        
        /*
        if(activeSubscriptionsCurrentCampaign.isEmpty() && activeSubscriptionsOtherCampaigns.isEmpty()) {
            subscriptionOperationResult = createSubscriptionAsNew(campaignExternalId, externalLeadId, account);
        } else if(!activeSubscriptionsCurrentCampaign.isEmpty() && activeSubscriptionsOtherCampaigns.isEmpty()) {
            subscriptionOperationResult = createSubscriptionAsInactive(campaignExternalId, externalLeadId, account);
            insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsCurrentCampaign[0]);
        } else if(activeSubscriptionsCurrentCampaign.isEmpty() && !activeSubscriptionsOtherCampaigns.isEmpty()) {
            subscriptionOperationResult = createSubscriptionAsDuplicated(campaignExternalId, externalLeadId, account);
            insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsOtherCampaigns[0]);
        } else {
            subscriptionOperationResult = createSubscriptionAsDuplicated(campaignExternalId, externalLeadId, account);
            insertSubscriptionHistorical(campaignExternalId, activeSubscriptionsCurrentCampaign[0]);
        }
        */
        
        
        System.debug(CLASE+metodo+'FIN');
        
        return subscriptionOperationResult;
    }
    
    private static AccountValidation validateAccountFields(Account account) {
        
        
    	string metodo = ' -- validateAccountFields -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        AccountValidation accounValidation = new AccountValidation();
		
        if(String.isBlank(account.TECH_ExternalLeadId__pc))
        	throw new MissingFieldException('Missing TECH_ExternalLeadId__pc field.');
        
        if(String.isBlank(account.FirstName))
        	throw new MissingFieldException('Missing FirstName field.');
        
        if(String.isBlank(account.LastName))
        	throw new MissingFieldException('Missing LastName field.');
            
        if(String.isBlank(account.personMobilePhone))
        	throw new MissingFieldException('Missing PersonMobilePhone field.');
            
        accounValidation.setSuccess();
        
        System.debug(CLASE+metodo+'FIN');
        
        return accounValidation;
    }

    private static URIValidation validateURI(String URI) {
        
    	string metodo = ' -- validateURI -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        URIValidation uriValidation = new URIValidation();
		List<String> splittedUrl;
        
        if(String.isBlank(URI))
        	throw new URLException('URI cannot be blank.');
        
        splittedUrl = URI.split('/');
        
        if(splittedUrl.size() <> 4)
            throw new URLException('URI has not the correct format (apexrest/v1/Subscriptions/<CampaignExternalId>).');
        
        uriValidation.setSuccess();
        
        System.debug(CLASE+metodo+'FIN');
        
        return uriValidation;
    }
    
    private static CampaignValidation validateCampaign(String campaignExternalId) {
        
        
    	string metodo = ' -- validateCampaign -- ';
        System.debug(CLASE+metodo+'INICIO');
        
        CampaignValidation campaignValidation = new CampaignValidation();
		
        List<Campana__c> campaigns = [SELECT id 
                                      FROM   Campana__c
                                      WHERE  externalId__c = :campaignExternalId AND
                                     	     Estado__c = 'En progreso'];
        
        if(campaigns.isEmpty()) 
			throw new CampaignException('This campaign does not exist or is not in progress.');  
        
        if(campaigns.size() > 1) 
			throw new CampaignException('There are multiple active campaigns associated to this externalId.');  
        
        campaignValidation.setSuccess();
        
        System.debug(CLASE+metodo+'FIN');
        
        return campaignValidation;
    }
    
    
    @HttpPost
    global static void postSubscribers() {
        
    	string metodo = ' -- postSubscribers -- ';
        System.debug(CLASE+metodo+'INICIO');
        
    	RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        ResponseBody responseBody;
        List<String> splittedUrl;
        String requestBody = restRequest.requestBody.toString();
        String requestURI = restRequest.requestURI;
        String campaignExternalId;
        String externalLeadId;
        
        SubscriptionOperationResult subscriptionOperationResult;
        
        AccountValidation accountValidation;
        URIValidation uriValidation;
        CampaignValidation campaignValidation;
        Account account;
        
        try {
            uriValidation = validateURI(requestURI);
            splittedUrl = requestURI.split('/');
            campaignExternalId = splittedUrl[splittedUrl.size() - 1];
            
            campaignValidation = validateCampaign(campaignExternalId);
            account = (Account)JSON.deserialize(requestBody, Account.class);

            externalLeadId = account.TECH_ExternalLeadId__pc;
            
            accountValidation = validateAccountFields(account);
            
            if(accountValidation.isSuccess()) {
                account = upsertAccount(account);
                System.debug('Llama a insertSubscription::');
        		subscriptionOperationResult = insertSubscription(campaignExternalId, externalLeadId, account);
                responseBody = new ResponseBody(200, 0, subscriptionOperationResult);
            }
        
        // Revisar códigos de error.
        } catch(URLException e) {
        	responseBody = new ResponseBody(400, 401, 'INVALID_URL_ERROR: ' + e.getMessage());
        } catch(CampaignException e) {
        	responseBody = new ResponseBody(400, 406, 'INVALID_CAMPAIGN_ERROR: ' + e.getMessage());
        } catch(JSONException e) {
        	responseBody = new ResponseBody(400, 402, 'MALFORMED_BODY_ERROR');
        } catch(MissingFieldException e) {
            responseBody = new ResponseBody(400, 403, 'REQUIRED_FIELD_ERROR: ' + e.getMessage());
        } catch(DmlException e) {
            if(e.getMessage().containsIgnoreCase('The existing country/territory') && e.getMessage().containsIgnoreCase('recognize the')) {
                responseBody = new ResponseBody(400, 408, 'MISMATCHED_ISO_CODES_ERROR');     
            } else if (e.getMessage().containsIgnoreCase('DUPLICATE_VALUE')) {
                System.debug(e.getMessage());
                responseBody = new ResponseBody(400, 409, 'DUPLICATE_VALUE: ' + e.getMessage().substringAfter('duplica el valor en el registro con Id.: ').substringBefore(': []'));
            } else {
                responseBody = new ResponseBody(400, 410, e.getMessage().substringAfter('first error:')); 
            }
        } catch(Exception e) {
            responseBody = new ResponseBody(500, 1, 'UNEXPECTED_ERROR: ' + e.getMessage());
        }
        
        restResponse = responseBody.formatAsRestResponse();
        LogRegistrationHelper.insertSubscriptionServiceLogs(restRequest, restResponse, responseBody, externalLeadId, account, subscriptionOperationResult,
                                                            campaignExternalId);
        
        System.debug(CLASE+metodo+'FIN');
    }
}