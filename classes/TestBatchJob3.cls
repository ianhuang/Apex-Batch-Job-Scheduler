global with sharing class TestBatchJob3 extends BatchJobBase implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT  Id, Type
                                         FROM    Account
                                         WHERE   Type = '_BJS_Testing_']);
    }
     
     
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for (Account account :scope) {
            account.Type = 'Prospect';
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        super.finishBatch(BC);
    }

}