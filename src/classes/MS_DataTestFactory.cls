public with sharing class MS_DataTestFactory {
	
	//create a new month for testing purposes
	public static List<MS_Month__c> createMonths (Integer batchSize){
		
		List<MS_Month__c> lMonth = new List<MS_Month__c>();
		
		Map<Integer, String> monthMap = MS_MonthUtility.MonthMap;
		for(Integer i=0; i< batchSize; i++){
			
    		MS_Month__c newMonth = new MS_Month__c ();
    		newMonth.Name = 'Month' + i;
    		newMonth.Month__c = monthMap.get(date.today().month() - 1);
    		newMonth.Year__c = String.valueOf(date.today().year());
    		lMonth.add(newMonth);
        }
		
		return lMonth;
	}
	//create a new sprint for testing purposes
	public static List<MS_Sprint__c> createSprint(List<MS_Month__c> lMonth){
		
		List<MS_Sprint__c> lSprint = new List<MS_Sprint__c>();
	
		for(MS_Month__c month : lMonth){
				
			MS_Sprint__c sprint =  new MS_Sprint__c();		
			sprint.Name = 'Tquila';
			sprint.MS_Month__c = lMonth.get(0).id;
			lSprint.add(sprint);
		}
		
		return lSprint;	
	}
	//create a new request for testing purposes
	public static List<MS_Request__c> createRequests (List<MS_Sprint__c> lSprint, Integer batchSize){
		
		List<MS_Request__c> lRequests = new List<MS_Request__c>();
		
		for (MS_Sprint__c sprint : lSprint){
			
			for (Integer i = 0; i < batchSize; i++){
				
				MS_Request__c request = new MS_Request__c();
				request.MS_Sprint__c = sprint.Id;
				request.Status__c = 'New';
				request.Type__c = 'problem';
				request.Area_of_Salesforce__c = 'opportunity';
				lRequests.add(request);
			}
		}
		
		return lRequests;

	}
	
	public static List<MS_Work_Activity__c> createWorkActivity (List<MS_Request__c> req, List<MS_Sprint__c> sp)
	{
		MS_Work_Activity__c wa = new MS_Work_Activity__c();
		List<MS_Work_Activity__c> w = new List<MS_Work_Activity__c>();
		
		wa.MS_Request__c = req.get(0).Id;
		wa.MS_Sprint__c = sp.get(0).Id;
		wa.Billable__c = req.get(0).Billable__c;
        wa.Work_Date__c = Date.newInstance(2013, 04, 01);
		
		w.add(wa);
		return w;
	}

}