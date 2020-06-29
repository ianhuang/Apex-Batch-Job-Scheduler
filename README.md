# Apex-Batch-Job-Scheduler
Batch Job Scheduler app helps you manage Batch job execution sequence and data dependency.

Are you using Batch Apex jobs to process large volume of data in Salesforce? Does it take long hours to run? Do you need to run some Batch jobs only when another Batch job is finished due to data dependencies? BatchJobScheduler can help you.

Batch Job Scheduler is a light weight Apex framework, it manages the execution of multiple Batch Apex jobs in preferred groups and sequences.

It provides the following benefits:

* Reduce total execution time - Executes up to 5 batch jobs simultaneously
* Manage data dependencies - Execute batch jobs in specific groups and orders
* Easy set up and maintenance - Configurations based and requires minimal code changes to existing Batch classes


How to set up Batch Job Scheduler
* Step 1. Create a Batch Apex class
* Step 2. Create a Batch Job Scheduler record
* Step 3. Create a Batch Job records
* Step 4. Schedule Batch Jobs

Batch Job Scheduler is published on Salesforce AppExchange, you can install it directly from AppExchange:
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FR4aUUAT

Design Document
https://partners.salesforce.com/servlet/servlet.FileDownload?file=00P3A00000jG21hUAC
