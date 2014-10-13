public with sharing class MS_PartnerNetworkConnection {
    
    //method that will create newRecordConnection when a request is created 
    public static void shareRecords (List<MS_Request__c> newObjects){
        
        List<PartnerNetworkRecordConnection> lRequestRecordConnections = new List<PartnerNetworkRecordConnection>();
        //custom settings that store connectionId
        MS_Settings__c msSettings = MS_Settings__c.getOrgDefaults();
        //loop over the object and share it
        for (MS_Request__c r : newObjects){
               
            PartnerNetworkRecordConnection newRecordConnection = new PartnerNetworkRecordConnection();
            newRecordConnection.ConnectionId = msSettings.PartnerNetworkConnectionId__c;
            newRecordConnection.LocalRecordId = r.Id;
            lRequestRecordConnections.add(newRecordConnection);  
        }
        insert lRequestRecordConnections;
     }
     
    public static void deleteRecords(list<SObject> ObjectsToDelete,string objectName)
	{	
		set<Id> objIds = new set<Id>();
		
		for (SObject obj : ObjectsToDelete) {
			objIds.add((Id)obj.get('Id'));
		}
		system.debug('***Id' + objIds);
		
		List<PartnerNetworkRecordConnection> pnrc = new List<PartnerNetworkRecordConnection>(
																					[SELECT Id, Status,LocalRecordId 
						             													FROM PartnerNetworkRecordConnection 
						            													WHERE (Status='Deleted' OR Status='Inactive') 
						            													AND LocalRecordId IN : objIds]);
		
        system.debug('***' + pnrc);
        
        if (pnrc.size()>0){   
        	     
	        List<SObject> listToDetele = new List<SObject>(); 
	        Type t = Type.forName(objectName);
	        for (Id Id : objIds) { 
	        
	            SObject recordToDelete = (SObject)t.newInstance();
	            recordToDelete.put('Id',Id);
	            
	            listToDetele.add(recordToDelete);                                                          
	        }
	        
	        if(!listToDetele.isEmpty()){                                                            
	        	database.delete(listToDetele,false);
	        } 
        }
	}
     
    public static void parseRecordsForLinking(list<SObject> newObjects, map<Id,SObject> oldObjects,
                                              string objectName, string sourceFieldName,
                                              string targetFieldName) {
        //map of local recordId with remote lookup record Id
        map<Id,Id> linkingIds = new map<Id,Id>();
        
        //loop over each object
        for(SObject obj : newObjects) {
            //lookup record from old map
            SObject oldObj = oldObjects.get((Id)obj.get('Id'));
         //   Object targetValue = recordRemoteToLocalMap.get((Id)obj.get(sourceFieldName));
            
            //if this is a new record, or the field has changed add it to the list
            if(oldObj == null || obj.get(sourceFieldName) != oldObj.get(sourceFieldName)/* || obj.get(targetFieldName) != targetValue*/) {
                linkingIds.put((Id)obj.get('Id'),(Id)obj.get(sourceFieldName));
            }
        }
        //call the future method to link the records
        if(!linkingIds.isEmpty())// && !System.isFuture() && !System.isBatch())
            linkRecordsFuture(linkingIds, objectName, targetFieldName);
    }
    
    @future
    public static void linkRecordsFuture(Map<Id,Id> recordIdMap, string objectName, string targetFieldName) {
        linkRecords(recordIdMap, objectName, targetFieldName);
    }
    //method that assigns text field values to lookup Ids
     
    public static void linkRecords(Map<Id,Id> recordIdMap, string objectName, string targetFieldName) {
        //set of remote ids for the records to be updated
        Set<Id> remoteIdSet = new Set<Id>();
        for (Id remoteId : recordIdMap.values()) {
            remoteIdSet.add(remoteId);
        }
  
        //mapping of the remote id to the local id
        Map<Id,Id> recordRemoteToLocalMap = new Map<Id,Id>(); 
        
        for (PartnerNetworkRecordConnection recordConnection : 
            [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
             FROM PartnerNetworkRecordConnection 
             WHERE PartnerRecordId in :remoteIdSet]) { 
                
            if ( recordConnection.Status == 'Sent' || recordConnection.Status == 'Received') {                                                                
                recordRemoteToLocalMap.put(recordConnection.PartnerRecordId, recordConnection.LocalRecordId); 
            } 
        } 
                
        List<SObject> localRecordList = new List<SObject>(); 
        Type t = Type.forName(objectName);
        for (Id recordId : recordIdMap.keySet()) { 
        
            SObject recordForUpdate = (SObject)t.newInstance();
            recordForUpdate.put('Id',recordId);
            recordForUpdate.put(targetFieldName, recordRemoteToLocalMap.get(recordIdMap.get(recordId))); 
            
            localRecordList.add(recordForUpdate);                                                          
        }
        
        if(!localRecordList.isEmpty()){                                                            
        	database.update(localRecordList);
        } 
    }
    
    //--------------
    public static void updateRelatedRecords(Set<Id> updatedObjIds, String objectName, string sourceFieldName,
                                              string targetFieldName){
        
        //mapping of the remote id to the local id
        Map<Id,Id> recordRemoteToLocalMap = new Map<Id,Id>();
        
        Set<String> remoteIdSet = new Set<String>();
        for (PartnerNetworkRecordConnection recordConnection : 
				            [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
				             FROM PartnerNetworkRecordConnection 
				             WHERE LocalRecordId IN :updatedObjIds]) { 
                
            if ( recordConnection.Status == 'Sent' || recordConnection.Status == 'Received' ) {                                                                
                recordRemoteToLocalMap.put(recordConnection.PartnerRecordId, recordConnection.LocalRecordId);
                String strId = recordConnection.PartnerRecordId;
                remoteIdSet.add(strId.substring(0, 15));
            } 
        }
        
        String queryStr = 'SELECT ' + sourceFieldName + ', ' + targetFieldName + ' FROM ' + objectName +
        				' WHERE ' + sourceFieldName + ' IN : remoteIdSet';
        
        List<SObject> objToUpdate = new List<SObject>(); 				
        for(SObject obj : Database.query(queryStr)){
        	Id oldVal = (Id)obj.get(targetFieldName);
        	Id newVal = recordRemoteToLocalMap.get((Id)obj.get(sourceFieldName));
        	if(oldVal != newVal){
	        	obj.put(targetFieldName, newVal);
	        	objToUpdate.add(obj);
        	}
        }
        
        if(!objToUpdate.isEmpty()){
        	database.update(objToUpdate);
        }
    }
/*
    public static void parseRecordsForLinking(list<SObject> newObjects, map<Id,SObject> oldObjects,
                                              string objectName, string sourceFieldName, string targetFieldName) {
        
        //objects to be mapped
        list<SObject> objForMapping = new list<SObject>();
        
        //set of remote ids to lookup
        set<Id> remoteIds = new set<Id>();
        
        //remote lookup record Id to local lookup record Id
        map<Id,Id> remoteToLocal = new map<Id,Id>();
        
        //loop over each object
        for(SObject obj : newObjects) {
            //lookup record from old map
            SObject oldObj = oldObjects.get((Id)obj.get('Id'));
            
            //if this is a new record, or the field has changed add it to the list
            if(oldObj == null || obj.get(sourceFieldName) != oldObj.get(sourceFieldName)) {
                remoteIds.add((Id)obj.get(sourceFieldName));
                objForMapping.add(obj);
            }
        }
        
        //if any records need updating then lookup the mapping records
        if(!objForMapping.isEmpty()) {
            //objects for update
            list<SObject> objForUpdate = new list<SObject>();
            //query for mapping records to get local lookups from remote
            for (PartnerNetworkRecordConnection recordConnection : 
                [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
                 FROM PartnerNetworkRecordConnection 
                 WHERE PartnerRecordId in :remoteIds]) { 
                    
                if ( recordConnection.Status == 'Sent' || recordConnection.Status == 'Received') {
                    //if we have a mapping from remote to local put it in a map                                                                
                    remoteToLocal.put(recordConnection.PartnerRecordId, recordConnection.LocalRecordId);
                } 
            }
            
            Type t = Type.forName(objectName);
            
            //for each object update 
            for(SObject obj : objForMapping) {
                //find the local lookup id using the remote one
                Id localLookup = remoteToLocal.get((Id)obj.get(sourceFieldName));
                
                //if the local lookup exists create new object for update and add it to commit list
                if(localLookup != null) {
                    SObject recordForUpdate = (SObject)t.newInstance();
                    recordForUpdate.put('Id',(Id)obj.get('Id'));
                    recordForUpdate.put(targetFieldName,localLookup);
                    objForUpdate.add(recordForUpdate);
                }
            }
            
            //update any sobjects
            if(!objForUpdate.isEmpty())
                update objForUpdate;
        }
    }*/
}

    /*public static void parseRecordsForLinking(list<SObject> newObjects, map<Id,SObject> oldObjects,
                                              string objectName, string sourceFieldName, string targetFieldName) {
        
        //objects to be mapped
        list<SObject> objForMapping = new list<SObject>();
        
        //set of remote ids to lookup
        set<Id> remoteIds = new set<Id>();
        
        //remote lookup record Id to local lookup record Id
        map<Id,Id> remoteToLocal = new map<Id,Id>();
        
        //loop over each object
        for(SObject obj : newObjects) {
            //lookup record from old map
            SObject oldObj = oldObjects.get((Id)obj.get('Id'));
            
            //if this is a new record, or the field has changed add it to the list
            if(oldObj == null || obj.get(sourceFieldName) != oldObj.get(sourceFieldName)) {
                remoteIds.add((Id)obj.get(sourceFieldName));
                objForMapping.add(obj);
            }
        }
        
        //if any records need updating then lookup the mapping records
        if(!objForMapping.isEmpty()) {
            //objects for update
            list<SObject> objForUpdate = new list<SObject>();
            //query for mapping records to get local lookups from remote
            for (PartnerNetworkRecordConnection recordConnection : 
                [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
                 FROM PartnerNetworkRecordConnection 
                 WHERE PartnerRecordId in :remoteIds]) { 
                    
                if ( recordConnection.Status == 'Sent' || recordConnection.Status == 'Received') {
                    //if we have a mapping from remote to local put it in a map                                                                
                    remoteToLocal.put(recordConnection.PartnerRecordId, recordConnection.LocalRecordId);
                } 
            }
            
            Type t = Type.forName(objectName);
            
            //for each object update 
            for(SObject obj : objForMapping) {
                //find the local lookup id using the remote one
                Id localLookup = remoteToLocal.get((Id)obj.get(sourceFieldName));
                
                //if the local lookup exists create new object for update and add it to commit list
                if(localLookup != null) {
                    SObject recordForUpdate = (SObject)t.newInstance();
                    recordForUpdate.put('Id',(Id)obj.get('Id'));
                    recordForUpdate.put(targetFieldName,localLookup);
                    objForUpdate.add(recordForUpdate);
                }
            }
            
            //update any sobjects
            if(!objForUpdate.isEmpty())
                update objForUpdate;
        }
    }
}*/