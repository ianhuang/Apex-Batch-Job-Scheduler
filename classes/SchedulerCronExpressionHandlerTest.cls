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
@isTest
private class SchedulerCronExpressionHandlerTest {

   @isTest
    static void testHourlyJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_HOURLY_JOB;
        sch.Name = 'Test Hourly Name 001';
        sch.Every_Number_of_Hours__c = 1;
        sch.Preferred_Start_Minute__c = '0';
        insert sch;
        
        Test.stopTest();
        
        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 0 0/1 1/1 * ? *', jobSch.Cron_Expression__c);
    }
    
    @isTest
    static void testDailyJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_DAILY_JOB;
        sch.Name = 'Test Daily Name 001';
        sch.Every_Number_of_Days__c = 1;
        sch.Preferred_Start_Hour__c = '2';
        sch.Preferred_Start_Minute__c = '1';
        insert sch;
        
        Test.stopTest();

        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 1 2 1/1 * ? *', jobSch.Cron_Expression__c);
    }
    
    @isTest
    static void testWeeklyJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_WEEKLY_JOB;
        sch.Name = 'Test Weekly Name 001';
        sch.Preferred_Start_Week_Day__c = 'MON;TUE;WED';
        sch.Preferred_Start_Hour__c = '3';
        sch.Preferred_Start_Minute__c = '2';
        insert sch;
        
        Test.stopTest();

        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 2 3 ? * MON,TUE,WED *', jobSch.Cron_Expression__c);
    }
    
    @isTest
    static void testMonthlyJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_MONTHLY_JOB;
        sch.Name = 'Test Monthly Name 001';
        sch.Every_Number_of_Months__c = 3;
        sch.Preferred_Start_Day__c = '5';
        sch.Preferred_Start_Hour__c = '4';
        sch.Preferred_Start_Minute__c = '3';
        insert sch;
        
        Test.stopTest();
        
        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 3 4 5 1/3 ? *', jobSch.Cron_Expression__c);
    }

    @isTest
    static void testYearlyJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_YEARLY_JOB;
        sch.Name = 'Test Yearly Name 001';
        sch.Preferred_Start_Month__c = 'December';
        sch.Preferred_Start_Day__c = '5';
        sch.Preferred_Start_Hour__c = '4';        
        sch.Preferred_Start_Minute__c = '4';
        insert sch;
        
        Test.stopTest();

        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 4 4 5 December ? *', jobSch.Cron_Expression__c);
    }

    @isTest
    static void testCustomCronExpressionJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_CUSTOM_CRON_EXPRESSION_JOB;
        sch.Name = 'Test Custom Name 001';
        sch.Cron_Expression__c = '0 0 1 3 */3 ? 2029-2030';
        insert sch;
        
        Test.stopTest();
        
        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 0 1 3 */3 ? 2029-2030', jobSch.Cron_Expression__c);
    }

    @isTest
    static void testExistingJob() {
        Test.startTest();
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_EXISTING_SHCEDULED_JOB_JOB;
        sch.Name = 'Test Existing Job Name 001';
        String jobId = System.schedule('15 Mins Batch Jobs', '0 0 12 1/1 * ? *', new BatchJobScheduler());
        sch.Cron_Trigger_Id__c = jobId;
        sch.Cron_Expression__c = '0 0 12 1/1 * ? *';
        insert sch;
        
        Test.stopTest();
        
        Batch_Job_Schedule__c jobSch = [SELECT Id, Cron_Expression__c FROM Batch_Job_Schedule__c][0];
        System.assertEquals('0 0 12 1/1 * ? *', jobSch.Cron_Expression__c);
    }

}
