/**
 * @author Altimetrik
 * @description
 *    started on 06/24/2013
 *    Front Controller of Service Cloud Mobile Self-Service App ChatterAnswers module
 **/
global with sharing class umChatterAnswerModel {

    public  static list<String>  sortOptions{
        get{
            if (null == sortOptions ) {
                sortOptions = new list<String>{'sortBy_POPULARITY','sortBy_RECENT','sortBy_LAST_REPLY'};
            }
            return sortOptions;
        }
        private set;
    }

    private  class localData{

        public String   lang = 'en_US';
        public String   communityId;
        public String   topicName;
        public String   sortBy;
        public String   searchInput;
        public String   authorId;
        public String   questionId;
        public String   replyId;
        public String   questionsType;
        public Integer  queryLimit = 10;
        public Integer  offset = 0;
        public map<String,Integer> fieldLengths ;

        public localData (){
            communityId = '';
            topicName = '-1';
            sortBy = 'VoteScore';
            searchInput = '';
            questionId = '';
            replyId = '';
            authorId = '';
            questionsType = '';
            fieldLengths = new map<String,Integer>{
                    'publicTitle' =>   Schema.SObjectType.Question.fields.Title.getLength(),
                    'publicBody' => Schema.sObjectType.Question.fields.Body.getLength(),
                    'privateTitle' => Schema.sObjectType.Case.fields.Subject.getLength(),
                    'privateBody' => Schema.sObjectType.Case.fields.Description.getLength()
            };
        }

        public localData (Map<String, Object> source){

            system.debug('\n\n umChatterAnswerModel localData :\n'+source);

            // communityId is a MUST if this is not part of the request we let the exception arise
            communityId = String.escapeSingleQuotes(String.valueOf(source.get('communityId')));

            if (source.containsKey('lang'))
                lang = String.escapeSingleQuotes(String.valueOf(source.get('lang')));

            if (source.containsKey('topicName')){
                topicName = String.escapeSingleQuotes(String.valueOf(source.get('topicName')));
                if (String.isNotBlank(topicName) && topicName != '-1'){
                    topicName = umController.topicsForDataCategories(topicName);
                }else{
                     topicName = '-1';
                }
            }

            /* sorting */
            if (source.containsKey('sortBy')){

                    sortBy = String.escapeSingleQuotes(String.valueOf(source.get('sortBy')));
                    set<String> setSort = new set<String>();
                    setSort.addAll(sortOptions);
                    if (setSort.contains(sortBy)){
                        if (sortBy == 'sortBy_POPULARITY')
                            sortBy ='VoteScore' ;
                        if (sortBy == 'sortBy_RECENT')
                            sortBy = 'CreatedDate';
                        if (sortBy == 'sortBy_LAST_REPLY')
                            sortBy = 'LastReplyDate';
                    }
            }
            /*search string*/
            if (source.containsKey('searchInput')){
                    searchInput = String.escapeSingleQuotes(String.valueOf(source.get('searchInput')));
                    searchInput = umController.process_SearchString(searchInput);
            }
            /* question Id */
            if (source.containsKey('questionId')){
                    questionId = String.valueOf(source.get('questionId'));
            }
            /* reply Id */
            if (source.containsKey('replyId')){
                    replyId = String.valueOf(source.get('replyId'));
            }
            /* authorId  */
            if (source.containsKey('authorId')){
                    authorId = String.valueOf(source.get('authorId'));
            }
            /* typeOf */
            if (source.containsKey('questionsType')){
                    questionsType = String.valueOf(source.get('questionsType'));
            }

            //questionList offset
            if (source.containsKey('offset')){
                    offset = Integer.valueOf(source.get('offset'));
            }

        }

    }

    private  class replyData{
        public Object   resultList;
        public Object   result;
        public Object   publicReplies;
        public Object   privateReplies;
        public Integer  offset;
        public Integer  filterByTotal;
        public Boolean  hasMore;
    }

    private static localData validateRequestForChatterAnswers (Object operationData){
        umChatterAnswerModel.localData data;
        try{
            system.debug('\n\n validateRequestForChatterAnswers :\n'+operationData);
            data = new umChatterAnswerModel.localData((Map<String, Object>)operationData);
        }catch(Exception e){
            system.debug('\n\n HORROR :\n'+e.getMessage());
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel');
        }
        return data;

    }


    public static Object getResponseModel(){
        return new localData();
    }


    /**
    * @description
    *   returns list of Questions
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getQuestions(Object operationData){
        replyData ret = new replyData();
        localData opData = validateRequestForChatterAnswers(operationData);

        if (String.isNotBlank(opData.questionsType) && ( opData.questionsType == 'private')){
            return umCasesModel.getPrivateQuestions(operationData);
        }else{
            return getPublicQuestions(opData);
        }
    }

    /**
    * @description
    *   returns list of Publci Questions
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getPublicQuestions(localData opData){
        replyData ret = new replyData();

        List<String> queryTokens = new List<String>();

        String query =  ' select Id, BestReplyId, BestReplySelectedById, Community.Name, Title, NumSubscriptions, NumReplies, Body, createdDate, '+
                        ' createdById, UpVotes, VoteScore, LastReplyDate,CreatorFullPhotoUrl,CreatorName,CreatorSmallPhotoUrl,CommunityId,'+
                        ' (Select Id from Votes v where Type = \'up\' and CreatedById = \''+Userinfo.getUserId()+'\'),'+
                        ' (Select Id From Subscriptions where CreatedById = \''+Userinfo.getUserId()+'\' ), '+
                        ' (Select Id From QuestionReportAbuses where CreatedById = \''+Userinfo.getUserId()+'\' ), '+
                        ' (Select DataCategoryName from DataCategorySelections limit 1 ) '+
                        ' FROM Question ';
                if ( opData.communityId != '-1' ){
                    queryTokens.add(' CommunityId =\''+opData.communityId+'\'');
                }

                if ( (opData.communityId == '-1' && String.isNotBlank(opData.authorId) )  ){
                    String auxToken = ' CreatedById =\''+opData.authorId+'\'';
                            //Getting what user is following
                        list<QuestionSubscription> whatIFollow = [Select QuestionId, SubscriberId from QuestionSubscription where SubscriberId = :opData.authorId limit 1000];
                        String  listOfWhatUserIsFollowing = '';
                        for ( Integer i=0; i<whatIFollow.size(); i++ ){
                            QuestionSubscription elm = whatIFollow[i];
                            listOfWhatUserIsFollowing += (i != 0) ? ',\''+elm.QuestionId+'\'' : '\''+elm.QuestionId+'\'';
                        }
                        if (String.isNotBlank( listOfWhatUserIsFollowing ))
                            auxToken = auxToken +' OR Id IN ('+listOfWhatUserIsFollowing+') ';

                        queryTokens.add(auxToken);
                }

                if (!queryTokens.isEmpty()){

                     query +=' WHERE ' + String.join(queryTokens, ' AND ');
                }

                /* data categories restriction */
                query += opData.topicName != '-1' ? ' WITH DATA CATEGORY '+opData.topicName :'';

                query += ' ORDER BY '+opData.sortBy+' DESC';
                query += ' LIMIT '+ (opData.queryLimit + 1 );
                query += ' OFFSET '+ opData.offset ;

        system.debug('\n\n getQuestions : query \n'+query);
        list<Object> resultData = Database.query(query);
        ret.hasMore = ( (opData.queryLimit + 1 ) == resultData.size() );

        String dString  = '\n\n getQuestions : PAGING ============================  :'+resultData.size();
               dString += '  (opData.queryLimit + 1 ) :  '+ (opData.queryLimit + 1 ) +' \n has more '+ret.hasMore;

        list<Object> res = new list<Object>();
        for ( Object obj : resultData ){
            if ( res.size()< ( opData.queryLimit ) )
                res.add(prepareRecordForResponse(obj));
        }
        ret.resultList = res;
        ret.offset = opData.offset + res.size() ;


        //filterByTotal

        query = ' Select  count(id) totalByStatus'+
                ' FROM Question '+
                ' WHERE  '+
                ' CreatedById =\''+opData.authorId+'\'';


        AggregateResult total = Database.query(query);
        system.debug('\n\n total  \n'+total);
        ret.filterByTotal = Integer.valueOf(total.get('totalByStatus'));

        system.debug(dString + '\n OFFSET  :'+ret.offset +' TOTAL SENT: '+res.size()  +'\n\n\n\n\n' );


        return ret;

    }


    /**
    * @description
    *   returns list of Questions filtering by searchInput
    * @param localData - operationData
    * @return Object response
    **/
    public static Object searchQuestions(Object operationData){
        replyData ret = new replyData();

        list<Object> res = new list<Object>();

        localData opData = validateRequestForChatterAnswers(operationData);
        system.debug('\n\n searchQuestions ======>\n'+opData);
        if (! String.isNotBlank(opData.searchInput))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel search');

        String soslQuery = 'FIND \''+opData.searchInput+'*\' IN ALL FIELDS RETURNING '+
            ' Question ( '+
            '   Id, BestReplyId, BestReplySelectedById, Community.Name, Title, NumSubscriptions,'+
            '   NumReplies, Body, createdDate, createdById, UpVotes, VoteScore, LastReplyDate,'+
            '   CreatorFullPhotoUrl,CreatorName,CreatorSmallPhotoUrl,CommunityId ';

            if ( opData.communityId != '-1' ){
                soslQuery +='   WHERE CommunityId = \''+opData.communityId+'\' ';
            }

            soslQuery += ' ) limit '+umController.MAX_SOSL_OBJECTS;

        list<list<SObject>> results = search.query(soslQuery);
        Set<Id> candidateIds = new Set<Id>();

        for ( sObject obj : results[0] ){
            Question q = (Question) obj;
            candidateIds.add(q.id);
        }

        //check if we have ids
        if ( ! candidateIds.isEmpty() ){
            String query =  ' select Id, BestReplyId, BestReplySelectedById, Community.Name, Title, NumSubscriptions, '+
                            ' NumReplies, Body, createdDate, createdById, UpVotes, VoteScore, LastReplyDate,CreatorFullPhotoUrl,'+
                            ' CreatorName,CreatorSmallPhotoUrl,'+
                            ' (Select DataCategoryName from DataCategorySelections limit 1 ), '+
                            ' (Select Id from Votes v where Type = \'up\' and CreatedById = \''+Userinfo.getUserId()+'\'), '+
                            ' (Select Id From Subscriptions where CreatedById = \''+Userinfo.getUserId()+'\' ), '+
                            ' (Select Id From QuestionReportAbuses where CreatedById = \''+Userinfo.getUserId()+'\' ) '+
                            'FROM Question where Id IN :candidateIds ';
            list<Object> resultData = Database.query(query);
            for ( Object obj : resultData){
                    res.add(prepareRecordForResponse(obj));
            }

        }

        ret.resultList = res;
        ret.offset = opData.offset + res.size();
        return ret;
    }

    /**
    * @description
    *   returns list of Questions filtering by searchInput
    * @param localData - operationData
    * @return Object response
    **/
    public static Object getQuestionDetail(Object operationData){

        replyData ret = new replyData();
        list<Object> res = new list<Object>();

        localData opData = validateRequestForChatterAnswers(operationData);
        system.debug('\n\n getQuestionDetail ======> ID: '+opData.questionId);
        if (! String.isNotBlank(opData.questionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel Question Detail View');

        String soql =   ' select (Select DataCategoryName From DataCategorySelections), '+
                        ' Id, BestReplyId, BestReplySelectedById, Community.Name, Title,'+
                        ' (Select Id from Votes v where Type = \'up\' and CreatedById = \''+Userinfo.getUserId()+'\'),'+
                        ' (Select Id From QuestionReportAbuses where CreatedById = \''+Userinfo.getUserId()+'\' ), '+
                        ' (Select Id From Subscriptions where CreatedById = \''+Userinfo.getUserId()+'\' ),'+
                        ' NumSubscriptions, NumReplies, Body, createdDate, createdById,'+
                        ' UpVotes, VoteScore, LastReplyDate,CreatorFullPhotoUrl,CreatorName,'+
                        ' CreatorSmallPhotoUrl, CommunityId ,'+
                        ' (Select Id from Cases )' +
                        ' FROM Question WHERE Id = \''+opData.questionId+'\''+
                        ' limit 1';

        system.debug('\n\n getQuestionDetail ======>QUERY \n'+soql);
        list<Object> q = Database.query(soql);
        //obtaing best Answer Id
        Question aux = (Question) q[0];

        ret.result = prepareRecordForResponse(q[0]);

        //Getting public replies
        ret.publicReplies = getPublicRepliesList(opData.questionId,null);

        List<Case> lccc = [select id from case where questionId =:opData.questionId];

        system.debug('\n\n cases with question =====: \n'+lccc);
        //getting private replies
        //checking if applies to check for private messages

        list<Object> caseComments;

        system.debug('\n\n getQuestionDetail PRIVATE =====: \n'+aux.Cases);
        Boolean CasesEnabled = true;
        if (CasesEnabled && aux.Cases.size() > 0 && aux.createdById == UserInfo.getUserId() ){
            caseComments = umCasesModel.getCaseCommentsList(aux.Cases[0].Id,null);
        }
        ret.privateReplies = caseComments;

        return ret;

    }


    /**
    * @description
    *   delegates question creation
    * @param localData - operationData
    * @return Object response
    **/
    public static Object createQuestion(Object operationData){

        replyData ret = new replyData();

        Map<String, Object> source = (Map<String, Object>)operationData;

        String questionType =  String.valueOf(source.get('Type'));
        // communityId is a MUST if this is not part of the request we let the exception arise
        String communityId = String.valueOf(source.get('CommunityId'));
        String title =  String.valueOf(source.get('Title'));


        if (    String.isNotBlank(communityId)
            &&  String.isNotBlank(title)
            &&  String.isNotBlank(questionType)  ){

            questionType = String.escapeSingleQuotes(questionType);
            communityId = String.escapeSingleQuotes(communityId);

            String body  =  String.valueOf(source.get('Body'));

            if (questionType =='public'){

                String topic = String.escapeSingleQuotes(String.valueOf(source.get('Topic')));
                //check create permissions
                umSecurityHandler.canCreate(
                    new Schema.SObjectType[] {Question.sObjectType,
                                            QuestionDataCategorySelection.sObjectType,
                                            QuestionSubscription.sObjectType});

                ret =  createPublicQuestion(communityId,topic,body,title);

            }else{
                //check create permissions
                umSecurityHandler.canCreate(
                        new Schema.SObjectType[] {Case.sObjectType});
                return  umCasesModel.createPrivateQuestion(communityId,body,title);
            }
        }else{
             throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  createQuestion');

        }
        return ret;
    }

    private static replyData createPublicQuestion (String communityId, String topic, String body, String title){

        replyData ret = new replyData();

        Question q = null;
        QuestionDataCategorySelection qDS = null;
        QuestionSubscription qS = null;

        title = sanitizeQuestionTitle(title,true);
        body = sanitizeQuestionBody(body,true);

        q = new Question( CommunityId = communityId , Title = title , Origin = 'Chatter Answers' , Body = body);
        insert q;

        qDS = new QuestionDataCategorySelection( DataCategoryGroupName = umProxy.CAM_ROOT_GROUP_NAME_SIMPLE , DataCategoryName = topic , ParentId = q.Id );
        insert qDS;

        qS = new QuestionSubscription( SubscriberId = Userinfo.getUserId() , QuestionId = q.Id );
        insert qS;

        ret.result = q.Id;

        return ret;
    }


    /*
     * @description
     *  Add a like to a question
     * @param questionId @type String
     * @return  Objbect with voteId on the result
     */
    public static Object addLikeVote(Object operationData){


        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        localData opData = validateRequestForChatterAnswers(operationData);
        if (! String.isNotBlank(opData.questionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  question add like : record id');


        Question record = [Select Id from Question where id =:opData.questionId ];

        return addVote(record.Id);

    }


    /*
     * @description
     *  Add a Abuse Report to a question
     * @param questionId @type String
     * @return  Object with QuestionReportAbuse record Id on the result
     */
    public static Object addReportOnQuestion(Object operationData){


        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        replyData ret = new replyData();

        localData opData = validateRequestForChatterAnswers(operationData);
        if (! String.isNotBlank(opData.questionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  question Abuse Report: record id');

        //check create permissions
        umSecurityHandler.canCreate(
            new Schema.SObjectType[] {QuestionReportAbuse.sObjectType});


        //Let's check if user already have a reported this  question
        list<QuestionReportAbuse> reports = [Select Id From QuestionReportAbuse where QuestionId = :opData.questionId AND CreatedById = :Userinfo.getUserId() limit 1];
        if ( reports.size() > 0 ){
             throw new umProxy.umException('User already flagged this question');
        }

        //add  report for given question
        QuestionReportAbuse report = new QuestionReportAbuse( QuestionId = opData.questionId, Reason = 'Inappropriate' );
        insert report;

        ret.result = report.Id;

        return ret;
    }



    /*
     * @description
     *  Add/Remove follow for a  question
     * @param questionId @type String
     * @return  Boolean
     */
    public static Object updateSubscription(Object operationData){

        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        replyData ret = new replyData();

        localData opData = validateRequestForChatterAnswers(operationData);
        if (! String.isNotBlank(opData.questionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  question add or remove subscription: record id');



        umSecurityHandler.canAccess(
                    new Schema.SObjectType[] {QuestionSubscription.sObjectType});

        //check if the user is already following

        list<QuestionSubscription> subscriptionList = [Select QuestionId,SubscriberId
                                                            from QuestionSubscription
                                                            where SubscriberId = :Userinfo.getUserId()
                                                            and QuestionId = :opData.questionId limit 1 ];

        if (subscriptionList.isEmpty()){
            //create
            umSecurityHandler.canCreate(
                    new Schema.SObjectType[] {QuestionSubscription.sObjectType});

            QuestionSubscription qS = new QuestionSubscription( SubscriberId = Userinfo.getUserId() ,
                                                                QuestionId = opData.questionId );
            insert qS;

        }else{

            //remove the control until we are able to read the proper permissions
            // or the permissions are consistent with the community
            /*umSecurityHandler.canDelete(
                    new Schema.SObjectType[] {QuestionSubscription.sObjectType});
            */
            delete subscriptionList;
        }

        ret.result = '';

        return ret;
    }


    /*
     * @description
     *  Add new reply
     * @param questionId @type String
     * @param replyBody  @type String
     * @return  Boolean
     */
    public static Object addReply(Object operationData){

        replyData ret = new replyData();

        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        Map<String, Object> source = (Map<String, Object>)operationData;
        system.debug('\n\n umChatterAnswerModel addReply :\n'+source);
        Boolean isPrivate   = Boolean.valueOf(source.get('isPrivate'));
        String questionId   =  String.valueOf(source.get('questionId'));
        String caseId       =  String.valueOf(source.get('caseId'));
        String body  = String.valueOf(source.get('Body'));

        if (!isPrivate){
            questionId = String.escapeSingleQuotes(questionId);

             umSecurityHandler.canCreate(
                    new Schema.SObjectType[] {Reply.sObjectType});

            //check if the question id is valid
            Question q = [select Id, BestReplyId from Question where id =: questionId];

            body = sanitizeReplyBody(body, true);
            Reply r = new Reply ( QuestionId = q.Id, Body = body );
            insert r;

            ret.publicReplies = getPublicRepliesList(questionId, r.Id );
        }else{

            if (String.isNotBlank(questionId) && !String.isNotBlank(caseId)){
                //check if the question id is valid
                Question q = [select Id, (Select Id from Cases ) from Question where id =: questionId];
                if (!q.Cases.isEmpty()){
                     caseId  = q.Cases[0].Id;
                }
            }
            if (String.isNotBlank(caseId)){
                caseId = String.escapeSingleQuotes(caseId);
            }
            //body = sanitizeReplyBody(body, false);
            ret.privateReplies = umCasesModel.addPrivateReply(caseId,body);
        }
        return ret;

    }




    public static Object addLikeVoteReply (Object operationData){

        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        localData opData = validateRequestForChatterAnswers(operationData);
        if (! String.isNotBlank(opData.replyId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  reply add like : record id');

        Reply record = [Select Id from Reply where id =:opData.replyId ];

        return addVote(record.Id);

    }


    private static Object addVote(Id recordToLike){

        replyData ret = new replyData();

        //check create permissions
        umSecurityHandler.canCreate(
            new Schema.SObjectType[] {Vote.sObjectType});


        //Let's check if user already have a vote this question
        list<Vote> voteList = [Select Id From Vote where ParentId = :recordToLike AND CreatedById = :Userinfo.getUserId() limit 1];
        if ( voteList.size() > 0 ){
             throw new umProxy.umException('User already voted this element');
        }

        Vote v = new Vote( ParentId = recordToLike, Type = 'Up' );
        insert v;

        ret.result = v.Id;

        return ret;

    }



    /*
     * @description
     *  Add a Abuse Report to a question
     * @param questionId @type String
     * @return  Object with ReplyReportAbuse record Id on the result
     */
    public static Object addReportOnReply(Object operationData){


        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        replyData ret = new replyData();

        localData opData = validateRequestForChatterAnswers(operationData);
        if (! String.isNotBlank(opData.replyId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  reply  Abuse Report: record id');

        //check create permissions
        umSecurityHandler.canCreate(
            new Schema.SObjectType[] {ReplyReportAbuse.sObjectType});


        //Let's check if user already have a reported this  question
        list<ReplyReportAbuse> reports = [Select Id From ReplyReportAbuse where ReplyId = :opData.replyId AND CreatedById = :Userinfo.getUserId() limit 1];
        if ( reports.size() > 0 ){
             throw new umProxy.umException('User already flagged this reply');
        }

        //add  report for given question
        ReplyReportAbuse report = new ReplyReportAbuse( ReplyId = opData.replyId, Reason = 'Inappropriate' );
        insert report;

        ret.result = report.Id;

        return ret;
    }


    /*
     * @description
     *  Add a Abuse Report to a question
     * @param questionId @type String
     * @return  Object with ReplyReportAbuse record Id on the result
     */
    public static Object selectAsBestAnswer(Object operationData){
       //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        replyData ret = new replyData();

        localData opData = validateRequestForChatterAnswers(operationData);

        if (! String.isNotBlank(opData.questionId) && ! String.isNotBlank(opData.replyId) )
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  choosing best answer');

        list<Question> questions = [Select Id from Question where CreatedById = :Userinfo.getUserId() and Id = :opData.questionId limit 1];

        if (questions.isEmpty() )
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Question Id does not correspond to a record');


        //check if the replyId and the questionId relation is ok
        if (opData.replyId == '-1'){
            //just remove best Answer
             Answers.setBestReply(opData.questionId,null);

        }else{
            //Let's check if the answer belongs to the question
            list<Reply> replies = [Select Id from Reply where QuestionId = :opData.questionId and Id = :opData.replyId limit 1];
            if (questions.isEmpty() )
             throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Reply  Id does not correspond to a record');

            Answers.setBestReply(opData.questionId,opData.replyId);

        }

        ret.publicReplies = getPublicRepliesList(opData.questionId , null);

        return ret;
    }




    private static list<Object> getPublicRepliesList( String questionId, String replyId){

        list<Object> res = new list<Object>();


        //check if the question id is valid
        Question q = [select Id, BestReplyId,createdById from Question where id =: questionId];


        //Getting public replies
        String soql =  ' SELECT Body,CreatedDate,Id,QuestionId,UpVotes,VoteTotal,createdById, CreatorFullPhotoUrl,'+
                ' CreatorName,CreatorSmallPhotoUrl,'+
                ' (Select Id from Votes v where Type = \'up\' and CreatedById = \''+Userinfo.getUserId()+'\'), '+
                ' (Select Id From ReplyReportAbuses where CreatedById = \''+Userinfo.getUserId()+'\' ) '+
                ' FROM Reply WHERE ';

         soql += String.isNotBlank(replyId) ? ' id = \''+replyId+'\' AND ' :'';
         soql += ' QuestionId = \''+q.Id+'\' '+
                 ' order by CreatedDate DESC '+
                 ' limit 100';

        system.debug('\n\n=========== getPublicRepliesList : '+soql);

        list<Object> resultData = Database.query(soql);

        //process replies
        for ( Object source : resultData){

                String qString = JSON.serialize(source);
                Map<String, Object> rMap = (Map<String, Object>) JSON.deserializeUntyped(qString);

                Reply rObj = (Reply) source;

                Datetime d = rObj.CreatedDate;
                String datetimeStr = d.format('MMMM d,  yyyy');
                Integer likeIt = rObj.Votes.size();
                Integer reports = rObj.ReplyReportAbuses.size();
                Long elap = Datetime.now().getTime() - d.getTime();

                rMap.put('CreatedDateText',datetimeStr);
                rMap.put('CreatedDateElap',String.valueOf( elap ));
                rMap.put('CreatedDate',String.valueOf( d.getTime() ));

                rMap.put('LikeIt',  (likeIt > 0)  );
                rMap.put('FlaggedIt', (reports > 0)   );
                rMap.put('isBestAnswer', (rObj.Id == q.BestReplyId)   );
                rMap.put('IAmAuthor', (rObj.createdById == UserInfo.getUserId()) );
                rMap.put('IAmQuestionAuthor', (q.createdById == UserInfo.getUserId()) );
                rMap.put('QuestionId', q.Id );
                rMap.put('isPrivate',false);
                rMap.put('isAgent',umController.zoneModeratorById.containsKey(rObj.createdById));
                res.add((Object)rMap);

                system.debug('\n\n   getPublicRepliesList loop  ======>\n'+rMap);
        }

        return res;

    }

/*
    private static list<Object> getPrivateRepliesList( String caseId,  String caseCommentId){

        list<Object> res = new list<Object>();

        //getting private messages

        String soql =   ' SELECT Id, CreatedDate, CommentBody, ParentId, CreatorFullPhotoUrl, CreatorName, CreatorSmallPhotoUrl '+
                        ' FROM CaseComment '+
                        ' WHERE ';
                soql += String.isNotBlank(caseCommentId) ? ' id = \''+caseCommentId+'\' AND ' :'';
                soql += ' ParentId =\''+caseId+'\' ' +
                        ' order by CreatedDate ASC ';
                system.debug('\n\n getQuestionDetail PRIVATE QUERY=====: \n'+caseId);

        list<Object> resultData = Database.query(soql);

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
                rMap.put('isPrivate',true);
                rMap.put('isAgent',umController.zoneModeratorById.containsKey(rObj.createdById));

                res.add((Object)rMap);

                system.debug('\n\n   getPrivateRepliesList loop  ======>\n'+rMap);
        }
        return res;

    }
    */


    /**
      * @description
      *  Build a map containing reputation details
      * @param source --  type
      * @return  object
    **/
    public static map<String,Object> getUserStatistics(String userId, String commId){

        map<String,Object> userMap = new map<String,Object>();
        Integer totalQuestions = 0, totalAnwers = 0, totalLikes = 0;

        String sql =    ' SELECT    '+
                        ' SUM(QuestionsCount) totalQuestions ,SUM(RepliesCount)  totalReplies, '+
                        ' SUM(QuestionUpVotesReceivedCount) totalLikes '+
                        ' FROM ChatterAnswersActivity where UserId = \''+ENCODE(userId)+'\''+
                        ' group by userId ';
        AggregateResult[] aggr = Database.query(sql);

        if ( aggr.size() > 0 ){
            totalQuestions = Integer.valueOf(aggr[0].get('totalQuestions'));
            totalAnwers =  Integer.valueOf(aggr[0].get('totalReplies'));
            totalLikes =  Integer.valueOf(aggr[0].get('totalLikes'));
        }

        userMap.put('Questions',(Object)totalQuestions);
        userMap.put('Answers',(Object)totalAnwers);
        userMap.put('Likes',(Object)totalLikes);

        //
        list<Question> lQ = [Select CreatorName,CreatorSmallPhotoUrl from Question where CreatedById = :userId limit 1];
        list<Reply> lR = (lQ.size() == 0) ? [Select CreatorName,CreatorSmallPhotoUrl from Reply where CreatedById = :userId limit 1] : new list<Reply>();
        list<Case> lC = (lQ.size() == 0 && lR.size() == 0) ? [Select CreatorName,CreatorSmallPhotoUrl from Case where CreatedById = :userId limit 1] : new list<Case>();
        list<CaseComment> lCC = (lQ.size() == 0 && lR.size() == 0 && lC.size() == 0) ? [Select CreatorName,CreatorSmallPhotoUrl from CaseComment where CreatedById = :userId limit 1] : new list<CaseComment>();

        String uPhoto = lQ.size() > 0 ? lQ[0].CreatorSmallPhotoUrl : lR.size() > 0 ? lR[0].CreatorSmallPhotoUrl : lC.size() > 0 ? lC[0].CreatorSmallPhotoUrl : lCC.size() > 0 ? lCC[0].CreatorSmallPhotoUrl : null;
        String uName = lQ.size() > 0 ? lQ[0].CreatorName : lR.size() > 0 ? lR[0].CreatorName : lC.size() > 0 ? lC[0].CreatorName : lCC.size() > 0 ? lCC[0].CreatorName : null;

        //if there are no Photo and Name check if
        if (uPhoto == null && uName== null && Userinfo.getUserId() == userId){

            User loggedUser = [SELECT ContactId,Id,SmallPhotoUrl,UserType FROM User where id=:userId ];
            uName = Userinfo.getName();
            //if photo was not retrieved elsewhere
            if (String.isNotBlank(loggedUser.SmallPhotoUrl)){
                uPhoto = loggedUser.SmallPhotoUrl;
            }
        }

        userMap.put('uPhoto',(Object)uPhoto);
        userMap.put('uName',(Object)uName);

        return userMap;

    }


    private static Object prepareRecordForResponse(Object source){

        String qString = JSON.serialize(source);
        Map<String, Object> qMap = (Map<String, Object>) JSON.deserializeUntyped(qString);

        Question qObj = (Question) source;

        Datetime d = qObj.CreatedDate;
        String datetimeStr = d.format('MMMM d, yyyy');
        Integer likeIt = qObj.Votes.size();
        Integer subscriptions = qObj.Subscriptions.size();
        Integer reports = qObj.QuestionReportAbuses.size();

        Long elap = Datetime.now().getTime() - d.getTime();
        qMap.put('CreatedDateText',datetimeStr);
        qMap.put('CreatedDateElap',String.valueOf( elap ));
        qMap.put('CreatedDate',String.valueOf( d.getTime() ));
        qMap.put('LikeIt',  (likeIt > 0)  );
        qMap.put('FollowingIt', (subscriptions > 0)  );
        qMap.put('FlaggedIt', (reports > 0)   );
        qMap.put('Subscriptions',null);
        qMap.put('Votes',null);
        qMap.put('ElementType','Question');
        qMap.put('IAmAuthor', (qObj.createdById == UserInfo.getUserId()) );
        //Resolving if it's a customer agent
        ID authorId =  qObj.CreatedById ;
        qMap.put('isAgent',umController.zoneModeratorById.containsKey(authorId));

        //Resove DataCategory selection
        if (qObj.DataCategorySelections != null){

            system.debug('\n\n prepareRecordForResponse ======>\n'+qObj.DataCategorySelections);
            List<QuestionDataCategorySelection> listD = qObj.DataCategorySelections;
            if (!listD.isEmpty()){
                system.debug('\n\n data C selection : =====>\n'+listD.get(0).DataCategoryName);
                qMap.put('DataCategorySelection',listD.get(0).DataCategoryName);
            }
            //DataCategoryName
            qMap.remove('DataCategorySelections');
        }
        source = (Object)qMap;
        system.debug('\n\n THE prepareRecordForResponse ======>\n'+source);
        return source;
    }


   /**
      * @description
      *  Tokenizes search string word0 word1 word2 and builds new string word0 OR word1 Or word2
      * @param qString -- String type
      * @return newQString String
      **/

    private static String topicsForDataCategories(String rootDC, String qString){
        String finalStr = '';

        if (!String.isNotBlank(qString)) return null;

        List<String> selectedCategorySOSL = new List<String>();
        List<String> selectedCategoryTokens = qString.split(',');

        for (String s : selectedCategoryTokens) {
            if (String.isNotBlank(s)){
                if ( finalStr != ''){
                    finalStr += ' AND ';
                }
                finalStr +=  rootDC +' BELOW ' +s+ '__c';
                system.debug( '\n===== ' +s);
            }

        }

        system.debug('\n======== rootDC '+finalStr);

        return finalStr;
    }


    /* sanitize methods*/


    /*
     * @description
     *  Sanitizes body of question :
     * @param element @string
     * @return String
     */
    public static String sanitizeQuestionTitle(String origStr, Boolean isPublic){

        String res = origStr;//.escapeHtml4();
        system.debug('\n\n=======sanitizeQuestionTitle '+isPublic+' IN =: '+origStr +' OUT: '+res);
        return res;
    }



    /*
     * @description
     *  Sanitizes body of question :
     * @param element @string
     * @return String
     */
    public static String sanitizeQuestionBody(String origStr, Boolean isPublic){

        String res = origStr;//.escapeHtml4();
        res = escapeNewLines(res);
        if (isPublic){
            res = replaceUrlsByLink(res);
        }


        system.debug('\n\n=======sanitizeQuestionBody '+isPublic+' IN =: '+origStr +' OUT: '+res);
        return res;
    }

    /*
     * @description
     *  Sanitizes body of reply :
     * @param element @type map<String,Object>
     * @return void
     */
    public static String sanitizeReplyBody(String origStr, Boolean isPublic){
        String res = '';

        if (isPublic){
            system.debug('\n\n=======sanitizeReplyBody [0] '+origStr);
            res = origStr;//.escapeHtml4();
            system.debug('\n\n=======sanitizeReplyBody [1] '+res);
            res = escapeNewLines(res);
            system.debug('\n\n=======sanitizeReplyBody [2] '+res);
            res = replaceUrlsByLink(res);
            system.debug('\n\n=======sanitizeReplyBody [3] '+res);

        }else{

            res = origStr.escapeHtml4();
            res = escapeNewLines(res);
            /* for Rich Text Disable : replace plain urls by links*/
            if (!Boolean.valueOf(umProxy.siteSettings.get('umChatterAnswers_richTextEnabled__c'))){
                  res = replaceUrlsByLink(res);
            }
        }

system.debug('\n\n=======sanitizeReplyBody '+isPublic+' IN =: '+origStr +' out: '+res);

        return res;
    }

    /*
    * @description
    * Replaces newlines by new line html tag
    * @param origString @type String
    * @return  String
    */
    public static String escapeNewLines(String origString){

        String res = origString;
            //sanitize
        res = res.replaceAll('\n','<br/>');
        res = res.replaceAll('\r','<br/>');

        return res;
    }

    /*
    * @description
    * Replaces plain urls by links
    * @param origString @type String
    * @return  String
    */
    public static String replaceUrlsByLink(String origString){

        List<String> s = origString.split(' ');
        String finalResult = '';

        String res = '';
        try {
            Pattern patt = Pattern.compile('(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:\'\".,<>???“”‘’]))');
            for (String str : s){

                Matcher matcher = patt.matcher(str);
                if(matcher.find()){

                    if (matcher.group(1).startsWith('http://')|| matcher.group(1).startsWith('https://')){
                        res = matcher.replaceAll('<a href=\'$1\'  target=\'_blank\'>$1</a>');
                    }else{
                        res = matcher.replaceAll('<a href=\'http://$1\'  target=\'_blank\'>$1</a>');
                    }
                }else{
                    res = str;
                }
                finalResult = finalResult +' '+ res;
            }
        } catch (Exception e) {
            finalResult = origString;
        }

        if (finalResult.length() >=  Schema.SObjectType.Question.fields.Body.getLength() ){
            finalResult = origString.replaceAll('<br>','\n').replaceAll('<br/>','\n');
        }


        return finalResult;
    }


    public static String ENCODE(String input) {
        return String.escapeSingleQuotes(input);
    }


}