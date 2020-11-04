public virtual class OperationResult {
	private Boolean success;
    private String errorMessage;
    private String successMessage;
    private sObject record;
    
    public void setSuccess(){
        this.success = true;
    }
    
    public void setRecord(sObject record) {
        this.record = record;
    }
    
    public sObject getRecord() {
        return this.record;
    }
    
    public void setSuccess(String successMessage) {
        this.success = true;
        this.successMessage = successMessage;
    }
    
    public void setError(String errorMessage) {
        this.success = false;
        this.errorMessage = errorMessage;
    }
    
    public Boolean isSuccess() {
        return this.success;
    }
    
    public String getSuccessMessage() {
        return this.successMessage;
    }
    
    public String getErrorMessage() {
        return this.errorMessage;
    }
}