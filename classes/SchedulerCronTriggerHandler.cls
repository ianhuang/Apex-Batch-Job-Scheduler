/*
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
*/
public class SchedulerCronTriggerHandler {
    
    public static void execute(List<Batch_Job_Schedule__c> batchJobSchedules) {
        
        Set<Id> cronTriggerIds = new Set<Id>();
        
        for(Batch_Job_Schedule__c sch :batchJobSchedules) {
            if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_EXISTING_SHCEDULED_JOB_JOB && sch.Cron_Trigger_Id__c != null)
                cronTriggerIds.add(sch.Cron_Trigger_Id__c);
        }
            
        Set<Id> cronTrigggerIdSet = getCronTrigggerIdSet(cronTriggerIds);
            
        for(Batch_Job_Schedule__c sch :batchJobSchedules) {
            if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_EXISTING_SHCEDULED_JOB_JOB) {
                //if (sch.Cron_Trigger_Id__c == null)
                //    sch.Cron_Trigger_Id__c.addError('Cron Trigger Id cannot be null for Existing Scheduled Job record type.');
                if(!cronTrigggerIdSet.contains(sch.Cron_Trigger_Id__c)) {
                    sch.Cron_Trigger_Id__c = null;
                    //sch.Cron_Trigger_Id__c.addError('Invalid Cron Trigger Id.');
                }    
            }    
        }
    }
    
    private static Set<Id> getCronTrigggerIdSet(Set<Id> cronTriggerIds) {
        String SCHEDULED_APEX = '7';
        Set<Id> result = new Set<Id>();
        
        for(CronTrigger cron :[SELECT Id FROM CronTrigger WHERE CronJobDetail.JobType = :SCHEDULED_APEX AND Id IN :cronTriggerIds])
            result.add(cron.Id);
        
        return result;
    }
}
