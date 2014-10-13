@isTest(SeeAllData=True)
public with sharing class ExternalSharingCleanupTest 
{
	static testmethod void testExternalSharingCleanupBatch ()
	{	
		List<MS_Month__c> lMonths = MS_DataTestFactory.createMonths(1);
		insert lMonths;
		
		List<MS_Sprint__c> lSprints = MS_DataTestFactory.createSprint(lMonths);
		insert lSprints;
		
		List<MS_Request__c> lRequests = MS_DataTestFactory.createRequests(lSprints, 1);
		insert lRequests;
		
		List<MS_Work_Activity__c> lWorkActivities = MS_DataTestFactory.createWorkActivity(lRequests, lSprints);
		insert lWorkActivities;
		
		Test.startTest();
		
		ExternalSharingCleanupBatch recordsToDelete = new ExternalSharingCleanupBatch ();
		Database.executeBatch(recordsToDelete);
		
		Test.stopTest();
		
		List<PartnerNetworkRecordConnection> lRecordConnection = ([SELECT localRecordId FROM PartnerNetworkRecordConnection
																						WHERE (status = 'Deleted' OR status = 'Inactive')]); 
        
        Set<Id> recordConnectionIds = new Set<Id>(); 
        for (PartnerNetworkRecordConnection recordConnection : lRecordConnection) { 
            recordConnectionIds.add(recordConnection.localrecordid);            
        } 
        
        List<MS_Month__c> monthsToBeDeleted = [SELECT Id FROM MS_Month__c WHERE Id IN : recordConnectionIds];
        system.assertEquals(monthsToBeDeleted.size(), 0);
        
        List<MS_Sprint__c> sprintsToBeDeleted = [SELECT Id FROM MS_Sprint__c WHERE Id IN : recordConnectionIds];
        system.assertEquals(sprintsToBeDeleted.size(), 0);
        
        List<MS_Request__c> requestsToBeDeleted = [SELECT Id FROM MS_Request__c WHERE Id IN : recordConnectionIds];
        system.assertEquals(requestsToBeDeleted.size(), 0);
        
        List<MS_Work_Activity__c> waToBeDeleted = [SELECT Id FROM MS_Work_Activity__c WHERE Id IN : recordConnectionIds];
        system.assertEquals(waToBeDeleted.size(), 0);
	}
}