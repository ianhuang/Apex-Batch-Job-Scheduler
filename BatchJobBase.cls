// Author : Ian Huang, Salesforce
// Created Date : 2015-11-19
// Last Modified Date : 2015-12-31
// BatchJob base class
public virtual class BatchJobBase {
    //default batch job size
    public Integer batchSize = 200;
    //whether to execute next batch job
    public Boolean executeNextJob = false;
    
    protected void finishBatch(Database.BatchableContext BC) {
		String className = String.valueOf(this).split(':')[0];
		BatchJobHelper.logBatchJob(className, BC);
        if(executeNextJob) BatchJobScheduler.ExecuteNextJob(className); 
	}
}