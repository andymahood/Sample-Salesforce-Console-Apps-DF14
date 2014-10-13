trigger UserTrigger on User (before update) {
  
  UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
  
  if(Trigger.isBefore && Trigger.isUpdate) {
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

}