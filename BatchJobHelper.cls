/*
Created at: Nov. 19, 2015
Author:  Ian Huang
Objects: Batch_Job_Log__c
Description: Batch Job Log helper class
*/
public class BatchJobHelper {
    //Log batch job exection result
    public static void logBatchJob(String batchJobName, Database.BatchableContext BC) {
        logBatchJob(batchJobName, BC, '');
    }
    
    //Log batch job exection result
    public static void logBatchJob(String batchJobName, Database.BatchableContext BC, String summary) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, CreatedBy.Email, ExtendedStatus 
                            FROM   AsyncApexJob 
                            WHERE  Id =:BC.getJobId()];

        String executeResult = 'JobItemsProcessed: ' + job.JobItemsProcessed
                               + '\nNumberOfErrors: ' + job.NumberOfErrors + '\nStatus: '
                               + job.Status + '\nExtendedStatus: ' + job.ExtendedStatus;

        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Execute_Date__c   = job.CompletedDate,
                Execute_Result__c = executeResult + '\n' + summary);
            insert bjl;
        } catch (Exception ex) {
            throw new HTWException('Failed to save batch job log: ' + ex.getMessage());          
        }
    }

    //Log batch job exection result
    public static void logBatchJob(String batchJobName, DateTime completedDate, String errorMessages) {
        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Execute_Date__c   = completedDate,
                Execute_Result__c = errorMessages);
            insert bjl;
        } catch (Exception ex) {
            throw new HTWException('Failed to save batch job log. ' + ex.getMessage());          
        }
    }
}