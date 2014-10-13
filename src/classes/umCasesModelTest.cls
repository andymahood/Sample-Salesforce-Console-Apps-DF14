/**
 * @author Altimetrik
 * @description
 *      started at 8/14/2012
 *      Unit Tests for umCasesModel
 **/
@isTest
private class umCasesModelTest {

    static Case aCase;

    static void populateCasesTestEnvironment(){

        aCase = new Case(
            Description = 'test description',
            Subject = 'test subject'
        );
        insert aCase;

        CaseComment cc = new CaseComment ( ParentId = aCase.Id, CommentBody = ' comment test ' );
        insert cc;

    }


    @isTest(SeeAllData=true)
    static  void test_staticAttributes(){
        populateCasesTestEnvironment();
        system.assertNotEquals(null, umCasesModel.sortOptions);
        system.assertNotEquals(null, umCasesModel.statusOptions);

    }


    @isTest(SeeAllData=true)
    static  void test_validateRequestForCases(){
        populateCasesTestEnvironment();

        Object source =  umCasesModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('offset', 'e');

        try{
            Object res = umCasesModel.getCaseDetail((Object)params);
        }catch(umProxy.umException uEx){
            system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel'));
        }


    }

    @isTest(SeeAllData=true)
    static  void test_getCaseDetail(){
        populateCasesTestEnvironment();
        umTestEnvironment.initData();

        Object source =  umCasesModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('caseId',aCase.Id);
        Object req = (Object)params;
        Object res = umCasesModel.getCaseDetail(req);

        Map<String, Object> results = umTestEnvironment.objectToMap(res);

        system.assert(results!= null);

        //check result
        Object resultObj = results.get('result');
        Map<String, Object> tmpM = umTestEnvironment.objectToMap(resultObj);
        system.assertEquals(aCase.Id,String.valueOf(tmpM.get('Id')));
        system.assert(Boolean.valueOf(tmpM.get('IAmAuthor')));

        //check replies
        resultObj = results.get('replies');
        list<Object> tmpL = umTestEnvironment.objectToList(resultObj);
        system.assertEquals(1,tmpL.size());

        params.remove('caseId');
        try{
            res = umCasesModel.getCaseDetail((Object)params);
        }catch(umProxy.umException uEx){
            system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]::: Request format invalid for umCasesModel Case Detail View'));
        }

    }

    @isTest(SeeAllData=true)
    static  void test_addCaseComment(){
        populateCasesTestEnvironment();

        //obtain initial amount of comments
        list<Object> initialCC = umCasesModel.getCaseCommentsList(aCase.Id,null);

        Object res = umCasesModel.addPrivateReply(aCase.Id,'the second comment');

        list<Object> finallCC = umCasesModel.getCaseCommentsList(aCase.Id,null);
        system.assertEquals(initialCC.size()+1, (finallCC.size() ));

    }

    @isTest(SeeAllData=true)
    static  void test_createPrivateQuestion(){

        umTestEnvironment.initData();
        populateCasesTestEnvironment();

        Object res = umCasesModel.createPrivateQuestion(umTestEnvironment.vcommunity.Id,'This new test body','this new title');
        Map<String, Object> results = umTestEnvironment.objectToMap(res);

        system.assert(results!= null);

        //check result
        String cId = String.valueOf(results.get('result'));

        system.assertEquals(1,[Select Id from Case where id =: cId].size());

        //
        Object source =  umCasesModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('authorId',Userinfo.getUserId());
        Object req = (Object)params;
         res = umCasesModel.getPrivateQuestions(req);

        results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);
        //wrong parameters
        params.remove('authorId');
        try{
            res = umCasesModel.getPrivateQuestions(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel get Private Questions'));
        }


        //list<Object> aList = umChatterAnswerModel.getPrivateRepliesList( cId, '');
        //system.assert(aList!= null);

    }

    @isTest(SeeAllData=true)
    static  void test_getCases(){

        populateCasesTestEnvironment();

        Object source =  umCasesModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('authorId', Userinfo.getUserId());

        params.put('sortBy', umCasesModel.sortOptions.get(0));
        params.put('filterBy', umCasesModel.statusOptions.values().get(0));
        Object req = (Object)params;
        Object res = umCasesModel.getCases(req);
        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //wrong parameters
        params.remove('authorId');
        try{
            res = umCasesModel.getCases(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel getCases'));
        }

        //using an author Id different than the currentUser returns empty list
        User u = [Select Id from User limit 1];
        params.put('authorId', u.Id);
        req = (Object)params;
    }


    @isTest(SeeAllData=false)
    static  void test_contactUS(){

        umTestEnvironment.initDataWithoutQAandKB();

        umTestEnvironment.umSite.umContactus_createContactAndAccount__c = false;
        populateCasesTestEnvironment();

        Object source =  umCasesModel.getContactUsResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        Map<String, Object> originOptions = umTestEnvironment.objectToMap(params.get('originOptions'));

        params.put('subject','A test subject');
        params.put('description', 'a simple short description');
        params.put('email', UserInfo.getUserEmail());
        params.put('origin', String.valueOf(originOptions.values().get(0)));


        Object req = (Object)params;
        Object res = umCasesModel.processContactUs(req);

        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //wrong parameters
        params.remove('email');
        try{
            res = umCasesModel.processContactUs(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel ContactUs email field'));
        }

        //contactUs disabled
        umTestEnvironment.umSite.umContactus_enabled__c = false;
        res = umCasesModel.processContactUs(req);
        results = umTestEnvironment.objectToMap(res);
        Boolean isSuccess = Boolean.valueOf(results.get('isSuccess'));
        system.assert(isSuccess);


        // case and account

        umTestEnvironment.umSite.umContactus_createContactAndAccount__c = true;
        params.put('email', UserInfo.getUserEmail());

        res = umCasesModel.processContactUs((Object)params);

       results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);



    }


 @isTest(SeeAllData=false)
    static  void test_contactUS_disabled(){

        umTestEnvironment.initDataWithoutQAandKB();
        populateCasesTestEnvironment();

        Object source =  umCasesModel.getContactUsResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        Map<String, Object> originOptions = umTestEnvironment.objectToMap(params.get('originOptions'));

        params.put('subject','A test subject');
        params.put('description', 'a simple short description');
        params.put('email', UserInfo.getUserEmail());
        params.put('origin', String.valueOf(originOptions.values().get(0)));


        Object req = (Object)params;
        Object res = umCasesModel.processContactUs(req);

        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //wrong parameters
        params.remove('email');
        try{
            res = umCasesModel.processContactUs(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umCasesModel ContactUs email field'));
        }
        // case and account

        umTestEnvironment.umSite.umContactus_createContactAndAccount__c = true;
        params.put('email', UserInfo.getUserEmail());

        res = umCasesModel.processContactUs((Object)params);

       results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);



    }




    @isTest(SeeAllData=true)
    static  void test_markAsCaseResolved(){
        populateCasesTestEnvironment();
        umTestEnvironment.initData();

        Object source =  umCasesModel.getResponseModel();
        Map<String, Object> params = umTestEnvironment.objectToMap(source);

        params.put('caseId',aCase.Id);
        Object req = (Object)params;
        Object res = umCasesModel.markAsCaseResolved(req);

        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

        //check if new status is closed
        Case checkQ = [Select id, Status from Case where id=: aCase.Id];
        system.assertEquals('Closed', checkQ.Status);
        //wrong parameters
        params.remove('caseId');
        try{
            res = umCasesModel.markAsCaseResolved(req);
        }catch(umProxy.umException uEx){
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]::: Request format invalid for umCasesModel Case mark as resolved'));
        }
    }

    @isTest(SeeAllData=true)
    static void test_MobilePhoneCall(){

        umTestEnvironment.initDataWithoutQAandKB();

        BusinessHours bH = [Select Id from BusinessHours where IsDefault = true limit 1];

        DateTime timeToSend = businesshours.addGmt(bH.id, system.now(), 1000 * 60);
        map<String,String> resp = (map<String,String>) umController.getPhoneCallAvailable(timeToSend);
        system.assertEquals( 'true', resp.get('available') );
    }


    @isTest(SeeAllData=true)
    static  void test_getUserStatistics(){
        umTestEnvironment.initDataWithoutQAandKB();

        Object res = umCasesModel.getUserStatistics(Userinfo.getUserId());

        Map<String, Object> results = umTestEnvironment.objectToMap(res);
        system.assert(results!= null);

    }

}