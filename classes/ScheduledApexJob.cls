public inherited sharing class ScheduledApexJob {
    
    public Boolean                Scheduled    {get; set;}
    public Batch_Job_Schedule__c  Schedule     {get; private set;}
    public CronTrigger            CronTrigger  {get; private set;}
    
    public ScheduledApexJob(Batch_Job_Schedule__c schedule, CronTrigger cronTrigger) {
        this.schedule    = schedule;
        this.cronTrigger = cronTrigger;
        this.scheduled   = cronTrigger != null;
    }
    
}