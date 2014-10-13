@isTest
private class ScDemoSocialWidgetTest {

	//Constants for creating test cases.
	private static final String ReasonCode = 'Product';
	private static final String ReasonDescription = 'Sizing';
	private static final String Region = 'EMEA';
	private static final String Language = 'English';

	// this is not the exact way Radian6 would create a case,
	// but the functionality only needs cases in the system with specific parameters
	static List<sObject> createTestData()
	{
		User u = getEUser();
		insert u;
		addToQueue(u.Id);
		
		ScDemoUserSettings__c us = new ScDemoUserSettings__c();
		us.User__c = u.id;
		us.Primary_Language__c = 'English';
		us.Secondary_Languages__c = 'German;Japanese';
		us.Specialities__c = 'Social;Customer Service';
		us.Role_Requested__c = 'Consultant EU';
		us.Skills_Assigned__c = 'English Language';
		insert us;
		
		Account a = new Account(name='Example');
		insert a;
	
		return new List<Sobject>{u,a};
	}

	static void addToQueue(Id uId)
	{
		User admin = getEAdminUser();
		admin.ProfileId = [select id from Profile where Name = 'System Administrator' limit 1].id;
		insert admin;
		System.runAs(admin)
		{
			insert new GroupMember(UserorGroupId = uId, GroupId = ScDemoSocialWidgetHelper.queueId);
		}
	}

	public static String getRandomName() {
		String randomString = EncodingUtil.base64Encode(crypto.generateAesKey(128)).substring(1,10).toUpperCase();
		return randomString + '@example.com';
	}

	public static User getEUser() {
		Map<String,ID> profiles = new Map<String,String>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
    	
    	User manager = new User(Alias = 'standt', Email='example@example.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = profiles.get('Standard User'), 
			TimeZoneSidKey='Europe/London', UserName=getRandomName());
    	
    	return manager;
	}

	public static User getEAdminUser() {
		Map<String,ID> profiles = new Map<String,String>();
		List<Profile> ps = [select id, name from Profile where name = 'System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
    	
    	User admin = new User(Alias = 'admint', Email='example@example.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = profiles.get('System Administrator'), 
			TimeZoneSidKey='Europe/London', UserName=getRandomName());
    	
    	return admin;
	}

	public static Case getCase() {
		Case testCase = new Case(Reason_Code__c = ReasonCode, 
			Reason_Description__c = ReasonDescription
		);
		return testCase;
	}

	static Case createCase(Id aId)
	{
		Case c = getCase();
		c.OwnerId = ScDemoSocialWidgetHelper.queueId;
		c.AccountId = aid;
		return c;
	}
	
	/* test methods */
	
    static testMethod void testBasic()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        Case c = createCase(a.Id);
        insert c;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
        	ctrl = new ScDemoSocialWidget();
        }
        
        Test.stopTest();
        
        system.assertEquals(ctrl.socialCases.size(),1);
    }








    static testMethod void testNoShowData()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        //Case c = createCase(a.Id);
        
        // change language to something the agent doesn't know
        //c.Language__c = 'Spanish';
        //insert c;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
        	ctrl = new ScDemoSocialWidget();
        }
        
        Test.stopTest();
        
        system.assertEquals(ctrl.socialCases.size(),0);
    }
    
    static testMethod void testAssign()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        
        List<Case> cs = new List<Case>();
        for(Integer i=0; i<3; i++) 
        {
        	cs.add(createCase(a.Id));
        }
        insert cs;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
	        ctrl = new ScDemoSocialWidget();
	        ctrl.chooseCaseId = cs.get(0).id;
	        ctrl.assignCase();
        }
        
        Test.stopTest();
        
        system.assert(ctrl.chooseSuccess);
        system.assertEquals([select count() from Case where OwnerId = :u.Id],1);
        system.assertEquals(ctrl.socialCases.size(),2);
    }
    
    static testMethod void testSpam()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        
        List<Case> cs = new List<Case>();
        for(Integer i=0; i<3; i++)
        {
        	cs.add(createCase(a.Id));
        }
        insert cs;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
	        ctrl = new ScDemoSocialWidget();
	        ctrl.chooseCaseId = cs.get(0).id;
	        ctrl.spamCase();
        }
        
        Test.stopTest();
        
        system.assert(ctrl.chooseSuccess);
        system.assertEquals([select count() from Case where OwnerId = :u.Id and isClosed = true],1);
        system.assertEquals(ctrl.socialCases.size(),2);
    }
    
    static testMethod void testConflict()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        
        List<Case> cs = new List<Case>();
        for(Integer i=0; i<3; i++)
        {
        	cs.add(createCase(a.Id));
        }
        insert cs;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
	        ctrl = new ScDemoSocialWidget();
	        // take first case
	        cs.get(0).OwnerId = System.Userinfo.getUserId();
	        update cs.get(0);
	        
	        ctrl.chooseCaseId = cs.get(0).id;
	        ctrl.assignCase();
	        system.assert(!ctrl.chooseSuccess);
	        ctrl.spamCase();
	        system.assert(!ctrl.chooseSuccess);
        }
        
        Test.stopTest();
        
        system.assertEquals(ctrl.socialCases.size(),2);
    }
    
    static testMethod void testException()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        
        List<Case> cs = new List<Case>();
        for(Integer i=0; i<3; i++) 
        {
        	cs.add(createCase(a.Id));
        }
        insert cs;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
	        ctrl = new ScDemoSocialWidget();
	        // delete case to cause exception
	        String deletedId = (String) cs.get(0).id;
	        delete cs.get(0);
	        
	        ctrl.chooseCaseId = (Id) deletedId;
	        ctrl.assignCase();
	        system.assert(!ctrl.chooseSuccess);
	        ctrl.spamCase();
	        system.assert(!ctrl.chooseSuccess);
        }
        
        Test.stopTest();
        
        system.assertEquals(ctrl.socialCases.size(),2);
    }
    
    static testMethod void testOtherMethods()
    {
        List<sObject> dataObj = createTestData();
        User u = (User) dataObj.get(0);
        Account a = (Account) dataObj.get(1);
        Case c = createCase(a.Id);
        insert c;
        
        Test.startTest();
        
        ScDemoSocialWidget ctrl;
        System.runAs(u)
        {
        	ctrl = new ScDemoSocialWidget();
        	ctrl.refresh();
        	system.assertEquals(ScDemoSocialWidget.getCaseAmount(),1);
        }
        
        Test.stopTest();
    }
	
}