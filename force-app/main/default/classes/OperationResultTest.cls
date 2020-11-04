@isTest
public class OperationResultTest {
    @isTest
    public static void useCase() {
        OperationResult o = new OperationResult();
        o.setSuccess();
        o.setRecord(new Account());
        o.getRecord();
        o.setSuccess('Test');
		o.setError('Test');
        o.isSuccess();
        o.getSuccessMessage();
        o.getErrorMessage();
    }
}