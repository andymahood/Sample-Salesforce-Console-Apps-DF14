/**
 * @author Altimetrik
 * @description
 *		originally started at 10/18/2012
 *		new version started at 6/26/2013
 *		Custom Settings Model Class
 **/
public with sharing class umCustomSettingModel {
	 private static final String CRITICAL_ERROR = 'Critical error found in custom settings.';
	 private static Boolean getOnlyCurrentSite = false;

	/*
	 * @description
	 *		get All Sites Setup
	 * @return Object / Map<String,Object>
	 */
	public static Object getAllSitesSetup(){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();

		map<String,umSite__c> umSitesMap = null;
		list<umSite__c> umSites = new list<umSite__c>();
		list<map<String,Object>> listOfSites = new list<map<String,Object>>();

		if ( getOnlyCurrentSite && Site.getName() != null){
			 umSites = [Select Id,umChatterAnswers_dataCategoryGroup__c,umChatterAnswers_enabled__c,
			 			umChatterAnswers_richTextEnabled__c,umChatterAnswers_zoneLabelPlural__c,
			 			umChatterAnswers_zoneLabelSingular__c,umContactus_addCaseNumberEnabled__c,
			 			umContactus_businessHourName__c,umContactus_ctiConfiguration__c,umContactus_enableCall__c,
			 			umContactus_createContactAndAccount__c,umContactus_enabled__c,umContactus_liveAgentChatButtonId__c,
			 			umContactus_liveAgentChatServerURL__c,umContactus_liveAgentDeploymentId__c,
			 			umContactus_liveAgentDeploymentURL__c,umContactus_enableLiveAgent__c,
			 			umContactus_phoneNumber__c,umKnowledgeBase_enabled__c,umSite_announcementsKaId__c,
			 			umSite_announcements__c,umSite_apiName__c,umSite_backgroundColor__c,umSite_backgroundImage__c,
			 			umSite_iconImage__c,umSite_searchBannerLabel__c,umSite_staticResource__c,umSite_welcomeMessage__c,
			 			umSite_casesEnabled__c,umSite_guestProfileId__c,umSite_authenticated__c,signUpProfile__c
							FROM umSite__c
							WHERE umSite_apiName__c = :Site.getName()];
		}else{
			 umSitesMap = umSite__c.getAll();
			 umSites = umSitesMap.values();
		}
		for ( umSite__c element : umSites ){
			 map<String,Object> s = new map<String,Object>{
			 	'id'									=>	element.id,
			 	'umChatterAnswers_dataCategoryGroup__c'	=>	element.umChatterAnswers_dataCategoryGroup__c == null ? '' : element.umChatterAnswers_dataCategoryGroup__c,
				'umChatterAnswers_enabled__c'			=>	element.umChatterAnswers_enabled__c,
				'umChatterAnswers_richTextEnabled__c'	=>	element.umChatterAnswers_richTextEnabled__c,
				'umChatterAnswers_zoneLabelPlural__c'	=>	element.umChatterAnswers_zoneLabelPlural__c == null ? '' : element.umChatterAnswers_zoneLabelPlural__c,
				'umChatterAnswers_zoneLabelSingular__c'	=>	element.umChatterAnswers_zoneLabelSingular__c == null ? '' : element.umChatterAnswers_zoneLabelSingular__c,
				'umContactus_addCaseNumberEnabled__c'	=>	element.umContactus_addCaseNumberEnabled__c,
				'umContactus_businessHourName__c'		=>	element.umContactus_businessHourName__c == null ? '' : element.umContactus_businessHourName__c,
				'umContactus_ctiConfiguration__c'		=>	element.umContactus_ctiConfiguration__c == null ? '' : element.umContactus_ctiConfiguration__c,
				'umContactus_enableCall__c'				=>	element.umContactus_enableCall__c,
				'umContactus_createContactAndAccount__c'=>	element.umContactus_createContactAndAccount__c,
				'umContactus_enabled__c'				=>	element.umContactus_enabled__c,
				'umContactus_liveAgentChatButtonId__c'	=>	element.umContactus_liveAgentChatButtonId__c == null ? '' : element.umContactus_liveAgentChatButtonId__c,
				'umContactus_liveAgentChatServerURL__c'	=>	element.umContactus_liveAgentChatServerURL__c == null ? '' : element.umContactus_liveAgentChatServerURL__c,
				'umContactus_liveAgentDeploymentId__c'	=>	element.umContactus_liveAgentDeploymentId__c == null ? '' : element.umContactus_liveAgentDeploymentId__c,
				'umContactus_liveAgentDeploymentURL__c'	=>	element.umContactus_liveAgentDeploymentURL__c == null ? '' : element.umContactus_liveAgentDeploymentURL__c,
				'umContactus_enableLiveAgent__c'		=>	element.umContactus_enableLiveAgent__c,
				'umContactus_phoneNumber__c'			=>	element.umContactus_phoneNumber__c == null ? '' : element.umContactus_phoneNumber__c,
				'umKnowledgeBase_enabled__c'			=>	element.umKnowledgeBase_enabled__c,
				'umSite_announcementsKaId__c'			=>	element.umSite_announcementsKaId__c == null ? '' : element.umSite_announcementsKaId__c,
				'umSite_announcements__c'				=>	element.umSite_announcements__c,
				'umSite_apiName__c'						=>	element.umSite_apiName__c == null ? '' : element.umSite_apiName__c,
				'umSite_backgroundColor__c'				=>	element.umSite_backgroundColor__c == null ? '' : element.umSite_backgroundColor__c,
				'umSite_backgroundImage__c'				=>	element.umSite_backgroundImage__c == null ? '' : element.umSite_backgroundImage__c,
				'umSite_iconImage__c'					=>	element.umSite_iconImage__c == null ? '' : element.umSite_iconImage__c,
				'umSite_searchBannerLabel__c'			=>	element.umSite_searchBannerLabel__c == null ? '' : element.umSite_searchBannerLabel__c,
				'umSite_staticResource__c'				=>	element.umSite_staticResource__c == null ? '' : element.umSite_staticResource__c,
				'umSite_welcomeMessage__c'				=>	element.umSite_welcomeMessage__c == null ? '' : element.umSite_welcomeMessage__c,
				'umSite_guestProfileId__c'				=>	element.umSite_guestProfileId__c == null ? '' : element.umSite_guestProfileId__c,
				'umSite_casesEnabled__c'				=>	element.umSite_casesEnabled__c,
				'umSite_authenticated__c'				=>	element.umSite_authenticated__c == null ? false : element.umSite_authenticated__c,
				'umSite_guestProfileId__c'				=>	element.umSite_guestProfileId__c == null ? '' : element.umSite_guestProfileId__c,
				'signUpProfile__c'						=>	element.signUpProfile__c == null ? '' : element.signUpProfile__c};
				s.put('KAStructure',getKnowledgeArticlesSetup(element.Id));
				s.put('Moderators',getModerators(element.Id));
				s.put('KnowledgeBase',getKnowledgeBaseDataCategory(element.Id));
				//if ( element.umChatterAnswers_enabled__c == true )
				s.put('Zones',getZones(element));//.Id,element.umChatterAnswers_dataCategoryGroup__c
				listOfSites.add(s);
		}
		ret.put('Sites',listOfSites);
		ret.put('Msg','Success');
		ret.put('Status','Success');
		return ret;
	}

	/*
	 * @description
	 *		get Zones of a given Site Name
	 * @param siteName @type String
	 * @return Object / Map<String,Object>
	 */
	private static Object getZones(umSite__c siteObj){

		String umSite_id = siteObj.Id;
		String CA_Data_Category = siteObj.umChatterAnswers_dataCategoryGroup__c;

		list<Id> zonesIds = new list<Id>();
		list<Object> ret = new list<Object>();
		list<String> availableArticles = new list<String>();
		list<umZone__c> zones = [Select Id,announcements__c,announcementsKaId__c,
									backgroundColor__c,backgroundImage__c,dataCategory__c,
									publicName__c,searchBannerLabel__c,umSite_id__c,zone__c,iconImage__c
									FROM umZone__c
									WHERE umSite_id__c = :umSite_id ];/* limit 1 */
		if ( zones.size() > 0 ){
				String articleTypeString = umSecurityHandler.getAllowedKav();
				Map<Id,String> qPerCommunity =  getTotalQuestionsPerCommunity();

				for ( umZone__c element : zones ){
					zonesIds.add( element.zone__c );
				}
				Map<Id,Community> cMap = new Map<Id,Community>([Select Id,Description from Community where Id IN :zonesIds]);
				for ( umZone__c element : zones ){

					map<String,Object> c = new map<String,Object>{
						'id'					=>	element.id,
						'announcements__c'		=>	element.announcements__c,
						'announcementsKaId__c'	=>	element.announcementsKaId__c == null ? '' : element.announcementsKaId__c,
						'backgroundColor__c'	=>	element.backgroundColor__c == null ? '' : element.backgroundColor__c,
						'backgroundImage__c'	=>	element.backgroundImage__c == null ? '' : element.backgroundImage__c,
						'dataCategory__c'		=>	element.dataCategory__c == null ? '' : element.dataCategory__c,
						'publicName__c'			=>	element.publicName__c == null ? '' : element.publicName__c,
						'searchBannerLabel__c'	=>	element.searchBannerLabel__c == null ? '' : element.searchBannerLabel__c,
						'umSite_id__c'			=>	element.umSite_id__c,
						'zone__c'				=>	element.zone__c == null ? '' : element.zone__c,
						'zoneDescription__c'	=>	(cMap.get(element.zone__c)).Description == null ? '' : (cMap.get(element.zone__c)).Description,
						'iconImage__c'			=>	element.iconImage__c == null ? '' : element.iconImage__c,
						'totalQuestions'		=>	(qPerCommunity.containsKey(element.zone__c)) ? qPerCommunity.get(element.zone__c) : '0'
					 };


					if (zones.size()==1){
						c.put('announcements__c',siteObj.umSite_announcementsKaId__c == null ? '' : siteObj.umSite_announcementsKaId__c);
						c.put('announcementsKaId__c', siteObj.umSite_announcementsKaId__c == null ? '' : siteObj.umSite_announcementsKaId__c);
						c.put('backgroundColor__c', siteObj.umSite_backgroundColor__c == null ? '' : siteObj.umSite_backgroundColor__c);
						c.put('backgroundImage__c',siteObj.umSite_backgroundImage__c == null ? '' : siteObj.umSite_backgroundImage__c );
						c.put('searchBannerLabel__c', siteObj.umSite_searchBannerLabel__c == null ? '' : siteObj.umSite_searchBannerLabel__c);
						c.put('iconImage__c', siteObj.umSite_iconImage__c == null ? '' : siteObj.umSite_iconImage__c);

					}
					 if (!test.isRunningTest()){
					 	try{
					 		c.put('totalArticles',getTotalArticleByType( articleTypeString, CA_Data_Category ,element.dataCategory__c));
					 	}catch(Exception e){
					 		c.put('totalArticles',0);
					 	}
					 }else{
					 	c.put('totalArticles',0);
					 }
					 ret.add(c);
				}
		}else{
				return 'No active zones.';
		}
		return ret;
	}

	public static String  getTotalArticleByType(String articleTypeString,String CA_Data_Category,String dCategory){
		String result = '0';
		if (umProxy.ACCESS_KNOWLEDGE){
			if (String.isNotBlank(CA_Data_Category)){
		 		dCategory = (dCategory.endsWith('__c')) ? dCategory : dCategory+'__c';
				CA_Data_Category = (CA_Data_Category.endsWith('__c')) ? CA_Data_Category : CA_Data_Category+'__c';

				String qStr = 	' SELECT ArticleType, count(Id) cant '+
								' FROM KnowledgeArticleVersion ' +
								' WHERE' +
								' ArticleType in ('+articleTypeString+') AND PublishStatus = \'online\' AND Language = \'en_US\' ' +
								' WITH DATA CATEGORY '+CA_Data_Category+' BELOW '+dCategory+' group by ArticleType ';
				AggregateResult[] totals = Database.query(qStr);
				Integer total = 0;
				for ( AggregateResult elm : totals ){
						total = total + Integer.valueof(elm.get('cant'));
				}
				result = String.valueOf(total);
		 	}
		}

		return result;
	 }


	public static Map<Id,String>  getTotalQuestionsPerCommunity(){
	 	Map<Id,String> result = new Map<Id,String>();
		String qStr = 'SELECT CommunityId, count(id) cant FROM Question group by CommunityId';
		AggregateResult[] totals = Database.query(qStr);
		Integer total = 0;
		for ( AggregateResult elm : totals ){
			result.put(String.valueOf(elm.get('CommunityId')),String.valueof(elm.get('cant')));
		}
		return result;
	}

	/*
	 * @description
	 *		get Moderators Information
	 * @return Object / Map<String,Object>
	 */
	 private static Object getModerators(String siteId){
		list<Object> ret = new list<Object>();
		list<umModerator__c> moderators = [ Select Id, umSite_id__c, userId__c, userInfo__c
											FROM umModerator__c
											WHERE umSite_id__c = :siteId
											limit: umController.MAX_SOQL_RESULTS];
		if ( moderators.size() > 0 ){
				for ( umModerator__c element : moderators ){
					 map<String,Object> c = new map<String,Object>{
						'Id'			=>	element.Id,
						'userId__c'		=>	element.userId__c,
						'userInfo__c'	=>	element.userInfo__c,
						'umSite_id__c'	=>	element.umSite_id__c
					 };
					 ret.add(c);
				}
		}else{
				return 'No Moderators assigned.';
		}
		return ret;
	 }


/*
	 * @description
	 *		get set of Moderators Id
	 * @return set<Id>
	 */
	 public static map<Id, String> getSiteModeratorsId(String siteId){
		map<Id, String> ret = new map<Id, String>();
		list<umModerator__c> moderators = [ Select Id, umSite_id__c, userId__c, userInfo__c
											FROM umModerator__c
											WHERE umSite_id__c = :siteId
											limit: umController.MAX_SOQL_RESULTS];
		if ( moderators.size() > 0 ){
				for ( umModerator__c element : moderators ){
					ret.put(element.userId__c, element.userInfo__c);
				}
		}
		return ret;
	 }
	/*
	 * @description
	 *		get KnowledgeArticles List from custom settings of a given site
	 * @return Object / Map<String,Object>
	 */
	 private static Object getKnowledgeArticlesSetup(String umSiteId){
		list<Object> ret = new list<Object>();
		list<umKALayout__c> umKASetup = [ Select Id, apiName__c, layout__c, umSite_id__c
											FROM umKALayout__c
											WHERE umSite_id__c = :umSiteId
											limit: umController.MAX_SOQL_RESULTS];
		if ( umkASetup.size() > 0 ){
				for ( umKALayout__c element : umKASetup ){
					 map<String,Object> k = new map<String,Object>{
					 	'Id'				=> element.Id,
						'apiName__c'		=> element.apiName__c,
						'layout__c'			=> element.layout__c,
						'umSite_id__c'	=> element.umSite_id__c
					 };
					 ret.add(k);
				}
				return ret;
		}else{
				return 'No KA created.';
		}
	 }

	/*
	 * @description
	 *		get Current Site Setup
	 * @return Object / Map<String,Object>
	 */
	 public static Object getCurrentSiteSetup(){
		if (!test.isRunningTest()) getOnlyCurrentSite = true;
		Object ret = getAllSitesSetup();
		getOnlyCurrentSite = false;
		return ret;
	 }

	 /**
	 * @description
	 *		Creates / Update a Site
	 * @param siteInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 **/
	 public static Object postPutModerator( String moderatorInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(moderatorInfoStr);
		umModerator__c element = null;

		if ( opts.get('userId__c') != null && opts.get('umSite_id__c') != null){
				try{
					//check create permissions
					umSecurityHandler.canCreate(new Schema.SObjectType[] {umModerator__c.sObjectType});
					if ( opts.get('Id') == null || (String.valueOf(opts.get('Id'))).length() < 18){
						 element = new umModerator__c(Name = String.valueOf((Datetime.now()).getTime()),
						 								umSite_id__c = String.valueOf(opts.get('umSite_id__c')),
						 								userId__c = String.valueOf(opts.get('userId__c')),
														userInfo__c	 = String.valueOf(opts.get('userInfo__c')) );
						insert element;
						ret.put('id',element.Id);
					 }else{
					//check update permissions
						umSecurityHandler.canUpdate(new Schema.SObjectType[] {umModerator__c.sObjectType});

						element = [Select Name,Id,userId__c, umSite_id__c,userInfo__c from umModerator__c where id = :String.valueOf(opts.get('Id'))];
						element.userId__c = String.valueOf(opts.get('userId__c'));
						element.userInfo__c = String.valueOf(opts.geT('userInfo__c'));
						element.umSite_id__c = String.valueof(opts.get('umSite_id__c'));
						upsert element;
					 }
					 ret.put('Status','Success');
				}catch(umSecurityHandler.SecurityException sEx){
					 ret.put('Msg','Internal error, received: '+sEx.getMessage() );
					 ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',moderatorInfoStr);
		}
		return ret;
	 }

	 /**
	 * @description
	 *		Deletes a moderator
	 * @param siteInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 **/
	 public static Object deleteModerator( String moderatorInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(moderatorInfoStr);
		umModerator__c element = null;
		if ( opts.get('userId__c') != null && opts.get('umSite_id__c') != null){
				try{
					 //check delete permissions
				umSecurityHandler.canDelete(new Schema.SObjectType[] {umModerator__c.sObjectType});
					element = [Select Id
								from umModerator__c
								where userId__c = :String.valueOf(opts.get('userId__c'))
								and umSite_id__c = :String.valueOf(opts.get('umSite_id__c'))
								limit 1];
					 delete element;
					 ret.put('Status','Success');
				}catch(umSecurityHandler.SecurityException sEx){
					 ret.put('Msg','Internal error, received: '+sEx.getMessage() );
					 ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',moderatorInfoStr);
		}
		return ret;
	 }

	/*
	 * @description
	 *		Creates / Update a Site
	 * @param siteInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object postPutSite( String siteInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(siteInfoStr);
		umSite__c element = null;

		if ( opts.get('umSite_apiName__c') != null && opts.get('umSite_welcomeMessage__c') != null &&
				opts.get('umSite_staticResource__c') != null && opts.get('umSite_searchBannerLabel__c') != null &&
				opts.get('umSite_iconImage__c') != null ){
			try{
				//check create permissions
				umSecurityHandler.canCreate(new Schema.SObjectType[] {umSite__c.sObjectType});
				Site objSite = null; String strGuestProfileSiteName = null; Profile objGuestProfile = null;
				if (opts.get('id') == null || (String.valueOf(opts.get('id'))).length() < 18){
					if ( !Test.isRunningTest() ){
						objSite = [SELECT Id, MasterLabel From Site WHERE Name =:String.valueOf(opts.get('umSite_apiName__c')) limit 1][0];
						strGuestProfileSiteName = objSite.MasterLabel + ' Profile';
						objGuestProfile = [SELECT Id, Name FROM Profile WHERE Name =: strGuestProfileSiteName limit 1][0];
					}else{
						strGuestProfileSiteName = 'testProfile';
						objGuestProfile = [SELECT Id, Name FROM Profile limit 1][0];
					}
					 	element = new umSite__c();
					 	element.Name = String.valueOf((Datetime.now()).getTime());
					 	element.umChatterAnswers_dataCategoryGroup__c = opts.get('umChatterAnswers_dataCategoryGroup__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_dataCategoryGroup__c')) : element.umChatterAnswers_dataCategoryGroup__c;
					 	element.umChatterAnswers_enabled__c =  opts.get('umChatterAnswers_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umChatterAnswers_enabled__c')) : element.umChatterAnswers_enabled__c;
					 	element.umChatterAnswers_richTextEnabled__c = opts.get('umChatterAnswers_richTextEnabled__c') != null ?
					 		Boolean.valueOf(opts.get('umChatterAnswers_richTextEnabled__c')) : element.umChatterAnswers_richTextEnabled__c;
					 	element.umChatterAnswers_zoneLabelPlural__c = opts.get('umChatterAnswers_zoneLabelPlural__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_zoneLabelPlural__c')) : element.umChatterAnswers_zoneLabelPlural__c;
					 	element.umChatterAnswers_zoneLabelSingular__c = opts.get('umChatterAnswers_zoneLabelSingular__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_zoneLabelSingular__c')) : element.umChatterAnswers_zoneLabelSingular__c;
					 	element.umContactus_addCaseNumberEnabled__c = opts.get('umContactus_addCaseNumberEnabled__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_addCaseNumberEnabled__c')) : element.umContactus_addCaseNumberEnabled__c;
					 	element.umContactus_businessHourName__c = opts.get('umContactus_businessHourName__c') != null ?
					 		String.valueOf(opts.get('umContactus_businessHourName__c')) : element.umContactus_businessHourName__c;
					 	element.umContactus_ctiConfiguration__c = opts.get('umContactus_ctiConfiguration__c') != null ?
					 		String.valueOf(opts.get('umContactus_ctiConfiguration__c')) : element.umContactus_ctiConfiguration__c;
					 	element.umContactus_enableCall__c = opts.get('umContactus_enableCall__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enableCall__c')) : element.umContactus_enableCall__c;
					 	element.umContactus_createContactAndAccount__c = opts.get('umContactus_createContactAndAccount__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_createContactAndAccount__c')) : element.umContactus_createContactAndAccount__c;
					 	element.umContactus_enabled__c = opts.get('umContactus_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enabled__c')) : element.umContactus_enabled__c;
					 	element.umContactus_liveAgentChatButtonId__c = opts.get('umContactus_liveAgentChatButtonId__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentChatButtonId__c')) : element.umContactus_liveAgentChatButtonId__c;
					 	element.umContactus_liveAgentChatServerURL__c = opts.get('umContactus_liveAgentChatServerURL__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentChatServerURL__c')) : element.umContactus_liveAgentChatServerURL__c;
					 	element.umContactus_liveAgentDeploymentId__c = opts.get('umContactus_liveAgentDeploymentId__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentDeploymentId__c')) : element.umContactus_liveAgentDeploymentId__c;
					 	element.umContactus_liveAgentDeploymentURL__c = opts.get('umContactus_liveAgentDeploymentURL__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentDeploymentURL__c')) : element.umContactus_liveAgentDeploymentURL__c;
					 	element.umContactus_enableLiveAgent__c = opts.get('umContactus_enableLiveAgent__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enableLiveAgent__c')) : element.umContactus_enableLiveAgent__c;
					 	element.umContactus_phoneNumber__c = opts.get('umContactus_phoneNumber__c') != null ?
					 		String.valueOf(opts.get('umContactus_phoneNumber__c')) : element.umContactus_phoneNumber__c;
					 	element.umKnowledgeBase_enabled__c = opts.get('umKnowledgeBase_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umKnowledgeBase_enabled__c')) : element.umKnowledgeBase_enabled__c;
					 	element.umSite_announcementsKaId__c = opts.get('umSite_announcementsKaId__c') != null ?
					 		String.valueOf(opts.get('umSite_announcementsKaId__c')) : element.umSite_announcementsKaId__c;
					 	element.umSite_announcements__c = opts.get('umSite_announcements__c') != null ?
					 		Boolean.valueOf(opts.get('umSite_announcements__c')) : element.umSite_announcements__c;
					 	element.umSite_apiName__c = String.valueOf(opts.get('umSite_apiName__c'));
					 	element.umSite_backgroundColor__c = opts.get('umSite_backgroundColor__c') != null ?
					 		String.valueOf(opts.get('umSite_backgroundColor__c')) : element.umSite_backgroundColor__c;
					 	element.umSite_backgroundImage__c = opts.get('umSite_backgroundImage__c') != null ?
					 		String.valueOf(opts.get('umSite_backgroundImage__c')) : element.umSite_backgroundImage__c;
					 	element.umSite_iconImage__c = String.valueOf(opts.get('umSite_iconImage__c'));
					 	element.umSite_searchBannerLabel__c = String.valueOf(opts.get('umSite_searchBannerLabel__c'));
					 	element.umSite_staticResource__c = String.valueOf(opts.get('umSite_staticResource__c'));
					 	element.umSite_welcomeMessage__c = String.valueOf(opts.get('umSite_welcomeMessage__c'));
					 	element.umSite_guestProfileId__c = objGuestProfile != null ? objGuestProfile.Id : String.valueOf(opts.get('umSite_guestProfileId__c'));
					 	element.umSite_casesEnabled__c = opts.get('umSite_casesEnabled__c') != null ?
					 		Boolean.valueOf(opts.get('umSite_casesEnabled__c')) : element.umSite_casesEnabled__c;
					 	element.umSite_authenticated__c = opts.get('umSite_authenticated__c') != null ?
					 		Boolean.valueOf(opts.get('umSite_authenticated__c')) : element.umSite_authenticated__c;
					 	element.signUpProfile__c = opts.get('signUpProfile__c') != null ?
					 		String.valueOf(opts.get('signUpProfile__c')) : element.signUpProfile__c;
					insert element;
				}else{
					//check update permissions
					umSecurityHandler.canUpdate(new Schema.SObjectType[] {umSite__c.sObjectType});

					element = [Select Id,umChatterAnswers_dataCategoryGroup__c,umChatterAnswers_enabled__c,umChatterAnswers_richTextEnabled__c,
								umChatterAnswers_zoneLabelPlural__c,umChatterAnswers_zoneLabelSingular__c,umContactus_addCaseNumberEnabled__c,
								umContactus_businessHourName__c,umContactus_ctiConfiguration__c,umContactus_enableCall__c,
								umContactus_createContactAndAccount__c,umContactus_enabled__c,umContactus_liveAgentChatButtonId__c,
								umContactus_liveAgentChatServerURL__c,umContactus_liveAgentDeploymentId__c,umContactus_liveAgentDeploymentURL__c,
								umContactus_enableLiveAgent__c,umContactus_phoneNumber__c,umKnowledgeBase_enabled__c,umSite_announcementsKaId__c,
								umSite_announcements__c,umSite_apiName__c,umSite_backgroundColor__c,umSite_backgroundImage__c,umSite_iconImage__c,
								umSite_searchBannerLabel__c,umSite_staticResource__c,umSite_welcomeMessage__c,umSite_guestProfileId__c,
								umSite_casesEnabled__c,signUpProfile__c,umSite_authenticated__c
								FROM umSite__c
								WHERE Id = :String.valueOf(opts.get('id'))];

					if ( !Test.isRunningTest() ){
						objSite = [SELECT Id, MasterLabel From Site WHERE Name =:String.valueOf(opts.get('umSite_apiName__c')) limit 1][0];
						strGuestProfileSiteName = objSite.MasterLabel + ' Profile';
						objGuestProfile = [SELECT Id, Name FROM Profile WHERE Name =: strGuestProfileSiteName limit 1][0];
					}else{
						strGuestProfileSiteName = 'testProfile';
						objGuestProfile = [SELECT Id, Name FROM Profile limit 1][0];
					}

					element.umChatterAnswers_dataCategoryGroup__c = opts.get('umChatterAnswers_dataCategoryGroup__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_dataCategoryGroup__c')) : element.umChatterAnswers_dataCategoryGroup__c;
					element.umChatterAnswers_enabled__c =  opts.get('umChatterAnswers_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umChatterAnswers_enabled__c')) : element.umChatterAnswers_enabled__c;
					element.umChatterAnswers_richTextEnabled__c = opts.get('umChatterAnswers_richTextEnabled__c') != null ?
					 		Boolean.valueOf(opts.get('umChatterAnswers_richTextEnabled__c')) : element.umChatterAnswers_richTextEnabled__c;
					element.umChatterAnswers_zoneLabelPlural__c = opts.get('umChatterAnswers_zoneLabelPlural__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_zoneLabelPlural__c')) : element.umChatterAnswers_zoneLabelPlural__c;
					element.umChatterAnswers_zoneLabelSingular__c = opts.get('umChatterAnswers_zoneLabelSingular__c') != null ?
					 		String.valueOf(opts.get('umChatterAnswers_zoneLabelSingular__c')) : element.umChatterAnswers_zoneLabelSingular__c;
					element.umContactus_addCaseNumberEnabled__c = opts.get('umContactus_addCaseNumberEnabled__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_addCaseNumberEnabled__c')) : element.umContactus_addCaseNumberEnabled__c;
					element.umContactus_businessHourName__c = opts.get('umContactus_businessHourName__c') != null ?
					 		String.valueOf(opts.get('umContactus_businessHourName__c')) : element.umContactus_businessHourName__c;
					element.umContactus_ctiConfiguration__c = opts.get('umContactus_ctiConfiguration__c') != null ?
					 		String.valueOf(opts.get('umContactus_ctiConfiguration__c')) : element.umContactus_ctiConfiguration__c;
					element.umContactus_enableCall__c = opts.get('umContactus_enableCall__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enableCall__c')) : element.umContactus_enableCall__c;
					element.umContactus_createContactAndAccount__c = opts.get('umContactus_createContactAndAccount__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_createContactAndAccount__c')) : element.umContactus_createContactAndAccount__c;
					element.umContactus_enabled__c = opts.get('umContactus_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enabled__c')) : element.umContactus_enabled__c;
					element.umContactus_liveAgentChatButtonId__c = opts.get('umContactus_liveAgentChatButtonId__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentChatButtonId__c')) : element.umContactus_liveAgentChatButtonId__c;
					element.umContactus_liveAgentChatServerURL__c = opts.get('umContactus_liveAgentChatServerURL__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentChatServerURL__c')) : element.umContactus_liveAgentChatServerURL__c;
					element.umContactus_liveAgentDeploymentId__c = opts.get('umContactus_liveAgentDeploymentId__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentDeploymentId__c')) : element.umContactus_liveAgentDeploymentId__c;
					element.umContactus_liveAgentDeploymentURL__c = opts.get('umContactus_liveAgentDeploymentURL__c') != null ?
					 		String.valueOf(opts.get('umContactus_liveAgentDeploymentURL__c')) : element.umContactus_liveAgentDeploymentURL__c;
					element.umContactus_enableLiveAgent__c = opts.get('umContactus_enableLiveAgent__c') != null ?
					 		Boolean.valueOf(opts.get('umContactus_enableLiveAgent__c')) : element.umContactus_enableLiveAgent__c;
					element.umContactus_phoneNumber__c = opts.get('umContactus_phoneNumber__c') != null ?
					 		String.valueOf(opts.get('umContactus_phoneNumber__c')) : element.umContactus_phoneNumber__c;
					element.umKnowledgeBase_enabled__c = opts.get('umKnowledgeBase_enabled__c') != null ?
					 		Boolean.valueOf(opts.get('umKnowledgeBase_enabled__c')) : element.umKnowledgeBase_enabled__c;
					element.umSite_announcementsKaId__c = opts.get('umSite_announcementsKaId__c') != null ?
					 		String.valueOf(opts.get('umSite_announcementsKaId__c')) : element.umSite_announcementsKaId__c;
					element.umSite_announcements__c = opts.get('umSite_announcements__c') != null ?
					 		Boolean.valueOf(opts.get('umSite_announcements__c')) : element.umSite_announcements__c;
					element.umSite_apiName__c = String.valueOf(opts.get('umSite_apiName__c'));
					element.umSite_backgroundColor__c = opts.get('umSite_backgroundColor__c') != null ?
					 		String.valueOf(opts.get('umSite_backgroundColor__c')) : element.umSite_backgroundColor__c;
					element.umSite_backgroundImage__c = opts.get('umSite_backgroundImage__c') != null ?
					 		String.valueOf(opts.get('umSite_backgroundImage__c')) : element.umSite_backgroundImage__c;
					element.umSite_iconImage__c = String.valueOf(opts.get('umSite_iconImage__c'));
					element.umSite_searchBannerLabel__c = String.valueOf(opts.get('umSite_searchBannerLabel__c'));
					element.umSite_staticResource__c = String.valueOf(opts.get('umSite_staticResource__c'));
					element.umSite_welcomeMessage__c = String.valueOf(opts.get('umSite_welcomeMessage__c'));
					element.umSite_guestProfileId__c = objGuestProfile != null ? objGuestProfile.Id : String.valueOf(opts.get('umSite_guestProfileId__c'));
					element.umSite_casesEnabled__c = opts.get('umSite_casesEnabled__c') != null ?
					 	Boolean.valueOf(opts.get('umSite_casesEnabled__c')) : element.umSite_casesEnabled__c;
					element.umSite_authenticated__c = opts.get('umSite_authenticated__c') != null ?
					 	Boolean.valueOf(opts.get('umSite_authenticated__c')) : element.umSite_authenticated__c;
					element.signUpProfile__c = opts.get('signUpProfile__c') != null ?
						String.valueOf(opts.get('signUpProfile__c')) : element.signUpProfile__c;
					upsert element;
				}
				ret.put('id',element.Id);
				ret.put('umSite_guestProfileId__c',element.umSite_guestProfileId__c);
				ret.put('Status','Success');
			 }catch(umSecurityHandler.SecurityException sEx){
				ret.put('Msg','Internal error, received: ' + sEx.getMessage() );
				ret.put('Status', 'Failed' );
			 }catch(Exception e){
				ret.put('Status','Failed');
				ret.put('Msg','Internal error, received: ' + e.getMessage());
			 }
		}else{
			ret.put('Status','Failed');
			ret.put('Msg','Received Invalid Options.');
			ret.put('Received',siteInfoStr);
		}
		return ret;
	}

	/*
	 * @description
	 *		Delete a Site (and all related zones)
	 * @param siteInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object deleteSite( String siteInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(siteInfoStr);
		umSite__c element = null;
		if ( opts.get('id') != null ){
				try{
					 //check delete permissions
					umSecurityHandler.canDelete(new Schema.SObjectType[] {umZone__c.sObjectType});
					 element = [Select Id from umSite__c where Id = :String.valueOf(opts.get('id'))];
					 list<umZone__c> childs = [Select Id From umZone__c where umSite_id__c = :element.id];
					 if ( childs.size() > 0 ) delete childs;
					 list<umModerator__c> mods = [Select Id from umModerator__c where umSite_id__c = :element.id];
					 if (mods.size()>0) delete mods;
					 list<umKBDataCategory__c> dckb = [Select Id from umKBDataCategory__c where umSite_id__c = :element.id];
					 if (dckb.size()>0) delete dckb;
					 list<umKALayout__c> kal = [Select Id from umKALayout__c where umSite_id__c = :element.id];
					 if (kal.size()>0) delete kal;
					 delete element;
					 ret.put('Status','Success');
				}catch(umSecurityHandler.SecurityException sEx){
						ret.put('Msg','Internal error, received: '+sEx.getMessage() );
						ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',siteInfoStr);
		}
		return ret;
	 }

	/*
	 * @description
	 *		Create / Update a Zone
	 * @param zoneInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object postPutZone( String zoneInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(zoneInfoStr);
		umZone__c zone = null;
		if ( opts.get('zone__c') != null && opts.get('umSite_id__c') != null &&
				opts.get('publicName__c') != null && opts.get('dataCategory__c') != null){
					try{
						//check data category

						//check create permissions
						umSecurityHandler.canCreate(new Schema.SObjectType[] {umZone__c.sObjectType});
						if ( opts.get('id') == null || (String.valueOf(opts.get('id'))).length() < 18){
								zone = new umZone__c();
								zone.Name = String.valueOf((Datetime.now()).getTime());
								zone.announcements__c = opts.get('announcements__c') != null ?
									Boolean.valueOf(opts.get('announcements__c')) : zone.announcements__c;
								zone.announcementsKaId__c = opts.get('announcementsKaId__c') != null ?
									String.valueOf(opts.get('announcementsKaId__c')) : zone.announcementsKaId__c;
								zone.backgroundColor__c = opts.get('backgroundColor__c') != null ?
									String.valueOf(opts.get('backgroundColor__c')) : zone.backgroundColor__c;
								zone.backgroundImage__c = opts.get('backgroundImage__c') != null ?
									String.valueOf(opts.get('backgroundImage__c')) : zone.backgroundImage__c;
								zone.dataCategory__c = opts.get('dataCategory__c') != null ?
									String.valueOf(opts.get('dataCategory__c')) : zone.dataCategory__c;
								zone.publicName__c = opts.get('publicName__c') != null ?
									String.valueOf(opts.get('publicName__c')) : zone.publicName__c;
								zone.searchBannerLabel__c = opts.get('searchBannerLabel__c') != null ?
									String.valueOf(opts.get('searchBannerLabel__c')) : zone.searchBannerLabel__c;
								zone.umSite_id__c = opts.get('umSite_id__c') != null ?
									String.valueOf(opts.get('umSite_id__c')) : zone.umSite_id__c;
								zone.zone__c = opts.get('zone__c') != null ?
									String.valueOf(opts.get('zone__c')) : zone.zone__c;
								zone.iconImage__c = opts.get('iconImage__c') != null ?
									String.valueOf(opts.get('iconImage__c')) : zone.iconImage__c;
								insert zone;
						}else{
							//check updatepermissions
							umSecurityHandler.canUpdate(new Schema.SObjectType[] {umZone__c.sObjectType});
							zone = [Select announcements__c,announcementsKaId__c,backgroundColor__c,backgroundImage__c,dataCategory__c,
									publicName__c,searchBannerLabel__c,umSite_id__c,zone__c
									FROM umZone__c
									WHERE Id = :String.valueOf(opts.get('id'))];
							zone.announcements__c = opts.get('announcements__c') != null ?
								Boolean.valueOf(opts.get('announcements__c')) : zone.announcements__c;
							zone.announcementsKaId__c = opts.get('announcementsKaId__c') != null ?
								String.valueOf(opts.get('announcementsKaId__c')) : zone.announcementsKaId__c;
							zone.backgroundColor__c = opts.get('backgroundColor__c') != null ?
								String.valueOf(opts.get('backgroundColor__c')) : zone.backgroundColor__c;
							zone.backgroundImage__c = opts.get('backgroundImage__c') != null ?
								String.valueOf(opts.get('backgroundImage__c')) : zone.backgroundImage__c;
							zone.dataCategory__c = opts.get('dataCategory__c') != null ?
								String.valueOf(opts.get('dataCategory__c')) : zone.dataCategory__c;
							zone.publicName__c = opts.get('publicName__c') != null ?
								String.valueOf(opts.get('publicName__c')) : zone.publicName__c;
							zone.searchBannerLabel__c = opts.get('searchBannerLabel__c') != null ?
								String.valueOf(opts.get('searchBannerLabel__c')) : zone.searchBannerLabel__c;
							zone.umSite_id__c = opts.get('umSite_id__c') != null ?
								String.valueOf(opts.get('umSite_id__c')) : zone.umSite_id__c;
							zone.zone__c = opts.get('zone__c') != null ?
								String.valueOf(opts.get('zone__c')) : zone.zone__c;
							zone.iconImage__c = opts.get('iconImage__c') != null ?
									String.valueOf(opts.get('iconImage__c')) : zone.iconImage__c;
							upsert zone;
						}
						ret.put('Status','Success');
						ret.put('id',zone.Id);
					 }catch(umSecurityHandler.SecurityException sEx){
						ret.put('Msg','Internal error, received: '+sEx.getMessage() );
						ret.put('Status', 'Failed' );
					 }catch(Exception e){
						ret.put('Status','Failed');
						ret.put('Msg','Internal error, received: '+e.getMessage());
					 }
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',zoneInfoStr);
		}
		return ret;
	 }

	/*
	 * @description
	 *		deletes a Zone
	 * @param zoneInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object deleteZone( String zoneInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(zoneInfoStr);
		umZone__c zone = null;
		if ( opts.get('id') != null ){
				try{
					//check delete permissions
					umSecurityHandler.canDelete(new Schema.SObjectType[] {umZone__c.sObjectType});
					zone = [Select Id from umZone__c where Id = :String.valueOf(opts.get('id'))];
					delete zone;
					ret.put('Status','Success');
				}catch(umSecurityHandler.SecurityException sEx){
						ret.put('Msg','Internal error, received: '+sEx.getMessage() );
						ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',zoneInfoStr);
		}
		return ret;
	 }

	/*
	 * @description
	 *		Creates/Update a new KnowledgeArticle (custom setting)
	 * @param knowledgeArticleInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object postPutKnowledgeArticle( String knowledgeArticleInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(knowledgeArticleInfoStr);
		umKALayout__c element = null;
		if(opts.get('apiName__c') != null && opts.get('layout__c') != null && opts.get('umSite_id__c') != null){
			String elementId = opts.get('Id') == null ? null : String.valueOf(opts.get('Id'));
			try{
				//check create permissions
				umSecurityHandler.canCreate(new Schema.SObjectType[] {umKALayout__c.sObjectType});
				//check create permissions
				umSecurityHandler.canUpdate(new Schema.SObjectType[] {umKALayout__c.sObjectType});
				list<umKALayout__c> elements = null;
				if(elementId != null && elementId.length() == 18){
					elements = [Select Id,Name,apiName__c,layout__c,umSite_id__c from umKALayout__c where Id = :elementId limit 1];
						 elements[0].umSite_id__c = String.valueOf(opts.get('umSite_id__c'));
						 elements[0].apiName__c = String.valueOf(opts.get('apiName__c'));
						 elements[0].layout__c = String.valueOf(opts.get('layout__c'));
					 }else{
						element = new umKALayout__c();
						element.name = String.valueOf( (Datetime.now()).getTime() );
						element.apiName__c = String.valueOf(opts.get('apiName__c'));
						element.layout__c = String.valueOf(opts.get('layout__c'));
						element.umSite_id__c = String.valueOf(opts.get('umSite_id__c'));
					 }
					 if ( elementId == null || elementId.length() < 18) insert element; else upsert elements[0];
					 //if here all ok
					 ret.put('Status','Success');
					 if ( element != null ) ret.put('id', element.Id );
					 else ret.put('id',elements[0].Id);
				}catch(umSecurityHandler.SecurityException sEx){
						ret.put('Msg','Internal error, received: '+sEx.getMessage() );
						ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
				ret.put('Status','Failed');
				ret.put('Msg','Received Invalid Options.');
				ret.put('Received',knowledgeArticleInfoStr);
		}
		return ret;
	 }

	/*
	 * @description
	 *		Delete KnowledgeArticle (custom setting)
	 * @param knowledgeArticleInfoStr @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	public static Object deleteKnowledgeArticle( String knowledgeArticleInfoStr ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(knowledgeArticleInfoStr);
		try{
			//check delete permissions
			umSecurityHandler.canDelete(new Schema.SObjectType[] {umKALayout__c.sObjectType});
			list<umKALayout__c> element = opts.get('Id') == null ? new list<umKALayout__c>() : [Select Id from umKALayout__c where Id = :String.valueOf(opts.get('Id'))];
			if ( element.size() > 0 ){
				delete element[0];
				ret.put('Status','Success');
			}else{
				ret.put('Status','Failed');
				ret.put('Msg','Given Id does not exist');
			}
		}catch(umSecurityHandler.SecurityException sEx){
			ret.put('Msg','Internal error, received: '+sEx.getMessage() );
			ret.put('Status', 'Failed' );
		}catch(Exception e){
			ret.put('Status','Failed');
			ret.put('Msg','Internal error, received: '+e.getMessage());
		}
		return ret;
	}

	/*
	 * @description
	 *	Get All Specific KA elements with all fields api name included
	 * @return @type Object
	 */
	public static Object getKnowledgeTypesAndFields(){
		map<String,Object> ret = new map<String,Object>();
		AggregateResult[] kas = [Select ArticleType from KnowledgeArticleVersion where Language = 'en_US' and PublishStatus = 'Online' group by ArticleType limit 25000];
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		for ( AggregateResult elm : kas ){
				Schema.DescribeSObjectResult descRes;
				Map<String, Schema.SObjectField> fieldMap;
				descRes = schemaMap.get(String.valueOf(elm.get('ArticleType'))).getDescribe();
				fieldMap = descRes.fields.getMap();
				ret.put(String.valueOf(elm.get('ArticleType')),fieldMap.keySet());
		}
		return ret;
	}

	/*
	 * @description
	 *		Creates/Update a new KnowledgeBase DataCategory relation (custom setting)
	 * @param KnowledgeBaseDCInfo @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	 public static Object postPutKnowledgeBaseDataCategory( String KnowledgeBaseDCInfo ){
	 	map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(KnowledgeBaseDCInfo);
		umKBDataCategory__c element = null;
		if(opts.get('dataCategoryGroup__c') != null && opts.get('dataCategory__c') != null && opts.get('umSite_id__c') != null && opts.get('publicName__c') != null){
			String elementId = opts.get('Id') == null ? null : String.valueOf(opts.get('Id'));
			try{
				//check create permissions
				umSecurityHandler.canCreate(new Schema.SObjectType[] {umKBDataCategory__c.sObjectType});
				//check create permissions
				umSecurityHandler.canUpdate(new Schema.SObjectType[] {umKBDataCategory__c.sObjectType});
				list<umKBDataCategory__c> elements = null;
				if(elementId != null && elementId.length() == 18){
					elements = [Select Id,Name,dataCategoryGroup__c,dataCategory__c,umSite_id__c from umKBDataCategory__c where Id = :elementId limit 1];
						 elements[0].dataCategoryGroup__c = String.valueOf(opts.get('dataCategoryGroup__c'));
						 elements[0].dataCategory__c = String.valueOf(opts.get('dataCategory__c'));
						 elements[0].umSite_id__c = String.valueOf(opts.get('umSite_id__c'));
						 elements[0].publicName__c = String.valueOf(opts.get('publicName__c'));
					 }else{
						element = new umKBDataCategory__c();
						element.name = String.valueOf( (Datetime.now()).getTime() );
						element.dataCategoryGroup__c = String.valueOf(opts.get('dataCategoryGroup__c'));
						element.dataCategory__c = String.valueOf(opts.get('dataCategory__c'));
						element.umSite_id__c = String.valueOf(opts.get('umSite_id__c'));
						element.publicName__c = String.valueOf(opts.get('publicName__c'));
					 }
					 if ( elementId == null || elementId.length() < 18 ) insert element; else upsert elements[0];
					 //if here all ok
					 ret.put('Status','Success');
					 if ( element != null ) ret.put('id', element.Id );
					 else ret.put('id',elements[0].Id);
				}catch(umSecurityHandler.SecurityException sEx){
						ret.put('Msg','Internal error, received: '+sEx.getMessage() );
						ret.put('Status', 'Failed' );
				}catch(Exception e){
					 ret.put('Status','Failed');
					 ret.put('Msg','Internal error, received: '+e.getMessage());
				}
		}else{
			ret.put('Status','Failed');
			ret.put('Msg','Received Invalid Options.');
			ret.put('Received',KnowledgeBaseDCInfo);
		}
		return ret;
	 }

	 /*
	 * @description
	 *		Delete KnowledgeBase DataCategory relation (custom setting)
	 * @param KnowledgeBaseDCInfo @type String (Json stringified object)
	 * @return Object / Map<String,Object>
	 */
	public static Object deleteKnowledgeBaseDataCategory( String KnowledgeBaseDCInfo ){
		map<String,Object> ret = (map<String,Object>) getResponseStructure();
		Map<String, Object> opts = (Map<String, Object>) JSON.deserializeUntyped(KnowledgeBaseDCInfo);
		try{
			//check delete permissions
			umSecurityHandler.canDelete(new Schema.SObjectType[] {umKBDataCategory__c.sObjectType});
			list<umKBDataCategory__c> element = opts.get('Id') == null ? new list<umKBDataCategory__c>() : [Select Id from umKBDataCategory__c where Id = :String.valueOf(opts.get('Id'))];
			if ( element.size() > 0 ){
				delete element[0];
				ret.put('Status','Success');
			}else{
				ret.put('Status','Failed');
				ret.put('Msg','Given Id does not exist');
			}
		}catch(umSecurityHandler.SecurityException sEx){
			ret.put('Msg','Internal error, received: '+sEx.getMessage() );
			ret.put('Status', 'Failed' );
		}catch(Exception e){
			ret.put('Status','Failed');
			ret.put('Msg','Internal error, received: '+e.getMessage());
		}
		return ret;
	}

	/*
	 * @description
	 *		get KnowledgeBaseDataCategory List from custom settings of a given site
	 * @return Object / Map<String,Object>
	 */
	 public static Object getKnowledgeBaseDataCategory(String umSiteId){
		list<Object> ret = new list<Object>();
		list<umKBDataCategory__c> umKAdc = [Select Id, dataCategoryGroup__c,dataCategory__c,umSite_id__c,publicName__c
												FROM umKBDataCategory__c
												WHERE umSite_id__c = :umSiteId
												limit: umController.MAX_SOQL_RESULTS];
		if ( umkAdc.size() > 0 ){
				for ( umKBDataCategory__c element : umKAdc ){
					 map<String,Object> k = new map<String,Object>{
					 	'Id' => element.Id,
					 	'dataCategoryGroup__c' => element.dataCategoryGroup__c,
					 	'dataCategory__c' => element.dataCategory__c,
					 	'umSite_id__c' => element.umSite_id__c,
					 	'publicName__c' => element.publicName__c
					 };
					 ret.add(k);
				}
				return ret;
		}else{
			return 'No Data categories for knowledge base created.';
		}
	 }


	public static String getArticleTypeLayout( String siteId, String articleType ){

		String result = '';

system.debug('\n\n getArticleTypeLayout == articleType:'+articleType+'===siteId:'+siteId);


		list<umKALayout__c> kaFields = [ Select	layout__c
									 from umKALayout__c
									 where  umSite_id__c =: siteId
											and apiName__c =: articleType];


		if (!kaFields.isEmpty()){
			result = kaFields.get(0).layout__c;
		}

		return result;

	}


	/*
	 * @description
	 *		Returns Org users information
	 * @return Object
	 */
	public static Object getOrgUsers(){
		return [Select Id,Name,Username from User limit 2500];
	}

	/*
	 * @description
	 *		Returns Org static resources information
	 * @return Object
	 */
	 public static Object getOrgStaticResources(){
		return [Select Id,Name from StaticResource limit 2500];
	 }

	/*
	 * @description
	 *		Returns Org Sites Information
	 * @return Object
	 */
	public static Object getOrgSites(){
		return [Select Id,Name from Site limit 100];
	}

	/*
	 * @description
	 *		Returns Org Zones Information
	 * @return Object
	 */
	 public static Object getOrgZones(){
		return [Select Id,Name from Community limit 1500];
	 }

	/*
	 * @description
	 *		Returns Org Profiles Information
	 * @return Object
	 */
	 public static Object getOrgProfiles(){
		return [Select Id,Name from Profile limit 1500];
	 }

	 private static Object getResponseStructure(){
		return new map<String,Object>{'Status' => '','Msg' => ''};
	 }

	 private static Object reportCriticalError(){
		map<String,Object> ret = (map<String,String>) getResponseStructure();
		ret.put('Status','FAILURE');
		ret.put('Msg',CRITICAL_ERROR);
		return ret;
	 }
}