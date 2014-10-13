trigger AccountTrigger on Account (after insert, after update) {

  AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isAfter) {
      if(Trigger.isInsert) {
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
      } else if(Trigger.isUpdate) {
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
      }
    }

}