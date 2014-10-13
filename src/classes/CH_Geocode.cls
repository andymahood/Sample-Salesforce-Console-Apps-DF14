public with sharing class CH_Geocode {
    
    public static String STATUS_OK = 'OK';
    public static String STATUS_OVER_QUERY_LIMIT = 'OVER_QUERY_LIMIT';
    public static String STATUS_ZERO_RESULTS = 'ZERO_RESULTS';
    
    public static String OBJ_SITES = 'Sites';
    public static String OBJ_CONTACTS = 'Contacts';
    public static String OBJ_LEADS = 'Leads';
    
    public static String GEOCODE_DATE;
    public static Boolean GEOCODE_IS_ALLOWED;
    public static String GEOCODE_COUNT;
    
    //object which stores geocoding web service result (latitude, longitude and status)
    public class Location {
        public String lat;
        public String lng;
        public String status;
    }
    
    /**
     *  Call geocoding web service for given address
     *  @param formattedAddress (String) - address formatted to be sent in GET request (use '+' instead of spaces)
     **/
    public static CH_Geocode.Location callGeocodeWebservice(String formattedAddress){
            HttpRequest req = new HttpRequest();
            
            formattedAddress = EncodingUtil.urlEncode(formattedAddress, 'UTF-8');
            
            String privateKey = 'ITTP8AHIF5G0e9HQ2nvVBlLtvhk';
            String clientID = 'gme-k2partneringsolutions';

            String url = '/maps/api/geocode/json?address='+formattedAddress+'&sensor=false&client='+clientID;

            privateKey = privateKey.replace('-', '+');
            privateKey = privateKey.replace('_', '/');
            Blob decodedKey = EncodingUtil.base64Decode(privateKey);
            Blob decodedUrl = Blob.valueof(url);
            Blob signature = Crypto.generateMac('hmacSHA1', decodedUrl, decodedKey);

            String encodedSignature = EncodingUtil.base64Encode(signature);
            encodedSignature = encodedSignature.replace('+', '-');
            encodedSignature = encodedSignature.replace('/', '_');
            
            req.setEndpoint('https://maps.googleapis.com'+url+'&signature='+encodedSignature);
            //req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+formattedAddress+'&sensor=true');
            //req.setEndpoint('http://wojtekm.devel.polsource.com/gm.php?address='+formattedAddress+'&sensor=true');
            req.setMethod('GET');
            
            CH_Geocode.Location loc;
            if(!Test.isRunningTest()){
                Http http = new Http();
                HTTPResponse response = http.send(req);
                loc = parseResponse(response.getBody());
            }
            
            return loc;
    }
    
    /**
    * Function checks if limit of batches has been crossed over
    */
    public static Boolean canExecuteBatch(String objName){
/*          
        String className;
        if(OBJ_SITES.equals(objName)){
            className = 'CH_GeocodeSites_Batch';
        } else if(OBJ_CONTACTS.equals(objName)){
            className = 'CH_GeocodeContact_Batch';
        } else if(OBJ_LEADS.equals(objName)){
            className = 'CH_GeocodeLeads_Batch';
        } else {
            return false;
        }
        Integer batch_count = K2Force_GlobalSettings.getValue('batch_executions_count_per_day') == null ? 0 : integer.valueOf(K2Force_GlobalSettings.getValue('batch_executions_count_per_day'));
        Date batch_date  = K2Force_GlobalSettings.getValue('batch_executions_date') == null ? date.newinstance(1960, 2, 17) : date.valueOf(K2Force_GlobalSettings.getValue('batch_executions_date'));
        
        AsyncApexJob[] batchInProgress = [select id from AsyncApexJob where(ApexClass.Name = :objName and (Status = 'Queued' or Status = 'Processing'))];
        AsyncApexJob[] activeJobs = [select id from AsyncApexJob where (Status = 'Queued' or Status = 'Processing')];
  
        if(activeJobs.size() < 5 && batchInProgress.size() < 1){
            if(!date.today().isSameDay(batch_date)){
                Date newDate = date.today();
                K2Force_GlobalSettings.setValue('batch_executions_date',  newDate.year()+'-'+newDate.month()+'-'+newDate.day());
                K2Force_GlobalSettings.setValue('batch_executions_count_per_day', String.valueOf(0));
                return true;
            } else {
                //BATCH_IS_ALLOWED = batch_count < 249900 ? true : false;
                return batch_count < 249900 ? true : false;
            }
        } else {
            //BATCH_IS_ALLOWED = false;
            return false;
        }
*/
        return true;
    }
    
    public static Boolean canSchedule(){
        Integer scheduledJobsCount = [SELECT count() FROM CronTrigger WHERE State = 'WAITING'];
        return scheduledJobsCount < 25 ? true : false;
    }
    
    /**
    * Function checks if google geocode web service can be called or if limit has been crossed over
    */
    public static Boolean canCallGeocode(){
/*
        Integer geocode_callouts_count = K2Force_GlobalSettings.getValue('geocode_callouts_count') == null ? 0 : integer.valueOf(K2Force_GlobalSettings.getValue('geocode_callouts_count'));
        String dateString = K2Force_GlobalSettings.getValue('geocode_callouts_date') == null ? '' : K2Force_GlobalSettings.getValue('geocode_callouts_date');
        Date geocode_callouts_date;
        
        if(StringUtils.equals(GEOCODE_DATE , dateString) && StringUtils.equals(GEOCODE_COUNT , String.valueOf(geocode_callouts_count))){
            return GEOCODE_IS_ALLOWED;
        } else {
            
            if(StringUtils.equals(dateString,'')){
                geocode_callouts_date = date.newinstance(1960, 2, 17);
            } else {
                geocode_callouts_date  = date.valueOf(dateString);
            }
            if(!date.today().isSameDay(geocode_callouts_date)){
                Date newDate = date.today();
                String newDateString = newDate.year()+'-'+newDate.month()+'-'+newDate.day();
                K2Force_GlobalSettings.setValue('geocode_callouts_date', newDateString);
                K2Force_GlobalSettings.setValue('geocode_callouts_count', String.valueOf(0));
                GEOCODE_DATE = newDateString;
                GEOCODE_COUNT = String.ValueOf(geocode_callouts_count);
                GEOCODE_IS_ALLOWED = true;
                return true;
            } else {
                GEOCODE_IS_ALLOWED = geocode_callouts_count < 2000 ? true : false;
                GEOCODE_DATE = dateString;
                GEOCODE_COUNT = String.ValueOf(geocode_callouts_count);
                return geocode_callouts_count < 2000 ? true : false;
            }
        }
*/  
        return true;        
    }
    
    public static CH_Geocode.Location parseResponse(String response){
        JSONParser parser = JSON.createParser(response);
        //parse response
            CH_Geocode.Location loc = new CH_Geocode.Location();
            while(parser.nextToken() != null) {
                if('status'.equalsIgnoreCase(parser.getCurrentName())) {
                    try {
                        if(STATUS_OVER_QUERY_LIMIT.equalsIgnoreCase(parser.getText())){
                            loc.status = STATUS_OVER_QUERY_LIMIT;
                            throw new IllegalStateException(STATUS_OVER_QUERY_LIMIT);
                        } else if(STATUS_ZERO_RESULTS.equalsIgnoreCase(parser.getText())){
                            loc.status = STATUS_ZERO_RESULTS;
                        }
                    } catch (Exception e){
                        return null;
                    }
                }
                //parse 'geometry' token
                if('geometry'.equalsIgnoreCase(parser.getCurrentName())) {
                    parser.nextValue();
                    while(parser.nextToken() != null) {
                        //parse 'location' token
                        if('location'.equalsIgnoreCase(parser.getCurrentName())){
                            parser.nextValue();
                            loc = (CH_Geocode.Location)parser.readValueAs(CH_Geocode.Location.class);
                            loc.status = STATUS_OK;
                            break;
                        }
                    }
                    break;  
                }
            }
            return loc;
    }
}