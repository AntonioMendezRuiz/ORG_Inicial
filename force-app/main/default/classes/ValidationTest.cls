@isTest
public class ValidationTest {
    @isTest
    public static void useCase() {
        Validation v = new Validation();
        
        v.setSuccess();
        v.setError('Test');
        v.isSuccess();
        v.getErrorMessage();
    }
}