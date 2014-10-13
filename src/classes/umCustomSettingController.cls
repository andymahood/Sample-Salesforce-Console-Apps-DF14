/**
 * @author Altimetrik
 * @description
 *		started at 10/25/2012
 *		refactor started 7/1/2013
 *		Front Controller Config Page
 *	DELEGATES TO umCustomSettingModel Class
 **/
 global with sharing class umCustomSettingController {

 	@RemoteAction
 	global static Object getAllSitesSetup(){
 		return umCustomSettingModel.getAllSitesSetup();
 	}

 	@RemoteAction
 	global static Object getCurrentSiteSetup(){
 		return umCustomSettingModel.getCurrentSiteSetup();
 	}

 	@RemoteAction
 	global static Object postPutModerator( String moderatorInfoStr ){
 		return umCustomSettingModel.postPutModerator(moderatorInfoStr);
 	}

 	@RemoteAction
 	global static Object deleteModerator( String moderatorInfoStr ){
 		return umCustomSettingModel.deleteModerator(moderatorInfoStr);
 	}

 	@RemoteAction
 	global static Object postPutSite( String siteInfoStr ){
 		return umCustomSettingModel.postPutSite(siteInfoStr);
 	}

 	@RemoteAction
 	global static Object deleteSite( String siteInfoStr ){
 		return umCustomSettingModel.deleteSite(siteInfoStr);
 	}

 	@RemoteAction
 	global static Object postPutZone( String zoneInfoStr ){
 		return umCustomSettingModel.postPutZone(zoneInfoStr);
 	}

 	@RemoteAction
 	global static Object deleteZone( String zoneInfoStr ){
 		return umCustomSettingModel.deleteZone(zoneInfoStr);
 	}

 	@RemoteAction
 	global static Object postPutKnowledgeArticle( String knowledgeArticleInfoStr ){
 		return umCustomSettingModel.postPutKnowledgeArticle(knowledgeArticleInfoStr);
 	}

 	@RemoteAction
 	global static Object deleteKnowledgeArticle( String knowledgeArticleInfoStr ){
 		return umCustomSettingModel.deleteKnowledgeArticle(knowledgeArticleInfoStr);
 	}

 	@RemoteAction
 	global static Object getOrgUsers(){
 		return umCustomSettingModel.getOrgUsers();
 	}

 	@RemoteAction
 	global static Object getOrgSites(){
 		return umCustomSettingModel.getOrgSites();
 	}

 	@RemoteAction
 	global static Object getOrgProfiles(){
 		return umCustomSettingModel.getOrgProfiles();
 	}

 	@RemoteAction
 	global static Object getOrgStaticResources(){
 		return umCustomSettingModel.getOrgStaticResources();
 	}

 	@RemoteAction
 	global static Object getOrgZones(){
 		return umCustomSettingModel.getOrgZones();
 	}

 	@RemoteAction
 	global static Object getKAStructure(){
 		return umCustomSettingModel.getKnowledgeTypesAndFields();
 	}

 	@RemoteAction
 	global static Object postPutKnowledgeBaseDataCategory(String knowledgeBaseDCinfo){
 		return umCustomSettingModel.postPutKnowledgeBaseDataCategory(knowledgeBaseDCinfo);
 	}

 	@RemoteAction
 	global static Object deleteKnowledgeBaseDataCategory(String knowledgeBaseDCinfo){
 		return umCustomSettingModel.deleteKnowledgeBaseDataCategory(knowledgeBaseDCinfo);
 	}

 	@RemoteAction
 	global static Object getKnowledgeBaseDataCategory(String siteInfoStr){
 		return umCustomSettingModel.getKnowledgeBaseDataCategory(siteInfoStr);
 	}

 	@RemoteAction
	global static Object verifyDc(String requestJson){
		Map<String,Object> thisResponseItem = new Map<String,Object>();
		Map<String, Object> source = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
		if ( source.get('group') == null || source.get('dc') == null ){
			thisResponseItem.put('isSuccess',false);
			thisResponseItem.put('message','Malformed request');
		}else{
			String g , dc;
			sObject[] r;
			try{
				g = String.valueOf(source.get('group'));
				dc = String.valueOf(source.get('dc'));
				r = Database.query('Select Id from Question WITH DATA CATEGORY '+g+' ABOVE '+dc+' limit 1');
			}catch(Exception e){
				thisResponseItem.put('isSuccess',false);
				thisResponseItem.put('message',e.getMessage());
			}
		}
		if (thisResponseItem.get('isSuccess') == null) thisResponseItem.put('isSuccess',true);
		return thisResponseItem;
	}
}