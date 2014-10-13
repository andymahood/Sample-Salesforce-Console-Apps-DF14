@isTest
private class CH_GeocodeTest {
  
    static testMethod void testWebserviceCall() {
      Test.StartTest();
      Date todayDate = date.today();
      
      String formattedAddress = '1600+Amphitheatre+Parkway,+Mountain+View,+CA';
      CH_Geocode.Location loc = CH_Geocode.callGeocodeWebservice(formattedAddress);
      Test.StopTest();
    }
  
     static testMethod void testParseResponse() {
       Test.StartTest();
       String response = '{ "results" : [ { "address_components" : [ { "long_name" : "2", "short_name" : "2", "types" : [ "street_number" ] }, { "long_name" : "Józefitów", "short_name" : "Józefitów", "types" : [ "route" ] }, { "long_name" : "dzielnica V Krowodrza", "short_name" : "dzielnica V Krowodrza", "types" : [ "sublocality", "political" ] }, { "long_name" : "Krakow", "short_name" : "Krakow", "types" : [ "locality", "political" ] }, { "long_name" : "Kraków", "short_name" : "Kraków", "types" : [ "administrative_area_level_3", "political" ] }, { "long_name" : "Kraków County", "short_name" : "Kraków County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Malopolskie", "short_name" : "Malopolskie", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "Poland", "short_name" : "PL", "types" : [ "country", "political" ] }, { "long_name" : "30-001", "short_name" : "30-001", "types" : [ "postal_code" ] }, { "long_name" : "30", "short_name" : "30", "types" : [ "postal_code_prefix", "postal_code" ] } ], "formatted_address" : "Józefitów 2, 30-001 Kraków, Poland", "geometry" : { "location" : { "lat" : 50.07147610, "lng" : 19.92439610 }, "location_type" : "ROOFTOP", "viewport" : { "northeast" : { "lat" : 50.07282508029149, "lng" : 19.92574508029150 }, "southwest" : { "lat" : 50.07012711970849, "lng" : 19.92304711970850 } } }, "partial_match" : true, "types" : [ "street_address" ] } ], "status" : "OK" }';
       CH_Geocode.Location loc = CH_Geocode.parseResponse(response);
       Test.StopTest();
         
       System.assertEquals('50.07147610', loc.lat);
       System.assertEquals('19.92439610', loc.lng);
       System.assertEquals('OK', loc.status);
     }
   
     static testMethod void testParseResponseOverQueryLimit() {
       Test.StartTest();
       String response = '{ "status" : "OVER_QUERY_LIMIT" }';
       CH_Geocode.Location loc = CH_Geocode.parseResponse(response);
       Test.StopTest();
         
     }
   
     static testMethod void testParseResponseZroResults() {
       Test.StartTest();
       String response = '{ "status" : "ZERO_RESULTS" }';
       CH_Geocode.Location loc = CH_Geocode.parseResponse(response);
       Test.StopTest();
       System.assertEquals(null, loc.lat);
       System.assertEquals(null, loc.lng);
       System.assertEquals('ZERO_RESULTS', loc.status);
         
     }
   
    /*
     static testMethod void testCanCallGeocode() {
       Test.StartTest();
       Date todayDate = date.today();
    
      Boolean resultSuccess = CH_Geocode.canCallGeocode();
      Boolean resultFail = CH_Geocode.canCallGeocode();
      
      Date newDate = date.newInstance(1960, 2, 17);
      Boolean resultDateChange = CH_Geocode.canCallGeocode();
      Test.StopTest();
      
      System.assertEquals(true, resultSuccess);
       System.assertEquals(false, resultFail);
     }
     
     static testMethod void testCanExecuteBatch() {
       Test.StartTest();
       Date todayDate = date.today();
      
      Boolean resultSuccess = CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS);
      
      Boolean resultFail = CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS);
      Test.StopTest();
      
       System.assertEquals(true, resultSuccess);
       System.assertEquals(false, resultFail);
     }
     
     static testMethod void testCanExecuteBatch2() {
       Test.StartTest();
       Date newDate = date.newInstance(1960, 2, 17);
      Boolean resultDateChange = CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS);
      
      for(Integer i = 0; i < 5; i++){
        if(CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS)){
          CH_GeocodeAccountBatch geocodeBatch = new CH_GeocodeAccountBatch();
        ID batchprocessid = Database.executeBatch(geocodeBatch,1);
        }
      }
      
      Boolean resultCrossedLimit = CH_Geocode.canExecuteBatch(CH_Geocode.OBJ_CONTACTS);
      Test.StopTest();
      
       System.assertEquals(false, resultCrossedLimit);
     }
  */
}