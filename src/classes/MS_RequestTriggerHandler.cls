// James Melville Tquila 28/03/2013
// Share the information for the client org to the Tquila org, after a request in inserted 

public with sharing class MS_RequestTriggerHandler {
    
    public MS_RequestTriggerHandler(){
    }

    public void OnAfterInsert(list<MS_Request__c> newObjects){
    	//share the new request created
    	MS_PartnerNetworkConnection.shareRecords(newObjects);
    	//link the request lookup MS_Sprint__c using MS_Sprint_Id__c
        MS_PartnerNetworkConnection.parseRecordsForLinking(newObjects,new map<Id,MS_Request__c>(),
                                                           'MS_Request__c','MS_Sprint_Id__c','MS_Sprint__c');
    }

    public void OnAfterUpdate(list<MS_Request__c> oldObjects, list<MS_Request__c> updatedObjects, map<Id,MS_Request__c> oldObjectMap){
        //link the request lookup MS_Sprint__c using MS_Sprint_Id__c
        MS_PartnerNetworkConnection.parseRecordsForLinking(updatedObjects,oldObjectMap,
                                                           'MS_Request__c','MS_Sprint_Id__c','MS_Sprint__c');
       	MS_PartnerNetworkConnection.deleteRecords(updatedObjects, 'MS_Request__c');
    }
 
    /*public void OnBeforeInsert(list<MS_Request__c> newObjects){
      // MS_PartnerNetworkConnection.linkRecords(new map<Id,Id>(),
      //                                           'MS_Sprint_Id__c','MS_Sprint__c');
    }*/

    /*public void OnBeforeUpdate(list<MS_Request__c> oldObjects, list<MS_Request__c> updatedObjects, map<Id,MS_Request__c> oldObjectMap){
        MS_PartnerNetworkConnection.parseRecordsForLinking(updatedObjects,oldObjectMap, 
                                                'MS_Request__c','MS_Sprint_Id__c','MS_Sprint__c');
    }*/

    /*public void OnBeforeDelete(Object[] ObjectsToDelete, MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }*/

}