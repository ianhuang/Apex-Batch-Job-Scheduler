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

Description:   Batch Job Log helper class, Objects: Batch_Job_Log__c
History:       2015-11-19   Ian Huang   Created.    
------------------------------------------------------------*/
public inherited sharing class BatchJobHelper {
    
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
                Completed_Date__c = job.CompletedDate,
                Execution_Result__c = executeResult + '\n' + summary);
            insert bjl;
        } catch (Exception ex) {
            throw new DmlException('Failed to save batch job log: ' + ex.getMessage());          
        }
    }

    //Log batch job exection result
    public static void logBatchJob(String batchJobName, DateTime completedDate, String errorMessages) {
        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Completed_Date__c = completedDate,
                Execution_Result__c = errorMessages);
            insert bjl;
        } catch (Exception ex) {
            throw new DmlException('Failed to save batch job log. ' + ex.getMessage());          
        }
    }
}
