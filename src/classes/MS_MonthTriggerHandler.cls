public with sharing class MS_MonthTriggerHandler {
	
	public MS_MonthTriggerHandler(){
    }

    public void OnAfterInsert(list<MS_Month__c> newObjects, map<Id,MS_Month__c> newObjectMap){
        // link the month lookup MS_Month__c using MS_Month_Id__c on MS_Sprint__c
        MS_PartnerNetworkConnection.updateRelatedRecords(newObjectMap.keyset(), 'MS_Sprint__c', 'MS_Month_Id__c',
                                              'MS_Month__c');
    }
}