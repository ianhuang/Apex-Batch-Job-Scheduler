public inherited sharing class GlobalConstants {
    
    public static Id SCHEDULER_RECORD_TYPE_HOURLY_JOB  = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Hourly_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_DAILY_JOB   = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Daily_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_WEEKLY_JOB  = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Weekly_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_MONTHLY_JOB = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Monthly_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_YEARLY_JOB  = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Yearly_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_CUSTOM_CRON_EXPRESSION_JOB = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Custom_Cron_Expression_Job').getRecordTypeId();
    public static Id SCHEDULER_RECORD_TYPE_EXISTING_SHCEDULED_JOB_JOB = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName ().get('Existing_Scheduled_Job').getRecordTypeId();

}