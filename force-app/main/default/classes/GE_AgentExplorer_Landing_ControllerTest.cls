@isTest
public class GE_AgentExplorer_Landing_ControllerTest {
    @testSetup
    public static void setup(){
        Test.startTest();
        TestDataFactory.createTestData();
        Test.stopTest();
    }
    @isTest 
    public static void GE_AgentExplorer_Landing_ControllerTest() {
        GE_AgentExplorer_Landing_Controller agentExplorerTest = new GE_AgentExplorer_Landing_Controller ();

        Test.startTest();
        pageReference response = agentExplorerTest.start();
        Test.stopTest();
    }
}