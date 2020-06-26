@isTest
private class BatchJobSchedulerTest {

    @testSetup static void setup() {
        
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = GlobalConstants.SCHEDULER_RECORD_TYPE_HOURLY_JOB;
        sch.Name = 'Test Hourly Name 001';
        sch.Every_Number_of_Hours__c = 1;
        sch.Preferred_Start_Minute__c = '0';
        insert sch;

        Batch_Apex_Job__c batchJob1 = new Batch_Apex_Job__c(Batch_Job_Schedule__c=sch.Id, Batch_Class_Name__c='TestBatchJob1',
                                                            Batch_Group__c='1', Enabled__c=true);
        Batch_Apex_Job__c batchJob2 = new Batch_Apex_Job__c(Batch_Job_Schedule__c=sch.Id, Batch_Class_Name__c='TestBatchJob2',
                                                            Batch_Group__c='1', Enabled__c=true);
        Batch_Apex_Job__c batchJob3 = new Batch_Apex_Job__c(Batch_Job_Schedule__c=sch.Id, Batch_Class_Name__c='TestBatchJob3',
                                                            Batch_Group__c='2', Enabled__c=true);
        insert new List<Batch_Apex_Job__c>{batchJob1, batchJob2, batchJob3};
 
        Account account1 = new Account(Name='__BatchJobSchedulerTest001', Type='_BJS_Testing_');
        Account account2 = new Account(Name='__BatchJobSchedulerTest002', Type='_BJS_Testing_');
        Account account3 = new Account(Name='__BatchJobSchedulerTest003', Type='_BJS_Testing_');
        insert new List<Account>{account1, account2, account3};
    }

    @isTest
    static void testExecute() {
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());
        
        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.executeJobs(cronTriggerId);
        
        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('_BJS_Testing_', accounts[0].Type);
        System.assertEquals('_BJS_Testing_', accounts[1].Type);
        System.assertEquals('_BJS_Testing_', accounts[2].Type);
    }    

    @isTest
    static void testExecuteNext() {
        
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());
        
        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.executeJobs(cronTriggerId);
        batchJobScheduler.executeNextJob('TestBatchJob1');
        
        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('_BJS_Testing_', accounts[0].Type);
        System.assertEquals('_BJS_Testing_', accounts[1].Type);
        System.assertEquals('_BJS_Testing_', accounts[2].Type);
    }

    @isTest
    static void testlogBatchJob() {
        BatchJobHelper.logBatchJob('batchJobName', System.now(), 'errorMessages');
        
        List<Batch_Job_Log__c> logs = [SELECT Id FROM Batch_Job_Log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
    static void testBatchJob1() {
        Test.startTest();
        Database.executeBatch(new TestBatchJob1());
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }
    
    @isTest
    static void testBatchJob2() {
        Test.startTest();
        Database.executeBatch(new TestBatchJob2());
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }
    
    @isTest
    static void testBatchJob3() {
        Test.startTest();
        Database.executeBatch(new TestBatchJob3());
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }

}