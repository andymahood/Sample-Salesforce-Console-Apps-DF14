@isTest
private class CH_TriggerUtilsTest {

  /**
     *  Method to create accounts for testing.
     *  <p>Changes may need to be made to work with your org
     **/
    private static Account createTestAccount( String accountName ){
        String testAddress= 'Address';
        String BillingStreet = 'testAddress', BillingCity = 'test',  BillingState = 'test', BillingPostalCode = 'test';
        
        return( new Account(
            Name = accountName,
            BillingStreet=BillingStreet,
            BillingCity=BillingCity,
            BillingState=BillingState,
            BillingPostalCode=BillingPostalCode ) );
    }
    
  static testMethod void test(){
        List<Account> oldList = new List<Account>{
            createTestAccount( 'a1' ),
            createTestAccount( 'a2' ),
            createTestAccount( 'a3' )
        };
        insert oldList;
        
        List<Account> newList = oldList.deepClone(true);
        
        Map<id,Account> oldMap = new Map<id,Account>( oldList );
        Map<id,Account> newMap = new Map<id,Account>( newList );
        
        List<Account> changedAccounts = new List<Account>();
        CH_TriggerUtils.filterChangedObjects(newList, oldMap, 'Name', changedAccounts);
        
        System.assertEquals( 0, changedAccounts.size() );
        
        newList[0].Name = 't1';
        newMap = new Map<id,Account>( newList );
        
        changedAccounts.clear();
        CH_TriggerUtils.filterChangedObjects( newList, oldMap, 'Name', changedAccounts );
        
        System.assertEquals( 1, changedAccounts.size() );
        System.assertEquals( newList[0].id, changedAccounts[0].id );
        System.assertEquals( newList[0], changedAccounts[0] );
        
        List<Account> notChangedAccounts = new List<Account>();
        CH_TriggerUtils.filterNotChangedObjects( newList, oldMap, 'Name', notChangedAccounts );
        System.assertEquals( 2, notChangedAccounts.size() );
        
        CH_TriggerUtils.filterChangedObjects(newList, null, 'Name', changedAccounts);
        CH_TriggerUtils.filterNotChangedObjects(newList, null, 'Name', notChangedAccounts);
    }  
}