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

//VF Page controller
public with sharing class SchedulerConfigurationController {

    public List<ScheduledApexJob> scheduledApexJobs {get; set;}
    
    private List<Batch_Job_Schedule__c> batchJobSchedules;
    
    //Constructor
    public SchedulerConfigurationController() {
        List<ScheduledApexJob> scheduledApexJobs = new List<ScheduledApexJob>();
        retrieveBatchJobSchedules();
    }
    
    public PageReference save() {
        PageReference pageRef = ApexPages.currentPage();

        try {
            updateBatchJobSchedules();
            pageRef.setRedirect(true);
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
            System.debug('Errors: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            pageRef.setRedirect(false);
        }

        return pageRef;
    }

    private void updateBatchJobSchedules() {
        BatchJobScheduler scheduler;
        
        //System.debug('*** batchJobSchedules = ' + batchJobSchedules);

        //update Schedulers
        for(ScheduledApexJob job :scheduledApexJobs) {
            if(job.scheduled) {
                if(job.cronTrigger == null) {
                    job.Schedule.Cron_Trigger_Id__c = scheduleJob(job);
                }
            } else {
                if(job.cronTrigger != null) {
                    job.Schedule.Cron_Trigger_Id__c = null;
                    System.abortJob(job.cronTrigger.Id);
                }
            }
        }
        
        //update Batch_Job_Scheduler__c records
        Database.SaveResult[] saveResults = Database.update(batchJobSchedules);
        for(Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'DML Error: ' + err.getMessage()));
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }    
        }
    }
    
    private Id scheduleJob(ScheduledApexJob job) {
        Id result = null;
        
        if(job.schedule.Cron_Expression__c != null)
            result = System.schedule(job.schedule.Name, job.schedule.Cron_Expression__c, new BatchJobScheduler());
        
        return result;
    }
    
    private Map<Id, CronTrigger> retrieveCronTriggerMap() {
        String SCHEDULED_APEX = '7';
        Map<Id, CronTrigger> result = new Map<Id, CronTrigger>(
                              [SELECT Id, CronExpression, CronJobDetailId, 
                                      NextFireTime, PreviousFireTime, 
                                      StartTime, EndTime,
                                      State, TimesTriggered, 
                                      CronJobDetail.Name 
                               FROM   CronTrigger
                               WHERE  CronJobDetail.JobType = :SCHEDULED_APEX]);
        return result;
    }
    
    private void retrieveBatchJobSchedules() {
        scheduledApexJobs = new List<ScheduledApexJob>();
        
        //exit if cannot edit batchJobSchedule
        if(!canUpdateSchedule()) return;
        
        Map<Id, CronTrigger> cronTriggerMap = retrieveCronTriggerMap();
        
        batchJobSchedules =  [SELECT   Id,
                                       Name,
                                       Cron_Trigger_Id__c,
                                       Cron_Expression__c,
                                       RecordType.Name
                              FROM     Batch_Job_Schedule__c
                              ORDER BY CreatedDate, Name
                              LIMIT 2000];

        for(Batch_Job_Schedule__c sch : batchJobSchedules) {
            if(sch.Cron_Trigger_Id__c != null && cronTriggerMap.containsKey(sch.Cron_Trigger_Id__c))   
                scheduledApexJobs.add(new ScheduledApexJob(sch, cronTriggerMap.get(sch.Cron_Trigger_Id__c)));
            else
                scheduledApexJobs.add(new ScheduledApexJob(sch, null));
        }    
    }
    
    private Boolean canUpdateSchedule() {
        String [] batchJobScheduleUpdateFields = new String [] {'batchjobsch__Name',
                                                       'batchjobsch__Cron_Trigger_Id__c',
                                                       'batchjobsch__Cron_Expression__c',
                                                       'batchjobsch__RecordTypeId'};

        // Obtaining the field name/token map for the Batch_Job_Schedule__c object
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Batch_Job_Schedule__c.fields.getMap();
        //System.debug('@@@fieldMap = ' + fieldMap);
        for(String fieldToCheck : batchJobScheduleUpdateFields) {
           // Check if the user has read access on the each field
           if (!fieldMap.get(fieldToCheck).getDescribe().isUpdateable()) {
              //System.debug('@@@fieldToCheck = ' + fieldToCheck);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access')); 
              return false;
           }
        }
        return true;
    }

}
