/**
 * @author Altimetrik
 * @description
 *      started at 8/14/2012
 *      Unit Tests for umKnowledgeBaseModel
 **/
@isTest
private class umKnowledgeBaseModelTest {

    static String objType;
    static SObject kavObj;
    static String lang  = KnowledgeArticleVersion.Language.getDescribe().getPickListValues().get(0).getValue();
    static String publishStatus = 'draft';

    static void populateKBTestEnvironment(){

        umTestEnvironment.initData();

        //Getting all allowed kav's for current user
        set<String> allowed = umSecurityHandler.getAllowedKavSet();
        if (!allowed.isEmpty()){
            list<String> lTmp = new list<String>();
            lTmp.addAll(allowed);
            objType = 'FAQ__kav';//lTmp.get(0);
            //remove the namespace
            objType = objType.replace(umController.getNamespace(),'');

            System.debug('\n TEST ENVIRONMENT  CUSTOM ARTICLE TYPE: ' +objType+'=================\n');

            kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
            kavObj.put('Title','SAMPLE foo title!!!');
            kavObj.put('UrlName', 'url-foo-foo');
            kavObj.put('Summary', 'This is a summary!!! for the test article.');
            kavObj.put('Language', lang);
            insert kavObj;

            String q = 'select Id, Title, ArticleNumber, UrlName, Summary, KnowledgeArticleId  from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
            kavObj = (KnowledgeArticleVersion)Database.query(q);
            system.debug('\n\n===== created : '+kavObj.id);
        }


    }


    @isTest(SeeAllData=true)
    static  void test_staticAttributes(){
        populateKBTestEnvironment();
        system.assertNotEquals(null, umKnowledgeBaseModel.sortOptions);
    }


    @isTest(SeeAllData=true)
    static  void test_getArticles(){
        populateKBTestEnvironment();
        Object source =  umKnowledgeBaseModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        //params.put('caseId',aCase.Id);
        system.debug('\n\n=========='+params);

        Object req = (Object)params;
        Object res = umKnowledgeBaseModel.getArticles(req);


        system.debug('\n\n=========='+res);
        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.assert(results!= null);

        //check result
        Object resultObj = results.get('resultList');
        String tmpS = JSON.serialize(resultObj);
        list<Object> tmpL = (list<Object>) JSON.deserializeUntyped(tmpS);
        system.assert( tmpL.size()>=1);

    }

    @isTest(SeeAllData=true)
    static  void test_searchArticles(){
        populateKBTestEnvironment();


        Id [] fixedSearchResults= new Id[]{(Id)kavObj.get('Id')};
        Test.setFixedSearchResults(fixedSearchResults);

        Object source =  umKnowledgeBaseModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('searchInput','text');

        Object req = (Object)params;
        Object res = umKnowledgeBaseModel.searchArticles(req);


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
            res =umKnowledgeBaseModel.searchArticles(req);
        }catch(umProxy.umException uEx){system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]:::Request format invalid for umKnowledgeBaseModel'));
        }

    }


    @isTest(SeeAllData=true)
    static  void test_getFeaturedArticleDetail(){
        populateKBTestEnvironment();

        Object source =  umKnowledgeBaseModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('articleNumber', kavObj.get('ArticleNumber'));

        Object req = (Object)params;
        Object res = umKnowledgeBaseModel.getFeaturedArticleDetail(req);

        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.debug('\n\n=========='+results.get('KnowledgeArticleId'));
        system.assertEquals(kavObj.get('KnowledgeArticleId'), String.valueOf(results.get('KnowledgeArticleId')));

        //wrong parameters
        params.remove('articleNumber');
        try{
            res = umKnowledgeBaseModel.getFeaturedArticleDetail(req);
        }catch(umProxy.umException uEx){system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]::: Request format invalid for KB  Featured Article detail  : articleNumber'));
        }
    }


    @isTest(SeeAllData=true)
    static  void test_getArticleDetail_addLike(){
        populateKBTestEnvironment();

        Object source =  umKnowledgeBaseModel.getResponseModel();
        String qString = JSON.serialize(source);
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(qString);

        params.put('articleId', (Id)kavObj.get('KnowledgeArticleId'));

        Object req = (Object)params;

 system.debug('\n\n=======req ==='+req);

        Object res = umKnowledgeBaseModel.getArticleDetail(req);

        String resString = JSON.serialize(res);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.debug('\n\n=========='+results.get('ArticleNumber'));
        system.assertEquals(kavObj.get('ArticleNumber'), String.valueOf(results.get('ArticleNumber')));


        Integer initialLikes = Integer.valueOf(results.get('Likes'));
        Boolean initialLikeIt = Boolean.valueOf(results.get('LikeIt'));


        //add like Vote
        params.put('articleVersionId', (Id)kavObj.get('Id'));
        req = (Object)params;
        res = umKnowledgeBaseModel.addLikeVote(req);

        //request detail again
        params = (Map<String, Object>) JSON.deserializeUntyped(qString);
        params.put('articleId', (Id)kavObj.get('KnowledgeArticleId'));

        req = (Object)params;
        res = umKnowledgeBaseModel.getArticleDetail(req);


        resString = JSON.serialize(res);
        results = (Map<String, Object>) JSON.deserializeUntyped(resString);
        system.debug('\n\n=========='+results.get('ArticleNumber'));

        Integer finalLikes = Integer.valueOf(results.get('Likes'));
        Boolean finalLikeIt = Boolean.valueOf(results.get('LikeIt'));

        system.assertEquals( (initialLikes + 1 ) , finalLikes);
        system.assertEquals( initialLikeIt, !finalLikeIt);

        //wrong parameters
        params.remove('articleId');
        try{
            res = umKnowledgeBaseModel.getArticleDetail(req);
        }catch(umProxy.umException uEx){system.debug('\n\n=========='+uEx.getMessage());
            system.assert(uEx.getMessage().contains('[INVALID_REQUEST_FORMAT]::: Request format invalid for KB  Article detail : articleId'));
        }

    }


}