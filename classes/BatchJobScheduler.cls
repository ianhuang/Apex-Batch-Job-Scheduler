/*------------------------------------------------------------
Copyright (c) Ian Huang Salesforce

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.

Description:   Manages all batch job executions in parallel
               Schedule Syntax: System.schedule('Batch Job Scheduler', '0 0 2 1/1 * ? *', new BatchJobScheduler());
History:       2015-11-19   Ian Huang   Created.
               2017-09-29   Ian Huang   Store batch jobs in Custom Metadata Types.
               2018-03-25   Ian Huang   Add 'Holding' status to AsyncApexJob query.
               2018-04-16   Ian Huang   Load batchJobs in every Scheduler execution.
               2020-05-22   Ian Huang   Fixes BatchSize bug.
------------------------------------------------------------*/
global with sharing class BatchJobScheduler implements Schedulable {
    
    //Batch jobs in parallel run batches
    private List<List<Batch_Apex_Job__c>> batchJobs;
    
    global void execute(SchedulableContext sc) {
        executeJobs(sc.getTriggerId());
    }
    
    //Execute jobs from the beginning
    public void executeJobs(Id cronTriggerId) {
        batchJobs = loadActiveBatchJobs(cronTriggerId);
        if(batchJobs.isEmpty()) return;
        
        Database.Batchable<Object> job = null;
        for (Batch_Apex_Job__c baj :batchJobs[0]) {
            job = getBatchJob(baj.Batch_Class_Name__c);
            if (job != null && !Test.isRunningTest()) {
                ((BatchJobBase)job).batchJobScheduler = this;
                Database.executeBatch(job, (Integer)baj.Batch_Size__c);
            }    
        }
    }
    
    //Execute jobs in next batch
    public void executeNextJob(String currentJob) {
        Database.Batchable<Object> job = null;
        
        for(Integer i=0; i<batchJobs.size()-1; i++) {
            for(Batch_Apex_Job__c baj :batchJobs[i]) {
                //if no remaining batch jobs running from the same batch
                if(baj.Batch_Class_Name__c == currentJob && !hasPendingJobs(batchJobs[i])) {
                    List<Batch_Apex_Job__c> nextBatchJobs = batchJobs[i+1];
                    if(nextBatchJobs != null) {
                        for(Batch_Apex_Job__c nextJob :nextBatchJobs) {
                            job = getBatchJob(nextJob.Batch_Class_Name__c);
                            if (job != null && !Test.isRunningTest()) {
                                ((BatchJobBase)job).batchJobScheduler = this;
                                Database.executeBatch(job, (Integer)nextJob.Batch_Size__c);
                            }    
                        }
                    }
                    break;
                }   
            }
        }
    }
    
    //load active batch jobs from Batch_Apex_Job__c, sort by Batch No and Batch Sequence
    private List<List<Batch_Apex_Job__c>> loadActiveBatchJobs(Id cronTriggerId) {
        Map<Integer, List<Batch_Apex_Job__c>> jobMap = new Map<Integer, List<Batch_Apex_Job__c>>();
        for (Batch_Apex_Job__c baj : [SELECT   Id, Name, 
                                               batchjobsch__Batch_Class_Name__c,
                                               batchjobsch__Batch_Size__c,
                                               batchjobsch__Batch_Group__c,
                                               batchjobsch__Batch_Job_Schedule__c
                                      FROM     batchjobsch__Batch_Apex_Job__c
                                      WHERE    batchjobsch__Enabled__c = true
                                      AND      batchjobsch__Batch_Job_Schedule__r.batchjobsch__Cron_Trigger_Id__c = :cronTriggerId
                                      ORDER BY batchjobsch__Batch_Group__c, CreatedDate]) {
                                            
            if (!jobMap.containsKey(Integer.valueOf(baj.Batch_Group__c)))
                jobMap.put(Integer.valueOf(baj.Batch_Group__c), new List<Batch_Apex_Job__c>());
                                            
            jobMap.get(Integer.valueOf(baj.Batch_Group__c)).add(baj);
        }
        
        List<Integer> jobBatchNoList = new List<Integer>(jobMap.keySet());
        jobBatchNoList.sort();        
                
        List<List<Batch_Apex_Job__c>> result = new List<List<Batch_Apex_Job__c>>();        
        for(Integer i=0; i<jobBatchNoList.size(); i++) {
            result.add(jobMap.get(jobBatchNoList[i]));             
        }                
                
        return result;
    }

    private Boolean hasPendingJobs(List<Batch_Apex_Job__c> batchJobs) {
        Set<String> batchJobNames = new Set<String>();
        for(Batch_Apex_Job__c job :batchJobs)
            batchJobNames.add(job.Batch_Class_Name__c);
        
        List<AsyncApexJob> apexJobs = [SELECT Id, JobType, ApexClassId, Status, ApexClass.Name  
                                       FROM   AsyncApexJob 
                                       WHERE  JobType = 'BatchApex'
                                       AND    Status IN ('Holding', 'Processing', 'Queued', 'Preparing')
                                       AND    ApexClass.Name IN :batchJobNames];
        //if any jobs are still running from the same batch
        if (!apexJobs.isEmpty())
            return true;
        else
            return false;                                      
    } 

    //Get batch job instance by batch job name
    private Database.Batchable<Object> getBatchJob(String jobName) {
        Database.Batchable<Object> result = null;

        Type t = Type.forName(jobName);
        if (t != null)
            result = (Database.Batchable<Object>)t.newInstance();
        else
            throw new TypeException('Cannot find batch job: ' + jobName);
        
        //set ExecuteNextJob to true so it executes the next job when it finishes       
        ((BatchJobBase)result).ExecuteNextJob = true;
        
        return result;
    }

}
