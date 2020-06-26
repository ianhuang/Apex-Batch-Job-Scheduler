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