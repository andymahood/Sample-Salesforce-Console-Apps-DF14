/**
 * @author Altimetrik
 * @description
 *      started at 8/14/2012
 *      Unit Tests for umCasesModel
 **/
@isTest
private class umChatterAnswerModelTest {

    static Community aCommunity;
    static Question aQuestion;
    static QuestionDataCategorySelection aQDataCategory;


    static void populateQATestEnvironment(){
        umTestEnvironment.initData();
        /*
            due to this error still present on api 28.0
            DML operation INSERT not allowed on Community
        */


        try{
            aQuestion = [Select Id, CommunityId, Body, UpVotes, NumSubscriptions from Question where Origin = 'Chatter Answers' limit 1];
            aCommunity = [Select Id,Name from Community where Id = :aQuestion.CommunityId limit 1];
            aQDataCategory = [Select DataCategoryName,DataCategoryGroupName from QuestionDataCategorySelection where ParentId = :aQuestion.Id];
            umProxy.CAM_ROOT_GROUP_NAME_SIMPLE = aQDataCategory.DataCategoryGroupName;

        }
        catch(Exception e){
            throw new umTestEnvironment.umTestException('Service Cloud Mobile App Test Methods: In order to run the App test methods you must have Chatter Answers properly set up and a Community ');
        }

    }


    @isTest(SeeAllData=true)
    static  void test_getQuestions(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        //invalid parameter
        params.put('offset', 'e');
        try{
            Object res = umChatterAnswerModel.getQuestionDetail((Object)params);
        }catch(umProxy.umException uEx){
            system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel'));
        }
        params.remove('offset');

        Object res;
        Object req = (Object)params;
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        //missing parameters
        try{

 system.debug('\n\n=========SORT BY ='+params.get('sortBy'));

            res = umChatterAnswerModel.getQuestions(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel'));
        }

        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        req = (Object)params;
        res = umChatterAnswerModel.getQuestions(req);

        system.debug('\n\n=========='+res);
        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);

        //check result
        Object resultObj = results.get('resultList');
        String tmpS = JSON.serialize(resultObj);
        list<Object> tmpL = (list<Object>) JSON.deserializeUntyped(tmpS);
        system.assert( tmpL.size()>=1);

        //wrong parameters
        params.put('communityId',null);
        try{
            res = umChatterAnswerModel.getQuestions(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel'));
        }

    }

    @isTest(SeeAllData=true)
    static  void test_searchQuestions(){
        populateQATestEnvironment();

        Id [] fixedSearchResults= new Id[]{aQuestion.Id};
        Test.setFixedSearchResults(fixedSearchResults);

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('searchInput','text');
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        Object req = (Object)params;
        Object res = umChatterAnswerModel.searchQuestions(req);

        system.debug('\n\n=========='+res);
        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);

        //check result
        Object resultObj = results.get('resultList');
        String tmpS = JSON.serialize(resultObj);
        list<Object> tmpL = (list<Object>) JSON.deserializeUntyped(tmpS);
        system.assertEquals(1, tmpL.size() );

        //wrong parameters
        params.remove('searchInput');
        try{
            res = umChatterAnswerModel.searchQuestions(req);
        }catch(umProxy.umException uEx){system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel search'));
        }
    }

