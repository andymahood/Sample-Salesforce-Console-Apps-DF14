public with sharing class MS_SprintTriggerHandler {

    public MS_SprintTriggerHandler(){
    }
    
    public void OnAfterInsert(list<MS_Sprint__c> newObjects, map<Id,MS_Sprint__c> newObjectMap){
        // link the month lookup MS_Month__c using MS_Month_Id__c
        MS_PartnerNetworkConnection.parseRecordsForLinking(newObjects,new map<Id,MS_Sprint__c>(), 
                                                'MS_Sprint__c','MS_Month_Id__c','MS_Month__c');
        // link the request lookup MS_Sprint__c using MS_Sprint_Id__c                                        
        MS_PartnerNetworkConnection.updateRelatedRecords(newObjectMap.keyset(), 'MS_Request__c', 'MS_Sprint_Id__c',
                                              'MS_Sprint__c');
    }

    public void OnAfterUpdate(list<MS_Sprint__c> oldObjects, list<MS_Sprint__c> updatedObjects, map<Id,MS_Sprint__c> oldObjectMap){
        // link the month lookup MS_Month__c using MS_Month_Id__c
        MS_PartnerNetworkConnection.parseRecordsForLinking(updatedObjects,oldObjectMap, 
                                                'MS_Sprint__c','MS_Month_Id__c','MS_Month__c');
    }
 
    /*public void OnBeforeInsert(list<MS_Sprint__c> newObjects){
    }

    public void OnBeforeUpdate(list<MS_Sprint__c> oldObjects, list<MS_Sprint__c> updatedObjects, map<Id,MS_Sprint__c> oldObjectMap){

    }

    public void OnBeforeDelete(Object[] ObjectsToDelete, MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }*/
}