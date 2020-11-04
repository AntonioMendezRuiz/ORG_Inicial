public virtual class Validation {
    private Boolean success;
    private String errorMessage;
    
    public void setSuccess(){
        this.success = true;
    }
    
    public void setError(String errorMessage) {
        this.success = false;
        this.errorMessage = errorMessage;
    }
    
    public Boolean isSuccess() {
        return this.success;
    }
    
    public String getErrorMessage() {
        return this.errorMessage;
    }
}