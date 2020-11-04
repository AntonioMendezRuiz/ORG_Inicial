public interface TriggerDispatcher {
	void bulkBefore		();
    void bulkAfter		();
    void andFinally		();
    void beforeInsert	();
    void beforeUpdate	();
    void beforeDelete	();
    void afterInsert	();
    void afterUpdate	();
    void afterDelete	();
    void afterUndelete	();
    
    boolean isEnabled	();
}