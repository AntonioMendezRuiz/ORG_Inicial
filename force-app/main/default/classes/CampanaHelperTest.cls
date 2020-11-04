@isTest
public class CampanaHelperTest {
    @testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    @isTest
    public static void getCaseCampaignsCase(){
        User agentUser = [SELECT id FROM User WHERE lastname = 'TestUser1'];
        User supervisorUser = [SELECT id FROM User WHERE lastname = 'Supervisor'];
        List<Campana__c> caseCampaigns;
        Map <String, Id> campaingsToCheck;
        List<Campana__Share> campaignsShare;

        System.runAs(supervisorUser) {
            caseCampaigns = TestDataFactory.createCaseCampaigns('Planificada');
            campaignsShare = TestDataFactory.shareCampaignsWithUser(caseCampaigns, agentUser);
        }
        System.runAs(agentUser) {
            Test.startTest();
            campaingsToCheck = CampanaHelper.getCaseCampaigns();
            Test.stopTest();
        }
        
        System.assertNotEquals(null, campaingsToCheck);
        System.assertEquals(caseCampaigns[0].id, campaingsToCheck.get('CLIENTES'));
        
    }
}