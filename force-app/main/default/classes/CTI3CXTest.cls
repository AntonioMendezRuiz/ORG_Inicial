@isTest
public class CTI3CXTest {
    @isTest
    public static void callTest() {
        Test.setMock(HttpCalloutMock.class, new CTI3CXMockImpl());

        Test.startTest();
        CTI3CX.call(600000,324);
        Test.stopTest();
    }
}