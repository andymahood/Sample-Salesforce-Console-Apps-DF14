public with sharing class AccountTriggerHandler {

  private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public AccountTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

  public void OnAfterInsert(Account[] newAccounts, Map<Id, Account> newAccountMap) {
    //Geocoding address
    CH_GeocodeAccountBatch geocodeBatch = new CH_GeocodeAccountBatch();
      geocodeBatch.ids = newAccountMap.keySet();
      if(!Test.isRunningTest()) {
      ID batchprocessid = Database.executeBatch(geocodeBatch, 1);
      }
  }
  
  public void OnAfterUpdate(List<Account> oldAccounts, List<Account> updatedAccounts, Map<Id, Account> oldAccountMap, Map<Id, Account> updatedAccountMap) {
    Account[] changedAccounts = checkIfAddressChanged(updatedAccounts, oldAccountMap);
      if(changedAccounts != null && changedAccounts.size() > 0){
          // Build a set of the item objects in the batch
      Set<Id> changedIds = new Set<Id>();
          for(Account objItem: changedAccounts){
             Id idItem = (Id) objItem.get('Id');
        changedIds.add(idItem);
          }
          //execute batch geocoding
      CH_GeocodeAccountBatch geocodeBatch = new CH_GeocodeAccountBatch();
        geocodeBatch.ids = changedIds;
        geocodeBatch.isUpdate = true;
        if(!Test.isRunningTest()) {
        ID batchprocessid = Database.executeBatch(geocodeBatch,1);
        }
      }
  }
  
  private Account[] checkIfAddressChanged(Account[] updatedAccounts, Map<ID, Account> oldAccountMap) {
      Account[] changedAccounts = new Account[]{};
    Account[] tmpChangedAccounts = new Account[]{};
    
      CH_TriggerUtils.filterChangedObjects(updatedAccounts, oldAccountMap, 'BillingStreet', tmpChangedAccounts);
      changedAccounts.addAll(tmpChangedAccounts);
      
      CH_TriggerUtils.filterChangedObjects(updatedAccounts, oldAccountMap, 'BillingState', tmpChangedAccounts);
      changedAccounts.addAll(tmpChangedAccounts);
      
      CH_TriggerUtils.filterChangedObjects(updatedAccounts, oldAccountMap, 'BillingPostalCode', tmpChangedAccounts);
      changedAccounts.addAll(tmpChangedAccounts);
      
      CH_TriggerUtils.filterChangedObjects(updatedAccounts, oldAccountMap, 'BillingCountry', tmpChangedAccounts);
      changedAccounts.addAll(tmpChangedAccounts);
      
      CH_TriggerUtils.filterChangedObjects(updatedAccounts, oldAccountMap, 'BillingCity', tmpChangedAccounts);
      changedAccounts.addAll(tmpChangedAccounts);
      
      return changedAccounts;
    }
  

}