/**
 * @author Altimetrik
 * @description
 *    started on 06/24/2013
 *    Front Controller of Service Cloud Mobile Self-Service App
 **/
global with sharing class umController {


    public static final Integer MAX_OBJECTS = 5;
    public static final Integer MAX_OBJECTS_SINGLE = 500;
    public static final Integer MAX_SOQL_QUERY_SIZE = Limits.getLimitQueryRows()*90/100 ;
    public static final Integer MAX_SOSL_OBJECTS = 10;
    public static final Integer MAX_SOQL_RESULTS = Limits.getLimitQueryRows();
    public static final Integer MAX_SOSL_RESULTS = 2000;
    public static String DEFAULT_SITE_NAME = Site.getName();
    public static String COOKIE_NAVIGATION = 'UM_N_';
    public static String COOKIE_SEARCH = 'UM_S_';


    public  static set<String> validOpsQA{
        get{
            if (null == validOpsQA ) {
                if( Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_enabled__c')) )
                    validOpsQA = new set<String>{   'getQuestionDetail',
                                                    'getQuestions',
                                                    'searchQuestions',
                                                    'createQuestion',
                                                    'addLikeVote',
                                                    'addAbuse',
                                                    'updateSubscription',
                                                    'addReply',
                                                    'addLikeVoteReply',
                                                    'addReportOnReply',
                                                    'selectAsBestAnswer',
                                                    'getPrivateQuestionDetail'};
                else
                    validOpsQA = new set<String>();
                }
                return validOpsQA;
        }
        private set;
    }

    public  static set<String> validOpsPKB{
        get{
            if (null == validOpsPKB ) {
                if( Boolean.valueOf(umProxy.siteSettings.get('umKnowledgeBase_enabled__c')))
                    validOpsPKB =  new set<String>{ 'getArticleDetail',
                                                    'getArticles',
                                                    'searchArticles',
                                                    'getFeaturedArticleDetail',
                                                    'addLikeVoteKB'};
                else
                    validOpsPKB =  new set<String>();
            }
            return validOpsPKB;
        }
        private set;
    }

    public  static set<String> validOpsCases{
        get{
            if (null == validOpsCases ) {
                if( Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) ||
                    Boolean.valueOf(umProxy.siteSettings.get('umSite_casesEnabled__c')) )
                    validOpsCases =  new set<String>{   'getCaseDetail',
                                                        'getCases',
                                                        'processContactUs',
                                                        'markAsCaseResolved',
                                                        'addCaseComment'};
                else
                    validOpsCases =  new set<String>();
            }
            return validOpsCases;
        }
        private set;
    }


    public static set<String> validOps= new set<String>{'getSetup'};


    /**
    * @description
    *   returns details of the app modules configuration
    * @param umProxy.RequestItem - req
    * @return Json string
    **/
    public static umProxy.Response getCurrentSiteSetUp(){

        umProxy.Response resp = new umProxy.Response();

        try {
             umProxy.RequestItem basicReq  =  new umProxy.RequestItem();


            map<string,Object> setup = new map<String,Object>();
            /* details per available module  */
            // Questions and answers
            if( Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_enabled__c'))){
                Map<String,Object> qa = new Map<String,Object>();
                basicReq.operationData = umChatterAnswerModel.getResponseModel();
                qa.put('sortOptions', umChatterAnswerModel.sortOptions);
                qa.put('requestModel', basicReq);
                qa.put('richTextEnabled',Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_richTextEnabled__c')));
                setup.put('Questions',qa);
            }


            // Knowledge
            if( Boolean.valueOf(umProxy.siteSettings.get('umKnowledgeBase_enabled__c')) && umProxy.ACCESS_KNOWLEDGE){
                basicReq  =  new umProxy.RequestItem();
                Map<String,Object> kB = new Map<String,Object>();
                kB.put('announcementsEnabled',String.valueOf(umProxy.siteSettings.get('umSite_announcements__c')));
                basicReq.operationData = umKnowledgeBaseModel.getResponseModel();
                kB.put('requestModel',basicReq);
                kB.put('sortOptions', umKnowledgeBaseModel.sortOptions);
                setup.put('KB',kB);
            }


            // ContactUs
            if( Boolean.valueOf(umProxy.siteSettings.get('umSite_casesEnabled__c')) ||
                Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) && (
                Boolean.valueOf(umProxy.siteSettings.get('umContactus_enableCall__c'))  ||
                Boolean.valueOf(umProxy.siteSettings.get('umContactus_enableLiveAgent__c'))
                ) ){
                basicReq  =  new umProxy.RequestItem();
		        Map<String,Object> contactUS = new Map<String,Object>();
                Boolean callEnabled = Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) &&
                                         Boolean.valueOf(umProxy.siteSettings.get('umContactus_enableCall__c'));
                Boolean liveAgentEnabled = Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) &&
                                         Boolean.valueOf(umProxy.siteSettings.get('umContactus_enableLiveAgent__c'));

                basicReq.operationData = umCasesModel.getContactUsResponseModel();
                contactUS.put('requestModel',basicReq);
                contactUs.put('umContactus_casesEnabled__c',umProxy.siteSettings.get('umSite_casesEnabled__c'));
		        contactUS.put('umContactus_createContactAndAccount__c',umProxy.siteSettings.get('umContactus_createContactAndAccount__c'));

                if (callEnabled){
                    contactUS.put('umContactus_businessHourName__c',umProxy.siteSettings.get('umContactus_businessHourName__c'));
                    contactUS.put('umContactus_ctiConfiguration__c',umProxy.siteSettings.get('umContactus_ctiConfiguration__c'));
                    contactUS.put('umContactus_enableCall__c',callEnabled);
                    contactUS.put('umContactus_addCaseNumberEnabled__c',umProxy.siteSettings.get('umContactus_addCaseNumberEnabled__c'));
                    contactUS.put('umContactus_phoneNumber__c',umProxy.siteSettings.get('umContactus_phoneNumber__c'));
                }
                if (liveAgentEnabled){
                    contactUS.put('umContactus_liveAgentChatButtonId__c',umProxy.siteSettings.get('umContactus_liveAgentChatButtonId__c'));
                    contactUS.put('umContactus_liveAgentChatServerURL__c',umProxy.siteSettings.get('umContactus_liveAgentChatServerURL__c'));
                    contactUS.put('umContactus_liveAgentDeploymentId__c',umProxy.siteSettings.get('umContactus_liveAgentDeploymentId__c'));
                    contactUS.put('umContactus_liveAgentDeploymentURL__c',umProxy.siteSettings.get('umContactus_liveAgentDeploymentURL__c'));
                    contactUS.put('umContactus_enableLiveAgent__c',liveAgentEnabled);
                }


                contactUS.put('organizationId__c',UserInfo.getOrganizationId().substring(0,15));

                setup.put('ContactUS',contactUS);

                //emoIcons
                String tmpStr = '';
                List<Schema.PicklistEntry>pl = Case.UMCustomer_emoticon_value__c.getDescribe().getPickListValues();
                for(Schema.PicklistEntry p : pl){
                   if(tmpStr == ''){
                    tmpStr = p.getLabel();
                   }else{
                    tmpStr = tmpStr + ';'+p.getLabel();
                   }
                }
                //CASES
                basicReq  =  new umProxy.RequestItem();
                Map<String,Object> cases = new Map<String,Object>();
                basicReq.operationData = umCasesModel.getResponseModel();
                cases.put('requestModel',basicReq);
                cases.put('statusOptions', umCasesModel.statusOptions);
                cases.put('caseEmoIcons', tmpStr);
                setup.put('Case',cases);

            }

            //multi-language
            setup.put('multiLanguageEnabled','false' );
            setup.put('allowedKAV', (umSecurityHandler.getAllowedKav() != null));

            //Profile
            if( Boolean.valueOf(umProxy.siteSettings.get('umSite_authenticated__c'))){
                basicReq  =  new umProxy.RequestItem();
                Map<String,Object> profile = new Map<String,Object>();
                basicReq.operationData = new Map<String,Object>();
                profile.put('requestModel',basicReq);

                setup.put('Profile',profile);
            }

            //authentication
            setup.put('Authentication',Boolean.valueOf(umProxy.siteSettings.get('umSite_authenticated__c')));



            //request
            setup.put('requestModel',new umProxy.RequestItem());

            //currentUser
            setup.put('session',getCurrentUserDetails());

            resp.responseBody = setup;

        } catch (Exception ex) {
            //Indicate that an error has occurred
            resp.isSuccess = false;
            resp.message    = ex.getMessage()+'\n=========\n'+ ex.getStackTraceString();
        }

        return resp;

    }


    /*
     * @description
     *  set containing Ids of all moderators designated in the setup
     * @return set of strings
     */
    public  static map<Id, String>  zoneModeratorById{
        get{
            if (null == zoneModeratorById ) {
                            system.debug('\n\n siteSettings  :\n');
                system.debug(umProxy.siteSettings);
                String siteId = String.valueOf( umProxy.siteSettings.get('id') );
                zoneModeratorById = (umCustomSettingModel.getSiteModeratorsId(siteId));
                            system.debug('\n\n zoneModeratorById ['+siteId+']===== :\n'+zoneModeratorById);
            }
            return zoneModeratorById;
        }
        private set;
    }


    public static umProxy.Response processResponse(umProxy.RequestItem req){
        umProxy.Response resp = new umProxy.Response();

        String opType = req.operationType;

        try{
            resp.isSuccess = true;
            resp.message = '';

            //validate request Operations
            if (validOps.contains(opType) ){
                if ( req.operationType == 'getSetup'){
                    resp = umController.getCurrentSiteSetUp();
                }
            }else
             /*  chatter answer operations  */
                if (validOpsQA.contains(opType) ){
                   if ( req.operationType == 'getQuestions'){
                        //@todo :check if operation is valid for this site !!
                        resp.responseBody = umChatterAnswerModel.getQuestions((Object)req.operationData);
                    }
                    //searchQuestions
                    if ( req.operationType == 'searchQuestions'){
                        //@todo :check if operation is valid for this site !!
                        resp.responseBody = umChatterAnswerModel.searchQuestions((Object)req.operationData);
                    }
                    //getQuestionDetail
                    if ( req.operationType == 'getQuestionDetail'){
                        //@todo :check if operation is valid for this site !!
                        resp.responseBody = umChatterAnswerModel.getQuestionDetail((Object)req.operationData);
                    }
                    //createQuestion
                    if ( req.operationType == 'createQuestion'){
                        //@todo :check if operation is valid for this site !!
                        resp.responseBody = umChatterAnswerModel.createQuestion((Object)req.operationData);
                    }
                    //addLikeVote
                    if ( req.operationType == 'addLikeVote'){

                        resp.responseBody = umChatterAnswerModel.addLikeVote((Object)req.operationData);
                    }
                    //addAbuse
                    if ( req.operationType == 'addAbuse'){
                        resp.responseBody = umChatterAnswerModel.addReportOnQuestion((Object)req.operationData);
                    }
                    //addReply
                    if ( req.operationType == 'addReply'){
                        resp.responseBody = umChatterAnswerModel.addReply((Object)req.operationData);
                    }
                    //updateSubscription
                    if ( req.operationType == 'updateSubscription'){
                        resp.responseBody = umChatterAnswerModel.updateSubscription((Object)req.operationData);
                    }
                    //addLikeVoteReply
                    if ( req.operationType == 'addLikeVoteReply'){
                        resp.responseBody = umChatterAnswerModel.addLikeVoteReply((Object)req.operationData);
                    }
                    //addReportOnReply
                    if ( req.operationType == 'addReportOnReply'){
                        resp.responseBody = umChatterAnswerModel.addReportOnReply((Object)req.operationData);
                    }
                    //selectAsBestAnswer
                    if ( req.operationType == 'selectAsBestAnswer'){
                        resp.responseBody = umChatterAnswerModel.selectAsBestAnswer((Object)req.operationData);
                    }
                    //getPrivateQuestionDetail
                    if ( req.operationType == 'getPrivateQuestionDetail'){
                        resp.responseBody = umCasesModel.getCaseDetail((Object)req.operationData);
                    }
            }else
                /*  pkb operations  */
                if (validOpsPKB.contains(opType) ){
                   if ( req.operationType == 'getFeaturedArticleDetail'){
                        resp.responseBody = umKnowledgeBaseModel.getFeaturedArticleDetail((Object)req.operationData);
                    }

                   if ( req.operationType == 'getArticleDetail'){
                        resp.responseBody = umKnowledgeBaseModel.getArticleDetail((Object)req.operationData);
                    }
                    //getArticles
                    if ( req.operationType == 'getArticles'){
                        resp.responseBody = umKnowledgeBaseModel.getArticles((Object)req.operationData);
                    }
                    //search
                    if ( req.operationType == 'searchArticles'){
                        //@todo :check if operation is valid for this site !!
                        resp.responseBody = umKnowledgeBaseModel.searchArticles((Object)req.operationData);
                    }
                    //addLikeVote
                    if ( req.operationType == 'addLikeVoteKB'){

                        resp.responseBody = umKnowledgeBaseModel.addLikeVote((Object)req.operationData);
                    }
            }else
                /*  Cases operations  */
                if (validOpsCases.contains(opType) ){
                   if ( req.operationType == 'getCases'){
                        resp.responseBody = umCasesModel.getCases((Object)req.operationData);
                    }
                    if ( req.operationType == 'processContactUs'){
                        resp.responseBody = umCasesModel.processContactUs((Object)req.operationData);
                    }
                    //getCaseDetail
                    if ( req.operationType == 'getCaseDetail'){
                        resp.responseBody = umCasesModel.getCaseDetail((Object)req.operationData);
                    }
                    //markAsCaseResolved
                    if ( req.operationType == 'markAsCaseResolved'){
                        resp.responseBody = umCasesModel.markAsCaseResolved((Object)req.operationData);
                    }
                    //addCaseComment
                    if ( req.operationType == 'addCaseComment'){
                        resp.responseBody = umCasesModel.addCaseComment((Object)req.operationData);
                    }
            }else
                /*  general  */

                   if ( req.operationType == 'getUserProfileDetail'){
                        resp.responseBody = getUserDetails(req.operationData);
                    }

            else{
                resp.isSuccess  = false;
                resp.message    = 'Wrong operation '+opType;
            }

        }catch(umProxy.umException uEx){

            resp.isSuccess = false;
            map<String,String> exceptionDetails = new map<String,String> ();
            String fullmsg = uEx.getMessage();
            if (fullmsg.contains(':::')){
                list<String> exp = fullmsg.split(':::');
                exceptionDetails.put('type',exp[0]);
                exceptionDetails.put('message',exp[1]);
                exceptionDetails.put('stackTrace',uEx.getStackTraceString());
                resp.responseBody = (Object)exceptionDetails;
            }else{
                resp.responseBody = (Object)fullmsg;
            }
            resp.message ='check responseBody';

        }catch(Exception ex){
            resp.isSuccess = false;
            resp.responseBody = (Object)ex.getMessage() +'====\n'+(Object)ex.getStackTraceString();
            resp.message ='check responseBody';
        }

        //currentUser
        resp.session = getCurrentUserDetails();
        return resp;
    }


    public static Boolean validSession(){

        return  ( Userinfo.getProfileId() != umProxy.guestProfileId );
    }

    /**
      * @description
      *  Retrieve current user information
      * @return Object object
    **/
      private static Object getCurrentUserDetails(){
        map<String,Object> userMap = new map<String,Object>();

        //default values
        String userId = '';
        String uName = '';
        String uCOOKIE_NAVIGATION = COOKIE_NAVIGATION+'ANONYMOUS';
        String uCOOKIE_SEARCH = COOKIE_SEARCH+'ANONYMOUS';
        String uPhoto = '';

        //checking if it's a guest user
        if (  Boolean.valueOf(umProxy.siteSettings.get('umSite_authenticated__c')) && validSession() ){

            userId = Userinfo.getUserId();
            uCOOKIE_NAVIGATION = COOKIE_NAVIGATION+userId;
            uCOOKIE_SEARCH = COOKIE_SEARCH+userId;

            map<String,Object> sourceObj = new map<String,Object>();
            sourceObj.put('userId',userId);
            Object userMapObj = getUserDetails(sourceObj);
            String resString = JSON.serialize(userMapObj);
            userMap = (Map<String, Object>) JSON.deserializeUntyped(resString);

           /* //check permissions on Case Object
            userMap.put('caseEnabled',Schema.sObjectType.Case.isCreateable());
            User loggedUser = [SELECT ContactId,Id,SmallPhotoUrl,UserType FROM User where id=:userId ];
            system.debug('\n============= getCurrentUserDetails for ['+userId+']: '+userMap);

            //profile stats and details form chatter Answers
            if (Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_enabled__c'))){

                map<String,Object> m = umChatterAnswerModel.getUserStatistics(userId,'-1');
                uPhoto = String.valueOf(m.get('uPhoto'));
                uName = String.valueOf(m.get('uName'));
            }else{
                system.debug('\n============= getCurrentUserDetails :chatter answers OFF ');

            }
            //if name was not retrieved elsewhere
            if ( !String.isNotBlank(uName) ) uName = Userinfo.getName();
            //if photo was not retrieved elsewhere
            if (!String.isNotBlank(uPhoto)  && String.isNotBlank(loggedUser.SmallPhotoUrl)){
                uPhoto = loggedUser.SmallPhotoUrl;
            }*/
        }else{
            userMap.put('Id', userId);
            userMap.put('Name',uName);
            userMap.put('Photo', uPhoto);
        }

        //cookie names
        userMap.put('COOKIE_NAVIGATION',uCOOKIE_NAVIGATION);
        userMap.put('COOKIE_SEARCH',uCOOKIE_SEARCH);

        system.debug('\n============= getCurrentUserDetails returns : '+userMap);

        return userMap;
    }


    /**
      * @description
      *  Retrieve  user information for profile page
      * @return Object object
    **/
      public static Object getUserDetails(Object source){
        map<String,Object> userMap = new map<String,Object>();

        String resString = JSON.serialize(source);
        Map<String, Object> opData = (Map<String, Object>) JSON.deserializeUntyped(resString);

        system.debug('\n============= getUserDetails for [opData]: '+opData);
        if (! opData.containsKey('userId'))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel search');

        //default values
        String uId = String.valueOf(opData.get('userId'));
        String uName = '';
        String uPhoto = '';
        Integer utotalLikes = 0;
        Integer utotalAnswers = 0;
        Integer utotalQuestions = 0;
        Integer utotalNew = 0;
        Integer utotalClosed = 0;
        Integer utotalOthers = 0;


        system.debug('\n============= getUserDetails for ['+uId+']: '+userMap);
        //profile stats and details form chatter Answers
        if (Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_enabled__c'))){
            map<String,Object> m = umChatterAnswerModel.getUserStatistics(uId,'-1');
            utotalAnswers = Integer.valueOf(m.get('Answers'));
            utotalQuestions = Integer.valueOf(m.get('Questions'));
            utotalLikes = Integer.valueOf(m.get('Likes'));
            uPhoto = String.valueOf(m.get('uPhoto'));
            uName = String.valueOf(m.get('uName'));
        }else{
            system.debug('\n============= getUserDetails :chatter answers OFF ');

            if (    Boolean.valueOf(umProxy.siteSettings.get('umSite_authenticated__c')) &&
                   ( Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) ||
                     Boolean.valueOf(umProxy.siteSettings.get('umSite_casesEnabled__c')) )
                ){
                system.debug('\n============= getUserDetails :AUTHENTICATED ONN CONTACT ON  ');
                map<String,Object> m = umCasesModel.getUserStatistics(uId);
                utotalNew = Integer.valueOf(m.get('New'));
                utotalClosed = Integer.valueOf(m.get('Closed'));
                utotalOthers = Integer.valueOf(m.get('Other'));
                uPhoto = String.valueOf(m.get('uPhoto'));
                uName = String.valueOf(m.get('uName'));
            }

            list<User> uList = [SELECT Name,Id,SmallPhotoUrl,FullPhotoUrl,UserType FROM User where id=:uId ];
            if (!uList.isEmpty() ){
                User theUser = uList.get(0);


                system.debug('\n ============= getUserDetails small : '+theUser.SmallPhotoUrl +
                                ' big '+theUser.FullPhotoUrl +
                                '\n public url '+System.URL.getSalesforceBaseUrl().toExternalForm());

                //if name was not retrieved elsewhere
                if ( !String.isNotBlank(uName) ) uName = theUser.Name;
                //if photo was not retrieved elsewhere
                if (!String.isNotBlank(uPhoto)  && String.isNotBlank(theUser.SmallPhotoUrl)){
                    uPhoto = theUser.SmallPhotoUrl;
                }
            }

        }


        system.debug('\n============= getUserDetails uPhoto : '+uPhoto);

        userMap.put('profileIsMine', (uId == Userinfo.getUserId()));
        userMap.put('Id', uId);
        userMap.put('Name',uName);
        userMap.put('Photo', uPhoto);
        userMap.put('totalLikes', utotalLikes);
        userMap.put('totalAnswers', utotalAnswers);
        userMap.put('totalQuestions', utotalQuestions);
        userMap.put('totalNew', utotalNew);
        userMap.put('totalOther', utotalOthers);
        userMap.put('totalClosed', utotalClosed);

        system.debug('\n============= getUserDetails returns : '+userMap);

        return userMap;
    }


    public static String ENCODE(String input) {
        return String.escapeSingleQuotes(input);
    }

    /**
      * @description
      *  Tokenizes search string word0 word1 word2 and builds new string word0 OR word1 Or word2
      * @param qString -- String type
      * @return newQString String
      **/
    public static String process_SearchString(String qString){
        String finalStr = '';
        String glue = ' OR ';
        for(String s0 : qString.split('\\s+')){
            finalStr += glue+s0;
        }
        finalStr = finalStr.replaceFirst(glue,'');
        return finalStr;
    }



   /**
      * @description
      *
      * @param qString -- String type
      * @return newQString String
      **/

    public static String topicsForDataCategories(String qString){

        String finalStr = '';
        //String qString = 'books:fiction#music:all:Awards#';
        system.debug('\n======== qString  '+qString);


        if (!String.isNotBlank(qString)) return null;
        if (qString.indexOf('#') == -1 ){
system.debug( '\n===== USING umProxy.CAM_ROOT_GROUP_NAME > '+umProxy.CAM_ROOT_GROUP_NAME);
            finalStr =  umProxy.CAM_ROOT_GROUP_NAME +' BELOW ' +qString+ '__c';

        }else{

            List<String> selectedCategorySOSL = new List<String>();

            Map<String,String> selectedCategoryTokens = new Map<String,String>();
            List<String> fullTokens = qString.split('#');
            for(String f : fullTokens){
                List<String> tmp = f.split(':');
                selectedCategoryTokens.put(tmp[0],tmp[tmp.size() -1]);
            }

            List<String> finalTokens = new List<String>();
            for (String s : selectedCategoryTokens.keySet()) {
                finalTokens.add(s+'__c  BELOW '+selectedCategoryTokens.get(s)+'__c ');
            }
            finalStr = String.join(finalTokens,' AND ');

        }

       system.debug( '\n===== topicsForDataCategories > \n'+finalStr);

        return finalStr;
    }

    public static String getNamespace() {
        String tmp = '';

        String fullName = Schema.SObjectType.umSite__c.fields.umChatterAnswers_enabled__c.getName();
        String[] nameParts = fullName.replaceAll('__c','').split('__');
        tmp =  (nameParts.size() > 1) ? nameParts[0]+'__' : '';

        return tmp;
    }

    //Bussines hours / call available
    public static Object getPhoneCallAvailable(DateTime d){
        map<String,String> ret = new map<String,String>();

        umProxy.Response r = umController.getCurrentSiteSetUp();
        //contact us information
        map<String,Object> c = (map<String,Object>)((map<String,Object>)r.responseBody).get('ContactUS');
        system.debug('\n======== getPhoneCallAvailable:  '+c);

        String businessHour = String.valueOf(c.get('umContactus_businessHourName__c'));

        if ( Test.isRunningTest() ) businessHour = umTestEnvironment.getTestBusinessHourName();

        system.debug('\n======== getPhoneCallAvailable:  '+businessHour);

        //If no value, requirements defines a 24/7 service
        if ((!String.isNotBlank(businessHour)) || businessHour == '24/7'){
            if ( c.get('umContactus_phoneNumber__c') != null ){
                ret.put('available',String.valueOf(true));
                ret.put('number', String.valueOf( c.get('umContactus_phoneNumber__c') ));
            }else{
                ret.put('available',String.valueOf(false));
            }
        }else{
            //Let's try to get businessHour record, if wrong, define NO SERVICE
            list<BusinessHours> l = [ Select Id
                                        from  BusinessHours b
                                        where b.isActive = true
                                        and   b.Name = :businessHour
                                        limit 1 ];
            if ( l.size() > 0 ){
                DateTime nextTime = businesshours.addGmt(l[0].id, d, 1);
                //If all values in GMT & using day/hour/minute as key equals system.now GMT day/hour/minute
                //it means service is active (it also covers Holiday Days)
                if ( nextTime.dayGmt()    == d.dayGmt() &&
                     nextTime.hourGmt()   == d.hourGmt() &&
                     nextTime.minuteGmt() == d.minuteGmt() ){

                     //Check if phone number has been setted up, otherwise return no service
                     if ( c.get('umContactus_phoneNumber__c') != null ){
                        ret.put('available',String.valueOf(true));
                        ret.put('number',String.valueOf(c.get('umContactus_phoneNumber__c')));
                     }else{
                        ret.put('available',String.valueOf(false));
                     }
                }else{
                    ret.put('available',String.valueOf(false));
                }
            }else{
                ret.put('available',String.valueOf(false));
            }
        }
        return ret;
    }

}