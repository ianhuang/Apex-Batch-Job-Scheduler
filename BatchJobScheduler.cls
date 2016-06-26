// Author : Ian Huang, Salesforce
// Created Date : 2015-11-19
// Last Modified Date : 2015-12-31
// Manages all batch job executions in parallel
global class BatchJobScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ExecuteJobs();
    }
    
    //Batch jobs in parallel run batches
    public static List<Set<String>> BatchJobs {
        get {
            BatchJobs = new List<Set<String>>();
            
            //每个批次最多4个job
            
            // 批次 1
            BatchJobs.add(new Set<String>{'ExpiringContractRenewalOpportunityBatch',
            	                          'SalesPerformanceActualUpdateBatch',
            	                          'SalesPerformanceEstimatedUpdateBatch',
            	                          'MessageCollectionBatch'});
            // 批次 2
            BatchJobs.add(new Set<String>{'SalesPerformanceRollUpBatch'});
            
            // 批次3
            
            return BatchJobs;
        }
        private set; 
    }
    
    //Execute jobs from begin to end
    public static void ExecuteJobs() {
        Set<String> batchJobNames = BatchJobs[0];
        Database.Batchable<Object> job = null;
        for (String jobName :batchJobNames) {
            job = getBatchJob(jobName);
            if (job != null && !Test.isRunningTest())
                Database.executeBatch(job, ((BatchJobBase)job).BatchSize);
        }
    }
    
    //Execute jobs in next batch
    public static void ExecuteNextJob(String currentJob) {
        Database.Batchable<Object> job = null;
        
        for(Integer i=0; i<BatchJobs.size()-1; i++) {
            for (String jobName :BatchJobs[i]) {
                //if find the batch job and no batch jobs running from the same batch
                if(jobName == currentJob && !hasPendingJobs(BatchJobs[i])) {
                    Set<String> nextBatchJobNames = BatchJobs[i+1];
                    if (nextBatchJobNames != null) {
                        for (String nextJob :nextBatchJobNames) {
                            job = getBatchJob(nextJob);
                            if (job != null && !Test.isRunningTest())
                                Database.executeBatch(job, ((BatchJobBase)job).BatchSize);
                        }
                    }
                    break;
                }   
            }
        }
    }
    
    private static Boolean hasPendingJobs(Set<String> batchJobNames) {
        List<AsyncApexJob> apexJobs = [SELECT Id, JobType, ApexClassId, Status, ApexClass.Name  
                                       FROM   AsyncApexJob 
                                       WHERE  JobType= 'BatchApex'
                                       AND    Status IN ('Processing', 'Queued', 'Preparing')
                                       AND    ApexClass.Name IN :batchJobNames];
        //if any jobs running from same batch
        if (!apexJobs.isEmpty())
            return true;
        else
            return false;                                      
    } 

    //Get batch job instance by batch job name
    private static Database.Batchable<Object> getBatchJob(String jobName) {
        Database.Batchable<Object> result = null;

        Type t = Type.forName(jobName);
        if (t != null)
            result = (Database.Batchable<Object>)t.newInstance();
        else
            throw new HTWException('Cannot find batch job - ' + jobName);
        
        //set ExecuteNextJob to true so it executes the next job when it finishes       
        ((BatchJobBase)result).ExecuteNextJob = true;       
        return result;
    }

}