// Cristina Popescu / James Melville Tquila 02/04/2013
//after insert / update : map lookup values
public with sharing class MS_WorkActivityTriggerHandler {

    public MS_WorkActivityTriggerHandler(){
    }
    
    public void OnAfterInsert(list<MS_Work_Activity__c> newObjects){
        // map sprint Id and request Id
        MS_PartnerNetworkConnection.parseRecordsForLinking(newObjects,new map<Id,MS_Sprint__c>(), 
                                                'MS_Work_Activity__c','MS_Sprint_Id__c','MS_Sprint__c');
        MS_PartnerNetworkConnection.parseRecordsForLinking(newObjects,new map<Id,MS_Sprint__c>(), 
                                                'MS_Work_Activity__c','MS_Request_Id__c','MS_Request__c');
    }

    public void OnAfterUpdate(list<MS_Work_Activity__c> oldObjects, list<MS_Work_Activity__c> updatedObjects, map<Id,MS_Work_Activity__c> oldObjectMap){
        // map sprint Id and request Id
        MS_PartnerNetworkConnection.parseRecordsForLinking(updatedObjects,oldObjectMap, 
                                                'MS_Work_Activity__c','MS_Sprint_Id__c','MS_Sprint__c');
        MS_PartnerNetworkConnection.parseRecordsForLinking(updatedObjects,oldObjectMap,
                                                'MS_Work_Activity__c','MS_Request_Id__c','MS_Request__c');
        MS_PartnerNetworkConnection.deleteRecords(updatedObjects, 'MS_Work_Activity__c');

    }
 
    /*public void OnBeforeInsert(list<MS_Sprint__c> newObjects){
    }

    public void OnBeforeUpdate(list<MS_Sprint__c> oldObjects, list<MS_Sprint__c> updatedObjects, map<Id,MS_Sprint__c> oldObjectMap){

    }

    public void OnBeforeDelete(list<MS_Work_Activity__c> ObjectsToDelete){
        
    }

    /*public void OnAfterDelete(Object[] deletedObjects, MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }*/
}