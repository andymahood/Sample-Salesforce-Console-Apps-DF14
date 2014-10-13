global class ExternalSharingCleanupBatch implements Schedulable, Database.Batchable <sObject>{ 

    global void execute(SchedulableContext SC) { 
        ExternalSharingCleanupBatch cleanupBatch = new ExternalSharingCleanupBatch(); 
        ID batchprocessid = Database.executeBatch(cleanupBatch); 
    } 
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([SELECT localrecordid 
                                         FROM PartnerNetworkRecordConnection 
                                         WHERE (status = 'Deleted' OR status = 'Inactive') 
                                         AND enddate = LAST_N_DAYS:30]); 
    } 
  
    global void execute(Database.BatchableContext BC, List<sObject> batch) { 
         
        List<PartnerNetworkRecordConnection> recordConnectionBatch = (List<PartnerNetworkRecordConnection>)batch; 
        
        Set<Id> recordConnectionIds = new Set<Id>(); 
        for (PartnerNetworkRecordConnection recordConnection : recordConnectionBatch) { 
            recordConnectionIds.add(recordConnection.localrecordid);            
        } 
  
        /*******  delete - MS_Months which are either deleted or made private in Tquila Org *******/ 
        List<MS_Month__c> monthsToBeDeleted ; 
        
        monthsToBeDeleted = [Select Id from MS_Month__c where Id IN :recordConnectionIds]; 
        
        if ((monthsToBeDeleted.size() > 0) || Test.isRunningTest())  { 
            Database.delete(monthsToBeDeleted,false); 
        } 
        
        /******* delete MS_Sprint which are either deleted or made private in Tquila Org *******/ 
        List<MS_Sprint__c> sprintsToBeDeleted ; 
  
        sprintsToBeDeleted = [Select Id from MS_Sprint__c where Id IN :recordConnectionIds]; 
        
        if ((sprintsToBeDeleted.size() > 0) || Test.isRunningTest()) { 
            Database.delete(sprintsToBeDeleted,false); 
        } 
  
        /******* delete MS_Requests which are either deleted or made private in Tquila Org *******/ 
        List<MS_Request__c> requestsToBeDeleted = [Select Id from MS_Request__c where Id IN :recordConnectionIds]; 
  
        if ((requestsToBeDeleted.size() > 0)||Test.isRunningTest()) { 
            Database.delete(requestsToBeDeleted,false); 
        }        
  
        
        /******* delete MS_Work_Activity which are either deleted or made private in Tquila Org *******/ 
        List<MS_Work_Activity__c> workActivitiesToBeDeleted = [Select Id from MS_Work_Activity__c where Id IN :recordConnectionIds]; 
  
        if ((workActivitiesToBeDeleted.size() > 0) || Test.isRunningTest()){ 
            Database.delete(workActivitiesToBeDeleted,false); 
        }         
        
    } 
    
    global void finish(Database.BatchableContext BC) { 
        
    } 
}