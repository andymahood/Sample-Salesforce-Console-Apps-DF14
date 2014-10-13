trigger ContactTrigger on Contact (after insert, after update) {

  ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isAfter) {
      if(Trigger.isInsert) {
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
      } else if(Trigger.isUpdate) {
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
      }
    }

}