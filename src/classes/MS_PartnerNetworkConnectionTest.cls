@isTest(SeeAllData=True)
private class MS_PartnerNetworkConnectionTest {
	
	static testMethod void shareRecordsTest(){
		// create a list of months
    	List<MS_Month__c> lMonth = MS_DataTestFactory.createMonths(1); 
    	insert lMonth;
    	//create a list of sprints
    	List<MS_Sprint__c> lSprint = MS_DataTestFactory.createSprint(lMonth);
    	insert lSprint;
    	for (MS_Sprint__c sp: lSprint){
    		sp.MS_Month__c = lMonth.get(0).Id;
    	}
    	update lSprint;
    	// create a list of requests
    	List<MS_Request__c> lRequest = MS_DataTestFactory.createRequests(lSprint, 1);
    	insert lRequest;
    	for (MS_Request__c req: lRequest){
    		req.MS_Sprint__c = lSprint.get(0).Id;
    	}
    	update lRequest;
    	List<MS_Work_Activity__c> lWorkActivity = MS_DataTestFactory.createWorkActivity(lRequest, lSprint);
    	insert lWorkActivity;
    	for (MS_Work_Activity__c wa: lWorkActivity){
    		wa.MS_Sprint__c = lSprint.get(0).Id;

    	}
    	update lWorkActivity;
    	
    	//share the records
    	MS_PartnerNetworkConnection.shareRecords(lRequest);
    	//check if there's connection between orgs
    	List<PartnerNetworkRecordConnection> reqPNRC = [SELECT ConnectionId, Status, LocalRecordId 
    													FROM PartnerNetworkRecordConnection 
    													WHERE LocalRecordId IN :lRequest];
    	//create a map of LocalRecordId and PartnerNetworkRecordConnection
    	Map<Id,PartnerNetworkRecordConnection> mapR_PNRC  = new map<Id,PartnerNetworkRecordConnection>();
    	//loop over the object to populate the map
    	for (PartnerNetworkRecordConnection rPNRC : reqPNRC){
    			mapR_PNRC.put(rPNRC.LocalRecordId, rPNRC);
    	}
    	//loop over the object and check if the request was shared
   		for (MS_Request__c r : lRequest) {	
			System.assert(mapR_PNRC.get(r.Id)!=null);	
   		}	
    }
}