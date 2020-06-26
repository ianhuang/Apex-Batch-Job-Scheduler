public class SchedulerCronExpressionHandler {
    
    public static void execute(List<Batch_Job_Schedule__c> batchJobSchedules) {
        for(Batch_Job_Schedule__c sch :batchJobSchedules) {
            if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_HOURLY_JOB)
                sch.Cron_Expression__c = String.format('0 {0} 0/{1} 1/1 * ? *', 
                                                       new List<String>{sch.Preferred_Start_Minute__c, 
                                                                        String.valueOf(sch.Every_Number_of_Hours__c)}); 
            else if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_DAILY_JOB)
                sch.Cron_Expression__c = String.format('0 {0} {1} 1/{2} * ? *', 
                                                       new List<String>{sch.Preferred_Start_Minute__c, 
                                                                        sch.Preferred_Start_Hour__c,
                                                                        String.valueOf(sch.Every_Number_of_Days__c)}); 
            else if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_WEEKLY_JOB)
                sch.Cron_Expression__c = String.format('0 {0} {1} ? * {2} *', 
                                                       new List<String>{sch.Preferred_Start_Minute__c, 
                                                                        sch.Preferred_Start_Hour__c,
                                                                        sch.Preferred_Start_Week_Day__c.replace(';', ',')}); 
            else if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_MONTHLY_JOB)
                sch.Cron_Expression__c = String.format('0 {0} {1} {2} 1/{3} ? *', 
                                                       new List<String>{sch.Preferred_Start_Minute__c, 
                                                                        sch.Preferred_Start_Hour__c,
                                                                        sch.Preferred_Start_Day__c,
                                                                        String.valueOf(sch.Every_Number_of_Months__c)}); 
            else if(sch.RecordTypeId == GlobalConstants.SCHEDULER_RECORD_TYPE_YEARLY_JOB)
                sch.Cron_Expression__c = String.format('0 {0} {1} {2} {3} ? *', 
                                                       new List<String>{sch.Preferred_Start_Minute__c, 
                                                                        sch.Preferred_Start_Hour__c,
                                                                        sch.Preferred_Start_Day__c,
                                                                        sch.Preferred_Start_Month__c}); 
            
        }
    }

}