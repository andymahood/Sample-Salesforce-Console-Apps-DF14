global with sharing class CH_GeocodeAccountBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
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
            if(isUpdate != null && isUpdate){
                return Database.getQueryLocator([select Id, Name, BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet 
                    from Account where Id IN :ids limit 1]);
            } else {
                return Database.getQueryLocator([select Id, Name, BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet 
                    from Account where Id IN :ids and (Latitude__c = null or Longitude__c = null) limit 1]);
            }
        } else {
            return Database.getQueryLocator([select Id, Name, BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet 
                from Account where (Latitude__c = null or Longitude__c = null) and (BillingCity != null OR BillingCountry != null OR BillingPostalCode != null OR BillingState != null OR BillingStreet != null) limit 1]);
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
                Account c = (Account) s;
                
                //format address
                String formattedAddress = '';
                if(c.BillingStreet != null && c.BillingStreet.length() > 0){
                    formattedAddress += c.BillingStreet;
                }
                if(c.BillingCity != null && c.BillingCity.length() > 0){
                    formattedAddress += ' '+c.BillingCity;
                }
                if(c.BillingPostalCode != null && c.BillingPostalCode.length() > 0){
                    formattedAddress += ', ' + c.BillingPostalCode;
                }
                if(c.BillingState != null && c.BillingState.length() > 0){
                    formattedAddress += ', ' + c.BillingState;
                }
                if(c.BillingCountry != null && c.BillingCountry.length() > 0){
                    formattedAddress += ', ' + c.BillingCountry;
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
                
                System.debug('CH Response is ' + loc);
                if(loc != null && CH_Geocode.STATUS_OK.equals(loc.status)){
                    //if status is OK store latitude & longitude in database
                    try {
                        c.Longitude__c = Double.valueOf(loc.lng);
                    } catch(Exception e) {
                        System.debug('CH_GeocodeAccount_Batch.execute: error casting longitude ' + e);
                    }
                    
                    try {
                        c.Latitude__c = Double.valueOf(loc.lat);
                    } catch(Exception e) {
                        System.debug('CH_GeocodeAccount_Batch.execute: error casting latitude ' + e);
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
                    System.debug('CH_GeocodeAccount_Batch.execute: Didn\'t get proper response from google geocoding web service.');
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //update accounts
        if(toUpdate != null){
            update toUpdate;
        }
        
        //check if there is more objests to geocode
        Integer numberOfRowsLeft = 0;
        if((ids == null || ids.isEmpty()) && (isBatch != null && isBatch)) {
            numberOfRowsLeft = [select count() from Account where (Latitude__c = null or Longitude__c = null) 
                and (BillingStreet != null OR BillingState != null OR BillingPostalCode != null OR BillingCountry != null OR BillingCity != null) limit 10];
        } else {
            if(isUpdate != null && isUpdate){
                numberOfRowsLeft = [select count() from Account where Id IN :ids limit 10 ];
            
            } else {
                numberOfRowsLeft = [select count() from Account where Id IN :ids and (Latitude__c = null or Longitude__c = null) limit 10 ];
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
            String name = 'Geocode Batch - Accounts';
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