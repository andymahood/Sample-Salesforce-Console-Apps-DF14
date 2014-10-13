/**
 * @author Altimetrik
 * @description
 *      started at 10/23/2012
 *      Refactor at 6/28/2013
 *      Unit Tests for umCustomSettingController
 **/
@isTest
private class umCustomSettingModelTest {

    static User getStandardUser(){
        Profile  stdPRf = [select Id, Name from Profile where Name = 'Standard User'  limit 1];

        User aUser = new User(alias = 'isUnique' , email='standarduser@testorg.com',
        FirstName='thisIsUnique',  UserName= 'thisIsUnique@testorg.com', lastname='thisIsUnique',
        emailencodingkey='UTF-8', timezonesidkey='America/Los_Angeles',
        languagelocalekey='en_US', localesidkey='en_US', profileid = stdPRf.Id);
        insert aUser;

        return aUser;
    }

    static testMethod void test_postPutKnowledgeArticle(){

        map<String,Object> options = new map<String,Object>{
                'apiName__c'    => 'cam_test__kav',
                'layout__c'     => 'Title,Summary,SomethingElse',
                'umSite_id__c'  => 'dummySiteId'
        };

        //check that standard user cannot add umKALayout__c
        User aUser = getStandardUser();
        system.runAs(aUser){
            if (!umKALayout__c.sObjectType.getDescribe().isCreateable()){
                Object response = umCustomSettingController.postPutKnowledgeArticle( Json.serialize(options) );
                map<String,Object> responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_CREATEABLE.substring(0,10)));
            }
        }

        //Insert
        Object response = umCustomSettingController.postPutKnowledgeArticle( Json.serialize(options) );
        map<String,Object> responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));


        //Editing
        umKALayout__c testElement = [Select Id from umKALayout__c where apiName__c = 'cam_test__kav'];
        options.put('id',testElement.Id);
        //check that standard user cannot update umKALayout__c
        system.runAs(aUser){
            if (!umKALayout__c.sObjectType.getDescribe().isUpdateable()){
                response = umCustomSettingController.postPutKnowledgeArticle( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_UPDATEABLE.substring(0,10)));
            }
        }

        response = umCustomSettingController.postPutKnowledgeArticle( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));

        //Test Deletion
        //options.put('id',testElement.Id);
        options.put('Id',testElement.Id);

        //check that standard user cannot delete umKALayout__c
        system.runAs(aUser){
            if (!umKALayout__c.sObjectType.getDescribe().isDeletable()){
                response = umCustomSettingController.deleteKnowledgeArticle( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_DELETABLE.substring(0,10)));
            }
        }
        response = umCustomSettingController.deleteKnowledgeArticle( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
        //Try again with an already deleted object
        response = umCustomSettingController.deleteKnowledgeArticle( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
    }

    @isTest(SeeAllData=true)
    static void test_postPutSite(){
        //create
        map<String,Object> options = new map<String,Object>{
            'umChatterAnswers_dataCategoryGroup__c' => 'dataCatGroup',
            'umChatterAnswers_enabled__c'           =>  true,
            'umChatterAnswers_richTextEnabled__c'   =>  false,
            'umChatterAnswers_zoneLabelPlural__c'   =>  'Zones',
            'umChatterAnswers_zoneLabelSingular__c' =>  'Zone',
            'umContactus_addCaseNumberEnabled__c'   =>  false,
            'umContactus_businessHourName__c'       =>  'bussinesHourVal',
            'umContactus_ctiConfiguration__c'       =>  '[NumberCTI]',
            'umContactus_enableCall__c'             =>  false,
            'umContactus_createContactAndAccount__c'=>  true,
            'umContactus_enabled__c'                =>  false,
            'umContactus_liveAgentChatButtonId__c'  =>  null,
            'umContactus_liveAgentChatServerURL__c' =>  null,
            'umContactus_liveAgentDeploymentId__c'  =>  null,
            'umContactus_liveAgentDeploymentURL__c' =>  null,
            'umContactus_enableLiveAgent__c'        =>  false,
            'umContactus_phoneNumber__c'            =>  '091217506',
            'umKnowledgeBase_enabled__c'            =>  true,
            'umSite_announcementsKaId__c'           =>  'dummyKAId',
            'umSite_announcements__c'               =>  false,
            'umSite_apiName__c'                     =>  'siteDummyApiName',
            'umSite_backgroundColor__c'             =>  null,
            'umSite_backgroundImage__c'             =>  null,
            'umSite_iconImage__c'                   =>  'iconDummy.jpg',
            'umSite_searchBannerLabel__c'           =>  'dummy search label',
            'umSite_staticResource__c'              =>  'staticRDummy',
            'umSite_welcomeMessage__c'              =>  'Welcome m8',
            'umSite_guestProfileId__c'              =>  'guestProfileDummy'
        };
        //check that standard user cannot add site
        User aUser = getStandardUser();
        system.runAs(aUser){
            if (!umSite__c.sObjectType.getDescribe().isCreateable()){
                Object response = umCustomSettingController.postPutSite( Json.serialize(options) );
                map<String,Object> responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_CREATEABLE.substring(0,10)));
            }
        }

        Object response = umCustomSettingController.postPutSite( Json.serialize(options) );
        map<String,Object> responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
        String theId = String.valueOf(responseMap.get('Id'));

        //edit
        system.runAs(aUser){
            if (!umSite__c.sObjectType.getDescribe().isUpdateable()){
                options.put('id',theId);
                options.put('umSite_apiName__c','dummyTwoSite');
                response = umCustomSettingController.postPutSite( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_UPDATEABLE.substring(0,10)));
            }
        }

        umTestEnvironment.initData(); // Since we can't create a Site standard record with apex code, we need to have a umSite__c record created to then run tests for updating /creating this record.
        theId = [Select Id FROM umSite__c limit 1][0].Id;
        options.put('id',theId);
        options.put('umSite_apiName__c','dummyTwoSite updated');
        response = umCustomSettingController.postPutSite( Json.serialize(options) );

        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
        system.assertEquals(1, [Select Id FROM umSite__c].size());
        //error
        options.put('umSite_apiName__c',null);
        response = umCustomSettingController.postPutSite( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
        //delete
        options.put('id',theId);
        system.runAs(aUser){
            if (!umSite__c.sObjectType.getDescribe().isDeletable()){
                response = umCustomSettingController.deleteSite( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_DELETABLE.substring(0,10)));
            }
        }
        response = umCustomSettingController.deleteSite( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
    }

    static testMethod void test_postPutModerator(){
        //Moderators
        map<String,Object> options = new map<String,Object>{
            'umSite_id__c'  =>  'dummySiteId',
            'userId__c'     =>  '123456789012345678',
            'userInfo__c'   =>  'user@user.com'
        };

        //check that standard user cannot add site
        User aUser = getStandardUser();
        system.runAs(aUser){
            if (!umModerator__c.sObjectType.getDescribe().isCreateable()){
                Object response = umCustomSettingController.postPutModerator( Json.serialize(options) );
                map<String,Object> responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_CREATEABLE.substring(0,10)));
            }
        }

        Object response = umCustomSettingController.postPutModerator( Json.serialize(options) );
        map<String,Object> responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
        String elmId = String.valueOf(responseMap.get('id'));

        //update
        options.put('id',elmId);
        options.put('userInfo__c','changed this!');
        response = umCustomSettingController.postPutModerator( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        String a = String.valueOf(responseMap.get('Msg'));
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));

        //delete

        system.runAs(aUser){
            if (!umModerator__c.sObjectType.getDescribe().isDeletable()){
                //delete
                response = umCustomSettingController.deleteModerator( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_DELETABLE.substring(0,10)));
            }
        }
        response = umCustomSettingController.deleteModerator( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
    }


    @isTest(SeeAllData=true)
    static void testNullables(){
        umTestEnvironment.initData();
        system.assertNotEquals(null,umCustomSettingController.getAllSitesSetup());
        system.assertNotEquals(null,umCustomSettingController.getCurrentSiteSetup());
        system.assertNotEquals(null,umCustomSettingController.getOrgUsers());
    }

    @isTest(SeeAllData=true)
    static void fetchBasicStandardRecords(){
        umTestEnvironment.initData();
        system.assertNotEquals(null,umCustomSettingController.getOrgSites());
        system.assertNotEquals(null,umCustomSettingController.getOrgStaticResources());
        system.assertNotEquals(null,umCustomSettingController.getOrgZones());
        system.assertNotEquals(null,umCustomSettingController.getKAStructure());
    }

    static testMethod void test_postZone(){
            map<String,Object> options = new map<String,Object>{
                'announcements__c'      =>  false,
                'announcementsKaId__c'  =>  null,
                'backgroundColor__c'    =>  null,
                'backgroundImage__c'    =>  null,
                'dataCategory__c'       =>  'dataCatIdDummy',
                'publicName__c'         =>  'Zone Test',
                'searchBannerLabel__c'  =>  'Search banner label',
                'umSite_id__c'          =>  'siteIdDummy',
                'zone__c'               =>  'communityIdDummy'
            };

        //check that standard user cannot add zone
        User aUser = getStandardUser();
        system.runAs(aUser){
            if (!umZone__c.sObjectType.getDescribe().isCreateable()){
                Object response = umCustomSettingController.postPutZone( Json.serialize(options) );
                map<String,Object> responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_CREATEABLE.substring(0,10)));
            }
        }

        Object response = umCustomSettingController.postPutZone( Json.serialize(options) );
        map<String,Object> responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));

        String elmId = String.valueOf(responseMap.get('id'));
        options.put('id',elmId);

        response = umCustomSettingController.postPutZone( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));

        system.runAs(aUser){
            if (!umZone__c.sObjectType.getDescribe().isDeletable()){
                //delete
                response = umCustomSettingController.deleteZone( Json.serialize(options) );
                responseMap = (map<String,Object>) response;
                String msg = String.valueOf(responseMap.get('Msg'));
                system.assertEquals('Failed',String.valueOf(responseMap.get('Status')));
                system.assert(msg.contains(umSecurityHandler.ERROR_OBJECT_NOT_DELETABLE.substring(0,10)));
            }
        }
        response = umCustomSettingController.deleteZone( Json.serialize(options) );
        responseMap = (map<String,Object>) response;
        system.assertEquals('Success',String.valueOf(responseMap.get('Status')));
    }

    static testMethod void test_KADC(){
            map<String,Object> options = new map<String,Object>{
                'dataCategoryGroup__c' => 'dummydcg',
				'dataCategory__c' => 'dummydc',
				'umSite_id__c' => '1234567890',
                'publicName__c' => 'dummyPublicName'
            };
            Object response = umCustomSettingController.postPutKnowledgeBaseDataCategory( Json.serialize(options) );
            map<String,Object> responseMap = (map<String,Object>) response;
            String msg = String.valueOf(responseMap.get('Msg'));
            system.assertEquals('Success',String.valueOf(responseMap.get('Status')));

            Object r = umCustomSettingController.getKnowledgeBaseDataCategory(String.valueOf(options.get('umSite_id__c')));
            system.assertNotEquals(null,r);

            //Deleting it
            options.put('Id',String.valueOf(responseMap.get('Id')));
            r = umCustomSettingController.deleteKnowledgeBaseDataCategory(Json.serialize(options));
            system.assertNotEquals(null,r);
    }

    static testMethod void test_getTotalArticleByType(){
             String res = umCustomSettingModel.getTotalArticleByType('','','');
             system.assertEquals('0',res);
    }
}