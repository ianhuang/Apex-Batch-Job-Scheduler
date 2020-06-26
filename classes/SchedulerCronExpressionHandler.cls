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
