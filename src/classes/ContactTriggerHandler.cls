public with sharing class ContactTriggerHandler {

  private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

  public void OnAfterInsert(Contact[] newContacts, Map<Id, Contact> newContactMap) {
    //Geocoding address 
    CH_GeocodeContactBatch geocodeBatch = new CH_GeocodeContactBatch();
      geocodeBatch.ids = newContactMap.keySet();
      if(!Test.isRunningTest()) {
      ID batchprocessid = Database.executeBatch(geocodeBatch, 1);
      }
  }
  
  public void OnAfterUpdate(List<Contact> oldContacts, List<Contact> updatedContacts, Map<Id, Contact> oldContactMap, Map<Id, Contact> updatedContactMap) {
    Contact[] changedContacts = checkIfAddressChanged(updatedContacts, oldContactMap);
      if(changedContacts != null && changedContacts.size() > 0){
          // Build a set of the item objects in the batch
      Set<Id> changedIds = new Set<Id>();
          for(Contact objItem: changedContacts){
             Id idItem = (Id) objItem.get('Id');
        changedIds.add(idItem);
          }
          //execute batch geocoding
      CH_GeocodeContactBatch geocodeBatch = new CH_GeocodeContactBatch();
        geocodeBatch.ids = changedIds;
        geocodeBatch.isUpdate = true;
        if(!Test.isRunningTest()) {
        ID batchprocessid = Database.executeBatch(geocodeBatch,1);
        }
      }
  }
  
  private Contact[] checkIfAddressChanged(Contact[] updatedContacts, Map<ID, Contact> oldContactMap) {
      Contact[] changedContacts = new Contact[]{};
    Contact[] tmpChangedContacts = new Contact[]{};
    
      CH_TriggerUtils.filterChangedObjects(updatedContacts, oldContactMap, 'MailingStreet', tmpChangedContacts);
      changedContacts.addAll(tmpChangedContacts);
      
      CH_TriggerUtils.filterChangedObjects(updatedContacts, oldContactMap, 'MailingState', tmpChangedContacts);
      changedContacts.addAll(tmpChangedContacts);
      
      CH_TriggerUtils.filterChangedObjects(updatedContacts, oldContactMap, 'MailingPostalCode', tmpChangedContacts);
      changedContacts.addAll(tmpChangedContacts);
      
      CH_TriggerUtils.filterChangedObjects(updatedContacts, oldContactMap, 'MailingCountry', tmpChangedContacts);
      changedContacts.addAll(tmpChangedContacts);
      
      CH_TriggerUtils.filterChangedObjects(updatedContacts, oldContactMap, 'MailingCity', tmpChangedContacts);
      changedContacts.addAll(tmpChangedContacts);
      
      return changedContacts;
    }
  
}