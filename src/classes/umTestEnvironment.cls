/**
 * @author Altimetrik
 * @description
 *		started at 08/24/2012
 *		refactor at 07/01/2013
 *		static methods to be used by each unit test class
 **/
public with sharing class umTestEnvironment {

	public static Community vcommunity {get;set;}
	public static String topic{get;set;}
	public static umKALayout__c camKAone {get;set;}
	public static umSite__c umSite {get;set;}
	public static umZone__c umZoneone {get;set;}
	public static umZone__c umZonetwo {get;set;}
	public static umModerator__c umModeratorone {get;set;}
	public static String siteName = 'UM' + String.valueOf(Crypto.getRandomInteger());


	public static void initData(){
		map<String,umKALayout__c> kMap = umKALayout__c.getAll(); delete kMap.values();
		map<String,umSite__c> sMap = umSite__c.getAll(); delete sMap.values();
		map<String,umZone__c> cMap = umZone__c.getAll(); delete cMap.values();
		map<String,umModerator__c> mMap = umModerator__c.getAll(); delete mMap.values();

		Question q; QuestionDataCategorySelection qDC; Profile profileToUse;

		try{
			//As our app needs this three items in order to run test methods, we will add a more "user friendly" exception if we can't reach this objects
			q = [Select Id, CommunityId from Question where Origin = 'Chatter Answers' limit 1];
			qDC = [Select DataCategoryName,DataCategoryGroupName from QuestionDataCategorySelection where ParentId = :q.Id];
			profileToUse = [Select Id,Name from Profile where Id != :Userinfo.getProfileId() limit 1];
		}
		catch(Exception e){
			throw new umTestException('Service Cloud Mobile App  Test Methods: In order to run the App test methods you must have Chatter Answers properly set up and at least one public Question in the Database');
		}
		vcommunity = [Select Id,Name from Community where Id = :q.CommunityId];
		topic = qDC.DataCategoryName;

		if ( umSite == null  ){
			umSite = new umSite__c(
				Name 									= String.valueOf( (Datetime.now()).getTime() ) ,
				umChatterAnswers_dataCategoryGroup__c	= 'dataCatGroup',
				umChatterAnswers_enabled__c				=	true,
				umChatterAnswers_richTextEnabled__c		=	false,
				umChatterAnswers_zoneLabelPlural__c		=	'Zones',
				umChatterAnswers_zoneLabelSingular__c	=	'Zone',
				umContactus_addCaseNumberEnabled__c		=	false,
				umContactus_businessHourName__c			=	'bussinesHourVal',
				umContactus_ctiConfiguration__c			=	'[NumberCTI]',
				umContactus_enableCall__c				=	false,
				umContactus_createContactAndAccount__c	=	true,
				umContactus_enabled__c					=	false,
				umContactus_liveAgentChatButtonId__c	=	null,
				umContactus_liveAgentChatServerURL__c	=	null,
				umContactus_liveAgentDeploymentId__c	=	null,
				umContactus_liveAgentDeploymentURL__c	=	null,
				umContactus_enableLiveAgent__c			=	false,
				umContactus_phoneNumber__c				=	'091217506',
				umKnowledgeBase_enabled__c				=	true,
				umSite_casesEnabled__c					=   true,
				umSite_announcementsKaId__c				=	'dummyKAId',
				umSite_announcements__c					=	false,
				umSite_apiName__c						=	siteName,
				umSite_backgroundColor__c				=	null,
				umSite_backgroundImage__c				=	null,
				umSite_iconImage__c						=	'iconDummy.jpg',
				umSite_searchBannerLabel__c				=	'dummy search label',
				umSite_staticResource__c				=	'staticRDummy',
				umSite_welcomeMessage__c				=	'Welcome m8',
				umSite_guestProfileId__c				=	'guestProfileDummy'
			);
			insert umSite;
		}

		if ( umModeratorone == null ){
			umModeratorone = new umModerator__c(
				Name		= String.valueOf( (Datetime.now()).getTime() ),
				userId__c 	= Userinfo.getUserId(),
				userInfo__c	= Userinfo.getUserName(),
				umSite_id__c= umSite.Id );
			insert umModeratorone;
		}




		if ( camKAone == null ){
			camKAone = new umKALayout__c(
				Name 		= String.valueOf( (Datetime.now()).getTime() ) ,
				apiName__c 	= 'FAQ__kav',
				layout__c	= 'Title,Summary,ArticleNumber',
				umSite_id__c= umSite.Id);
			insert camKAone;
		}

		if ( umZoneone == null ){
			umZoneone = new umZone__c(
				Name 					= 	String.valueOf( (Datetime.now()).getTime() ) ,
				announcements__c		=	false,
				announcementsKaId__c	=	null,
				backgroundColor__c		=	null,
				backgroundImage__c		=	null,
				dataCategory__c			=	qDC.DataCategoryName,
				publicName__c			=	'Zone Test',
				searchBannerLabel__c	=	'Search banner label',
				umSite_id__c			=	umSite.Id,
				zone__c					=	q.CommunityId
			);
			insert umZoneone;
		}
	}

	public class umTestException extends Exception{

	}


	public static void initDataWithoutQAandKB(){
		map<String,umKALayout__c> kMap = umKALayout__c.getAll(); delete kMap.values();
		map<String,umSite__c> sMap = umSite__c.getAll(); delete sMap.values();
		map<String,umZone__c> cMap = umZone__c.getAll(); delete cMap.values();
		map<String,umModerator__c> mMap = umModerator__c.getAll(); delete mMap.values();

		if ( umSite == null  ){
			umSite = new umSite__c(
				Name 									= String.valueOf( (Datetime.now()).getTime() ) ,
				umChatterAnswers_dataCategoryGroup__c	= 'dataCatGroup',
				umChatterAnswers_enabled__c				=	false,
				umChatterAnswers_richTextEnabled__c		=	false,
				umChatterAnswers_zoneLabelPlural__c		=	'Zones',
				umChatterAnswers_zoneLabelSingular__c	=	'Zone',
				umContactus_addCaseNumberEnabled__c		=	false,
				umContactus_businessHourName__c			=	'bussinesHourVal',
				umContactus_ctiConfiguration__c			=	'[NumberCTI]',
				umContactus_enableCall__c				=	true,
				umContactus_createContactAndAccount__c	=	true,
				umContactus_enabled__c					=	true,
				umSite_casesEnabled__c					=   true,
				umContactus_liveAgentChatButtonId__c	=	null,
				umContactus_liveAgentChatServerURL__c	=	null,
				umContactus_liveAgentDeploymentId__c	=	null,
				umContactus_liveAgentDeploymentURL__c	=	null,
				umContactus_enableLiveAgent__c			=	false,
				umContactus_phoneNumber__c				=	'091217506',
				umKnowledgeBase_enabled__c				=	false,
				umSite_announcementsKaId__c				=	'dummyKAId',
				umSite_announcements__c					=	false,
				umSite_apiName__c						=	siteName,
				umSite_backgroundColor__c				=	null,
				umSite_backgroundImage__c				=	null,
				umSite_iconImage__c						=	'iconDummy.jpg',
				umSite_searchBannerLabel__c				=	'dummy search label',
				umSite_staticResource__c				=	'staticRDummy',
				umSite_welcomeMessage__c				=	'Welcome m8',
				umSite_guestProfileId__c				=	'guestProfileDummy'
			);
			insert umSite;
		}

	}


    public static  Map<String, Object> objectToMap(Object source){

        String resString = JSON.serialize(source);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);

        return results;
    }


    public static  list<Object> objectToList(Object source){

        String resString = JSON.serialize(source);
        list<Object> results = (list<Object>) JSON.deserializeUntyped(resString);

        return results;
    }

    public static String getTestBusinessHourName(){
        BusinessHours bH = [Select Id,Name from BusinessHours where IsDefault = true limit 1];
        return bH.Name;
    }


}