    @isTest(SeeAllData=true)
    static  void test_Question_CRUD(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        Object req = (Object)params;
        Object res;

        //wrong parameters
        try{
            res = umChatterAnswerModel.createQuestion(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  createQuestion'));
        }

        params.put('CommunityId',aCommunity.Id);
        params.put('Type','public');
        params.put('Title','this a new impossible test title');
        params.put('Body','this a new impossible test body');
        params.put('Topic',aQDataCategory.DataCategoryName);

        res = umChatterAnswerModel.createQuestion(req);
        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //check result
        Object resultObj = results.get('result');
        String tmpS = JSON.serialize(resultObj);
        String newQuestionId = (String) JSON.deserializeUntyped(tmpS);

        //get QuestionDetail
        params.put('questionId',newQuestionId);
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        req = (Object)params;
        res = umChatterAnswerModel.getQuestionDetail(req);
        Map<String, Object> resultsQD = umTestEnvironment.objectToMap(res);
        system.assert(resultsQD!= null);

        //check result
        resultObj = resultsQD.get('result');
        Map<String, Object> tmpQL = umTestEnvironment.objectToMap(resultObj);
        String responseBody = String.valueOf(tmpQL.get('Body'));
        system.assertEquals('this a new impossible test body', responseBody);


        //addReply
        source =  umChatterAnswerModel.getResponseModel();
        params = umTestEnvironment.objectToMap(source);
        params.put('questionId',newQuestionId);
        params.put('isPrivate',false);
        params.put('Body','a body');

        res = umChatterAnswerModel.addReply((Object)params);
        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        Reply r = [Select Id , Body from Reply where QuestionId=: newQuestionId order by CreatedDate desc limit 1];
        system.assertEquals(r.Body, params.get('Body'));

        //add like vote
        //1 - like vote without reply id


        try{
            res = umChatterAnswerModel.addLikeVoteReply((Object)params);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  reply add like : record id'));
        }
        List<Reply> l = [Select Id , Body from Reply where CreatedById !=: Userinfo.getUserId()  limit 1];
        if (!l.isEmpty()){
            Reply r2 = l.get(0);

            //2 - normal case
            params.put('replyId',r2.Id);
            res = umChatterAnswerModel.addLikeVoteReply((Object)params);
            results = umTestEnvironment.objectToMap(res);
            system.assert(results!= null);

            list<Vote> voteList = [Select Id From Vote where ParentId = :r2.Id AND CreatedById = :Userinfo.getUserId() limit 1];
            system.assert(voteList.size() ==1);

            //3 - duplicated vote
            try{
                res = umChatterAnswerModel.addLikeVoteReply((Object)params);
            }catch(umProxy.umException uEx){
                system.assert(uEx.getMessage().contains('User already voted this element'));
            }


        }


        //select as best anser
        //1 -  without reply id
        params.remove('replyId');
        try{
            res = umChatterAnswerModel.selectAsBestAnswer((Object)params);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  choosing best answer'));
        }
        //2- invalid question id
        params.put('questionId',Userinfo.getUserId());
        try{
            res = umChatterAnswerModel.selectAsBestAnswer((Object)params);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Question Id does not correspond to a record'));
        }
        //3 - valid flow
        params.put('replyId',r.Id);
        params.put('questionId',newQuestionId);
        res = umChatterAnswerModel.selectAsBestAnswer((Object)params);
        results = umTestEnvironment.objectToMap(res);
        Question q = [Select id, BestReplyId from Question where id =: newQuestionId];
        system.assert(q.BestReplyId == r.Id);



        //add report on Reply
        //1 - report vote without reply id
        params.remove('replyId');
        try{
            res = umChatterAnswerModel.addReportOnReply(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  reply  Abuse Report: record id'));
        }


        //2- valid flow
        params.put('replyId',r.Id);
        res = umChatterAnswerModel.addReportOnReply((Object)params);
        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);
        list<ReplyReportAbuse> reports = [Select Id From ReplyReportAbuse where ReplyId = : r.Id AND CreatedById = :Userinfo.getUserId() limit 1];
        system.assert(reports.size() ==1);

        //3 - duplicated report
        try{
            res = umChatterAnswerModel.addReportOnReply((Object)params);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('User already flagged this reply'));
        }

    }



    @isTest(SeeAllData=true)
    static  void test_getQuestionDetail(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('questionId',aQuestion.Id);
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        Object req = (Object)params;
        Object res = umChatterAnswerModel.getQuestionDetail(req);

        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);

