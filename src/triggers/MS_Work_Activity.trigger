// James Melville Tquila 28/03/2013
//after insert / update : map lookup values
trigger MS_Work_Activity on MS_Work_Activity__c (
    //after delete, after undelete, before delete, before insert, before update
    after insert, after update) {

    MS_WorkActivityTriggerHandler handler = new MS_WorkActivityTriggerHandler();
    
    /* After Insert */
    //share the work activity record after insert
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }
    /* Before Insert */
    /*else if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }*/
    /* Before Update */
    /*else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }*/
    /* Before Delete */
    /*else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }*/
    /* After Delete */
    /*else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }*/
    /* After Undelete */
    /*else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }*/
}
/*trigger MS_Work_Activity on MS_Work_Activity__c (after insert, after update) {

    // build the client local work activity map used to link the id to the Request lookup
    Map<Id,Id> workActivityRequestIdMap = new Map<Id,Id>();
     // build the client local work activity map used to link the id to the Sprint lookup
    Map<Id,Id> workActivitySprintIdMap = new Map<Id,Id>();
    //loop over the object
    for (MS_Work_Activity__c newWorkActivity : Trigger.new) {
        //make sure the field created to store the request id is populated
        if ((newWorkActivity.MS_Request_Id__c != null && newWorkActivity.MS_Request_Id__c != '') 
                //make sure the field created to store the sprint id is populated
                && (newWorkActivity.MS_Sprint_Id__c != null && newWorkActivity.MS_Sprint_Id__c != '')){

            if (Trigger.isInsert

                || (Trigger.isUpdate
                    // if the value of the field changed
                    && (Trigger.oldMap.get(newWorkActivity.Id).MS_Request_Id__c != newWorkActivity.MS_Request_Id__c)
                        && (Trigger.oldMap.get(newWorkActivity.Id).MS_Sprint_Id__c != newWorkActivity.MS_Sprint_Id__c))) {
               //populate the map with the work activity id and MS_Id
               workActivityRequestIdMap.put(newWorkActivity.Id, newWorkActivity.MS_Request_Id__c);
               workActivitySprintIdMap.put(newWorkActivity.Id, newWorkActivity.MS_Sprint_Id__c);
            }
        }
    }
  
    // call future method to link local work activity with the coresponding MS_Request and MS_Sprint.
    if ((workActivityRequestIdMap.size() > 0) && (workActivitySprintIdMap.size() > 0)){

        ExternalSharingHelper.linkRequestWorkActivity(workActivityRequestIdMap);
        ExternalSharingHelper.linkSprintWorkActivity(workActivitySprintIdMap);

    }
}*/