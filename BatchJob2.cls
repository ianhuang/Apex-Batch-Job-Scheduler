global class BatchJob1 extends BatchJobBase implements Database.Batchable<sObject> {
    
    global BatchJob2() {
    	//override default batch job size
    	BatchSize = 100;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT  Id 
                                         FROM    Account
                                         WHERE   LastModifiedDate = TODAY]);
    }
     
     
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for (Account account :scope) {
            //......
        }
        //......
    }
    
    global void finish(Database.BatchableContext BC) {
        if (executeNextJob) BatchJobScheduler.ExecuteNextJob('BatchJob2');
    }

}