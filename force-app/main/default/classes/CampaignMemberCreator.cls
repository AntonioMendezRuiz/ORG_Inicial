public inherited sharing class CampaignMemberCreator {

    private static Map<String, Schema.SObjectField> campaignMemberFieldSchema {
        get {
            if (campaignMemberFieldSchema == null) {
                campaignMemberFieldSchema = Schema.SObjectType.SubscripcionACampana__c.fields.getMap();
            }
            return campaignMemberFieldSchema;
        }
        set;
    }

    private static Map<String, String> pardotFieldMapping {
        get {
            if (pardotFieldMapping == null) {
                pardotFieldMapping = generatePardotMapping();
            }
            return pardotFieldMapping;
        }
        set;
    }

    private static Map<String, String> generatePardotMapping() {
        Map<String, String> pardotFieldMapping = new Map<String, String>();
        for (PardotMapping__mdt pardotMapping : getAllPardotMappings()) {
            pardotFieldMapping.put(pardotMapping.PardotFieldName__c ,pardotMapping.SalesforceFieldName__c);
        }
        return pardotFieldMapping;
    }

    private static List<PardotMapping__mdt> getAllPardotMappings() {
        return [SELECT SalesforceFieldName__c, PardotFieldName__c FROM PardotMapping__mdt];
    }
    
    private Account account;
    private FormSubmission__c formSubmission;
    private SubscripcionACampana__c campaignMember;
    private List<FormSubmissionItem__c> formSubmissionItems;
    private Id campaignID;


    public CampaignMemberCreator(Account account, FormSubmission__c formSubmission, List<FormSubmissionItem__c> formSubmissionItems, Id campaignID) {
        system.debug(account + '' + formSubmission + '' + formSubmissionItems + '' + campaignID);
        this.account = account;
        this.formSubmission = formSubmission;
        this.formSubmissionItems = formSubmissionItems;
        this.campaignID = campaignID;
    }

    public CampaignMemberCreator(Account account, FormSubmission__c formSubmission, Id campaignID) {
        
        this(account, formSubmission, formSubmission.FormSubmissionItems__r, campaignID);
        system.debug(account + '' + formSubmission + '' + campaignID);
    }

    public SubscripcionACampana__c generateCampaignMember() {
        formatSubmissionFormItems();
        setParentRecords();
        system.debug('generateCampaignMember ' + this.campaignMember);
        return this.campaignMember;
    }

    public void insertCampaignMember() {
        insert this.campaignMember;
        this.formSubmission.SubscripcionACampana__c = this.campaignMember.Id;
        update formSubmission; 
    }

    private void formatSubmissionFormItems() {
        Map<String, Object> untypedCampaignMember = new Map<String, Object>();
        for (FormSubmissionItem__c formItem : formSubmissionItems) {
            if (String.isNotBlank(pardotFieldMapping.get(formItem.FieldName__c))) {
                untypedCampaignMember.put(
                    pardotFieldMapping.get(formItem.FieldName__c),
                    formatFieldValue(pardotFieldMapping.get(formItem.FieldName__c), formItem.FieldValue__c)
                );
            }
        }
        System.debug('Campana__c :: ' + this.campaignMember.Campana__c);
        System.debug('Campana__r :: ' + this.campaignMember.Campana__r);
        this.campaignMember = (SubscripcionACampana__c) JSON.deserialize(JSON.serialize(untypedCampaignMember), SubscripcionACampana__c.class);
        
    }

    private Object formatFieldValue(String fieldName, String fieldValue) {
        String unformattedValue = String.valueOf(fieldValue);
        try {
            switch on campaignMemberFieldSchema.get(fieldName).getDescribe().getType() {
                when DATE {
                    return Date.valueOf(unformattedValue);
                }
                when DATETIME {
                    TimeZone tz = UserInfo.getTimeZone();
                    DateTime dt = DateTime.valueOf(unformattedValue.replace('T', ' '));
                    return dt.addSeconds((tz.getOffset(dt)/1000));
                    //return Datetime.valueOf(unformattedValue.replace('T', ' '));
                }
                when INTEGER {
                    return Integer.valueOf(unformattedValue);
                }
                when LONG, PERCENT, CURRENCY, DOUBLE {
                    return Decimal.valueOf(unformattedValue);
                }
                when else {
                    return unformattedValue;
                }
            }    
        } catch(Exception e) {
            return null;
        }
    }

    private void setParentRecords() {
        this.campaignMember.Cuenta__c = this.account.Id;
        if (this.campaignID != null) {
            Map<Id, Map<String, PrioridadDeCampana__c>> prioritites = SubscripcionACampanaHelper.getSubscriptionsAvailablePrioritiesByCampaignAndName(new Set<Id> { this.campaignID });
            this.campaignMember.Campana__c = this.campaignID;
            this.campaignMember.PrioridadDeCampana__c = prioritites.get(this.campaignId).get('NUEVO').id;
        }
    }
}