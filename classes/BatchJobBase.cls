/*------------------------------------------------------------
Author:        Ian Huang
Company:       Salesforce
Description:   BatchJob base class
History:       2015-11-19   Ian Huang   Created.    
------------------------------------------------------------*/
global virtual with sharing class BatchJobBase {
    //default batch job size
    //global Integer BatchSize = 200;
    global Boolean ExecuteNextJob = false;
    global BatchJobScheduler batchJobScheduler;
    
    global virtual void finishBatch(Database.BatchableContext BC) {
        String className = String.valueOf(this).split(':')[0];
        BatchJobHelper.logBatchJob(className, BC);
        if(ExecuteNextJob) batchJobScheduler.ExecuteNextJob(className); 
    }
}