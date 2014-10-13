/**
 * @author Altimetrik
 * @description
 *    started on 08/13/2013
 *     Controller of Cases Mobile App
 **/
global with sharing class umCasesModel {

    /*
     * @description
     *  array that contains sorting options to be used in the front-end filters
     * @return list of strings
     */
    public  static list<String>  sortOptions{
        get{
            if (null == sortOptions ) {
                sortOptions = new list<String>{ 'sortBy_RECENT','sortBy_LAST_REPLY'};
            }
            return sortOptions;
        }
        private set;
    }

    /*
     * @description
     *  array that contains the options for Case Status
     * @return list of strings
     */
    public  static Map<String,String>  statusOptions{
        get{
            if (null == statusOptions ) {

                statusOptions = getActivePicklistOptions('Case','Status');
            }
            return statusOptions;
        }
        private set;
    }


    /*
     * @description
     *  this inner class holds the structure for the requests from front-end
     */
    private  class localData{

        public String   lang = umProxy.DEFAULT_LANGUAGE;
        public String   communityId;
        public String   sortBy;
        public String   authorId;
        public String   searchInput;
        public String   filterBy;
        public String   caseId;
        public String   questionId;
        public Integer  queryLimit = 10;
        public Integer  offset = 0;

        public localData (){
            communityId = '';
            sortBy = 'CreatedDate';
            filterBy = '-1';
            searchInput = '';
            caseId = '';
            questionId = '';
            authorId = '';

        }

    /*
     * @description
     *  builds objects of localData type validating each field
     */
        public localData (Map<String, Object> source){

            system.debug('\n\n umCasesModel **** localData :\n'+source);

            if (source.containsKey('lang'))
                lang = String.escapeSingleQuotes(String.valueOf(source.get('lang')));

            /* sorting */

            if (source.containsKey('sortBy')){
                      system.debug('\n\n umCasesModel source.sortBy : '+source.get('sortBy'));
                sortBy = String.escapeSingleQuotes(String.valueOf(source.get('sortBy')));

                if (sortBy == 'sortBy_LAST_REPLY')
                    sortBy = 'LastReplyDate';
                else
                    sortBy = 'CreatedDate';
            }

            /* filterBy */
            if (source.containsKey('filterBy')){
                filterBy = String.escapeSingleQuotes(String.valueOf(source.get('filterBy')));
                Map<String,String> validEntries = getActivePicklistOptions('Case','Status');
                if (! validEntries.containsKey(filterBy)){
                        filterBy = '-1';
                }
            }

            /*search string*/
            if (source.containsKey('searchInput')){
                    searchInput = String.escapeSingleQuotes(String.valueOf(source.get('searchInput')));
                    searchInput = umController.process_SearchString(searchInput);
            }

            /* communityId Id */
            if (source.containsKey('communityId')){
                    communityId = String.valueOf(source.get('communityId'));
            }

            /* question Id */
            if (source.containsKey('questionId')){
                    questionId = String.valueOf(source.get('questionId'));
            }
            /* case Id */
            if (source.containsKey('caseId')){
                    caseId = String.valueOf(source.get('caseId'));
            }

            /* authorId  */
            if (source.containsKey('authorId')){
                    authorId = String.valueOf(source.get('authorId'));
            }

            //questionList offset
            if (source.containsKey('offset')){
                    offset = Integer.valueOf(source.get('offset'));
            }

        }

    }


    /*
     * @description
     *  this inner class holds the structure for the response format to front-end
     */
    private  class replyData{
        public Object   resultList;
        public Object   result;
        public Object   replies;
        public Boolean  hasMore;
        public Integer   offset;
        public Integer   filterByTotal;
    }

    public static localData validateRequestForCases (Object operationData){
        umCasesModel.localData data;
        try{
            system.debug('\n\n validateRequestForCases :\n'+operationData);
            data = new umCasesModel.localData((Map<String, Object>)operationData);
        }catch(Exception e){
            system.debug('\n\n HORROR :\n'+e.getMessage());
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel');
        }
        return data;

    }


    public static Object getResponseModel(){
        return new localData();
    }
    /**
    * @description
    *   returns list of Cases
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getCases(Object operationData){
        replyData ret = new replyData();
        localData opData = validateRequestForCases(operationData);

        String contactIdFilter = '';

        if (! String.isNotBlank(opData.authorId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel getCases');

        //only author can see Cases

        list<User> u = [SELECT AccountId,ContactId FROM User where id =: opData.authorId ];
        if (!u.isEmpty() && u.get(0).ContactId != null ){
            contactIdFilter = u.get(0).ContactId;
        }

        system.debug('\n\n getCases : CONTACT DETAILS === \n'+u);

        if (Userinfo.getUserId() != opData.authorId ) return ret;

        String query =  ' Select  Id, Description, Subject, createdDate, status, caseNumber, '+
                        '  createdById,CreatorFullPhotoUrl,CreatorName,CreatorSmallPhotoUrl, '+
                        '  (Select Id from CaseComments) '+
                        ' FROM Case '+
                        ' WHERE  CommunityId = null ';

                if ( contactIdFilter != '' ){
                    query +='   AND  ContactId = \''+contactIdFilter+'\' ';
                }else{
                    query +='   AND CreatedById =\''+opData.authorId+'\'';
                }


            if ( opData.filterBy != '-1' ){
                    query +='   AND  status = \''+opData.filterBy+'\' ';
                }

                query += ' ORDER BY '+opData.sortBy+' DESC';
                query += ' LIMIT '+(opData.queryLimit + 1 );
                query += ' OFFSET '+opData.offset;

        system.debug('\n\n getCases : query \n'+query);
        list<Object> resultData = Database.query(query);

        ret.hasMore = ( (opData.queryLimit + 1 ) == resultData.size() );

        list<Object> res = new list<Object>();
        for ( Object obj : resultData ){

            if ( res.size()< ( opData.queryLimit ) )
                res.add(prepareRecordForResponse(obj));
        }
        ret.resultList = res;
        ret.offset = opData.offset + res.size();
        //filterByTotal

        query = ' Select  count(id) totalByStatus'+
                ' FROM Case '+
                ' WHERE  CommunityId = null ';
        if ( contactIdFilter != '' ){
            query +='   AND  ContactId = \''+contactIdFilter+'\' ';
        }else{
            query +='   AND CreatedById =\''+opData.authorId+'\'';
        }
        if ( opData.filterBy != '-1' ){
            query +='   AND  status = \''+opData.filterBy+'\' ';
        }

        system.debug('\n\n AggregateResult getCases : query \n'+query);

        AggregateResult total = Database.query(query);
        system.debug('\n\n total  \n'+total);
        ret.filterByTotal = Integer.valueOf(total.get('totalByStatus'));

        return ret;

    }



    /**
      * @description
      *  Build a map containing case  details
      * @param source --  type
      * @return  object
    **/
    public static map<String,Object> getUserStatistics(String userId){


        String contactIdFilter = '';
        String uPhoto = null;
        String uName = null;
        //only author can see Cases

        list<User> u = [SELECT AccountId,ContactId FROM User where id =: userId ];
        if (!u.isEmpty() && u.get(0).ContactId != null ){
            contactIdFilter = u.get(0).ContactId;
        }

        system.debug('\n\n getUserStatistics === \n'+u);


        map<String,Object> userMap = new map<String,Object>();
        userMap.put('New', 0);
        userMap.put('Closed', 0);
        userMap.put('Other', 0);
        Integer totalQuestions = 0, totalAnwers = 0;

        String sql =    ' SELECT    '+
                        '   Status, count(id) totalBy'+
                        ' FROM Case';

        if ( contactIdFilter != '' ){
            sql +='   WHERE ContactId = \''+contactIdFilter+'\' ';
        }else{
            sql +='   WHERE CreatedById =\''+userId+'\'';
        }

            sql += '  and CommunityId = null  ';
            sql +=' GROUP BY Status ';

        AggregateResult[] aggr = Database.query(sql);
        String st = '';
        Integer val = 0;

        for (AggregateResult r : aggr){
            st = String.valueOf(r.get('Status'));
            val = Integer.valueOf(r.get('totalBy'));
            if (st !='New' && st !='Closed' ){
                st = 'Other';
            }
            userMap.put(st, Integer.valueOf(userMap.get(st)) + val);
        }

        sql =   ' Select CreatorName, CreatorSmallPhotoUrl     '+
                ' FROM Case ';

        if ( contactIdFilter != '' ){
            sql +='   WHERE ContactId = \''+contactIdFilter+'\' ';
        }else{
            sql +='   WHERE CreatedById =\''+userId+'\'';
        }
        list<Case> lC =Database.query(sql);
        if (!lC.isEmpty()){
            uPhoto = lC[0].CreatorSmallPhotoUrl;
        }else{
            sql =   ' Select CreatorName, CreatorSmallPhotoUrl  '+
                    ' FROM CaseComment '+
                    ' WHERE CreatedById =\''+userId+'\'';

            list<CaseComment> lCC =Database.query(sql);
            if (!lCC.isEmpty()){
                uPhoto = lCC[0].CreatorSmallPhotoUrl;
            }
        }

        userMap.put('uPhoto',(Object)uPhoto);
        userMap.put('uName',(Object)uName);


        system.debug('\n\n getUserStatistics === \n'+userMap);
        return userMap;

    }




    /**
    * @description
    *   returns Case details
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getCaseDetail(Object operationData){

        replyData ret = new replyData();
        list<Object> res = new list<Object>();

        localData opData = validateRequestForCases(operationData);

        if (! String.isNotBlank(opData.caseId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]::: Request format invalid for umCasesModel Case Detail View');

        String soql =   ' Select  Id, Description, Subject, createdDate, Status , caseNumber, '+
                        '  createdById,CreatorFullPhotoUrl,CreatorName,CreatorSmallPhotoUrl, '+
                        '  UMgeolocalization__Latitude__s, UMgeolocalization__Longitude__s, '+
                        '  UMCustomer_emoticon_value__c, UMCustomer_emoticon__c '+
                        '  FROM Case '+
                        '  WHERE ';
        soql += ( String.isNotBlank(opData.CommunityId) && (opData.CommunityId!= '-1') )? ' CommunityId = \''+opData.CommunityId+'\' AND ' :'';
        soql += ' Id = \''+opData.caseId+'\'';

        system.debug('\n\n getCaseDetail : query \n'+soql);

        list<SObject> cases = Database.query(soql);

        if (!cases.isEmpty()) {
            ret.result = prepareRecordForResponse(cases[0]);
            //getting private replies
            String cId = String.valueOf(cases[0].Id);
            ret.replies = getCaseCommentsList(cId,null);
        }

        return ret;

    }



   /*
     * @description
     *  Add new reply
     * @param questionId @type String
     * @param replyBody  @type String
     * @return  Boolean
     */
    public static Object addCaseComment(Object operationData){

        replyData ret = new replyData();

        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        Map<String, Object> source = (Map<String, Object>)operationData;
        system.debug('\n\n umChatterAnswerModel addReply :\n'+source);
        String caseId       =  String.valueOf(source.get('caseId'));
        String body  = String.valueOf(source.get('Body'));


        if (String.isNotBlank(caseId)){
            caseId = String.escapeSingleQuotes(caseId);
            return umCasesModel.addPrivateReply(caseId,body);
        }

        return ret;

    }



    /*
     * @description
     *  Add new reply
     * @param caseId @type String
     * @param replyBody  @type String
     * @return  list of replies with new record as only element
     */
    public static Object addPrivateReply(Id caseId, String body){

        //create private reply
        umSecurityHandler.canCreate(
                new Schema.SObjectType[] {CaseComment.sObjectType});

        CaseComment cc = new CaseComment ( ParentId = caseId, CommentBody = body );
        insert cc;

        return getCaseCommentsList(caseId, cc.Id);
    }


    /*
     * @description
     *  Add new caseComment for given Case
     * @param caseId @type String
     * @param body  @type String
     * @param title  @type String
     * @return  new record Id
     */

    public static Object createPrivateQuestion (String communityId, String body, String title){
        replyData ret = new replyData();
        Case c;

        if (String.isNotBlank(communityId)){

            c = new Case(CommunityId = communityId,
                     Origin = 'Chatter Answers',
                     Subject = title,
                     Description = body);

        }else{
             c = new Case( Origin = 'Chatter Answers',
                     Subject = title,
                     Description = body);
        }

        insert c;

        ret.result = c.Id;

        return ret;
    }


    /*
     * @description
     *  returns list with caseComments associated to given CaseId,
     * @param caseId @type String
     * @param caseCommentId  @type String if not blank this is the only record it will return
     * @return  list of caseComments
     */

    public static list<Object> getCaseCommentsList( String caseId,  String caseCommentId){

        list<Object> res = new list<Object>();

        //getting private messages
        String soql =   ' SELECT Id, CreatedDate, CommentBody, ParentId, CreatorFullPhotoUrl,CreatedById , CreatorName, CreatorSmallPhotoUrl '+
                        ' FROM CaseComment '+
                        ' WHERE ';
                soql += String.isNotBlank(caseCommentId) ? ' id = \''+caseCommentId+'\' AND ' :'';
                soql += ' ParentId =\''+caseId+'\' ' +
                        ' order by CreatedDate ASC ';
                system.debug('\n\n getQuestionDetail PRIVATE QUERY=====: \n'+caseId);

        list<Object> resultData = Database.query(soql);

        //get UserNames
        set<Id> ids = new set<Id>();
         for ( Object source : resultData){
            CaseComment rObj = (CaseComment) source;
            ids.add(rObj.CreatedById);
         }

         Map <Id, User> mapUsers = new Map<Id,User>([Select Id, Name from User where id in: ids]);

        //process replies
        for ( Object source : resultData){

                String qString = JSON.serialize(source);
                Map<String, Object> rMap = (Map<String, Object>) JSON.deserializeUntyped(qString);

                CaseComment rObj = (CaseComment) source;

                Datetime d = rObj.CreatedDate;
                String datetimeStr = d.format('MMMM d, yyyy');

                Long elap = Datetime.now().getTime() - d.getTime();
                rMap.put('CreatedDateText',datetimeStr);
                rMap.put('CreatedDateElap',String.valueOf( elap ));
                rMap.put('CreatedDate',String.valueOf( d.getTime() ));

                if ( rObj.CreatedById == Userinfo.getUserId() ){
                    rMap.put('CreatorName',Userinfo.getName());
                    rMap.put('isAgent',false);
                }
                else{
                    rMap.put('isAgent',true);
                    if (mapUsers.containsKey(rObj.CreatedById)){
                            rMap.put('CreatorName',mapUsers.get(rObj.CreatedById));
                    }else{
                        if (umController.zoneModeratorById.containsKey(rObj.CreatedById)){
                            rMap.put('CreatorName',umController.zoneModeratorById.get(rObj.CreatedById));
                        }
                    }
                }
                rMap.put('isPrivate',true);
                res.add((Object)rMap);
                system.debug('\n\n   getPrivateRepliesList loop  ======>\n'+rMap);
        }

        return res;

    }


    /**
    * @description
    *   returns list of Private Questions
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getPrivateQuestions(Object operationData){
        replyData ret = new replyData();

        localData opData = validateRequestForCases(operationData);

        if (! String.isNotBlank(opData.authorId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel get Private Questions');

        //only author can see Cases
        if (Userinfo.getUserId() != opData.authorId ) return ret;

        String query =  ' Select  Id, Description, Subject, createdDate, status, caseNumber, '+
                        '  createdById,CreatorFullPhotoUrl,CreatorName,CreatorSmallPhotoUrl, '+
                        '  (Select Id from CaseComments) '+
                        ' FROM Case '+
                        ' WHERE CreatedById =\''+opData.authorId+'\' and CommunityId != null';

                query += ' ORDER BY '+opData.sortBy+' DESC';
                query += ' LIMIT '+opData.queryLimit;
                query += ' OFFSET '+opData.offset;

        system.debug('\n\n getCases : getPrivateQuestions  \n'+query);
        list<Object> resultData = Database.query(query);

        list<Object> res = new list<Object>();
        for ( Object obj : resultData ){
                res.add(prepareRecordForResponse(obj));
        }
        ret.resultList = res;
        ret.offset = opData.offset + res.size();

 //filterByTotal

        query = ' Select  count(id) totalByStatus'+
                ' FROM Case '+
                ' WHERE  CommunityId != null '+
                '   AND CreatedById =\''+opData.authorId+'\'';

        AggregateResult total = Database.query(query);
        system.debug('\n\n total of private questions   \n'+total);
        ret.filterByTotal = Integer.valueOf(total.get('totalByStatus'));

        return ret;

    }

    /*
     * @description
     *  Add new reply
     * @param caseId @type String
     * @param replyBody  @type String
     * @return  list of replies with new record as only element
     */
    public static Object markAsCaseResolved(Object operationData){

        replyData ret = new replyData();

        localData opData = validateRequestForCases(operationData);

        if (! String.isNotBlank(opData.caseId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]::: Request format invalid for umCasesModel Case mark as resolved');

        //create private reply
        umSecurityHandler.canUpdate(
                new Schema.SObjectType[] {CaseComment.sObjectType});

        Case c = [Select id, Status from Case where id=:opData.caseId];

        c.Status = 'Closed';
        update c;

        return getCaseDetail(operationData);
    }


    /* ***** CONTACT US FORM WRAPPER CLASS ***** */

    public static Object getContactUsResponseModel(){
        return new contactUsRequest();
    }


    private  class contactUsRequest {
        public String  firstName    { get; set; }
        public String  lastName     { get; set; }
        public String  email        { get; set; }
        public String  subject      { get; set; }
        public String  description  { get; set; }
        public Decimal latitude     { get; set; }
        public Decimal longitude    { get; set; }
        public String  emoIcon      { get; set; }
        public Map<String,String>   originOptions  { get; set; }
        public String   origin  { get; set; }


        public contactUsRequest() {
            firstName ='';
            lastName='';
            email ='';
            subject='';
            description='';
            latitude =0;
            longitude =0;
            emoIcon ='';
            originOptions = getActivePicklistOptions('Case','Origin');
            origin = '';

        }
    /*
     * @description
     *  builds objects of localData type validating each field
     */
        public contactUsRequest (Map<String, Object> source){

            String auxString;

            system.debug('\n\n umCasesModel contactUsRequest :\n'+source);
            /* subject */
            subject = String.valueOf(source.get('subject'));
            /* description  */
            description = String.valueOf(source.get('description'));
            /* firstName */
            if (source.containsKey('firstName') ){
                auxString = String.valueOf(source.get('firstName'));
                if (String.isNotBlank(auxString))
                    firstName = String.escapeSingleQuotes(auxString);
                else
                    firstName ='n/a';
            }
            /* lastName */
            if (source.containsKey('lastName')){
                auxString = String.valueOf(source.get('lastName'));
                if (String.isNotBlank(auxString))
                    lastName = String.escapeSingleQuotes(auxString);
                else
                    lastName ='n/a';
            }

            /* email is REQUIRED */
            if ( umController.validSession() ){
                //valid session
                email = UserInfo.getUserEmail();
            }else{
                auxString = '';
                if (source.containsKey('email'))
                    auxString = String.valueOf(source.get('email'));
                if (String.isNotBlank(auxString)){
                    email = String.escapeSingleQuotes(auxString);
                }
            }

            if (source.containsKey('latitude') && source.containsKey('longitude')){
                /* latitude  */
                if (String.isNotBlank(String.valueOf(source.get('latitude'))))
                    latitude = decimal.valueOf(String.valueOf(source.get('latitude')));
                /* longitude  */
                if (String.isNotBlank(String.valueOf(source.get('longitude'))))
                    longitude = decimal.valueOf(String.valueOf(source.get('longitude')));
            }
            /* emoIcon  */
            if (source.containsKey('emoIcon')){
                emoIcon = String.valueOf(source.get('emoIcon'));
                //update emoIcon
                Map<String,String> validEntries = getActivePicklistOptions('Case','UMCustomer_emoticon_value__c');
                if (! validEntries.containsKey(emoIcon)){
                        emoIcon = null;
                }
            }

            /* origin  */
            if (source.containsKey('origin')){
                origin = String.valueOf(source.get('origin'));
                //update origin
                Map<String,String> validEntries = getActivePicklistOptions('Case','Origin');
                if (! validEntries.containsKey(origin)){
                        origin = null;
                }
            }
        }
    }

    private static contactUsRequest validateContactUsParameters (Object operationData){
        umCasesModel.contactUsRequest data;
        try{
            system.debug('\n\n validateContactUsParameters :\n'+operationData);
            data = new umCasesModel.contactUsRequest((Map<String, Object>)operationData);
        }catch(Exception e){
            system.debug('\n\n HORROR :\n'+e.getMessage()+'\n=========\n'+ e.getStackTraceString());
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Contact Us flow');
        }
        return data;

    }
    /* ****** CONTACT US  RESPONSE WRAPPER CLASS ***************/

    global with sharing  class contactUsResponse {
        public Boolean isSuccess = true;
        public String message;
        public String caseId;
        public String caseNumber;
        public map <String,String> contactDetails;
    }

    /**
      * @description
      *
      * @param source @type umCasesModel.contactUsResponse
      * @return @type object/umCasesModel.contactUsResponse
      **/
    public static Object processContactUs(Object operationData){

        contactUsResponse response = new contactUsResponse();

        contactUsRequest opData = validateContactUsParameters(operationData);

        if (! String.isNotBlank(opData.email))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel ContactUs email field');



        system.debug('\n======== umContactus_enabled__c :'+umProxy.siteSettings.get('umContactus_enabled__c'));
        system.debug('\n======== umContactus_createContactAndAccount__c :'+umProxy.siteSettings.get('umContactus_createContactAndAccount__c'));
        //check create permissions

        umSecurityHandler.canCreate(
            new Schema.SObjectType[] {Case.sObjectType});

system.debug('\n======== process [0]');
        if (! Boolean.valueOf(umProxy.siteSettings.get('umContactus_enabled__c')) ) {
            //Indicate that an error has occurred
            response.isSuccess = false;
            response.message =  'Cannot create Case' ;
            return response;
        }

system.debug('\n======== process [1]');

        Integer CASE_SUBJECT_LENGTH = Schema.SObjectType.Case.fields.Subject.getLength();
        Case aCase = new Case();

        aCase.Subject = opData.Subject;
        aCase.Description = opData.Description;
        aCase.Origin = 'Web';

system.debug('\n======== process [2]');
        if (opData.emoIcon != null)
            aCase.UMCustomer_emoticon_value__c = opData.emoIcon;

        if (opData.longitude != null && opData.latitude != null){
            aCase.UMgeolocalization__Latitude__s = opData.latitude;
            aCase.UMgeolocalization__Longitude__s = opData.longitude;
        }

system.debug('\n======== process [3]');
        // ***** insert case

        // attempt to create the account and contact if configured to do so
        System.Savepoint sp = Database.setSavepoint();
        system.debug('\n======== : '+umProxy.siteSettings.get('umContactus_createContactAndAccount__c'));
        system.debug('\n======== valid session :'+umController.validSession() );

        if (    ! umController.validSession() &&
                Boolean.valueOf(umProxy.siteSettings.get('umContactus_createContactAndAccount__c')) &&
                String.isNotBlank(opData.email)){
            //check create permissions over Account and Contact
            umSecurityHandler.canCreate(
                new Schema.SObjectType[] {Account.sObjectType,Contact.sObjectType});

            try {
                Account a;
                Contact c;
                List<Contact> cons = [select Id, Account.Id from Contact where Email = :opData.email and Email != null limit 2];

                if (!cons.isEmpty()) {
                    a = cons[0].Account;
                    c = cons[0];
                } else {

                    a = new Account(Name = opData.lastName + ', ' +opData.firstName);
                    insert a;

                    c = new Contact(
                        AccountId = a.Id
                        ,FirstName = opData.firstName
                        ,LastName = opData.lastName
                        ,Email = opData.email
                    );
                    insert c;
                }

                aCase.AccountId = a.Id;
                aCase.ContactId = c.Id;

            } catch (System.DmlException de) {
                Database.rollback(sp);
                notifyAdmin(de, null,'Error In Case creation',aCase);

            } catch (Exception e) {
                Database.rollback(sp);
                notifyAdmin(null, e,'Error In Case creation',aCase);
            }
        }

        // try to insert the case regardless if the account or contact succeeded or not
        try {
            insert aCase;
        } catch (DmlException de) {
            Database.rollback(sp);
            notifyAdmin(de, null, 'Error In Case creation',aCase);
        } catch (Exception e) {
            Database.rollback(sp);
            notifyAdmin(null, e,  'Error In Case creation',aCase);
        }

        response.caseId = aCase.Id;
        List<Case> caseDetails = [select Id, casenumber  from Case where id=:aCase.Id limit 1];
        if (!caseDetails.isEmpty()){
            Case tc = caseDetails[0];
            response.caseNumber = tc.caseNumber;
        }
        if (aCase.ContactId != null){
            List<Contact> lc = [select Id, Name, Email from Contact where id=:aCase.ContactId limit 1];
            if (!lc.isEmpty()){
                Contact c = lc[0];
                response.contactDetails = new map<string,string>();
                response.contactDetails.put('Id',c.Id);
                response.contactDetails.put('Email',c.Email);
                response.contactDetails.put('Name',c.Name);
                response.contactDetails.put('CaseNumber',response.caseNumber);
                response.contactDetails.put('CaseId',response.caseId);
            }
        }

            return response;
    }

    public static Map<String,String> getActivePicklistOptions(String so, String field) {
        Map<String,String> options = new Map<String,String>();

        for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
            options.put(ple.getValue(), ple.getLabel());
        }
        return options;
    }

    private static Object prepareRecordForResponse(Object source){

        system.debug('\n\n THE prepareRecordForResponse ====IN==>\n'+source);
        String qString = JSON.serialize(source);
        Map<String, Object> cMap = (Map<String, Object>) JSON.deserializeUntyped(qString);

        Case cObj = (Case) source;

        Datetime d = cObj.CreatedDate;
        String datetimeStr = d.format('MMMM d, yyyy');
        Long elap = Datetime.now().getTime() - d.getTime();

        cMap.put('CreatedDateText',datetimeStr);
        cMap.put('CreatedDateElap',String.valueOf( elap ));
        cMap.put('CreatedDate',String.valueOf( d.getTime() ));

        cMap.put('CreatorName',Userinfo.getName());

        cMap.put('IAmAuthor', (cObj.createdById == UserInfo.getUserId()) );
        //Resolving if it's a customer agent
        ID authorId =  cObj.CreatedById ;
        cMap.put('isAgent',umController.zoneModeratorById.containsKey(authorId));

        Integer numComment = cObj.CaseComments.size();
        cMap.put('NumComment',numComment);
        cMap.put('caseNumber',cObj.caseNumber);

        //escape Description
        if (cObj.Description != null)
            cObj.Description = cObj.Description.replaceAll('\r','<br/>');

        source = (Object)cMap;
        system.debug('\n\n THE prepareRecordForResponse ====OUT==>\n'+source);
        return source;

    }


    public static void notifyAdmin(System.DmlException de, Exception e, String introMessage, Case theCase) {
        String body;
        Messaging.SingleEmailMessage msg;

        String debug;
        User siteAdmin = getSiteAdmin();

        // send email only if siteAdmin isn't null
        if (siteAdmin != null) {

            if (de != null) {
                debug = debugDmlException(de);
            } else if (e != null) {
                debug = debugException(e);
            }

            msg = new Messaging.SingleEmailMessage();
            msg.setSubject('Service Cloud Mobile Self-Service - Package Exception Notification');
            msg.setToAddresses(new List<String>{siteAdmin.Email});

            body = introMessage+
                '\n\nAPEX TRANSACTION DEBUG INFORMATION:\n' +debug+
                '\n\nSUBMITTED CASE INFORMATION:'+
                '\n\nSubject: ' +theCase.Subject+
                 '\n\nCase Type: ' +theCase.Type+
                 '\n\nCase Origin: ' +theCase.Origin+
                 '\n\nDescription: ' +theCase.Description+
                 '\n\n';
            msg.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
        }
    }
    public static String debugDmlException(System.DmlException de) {
        String s ='Cause: ' +de.getCause()+
                '\nLineNumber: ' +de.getLineNumber()+
                '\nMessage: ' +de.getMessage()+
                '\nStackTraceString: ' +de.getStackTraceString()+
                '\nTypeName: ' +de.getTypeName()+
                '\nDmlFieldNames: ' +de.getDmlFieldNames(0)+
                '\nDmlFields: ' +de.getDmlFields(0)+
                '\nDmlIndex: ' +de.getDmlIndex(0)+
                '\nDmlMessage: ' +de.getDmlMessage(0)+
                '\nDmlStatusCode: ' +de.getDmlStatusCode(0)+
                '\nNumDml: ' +de.getNumDml();
        return s;
    }

    public static String debugException(Exception e) {
        String s = '';
        s += 'Cause: ' +e.getCause()+
                '\nLineNumber: ' +e.getLineNumber()+
                '\nMessage: ' +e.getMessage()+
                '\nStackTraceString: ' +e.getStackTraceString()+
                '\nTypeName: ' +e.getTypeName();
        return s;
    }

    public static User getSiteAdmin() {
        String thisSiteName = String.valueOf(umProxy.siteSettings.get('umSite_apiName__c'));
        List<Site> sites = [
            select Id ,Name ,Admin.Id ,Admin.FirstName ,Admin.LastName ,Admin.Name ,Admin.Email
            from Site
            where
            Name = :thisSiteName
        ];

        // send the admin back if it's a site, send null back if not a site
        User u = (!sites.isEmpty() && sites[0].Admin != null ? sites[0].Admin : null);
        return u;
    }

    public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();

        // return empty list if object name was not found in the schema
        if (!gd.containsKey(so)) return ples;

        Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
        Map<String,Schema.SObjectField> sofs = sor.fields.getMap();

        // return empty list if field name was not found in the object's field list
        if (!sofs.containsKey(field)) return ples;

        Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();

        // return empty list if the field type is not picklist
        if (dfr.getType() != Schema.DisplayType.Picklist) return ples;

        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            if (ple.isActive()) {
                ples.add(ple);
            }
        }
        return ples;
    }




}