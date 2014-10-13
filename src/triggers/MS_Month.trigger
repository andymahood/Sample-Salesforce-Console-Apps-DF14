trigger MS_Month on MS_Month__c (after insert) {
	MS_MonthTriggerHandler handler = new MS_MonthTriggerHandler();
    
    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
    /* After Update */
    /*else if(Trigger.isUpdate && Trigger.isAfter){
       handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }
    /* Before Insert */
    /*else if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new); 
    }
    /* Before Update */
    /*else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
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