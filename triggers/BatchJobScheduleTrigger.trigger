trigger BatchJobScheduleTrigger on Batch_Job_Schedule__c (before insert, before update) {
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        SchedulerCronExpressionHandler.execute(trigger.new);
        SchedulerCronTriggerHandler.execute(trigger.new);
    }    
    
}