        //check result
        Object resultObj = results.get('result');
        String tmpS = JSON.serialize(resultObj);
        Map<String, Object> tmpL = (Map<String, Object>) JSON.deserializeUntyped(tmpS);
        String responseBody = String.valueOf(tmpL.get('Body'));
        system.assertEquals(aQuestion.Body, responseBody);

        //wrong parameters
        params.remove('questionId');
        try{
            res = umChatterAnswerModel.getQuestionDetail(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umChatterAnswerModel Question Detail View'));
        }

    }

    /*
        Actions over question retrieved on populateQATestEnvironment
    */

    @isTest(SeeAllData=true)
    static  void test_addLikeVote(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('questionId',aQuestion.Id);
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        //add Like Vote
        Object req = (Object)params;
        Object res = umChatterAnswerModel.addLikeVote(req);

        system.debug('\n\n=========='+res);
        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);

        //get Details and check number of UpVotes
        res = umChatterAnswerModel.getQuestionDetail(req);
        resString = JSON.serialize(res);
        results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);
        //check result
        Object resultObj = results.get('result');
        String tmpS = JSON.serialize(resultObj);
        Map<String, Object> tmpL = (Map<String, Object>) JSON.deserializeUntyped(tmpS);
        Integer UpVotes = Integer.valueOf(tmpL.get('UpVotes'));
        system.assertEquals((aQuestion.UpVotes + 1), UpVotes);
    }

   /*
        Actions over question retrieved on populateQATestEnvironment
    */

    @isTest(SeeAllData=true)
    static  void test_updateSubscription(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('questionId',aQuestion.Id);
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        //add Like Vote
        Object req = (Object)params;
        Object res = umChatterAnswerModel.updateSubscription(req);

        system.debug('\n\n=========='+res);
        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //get Details and check number of NumSubscriptions
        res = umChatterAnswerModel.getQuestionDetail(req);
        String resString = JSON.serialize(res);
        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);
        //check result
        Object resultObj = results.get('result');
        Map<String, Object> tmpL = umTestEnvironment.objectToMap(resultObj);
        Integer NumSubscriptions = Integer.valueOf(tmpL.get('NumSubscriptions'));
        system.assertEquals((aQuestion.NumSubscriptions + 1), NumSubscriptions);

        //remove subscription
        res = umChatterAnswerModel.updateSubscription(req);

        system.debug('\n\n=========='+res);
        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //get Details and check number of NumSubscriptions
        res = umChatterAnswerModel.getQuestionDetail(req);
        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);
        //check result
        resultObj = results.get('result');
        tmpL = umTestEnvironment.objectToMap(resultObj);
        NumSubscriptions = Integer.valueOf(tmpL.get('NumSubscriptions'));
        system.assertEquals(aQuestion.NumSubscriptions , NumSubscriptions);

    }


    /*
        Actions over question retrieved on populateQATestEnvironment
    */
    @isTest(SeeAllData=true)
    static  void test_addReportOnQuestion(){
        populateQATestEnvironment();

        Object source =  umChatterAnswerModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('questionId',aQuestion.Id);
        params.put('communityId',aCommunity.Id);
        params.put('sortBy', umChatterAnswerModel.sortOptions.get(0));

        //add Like Vote
        Object req = (Object)params;
        Object res = umChatterAnswerModel.addReportOnQuestion(req);


        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //try to report againg
        try{
            res = umChatterAnswerModel.addReportOnQuestion(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('User already flagged this question'));
        }

        //wrong parameters
        params.remove('questionId');
        try{
            res = umChatterAnswerModel.addReportOnQuestion(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for Q and A  question Abuse Report: record id'));
        }

    }


    @isTest(SeeAllData=true)
    static  void test_getUserStatistics(){
        populateQATestEnvironment();

        Object res = umChatterAnswerModel.getUserStatistics(Userinfo.getUserId(),'');

        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);



    }
}