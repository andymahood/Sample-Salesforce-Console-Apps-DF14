/**
 * @author Altimetrik
 * @description
 *      started at 7/5/2013
 *      Unit Tests for umProxy
 **/
@isTest
private class umProxyTest {

	/*******************************************************************
		PROXY Test methods
	********************************************************************/
    @isTest(SeeAllData=true)
	static  void test_getRemoteAction() {

		umProxy.Response response = null;
		String testRequestJson = '';
		umProxy.RequestItem testRequestItem = null;

		umTestEnvironment.initData();

		Test.startTest();

	//case0 : invoke with null
		response=umProxy.getRemoteAction(null);
		system.assertEquals(response.isSuccess, false);

	//case1 : invoke with empty
		response=umProxy.getRemoteAction('{}');
		system.assertEquals(response.isSuccess, false);

	//case2 : invoke with invalid json string
		response=umProxy.getRemoteAction('{NOT VALID}');
		system.assertEquals(response.isSuccess, false);


	//case3 :check no parameters
		testRequestItem = new umProxy.RequestItem();
		testRequestItem.sessionId = 'TESTSESSION';
		testRequestJson = JSON.serialize(testRequestItem);
		response=umProxy.getRemoteAction(testRequestJson);
		system.assertEquals(response.isSuccess, false);

	//case4 :check wrong parameters
		testRequestItem = new umProxy.RequestItem();
		testRequestItem.sessionId = 'TESTSESSION';
		testRequestItem.lang = 'NEVAH';
		testRequestItem.operationType = 'SO WRONG';
		testRequestJson = JSON.serialize(testRequestItem);
		response=umProxy.getRemoteAction(testRequestJson);
		system.assertEquals(response.isSuccess, false);

	//case5 :check correct parameters
		testRequestItem = new umProxy.RequestItem();
		testRequestItem.lang = KnowledgeArticleVersion.Language.getDescribe().getPickListValues().get(0).getValue();
		testRequestItem.operationType = 'getSetup';
		testRequestJson = JSON.serialize(testRequestItem);
		response=umProxy.getRemoteAction(testRequestJson);
		system.assertEquals(response.isSuccess, true);

		Test.stopTest();
	}



	    @isTest(SeeAllData=true)
	static  void test_getsiteSettings() {

		umTestEnvironment.initData();

		system.assertNotEquals(null, umProxy.siteSettings );
		system.assertNotEquals(null, umProxy.Zones );
		system.assertNotEquals(null, umProxy.DCRootGroupName);
		system.assertNotEquals(null, umProxy.CAM_ROOT_GROUP_NAME);
		system.assertNotEquals(null, umProxy.CAM_ROOT_GROUP_NAME_SIMPLE);

		//delete
		umTestEnvironment.umSite.umChatterAnswers_dataCategoryGroup__c = null;

		system.assertNotEquals(null, umProxy.DCRootGroupName);
		system.assertNotEquals(null, umProxy.CAM_ROOT_GROUP_NAME);
		system.assertNotEquals(null, umProxy.CAM_ROOT_GROUP_NAME_SIMPLE);


		umTestEnvironment.umSite.umChatterAnswers_enabled__c = false;
		system.assertEquals(1,umProxy.categoriesDepth);
		//umTestEnvironment.umSite.umChatterAnswers_enabled__c = true;
		//system.assertEquals(-1,umProxy.categoriesDepth);

	}

	static testMethod void uploadTest() {
		//Split string 'file' in to two chunks, first chunk must be divisible by 3 for base64 encode with no padding
		Blob part1 = Blob.valueOf('This text re'); //length is 12
		Blob part2 = Blob.valueOf('presents a dummy file');

		String part1base64 = EncodingUtil.base64Encode(part1);
		String part2base64 = EncodingUtil.base64Encode(part2);

		//Create a test accound the 'file' can be attached to.
		Account acct = new Account(Name = 'test');
		insert acct;

		//Start the test
		Test.startTest();
		//Send first part of the file to be uploaded
		String attachmentId = umProxy.postBlobContent((String)acct.Id,'','fileName','text',part1base64);

		//Send the second piece of the file to be uploaded
		umProxy.postBlobContent(acct.Id,attachmentId,'fileName','text',part2base64);
		Test.stopTest();

		//Assert one file has been attached to the test account
		List<Attachment> attachments = [select Id, Body from Attachment where ParentId = :acct.Id];
		system.assert(attachments.size() == 1);

		//Assert the contents of the split file were recontructed correctly
		system.assert(attachments[0].Body.toString() == 'This text represents a dummy file');


		//global static Object getAttachment(id atachmentParentId){
		Object testDownload = umProxy.getAttachment(attachmentId);
		system.assert(testDownload != null);

	}


}