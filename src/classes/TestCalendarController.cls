@isTest
private class TestCalendarController {
	
	static testMethod void isDefaultSettingTestHappyPath() {
		
		//Set the Custom Setting for Default
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', 'End Date', '', filterMap);
		system.assertEquals(result, true);
		
		//Check if the given query Set is Default
		Boolean isDefault = CalendarController.isDefaultSetting('campaign', 'StartDate', 'EndDate', filterMap);
		system.assertEquals(isDefault, true);
		
	}
	
	static testMethod void isDefaultSettingTestSadPath() {
		
		//Set the Custom Setting for Default
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', 'End Date', '' , filterMap);
		system.assertEquals(result, true);
		
		//Check if the given query Set is Default
		Boolean isDefault = CalendarController.isDefaultSetting('account', 'StartDate', 'EndDate', filterMap);
		system.assertEquals(isDefault, false);
		
	}
	
	static testMethod void deleteDefaultSettingTest() {
		
		//Set the Custom Setting for Default
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', 'End Date', '' , filterMap);
		system.assertEquals(result, true);
		
		//Now retrieve the Custom Setting set in the above method
		List<Calendar_Setting__c> querySet = CalendarController.getDefaultSetting();
		system.assertNotEquals(querySet, null);
		
		//Now delete the Custom Setting
		Boolean deleteResult = CalendarController.deleteDefaultSetting();
		system.assertEquals(deleteResult, true);
				
	}
	
	static testMethod void getDefaultSettingTest() {
		
		//Set the Custom Setting for Default
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', 'End Date', '' , filterMap);
		system.assertEquals(result, true);
		
		//Now retrieve the Custom Setting set in the above method
		List<Calendar_Setting__c> querySet = CalendarController.getDefaultSetting();
		system.assertNotEquals(querySet, null);
				
	}
	
	static testMethod void setDefaultSettingTest() {
		
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', 'End Date', '' , filterMap);
		
		system.assertEquals(result, true);
		
	}
	
	static testMethod void setDefaultSettingFailTest() {
		Map<String, String> filterMap = new Map<String, String>();
		Boolean result = CalendarController.setDefaultSetting( 'campaign', 'StartDate', 'EndDate', 'Campaign', 'Start Date', '', '' , filterMap);
		
		system.assertEquals(result, false);
		
	}
	
	static testMethod void buildQueryTest() {
		
		String expectedQuery = 'SELECT id, name , StartDate, EndDate FROM campaign LIMIT 1000';
		List<String> fields = new List<String>{'StartDate', 'EndDate'};
		String result = CalendarController.buildQuery('campaign', fields, '');
		system.assertEquals(result, expectedQuery);
		
		expectedQuery = 'SELECT id, name , StartDate FROM campaign LIMIT 1000';
		List<String> sameFields = new List<String>{'StartDate', 'StartDate'};
		result = CalendarController.buildQuery('campaign', sameFields, '');
		system.assertEquals(result, expectedQuery);
		
	}
	
	static testMethod void getObjectsListTest() {
		
		system.assertNotEquals(CalendarController.getObjectsList(), null);
		
	}
	
	static testMethod void getDateTimeFieldListTest() {
		
		system.assertNotEquals(CalendarController.getDateTimeFieldList('campaign'), null);
		
	}
	
	static testMethod void getAllFieldListTest() {
		
		system.assertNotEquals(CalendarController.getAllFieldList('campaign', true), null);
		
	}
	
	static testMethod void getNewActionUrlTest() {
		
		String url = CalendarController.getNewActionUrl('campaign');
		system.assertEquals(url, '/701/e?nooverride=1');
		 
	}
	
	static testMethod void getPicklistValuesAsStringTest() {
		
		String objectName = 'campaign';
		String fieldName = 'Status';
		String expectedOptionString = '</option>';
		
		String resultedOptionString = CalendarController.getPicklistValuesAsString(objectName, fieldName);
		system.assertEquals(resultedOptionString.contains(expectedOptionString), true);
		
	} 
	
	static testMethod void saveColourTest() {
		
		String color = 'blue';
		
		CalendarController.saveColour('701d0000000AYcmAAG',color);
		
		Record_Colour__c rc = [SELECT foreign_key__c, colour__c FROM Record_Colour__c WHERE Foreign_Key__c = '701d0000000AYcmAAG'];
		
		system.assertEquals(color, rc.colour__c);
		
	}
	
