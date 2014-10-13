/**
 * @author Altimetrik
 * @description
 *    started on 06/24/2013
 *    Front Controller of Service Cloud Mobile Self-Service App
 **/
global with sharing class umProxy {

public static String DEFAULT_LANGUAGE = 'en_US';

	/**
	 * @description
	 *	CHATTER ANSWERS MOBILE PRIMARY CONSTANT (DATA CATEGORY GROUP NAME RELATED)
	 **/
	public  static String CAM_ROOT_GROUP_NAME{
		get{
			if (null == CAM_ROOT_GROUP_NAME && umProxy.siteSettings != null
					&& umProxy.siteSettings.get('umChatterAnswers_dataCategoryGroup__c') != null ) {
				CAM_ROOT_GROUP_NAME = String.valueOf(umProxy.siteSettings.get('umChatterAnswers_dataCategoryGroup__c'))+'__c';
			}
			return CAM_ROOT_GROUP_NAME;
		}
		private set;
	}

	public  static String CAM_ROOT_GROUP_NAME_SIMPLE{
		get{
			if (null == CAM_ROOT_GROUP_NAME_SIMPLE && umProxy.siteSettings != null
					&& umProxy.siteSettings.get('umChatterAnswers_dataCategoryGroup__c') != null) {
				CAM_ROOT_GROUP_NAME_SIMPLE = String.valueOf(umProxy.siteSettings.get('umChatterAnswers_dataCategoryGroup__c'));
			}
			return CAM_ROOT_GROUP_NAME_SIMPLE;
		}
		private set;
	}


	public  static String DCRootGroupName{
		get{
			if (null == DCRootGroupName ) {
				DCRootGroupName = String.valueOf( siteSettings.get('umChatterAnswers_dataCategoryGroup__c') );
			}
			return DCRootGroupName;
		}
		private set;
	}


	public static list<map<String,Object>>  Zones {

		get{/* i would like this to be handled in the custom settings page */
			if (Zones == null){
				if ( Boolean.valueOf(siteSettings.get('umChatterAnswers_enabled__c'))){
					Zones = new list<map<String,Object>>();

					categories = new list<map<String,String>>();

					Object comms = siteSettings.get('Zones');
					list<Object> commsList = (list<Object>) comms;
					for ( Object elm : commsList ){
						map<String,Object> elmMap = (map<String,Object>) elm;
						if (elmMap.get('backgroundColor__c') == null){
							elmMap.put('backgroundColor__c','null');
						}
						Zones.add(elmMap);
						categories.add(new map<String,String>{
										'rootCategory' => String.valueOf(elmMap.get('dataCategory__c')) ,
										'categoryGroup'=> DCRootGroupName,
										'label' => String.valueOf(elmMap.get('publicName__c'))
								});
					}
				}
				system.debug('\n\n [DEBUG MAP ZONES ALL categories ]:\n' + categories);
			}
			return Zones;
		}

		private set;
	}

	public static String  guestProfileId {

		get{
			if (null == guestProfileId ) {
				guestProfileId = String.valueOf( siteSettings.get('umSite_guestProfileId__c') );
			}
			return guestProfileId;
		}

		private set;
	}

    public  static map<String,Object> siteSettings{
        get{
            if (null == siteSettings ) {
                map<String,Object> tmp = (map<String,Object>)umCustomSettingModel.getCurrentSiteSetup();
                if (  String.valueOf(tmp.get('Status')) == 'Success' ){
                    list<Object> lSites = (list<Object>)tmp.get('Sites');
                    siteSettings = (map<String,Object>)lSites[0];
			    }
            }
            return siteSettings;
        }
        private set;
    }

    public  static Integer categoriesDepth{
        get{
            if (null == categoriesDepth ) {
            	if (! Boolean.valueOf(siteSettings.get('umChatterAnswers_enabled__c'))){
					categoriesDepth = -1;
				}else{
					categoriesDepth = 1;
				}
            }
            return categoriesDepth;
        }
        private set;
    }


    public  static list<map<String,String>> categories{
        get{
        	system.debug('>>> CHECKING CATEGORIES : umChatterAnswers_enabled__c '+Boolean.valueOf(siteSettings.get('umChatterAnswers_enabled__c')) );
            if (null == categories ) {

            	if (! Boolean.valueOf(siteSettings.get('umChatterAnswers_enabled__c')) && Boolean.valueOf(siteSettings.get('umKnowledgeBase_enabled__c'))){
					map<String,Object> k;
					categories = new list<map<String,String>>();
					for(Object obj : (list<Object>)siteSettings.get('KnowledgeBase')){
						k = (map<String,Object>)obj;
						categories.add(new map<String,String>{
										'rootCategory' => String.valueOf(k.get('dataCategory__c')) ,
										'categoryGroup'=> String.valueOf(k.get('dataCategoryGroup__c')) ,
										'label' => String.valueOf(k.get('publicName__c'))
								});
					}
				}
            }
            return categories;
        }
        private set;
    }


public  static Boolean ACCESS_KNOWLEDGE{
        get{
			if (null == ACCESS_KNOWLEDGE ) {
				ACCESS_KNOWLEDGE = (umSecurityHandler.getAllowedKav() != null);
			}
				return ACCESS_KNOWLEDGE;
	    }
        private set;
    }




    @RemoteAction
	global static String postBlobContent(String pId, String aId, String fileName, String contentType, String base64BlobValue){
	/*
	parentId: The sfdc object Id this file will be attached to
	attachmentId: The record of the current Attachment file being processed
	fileName: Name of the attachment
	contentTye: Content Type of the file being attached
	base64BlobValue: Base64 encoded string of the file piece currently processing
	*/
		try{
			Id parentId = pId;
			Id attachmentId;
			//If recordId is blank this is the first part of a multi piece upload
			if((!String.isNotBlank(aId)) ){
				Attachment att = new Attachment(
					ParentId = parentId,
					Body = EncodingUtil.Base64Decode(base64BlobValue),
					Name = fileName,
					ContentType = contentType
				);

				//check create permissions
				umSecurityHandler.canCreate(
					new Schema.SObjectType[] {Attachment.sObjectType});

				insert att;
				//Return the new attachment Id
				return att.Id;

			}else{
				//check Update permissions
				umSecurityHandler.canUpdate(
					new Schema.SObjectType[] {Attachment.sObjectType});
				attachmentId = aId;
				for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
					//Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
					update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
				}

				//Return the Id of the attachment we are currently processing
				return attachmentId;
			}
		}catch(umSecurityHandler.SecurityException sEx){
			 return null;
		}
	}

	//gets a single attachment (photo) by id. The data is returned as a base64 string that can be plugged
	// into an html img tag to display the image.
	@RemoteAction
	global static Object getAttachment(id atachmentParentId){

		Map<String,Object> results = new Map<String,Object>();

		try{
			Id parentId = atachmentParentId;
			list<Attachment> docs = [select id, body from Attachment where parentId = :parentId limit 1];
			if(!docs.isEmpty()){
				results.put('data',EncodingUtil.base64Encode(docs[0].body));
				results.put('success',true);
			}else{
				results.put('success',false);
			}
		}
		catch(exception e){
			results.put('success',false);
			results.put('message',e.getMessage());
		}
		return results;
	}

	/**
	 *			REMOTE ACTIONS
	**/

	@RemoteAction
	global static  Response getRemoteAction(String requestJson){


		Response thisResponseItem = new Response();
		RequestItem thisRequestItem;
		String opType = null;

		try {
			Map<String, Object> source = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
			thisRequestItem = new RequestItem(source);
			opType = thisRequestItem.operationType;
			system.debug('\n\n [DEBUG RequestItem ]:\n' + thisRequestItem);

			thisRequestItem.lang = (String.isNotBlank(thisRequestItem.lang)) ? thisRequestItem.lang : DEFAULT_LANGUAGE ;
			thisResponseItem = umController.processResponse(thisRequestItem);

		} catch (Exception ex) {
			//Indicate that an error has occurred
			thisResponseItem.isSuccess = false;
			thisResponseItem.message = ' Exception '+ex.getMessage()+'\n=========\n'+ ex.getStackTraceString();
		}

		system.debug('\n\n [DEBUG RESPONSE ]:' + thisResponseItem);
		return  thisResponseItem;
	}

	@RemoteAction
	global static Object getPhoneCallAvailable(){
		return umController.getPhoneCallAvailable(system.now());
	}

	/*******************************************************************
		Inner class encapsulate request parameters
	********************************************************************/
	global with sharing class RequestItem{

		public String   lang = DEFAULT_LANGUAGE;
		public String   sessionId;
		public String   operationType;
		public Object 	operationData;

		public RequestItem (){
			sessionId = '';
			operationType = '';
			operationData = null;
		}

		public RequestItem (Map<String, Object> source){
			lang = String.valueOf(source.get('lang'));
			sessionId = String.valueOf(source.get('sessionId'));
			operationType = String.valueOf(source.get('operationType'));
			operationData = source.get('operationData');
		}
	}

	global with sharing  class Response {
		public Boolean isSuccess = true;
		public String message;
		public Object responseBody;
		public Object session;
	}

	public class umException extends Exception {}

}