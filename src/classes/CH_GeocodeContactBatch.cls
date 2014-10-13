global with sharing class CH_GeocodeContactBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
  
  //query
  public String Query {get; set;}
  //list of contacts which needs to be updated
  public  sObject[] toUpdate {get; set;}
  //set of contsct id which should be geocoded, used in triggers
  public Set<Id> ids {get; set;}
  //is update
  public Boolean isUpdate {get; set;}
  //is batch
  public Boolean isBatch {get; set;}
  
  //set webservice status, use only in tests
  public String testStatus {get; set;}
   
  global database.querylocator start(Database.BatchableContext BC) {
    toUpdate = new sObject[]{};
    
    //ids are set when we use it from trigger
    if(ids != null && !ids.isEmpty()) {
      if(isUpdate != null && isUpdate) {
        return Database.getQueryLocator([select Id, Name, MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
          from Contact where Id IN :ids limit 1]);
      } else {
        return Database.getQueryLocator([select Id, Name, MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
          from Contact where Id IN :ids and (Latitude__c = null or Longitude__c = null) limit 1]);
      }
    } else {
      return Database.getQueryLocator([select Id, Name, MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
        from Contact where (Latitude__c = null or Longitude__c = null) and (MailingCity != null OR MailingCountry != null OR MailingPostalCode != null OR MailingState != null OR MailingStreet != null) limit 1]);
    }
    
    }
    
    global void execute(SchedulableContext sc){
        try{
            Database.executeBatch(this);
            String jobid = sc.getTriggerId();
            system.abortjob(jobid);
        } catch(Exception ex){
            String jobid = sc.getTriggerId();
            system.abortjob(jobid);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
      if(scope != null && scope.size() > 0 ) {
    
      for(sObject s : scope){  
        Contact c = (Contact) s;
        
        //format address
        String formattedAddress = '';
        if(c.MailingStreet != null && c.MailingStreet.length() > 0){
          formattedAddress += c.MailingStreet;
        }
        if(c.MailingCity != null && c.MailingCity.length() > 0){
          formattedAddress += ' '+c.MailingCity;
        }
        if(c.MailingPostalCode != null && c.MailingPostalCode.length() > 0){
          formattedAddress += ', ' + c.MailingPostalCode;
        }
        if(c.MailingState != null && c.MailingState.length() > 0){
          formattedAddress += ', ' + c.MailingState;
        }
        if(c.MailingCountry != null && c.MailingCountry.length() > 0){
          formattedAddress += ', ' + c.MailingCountry;
        }
        
        formattedAddress = formattedAddress.replace(' ', '+');
        
        CH_Geocode.Location loc;
        if(!Test.isRunningTest()){
          //call the web service
          loc = CH_Geocode.callGeocodeWebservice(formattedAddress);
        } else {
          loc = new CH_Geocode.Location();
          loc.lng = '-44.56';
          loc.lat = '-23.56';
          loc.status = testStatus;
          
        }
        
        if(loc != null && CH_Geocode.STATUS_OK.equals(loc.status)){
          //if status is OK store latitude & longitude in database
          try {
              c.Longitude__c = Double.valueOf(loc.lng);
            } catch(Exception e) {
              System.debug('CH_GeocodeContact_Batch.execute: error casting longitude ' + e);
            }
            
            try {
              c.Latitude__c = Double.valueOf(loc.lat);
            } catch(Exception e) {
              System.debug('CH_GeocodeContact_Batch.execute: error casting latitude ' + e);
            }
            //c.Address_Not_Valid__c = false; 
            toUpdate.add(c);
            if(isUpdate != null && isUpdate) {
              ids.remove(c.id);
            }
        } else if (loc != null && CH_Geocode.STATUS_ZERO_RESULTS.equals(loc.status)){
          // if web service returned zero results set address_not_valid class to false,
          // to prevent calling the web service again and again
          //c.Address_Not_Valid__c = true; 
          toUpdate.add(c);
        } else {
          System.debug('CH_GeocodeContact_Batch.execute: Didn\'t get proper response from google geocoding web service.');
        }
      }
      }
    }
    
    global void finish(Database.BatchableContext BC){
      //update contacts
      if(toUpdate != null){
        update toUpdate;
      }
      
      //check if there is more objests to geocode
      Integer numberOfRowsLeft = 0;
      if((ids == null || ids.isEmpty()) && (isBatch != null && isBatch)) {
        numberOfRowsLeft = [select count() from Contact where (Latitude__c = null or Longitude__c = null) 
          and (MailingStreet != null OR MailingState != null OR MailingPostalCode != null OR MailingCountry != null OR MailingCity != null) limit 10];
      } else {
        if(isUpdate != null && isUpdate){
          numberOfRowsLeft = [select count() from Contact where Id IN :ids limit 10 ];
        
        } else {
          numberOfRowsLeft = [select count() from Contact where Id IN :ids and (Latitude__c = null or Longitude__c = null) limit 10 ];
        }
      }
    
    //if yes schedule new geocode batch job after timeout
      if(numberOfRowsLeft > 0 && CH_Geocode.canCallGeocode() && CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS) && CH_Geocode.canSchedule()){  
        CH_GeocodeAccountBatch n = new CH_GeocodeAccountBatch();
        n.ids =  (isBatch != null && isBatch) ? new Set<Id>() : ids;
        n.isUpdate = isUpdate;
        n.isBatch = isBatch;
        n.testStatus = testStatus;
        //set default timeout to 60s
        Integer secondsInFuture = 60;

        DateTime curr = System.now();
            curr = curr.addSeconds(secondsInFuture);
            String name = 'Geocode Batch - Contacts';
            String nextTime = '';
            nextTime+=curr.second()+' ';
            nextTime+=curr.minute()+' ';
            nextTime+=curr.hour()+' ';
            nextTime+=curr.day()+' ';
            nextTime+=curr.month()+' ? ';
            nextTime+=curr.year();
            
            system.schedule(name,nextTime,n);
      }
      
    }

}