	static testMethod void loadColourRecordsTest() {
       	system.debug('ok this is my terrible List');
       	Date d = Date.parse('01/01/2012');
    	String n = 'TEST Campaign';
    	String colour = '';

		String sObjectName = 'campaign';
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
		SObject c = t.newSObject();
		c.put('name',n);
		c.put('startDate',d);
		c.put('endDate',d.addMonths(2));
		c.put('isActive',true);
    	insert c;

    	List<String> fields = new List<String>{'StartDate','EndDate'};
    	List<CalendarController.RecordColourWrapper> recordColorList = CalendarController.loadColourRecords('campaign', fields, '', '2011-05-01 12:00:00' , '2013-05-01 12:00:00');
    	for (CalendarController.RecordColourWrapper rcw: recordColorList) {
    		if(rcw.name == 'TEST Campaign'){
    			colour = rcw.colour;
    		}
    	}
    	system.assertEquals(colour, 'orange');
    }
    
    // Current object is hardcoded as 'Campaign'
    static testMethod void testGetFieldTypeDate(){
    	String fieldName = 'name';
    	String objectName = 'campaign';
    	String fieldTypeStr = CalendarController.getFieldType(objectName, fieldName);
    	System.assertEquals('STRING',fieldTypeStr);
    }
    
    static testMethod void testGetSObjectsAsJsonWithStringFilter(){
    	Date d = Date.parse('01/01/3000');
    	
    	String expectedJson = '[ {\n  "id" : "???",\n  "title" : "XXXZ",\n  "start" : "3000-01-01",\n  "end" : "3000-11-01",\n  "color" : "orange"\n} ]';
    	
    	String n = 'XXXZ';
    	
    	String sObjectName = 'campaign';
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
		SObject c = t.newSObject();
		c.put('name',n);
		c.put('startDate',d);
		c.put('endDate',d.addMonths(10));
		c.put('isActive',true);
    	insert c;
    	
    	expectedJson = expectedJson.replace('???',c.id);
    	
    	String[] fields = new String[]{'startdate','enddate'};
    	CalendarController.calendarData cData  = CalendarController.getMyObjectAsJson(fields, sObjectName ,' WHERE name = \'' + n + '\'');
    	String jsonString = cData.eventData;
    	
    	System.assertEquals(expectedJson, jsonString);
    }
    
    static testMethod void testGetSObjectsAsJsonWithDateFilter(){
    	String expectedJson = '[ {\n  "id" : "???",\n  "title" : "xxxz",\n  "start" : "3000-01-01",\n  "end" : "3000-11-01",\n  "color" : "orange"\n} ]';
    	    	
    	String dString = '3000-01-01';
    	Date d = Date.parse('01/01/3000');
    	
    	String sObjectName = 'campaign';
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
		SObject c = t.newSObject();
		c.put('name','xxxz');
		c.put('startDate',d);
		c.put('endDate',d.addMonths(10));
		c.put('isActive',true);
    	insert c;
    	
    	expectedJson = expectedJson.replace('???',c.id);
    	
    	String[] fields = new String[]{'startdate','enddate'};
    	CalendarController.calendarData cData = CalendarController.getMyObjectAsJson(fields, sObjectName ,' WHERE startDate = ' + dString);
    	String jsonString = cData.eventData;
    	
    	System.assertEquals(expectedJson, jsonString);
    }  
    
    static testMethod void testSaveEventsNullParms(){
    	// TODO: fix this
    	try{
    		CalendarController.SaveReport sr = CalendarController.saveEventObject(null, null, null);
    	}catch(Exception e){}
    }
    
    static testMethod void testSaveEventsValidSingleRec(){
    	String dString = '3000-01-01';
    	Date d = Date.parse('01/01/3000');
    	
    	String sObjectName = 'campaign';
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
		SObject obj = t.newSObject();
		obj.put('name','xxxz');
		obj.put('startDate',d);
		obj.put('endDate',d.addMonths(18));
		obj.put('isActive',true);
    	insert obj;
    	
    	String[] fields = new String[]{'startdate','enddate'};

    	CalendarController.calendarData cData = CalendarController.getMyObjectAsJson(fields, sObjectName ,' WHERE startDate = ' + dString);
    	String jsonString = cData.eventData;
    	String newDString = '3001-01-01';
    	jsonString = jsonString.replace(dString, newDString);
    	
    	CalendarController.SaveReport sr = CalendarController.saveEventObject(fields, sObjectName, jsonString);
    	System.assertEquals(true,sr.isSaved);
    	String dbQuery = 'SELECT startDate FROM Campaign WHERE id = \''+obj.id+'\'';
    	SObject newC = database.query(dbQuery);
    	System.assertEquals(Date.parse('01/01/3001'), newC.get('startDate'));    	
    }
    
}