/**
 * @author Altimetrik
 * @description
 *    started on 06/25/2013
 *    Model for all Knowledge Base operations on the Service Cloud Mobile Self-Service App
 **/
global with sharing class umKnowledgeBaseModel {

    /*
     * @description
     *  Dealing with restrictions in unit testing about knowledgeArticles publishStatus
     */
    static String publishStatus = Test.isRunningTest() ? 'Draft' : 'Online';

    /*
     * @description
     *  array that contains sorting options to be used in the front-end filters
     * @return list of strings
     */
    public  static set<String>  sortOptions{
        get{
            if (null == sortOptions ) {
                sortOptions = new set<String>{'sortBy_LAST_PUBLISHED'};
            }
            return sortOptions;
        }
        private set;
    }


    /*
     * @description
     *  this inner class holds the structure for the requests from front-end
     */
    private  class localData{

        public String   lang = 'en_US';
        public String   communityId;
        public String   topicName;
        public String   searchInput;
        public String   sortBy;
        public String   articleNumber;
        public String   articleId;
        public String   articleVersionId;
        public Integer  queryLimit = 10;
        public Integer  offset = 0;

        public localData (){
            lang        = 'en_US';
            communityId = '';
            topicName = '';
            sortBy = '';
            searchInput = '';
            articleNumber = '';
            articleId = '';
            articleVersionId='';
        }

        public localData (Map<String, Object> source){

            system.debug('\n\n localData :\n'+source);

            if (!source.containsKey('communityId') )
                communityId = '-1';
            else{
                  communityId = String.escapeSingleQuotes(String.valueOf(source.get('communityId')));
                  if (!String.isNotBlank(communityId))
                        communityId = '-1';

            }


system.debug('\n\n localData  communityId :['+communityId+']');


            if (!source.containsKey('lang'))
                lang = umProxy.DEFAULT_LANGUAGE;
            else
                lang = String.escapeSingleQuotes(String.valueOf(source.get('lang')));

            if (source.containsKey('topicName')){
                topicName = String.valueOf(source.get('topicName'));
                if (String.isNotBlank(topicName) && topicName != '-1'){
                    topicName = String.escapeSingleQuotes(String.valueOf(source.get('topicName')));
                    topicName = umController.topicsForDataCategories(topicName);
                }else{
                    if (communityId != '-1' ){
                        umZone__c uZ = [ SELECT dataCategory__c
                                            FROM umZone__c
                                            WHERE zone__c =: communityId limit 1];
                        topicName = umController.topicsForDataCategories(uZ.dataCategory__c);
                    }else{
                        topicName = '-1';
                    }
                }
            }

            /* sorting */
            sortBy = 'LastPublishedDate';

            /*search string*/
            if (source.containsKey('searchInput')){
                    searchInput = String.escapeSingleQuotes(String.valueOf(source.get('searchInput')));
                    searchInput = umController.process_SearchString(searchInput);
            }

            /* article Id */
            if (source.containsKey('articleId')){
                articleId = String.valueOf(source.get('articleId'));
                if (String.isNotBlank(articleId)){

                    KnowledgeArticleVersion kA  =  Database.query(  ' SELECT Id,KnowledgeArticleId '+
                                                                    ' FROM KnowledgeArticleVersion '+
                                                                    ' WHERE KnowledgeArticleId =\''+articleId+'\' '+
                                                                    ' AND  PublishStatus=\''+publishStatus+'\' AND language =\'en_US\' '+
                                                                    ' order by VersionNumber desc '+
                                                                    ' limit 1');
                    articleVersionId = kA.Id;
                }
            }

            /* articleNumber  */
            if (source.containsKey('articleNumber')){
                articleNumber = String.valueOf(source.get('articleNumber'));
                if (String.isNotBlank(articleNumber))
                    articleNumber = String.escapeSingleQuotes(articleNumber);
            }

            //articleList offset
            if (source.containsKey('offset')){
                offset = Integer.valueOf(source.get('offset'));
            }else
                offset = 0;
            system.debug('\n\n umKnowledgeBaseModel request :\n'+this);

        }

    }

    /*
     * @description
     *  this inner class holds the structure for the response format to front-end
     */
    private  class replyData{
        public Object   resultList;
        public Object   result;
        public Integer   offset;
        public Boolean   hasMore;
    }

    private static localData validateRequestForKB (Object operationData){
        localData data;
        try{
            data = new localData((Map<String, Object>)operationData);
        }catch(Exception e){
            system.debug('\n\n HORROR on KB :\n'+e.getMessage()+'\n=========\n'+ e.getStackTraceString());
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umKnowledgeBaseModel \n=========\n'+ e.getStackTraceString());
        }
        return data;

    }


    public static Object getResponseModel(){
        return new localData();
    }


    /**
    * @description
    *   returns list of articles
    * @param localData - operationData {community, dataCategory}
    * @return Object response
    **/
    public static Object getArticles(Object operationData){
        replyData ret = new replyData();
        localData opData = validateRequestForKB(operationData);

        //Getting all allowed kav's for current user
        String allowed = umSecurityHandler.getAllowedKav() != null ? 'and ArticleType IN ('+umSecurityHandler.getAllowedKav()+') ' : null;

        String query =  ' Select Id, KnowledgeArticleId, Title, CreatedDate, LastPublishedDate, Summary '+
                        ' from KnowledgeArticleVersion '+
                        '  WHERE PublishStatus=\''+publishStatus+'\' AND language =\'en_US\' '+
                         allowed ;
                /* data categories restriction */
                query += opData.topicName != '-1' ? ' WITH DATA CATEGORY '+opData.topicName :'';
                query += ' ORDER BY LastPublishedDate DESC ';
                query += ' LIMIT '+(opData.queryLimit + 1 );
                query += ' OFFSET '+opData.offset;

            system.debug('\n\n umKnowledgeBaseModel ===> getArticles :\n'+query);
            list<Object> results = Database.query(query);
            ret.hasMore = ( (opData.queryLimit + 1 ) == results.size() );

            ret.resultList = prepareRecordsForResponse(results , opData.queryLimit);
            ret.offset = opData.offset + ((list<Object>)ret.resultList).size();
            return ret;
        }

    /**
    * @description
    *   returns list of articles filtering by searchInput
    * @param localData - operationData
    * @return Object response
    **/
    public static Object searchArticles(Object operationData){
        replyData ret = new replyData();
        list<Object> res = new list<Object>();

        localData opData = validateRequestForKB(operationData);

        if (! String.isNotBlank(opData.searchInput))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for umKnowledgeBaseModel');

        //Getting all allowed kav's for current user
        String allowed = umSecurityHandler.getAllowedKav() != null ? 'and ArticleType IN ('+umSecurityHandler.getAllowedKav()+') ' : null;

        String query =  ' FIND \''+opData.searchInput+'*\' IN ALL FIELDS RETURNING '+
                        ' KnowledgeArticleVersion '+
                        '  (Id, KnowledgeArticleId, Title, CreatedDate, LastPublishedDate, Summary  '+
                        '      WHERE  '+
                        '       PublishStatus=\''+publishStatus+'\' AND language =\'en_US\' '+allowed+
                        '   order by CreatedDate) ';
                /* data categories restriction */
                //query += opData.topicName != '-1' ? ' WITH DATA CATEGORY '+umProxy.CAM_ROOT_GROUP_NAME+' BELOW '+opData.topicName+'__c' :'';
                query += opData.topicName != '-1' ? ' WITH DATA CATEGORY '+opData.topicName :'';

                query +=' LIMIT '+ umController.MAX_SOSL_OBJECTS;
            system.debug('\n\n umKnowledgeBaseModel ===> searchArticles :\n'+query);
        list<Object> results = search.query(query);

        ret.resultList = prepareRecordsForResponse((list<Object>)results[0],0);

        system.debug('\n\n umKnowledgeBaseModel ===> PAGE :'+((list<Object>)ret.resultList).size() + '= '+((list<Object>)results[0]).size());



        ret.offset = opData.offset + ((list<Object>)ret.resultList).size();
        return ret;
    }


    /**
    * @description
    *   returns title and smmary given the  ArticleNumber
    * @param localData - operationData {community, dataCategory, ArticleNumber}
    * @return Object response
    **/
    public static Object getFeaturedArticleDetail(Object operationData){

        localData opData = validateRequestForKB(operationData);
        if (! String.isNotBlank(opData.articleNumber))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]::: Request format invalid for KB  Featured Article detail  : articleNumber');

        //Getting all allowed kav's for current user
        String allowed = umSecurityHandler.getAllowedKav() != null ? 'and ArticleType IN ('+umSecurityHandler.getAllowedKav()+') ' : null;

        String query =  ' Select Id, KnowledgeArticleId, Title, CreatedDate, LastPublishedDate, Summary '+
                        ' from KnowledgeArticleVersion '+
                        '  WHERE PublishStatus=\''+publishStatus+'\' AND language =\'en_US\' '+
                        ' and ArticleNumber = \''+opData.articleNumber+'\' '+
                         allowed ;
        /* data categories restriction */
        query += opData.topicName != '-1' ? ' WITH DATA CATEGORY '+opData.topicName :'';

        query += ' ORDER BY LastPublishedDate DESC '+
                 ' LIMIT 1 ';
        system.debug('\n\n umKnowledgeBaseModel ===> getFeaturedArticleDetail :\n'+query);
        list<Object> results = Database.query(query);

        if (results.isEmpty())
            return results;
        else
            return results[0];

        }


    /**
    * @description
    *   returns title and smmary given the  article Id
    * @param localData - operationData {community, dataCategory, KnowledgeArticleId}
    * @return Object response
    **/
    public static Object getArticleDetail(Object operationData){

        localData opData = validateRequestForKB(operationData);
        if (! String.isNotBlank(opData.articleVersionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]::: Request format invalid for KB  Article detail : articleId');

        //obtain Knowledge article type
        Id kavID = opData.articleVersionId;
        Schema.SObjectType token = kavID.getSObjectType();

        umsecurityHandler.canAccess(new Schema.SObjectType[] {token });

        //get map containing all fields
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, SObjectField> mapFields =token.getDescribe().fields.getMap();
        String artFields = umCustomSettingModel.getArticleTypeLayout( String.valueOf(umProxy.siteSettings.get('id')), dr.getName());

        String fieldsOrder=artFields;
        set<String> fieldSet = new set<String>();
        if (artFields.length() > 0)
                fieldSet.addAll(artFields.tolowerCase().split(','));

        if (!fieldSet.contains('title'))                artFields += ',title';
        if (!fieldSet.contains('lastpublisheddate'))     artFields += ',lastpublisheddate';
        if (!fieldSet.contains('articlenumber'))        artFields += ',articlenumber';
        if (!fieldSet.contains('summary'))              artFields += ',summary';
        if (!fieldSet.contains('knowledgearticleid'))   artFields += ',KnowledgeArticleId';
        if (!fieldSet.contains('createddate'))   artFields += ',createddate';

        if (artFields.startsWith(',')) artFields = artFields.substring(1);
        //artFields = artFields;
        String sql = '  Select  '+ artFields+
                    '   from '+dr.getName()+
                    '   WHERE id = \''+kavID+'\'  '+
                    '   limit 1';

        list<Object> soqlResults = Database.query(sql);

        sObject article = (sObject)soqlResults[0];

        String qString = JSON.serialize(article);
        Map<String, Object> elm = (Map<String, Object>) JSON.deserializeUntyped(qString);

        //Article Likes
        String kID = String.valueOf(article.get('knowledgearticleid'));

        AggregateResult[] votes = [SELECT Count(Type) daVotes FROM Vote WHERE ParentId = :kID AND Type = '5'];
        elm.put('Likes',String.valueOf(votes[0].get('daVotes')));
        //Knowing if current user likes this article
        list<Vote> cUserVote = [Select Id FROM Vote WHERE ParentId = : kID and CreatedById = :userInfo.getUserId()];
        if ( cUserVote.size() > 0 ){
            elm.put('LikeIt',true);
        }else{
            elm.put('LikeIt',false);
        }

        Datetime d =   Datetime.valueOf(article.get('createddate'));
        Datetime d2 = Datetime.valueOf(article.get('LastPublishedDate'));
        String datetimeStr = '';
        if ( Test.isRunningTest() ){
            datetimeStr = d.format('MMMM d, yyyy');
        }else{
            datetimeStr = d2.format('MMMM d, yyyy');
        }

        Long elap = Datetime.now().getTime() - d.getTime();

        elm.put('CreatedDateText',datetimeStr);
        elm.put('CreatedDateElap',String.valueOf( elap ));
        elm.put('CreatedDate',d.getTime());
        elm.put('LastPublishedDate',d2 == null ? d.getTime() : d2.getTime());

        Map<String,String> fieldValues = new Map<String,String>();
        String value='';
        String keyVal='';
        String richTextFields='';
        Schema.DescribeFieldResult fDescribe = null;
        Set<String> skipFields = new Set<String>();//{'title','lastmodifieddate','articlenumber', 'summary','knowledgearticleid'};
        String flsCheckedList = filterArticleByFLS(artFields,mapFields);
        for(String f : flsCheckedList.split(',')){
            keyVal = f.trim() ;

            if (! skipFields.contains(keyVal.toLowerCase())){
            if (mapFields.containsKey(keyVal) ){
                fDescribe = mapFields.get(keyVal).getDescribe();
                keyVal= fDescribe.getLabel() ;
                if (fDescribe.getType() == Schema.DisplayType.TEXTAREA && fDescribe.isHtmlFormatted()) {
                    richTextFields += ','+keyVal;
                }
            }
            if ( article.get(f.trim()) != null){
                value = String.valueOf(article.get(f.trim()));

            }else {
                value='n/a';
            }
            fieldValues.put(keyVal , value);
            fieldsOrder = fieldsOrder.replace(f,keyVal);
            }
        }
        fieldValues.put('fieldOrder',fieldsOrder);
        fieldValues.put('richTextFields',richTextFields);

        elm.put('fieldValues',fieldValues);

        return (Object)elm;

    }


   /**
    * @description
    *   returns list of article fields to be displayed in the article Detail page,
    *   the original list contains the fields specifiend in the custom setting
    *   the result list is that list with the inaccessible fields removed
    * @param String - fieldList
    * @param Map<String, SObjectField> - mapFields
    * @return String
    **/
    public static String filterArticleByFLS(String fieldList,Map<String, SObjectField> mapFields ){
    String finalText = fieldList;
    SObjectField k = null;
    for (String f : fieldList.split(',')){
            if (f.trim() != 'ArticleType' ){
                k = mapFields.get(f.trim());
                if (!umsecurityHandler.isAccessible(k)){
                    finalText = finalText.replace(','+k,'');

                }
            }
        }
        return finalText;
    }


    /*
     * @description
     *  Add a like to an article
     * @param questionId @type String
     * @return  Objbect with voteId on the result
     */
    public static Object addLikeVote(Object operationData){


        //check valid session
        if (!umController.validSession())
                throw new umProxy.umException('[SESSION_TIMED_OUT]:::You need to be logged');

        replyData ret = new replyData();

        localData opData = validateRequestForKB(operationData);
        if (! String.isNotBlank(opData.articleVersionId))
            throw new umProxy.umException('[INVALID_REQUEST_FORMAT]:::Request format invalid for KB  Article detail : articleId');

        //obtain Knowledge article type
        Id kavID = opData.articleVersionId;

        //check create permissions
        umSecurityHandler.canCreate(
            new Schema.SObjectType[] {Vote.sObjectType});

        KnowledgeArticleVersion kav = [Select Id, KnowledgeArticleId from KnowledgeArticleVersion where Id = :kavID];

        system.debug('\n\n umKnowledgeBaseModel ===> check previous votes  :\n'+kav.KnowledgeArticleId +'  user '+Userinfo.getUserId());

        //Let's check if user already have a vote for the article
        list<Vote> voteList = [Select Id From Vote where ParentId = :kav.KnowledgeArticleId AND CreatedById = :Userinfo.getUserId() limit 1];
        if ( voteList.size() > 0 ){
             throw new umProxy.umException('User already voted this article');
        }

        Vote v = new Vote( ParentId = kav.KnowledgeArticleId, Type = '5' );
        insert v;

        ret.result = v.Id;

        return ret;
    }


    private static list<Object> prepareRecordsForResponse(list<Object> sourceList, Integer maxItems){

        list<Object> res = new list<Object>();
        Map<String,String> articleTypes = kavDescribeMap();
        String elementPrefix;
        String articleType;

        //resolve likes
        set<String> kaIds = new set<String>();
        String tmpId;
        for ( Object obj : sourceList){
            String objString = JSON.serialize(obj);
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(objString);
            tmpId = String.valueOf(objMap.get('KnowledgeArticleId'));
            system.debug('\n\n umKnowledgeBaseModel ===> listOf KnowledgeArticle   :'+tmpId);
            kaIds.add(tmpId);
        }
        system.debug('\n\n umKnowledgeBaseModel ===> listOf KnowledgeArticle Ids :\n'+kaIds +' ====== maxItems '+maxItems);

        Map<Id,KnowledgeArticle> kaVotes = new Map<Id,KnowledgeArticle>([ Select k.Id, (SELECT Id FROM Votes where Type='5')
                                                                         from KnowledgeArticle k
                                                                         where Id IN :kaIds ]);

        // process kav records and prepare
        Datetime d,d2;
        Long elap;
        KnowledgeArticle elm;
        for ( Object obj : sourceList){

            if ( maxItems== 0  || res.size()< maxItems ){

                String objString = JSON.serialize(obj);
                Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(objString);

                d = ((KnowledgeArticleVersion) obj).CreatedDate;
                d2 = ((KnowledgeArticleVersion) obj).LastPublishedDate;
                elap = Datetime.now().getTime() - d.getTime();

                objMap.put('CreatedDateElap',String.valueOf( elap ));
                objMap.put('CreatedDate',d.getTime());
                objMap.put('LastPublishedDate',d2 == null ? d.getTime() : d2.getTime());

                elementPrefix = ((KnowledgeArticleVersion) obj).KnowledgeArticleId;

                if (kaVotes.containsKey(elementPrefix)){
                    elm = kaVotes.get(elementPrefix);
                    objMap.put('Likes',elm.Votes.size());
                }else{
                    objMap.put('Likes','0');
                }

                elementPrefix = elementPrefix.subString(0,3);
                if (articleTypes.containsKey(elementPrefix))
                    objMap.put('ArticleTypeLabel',articleTypes.get(elementPrefix));
                else
                    objMap.put('ArticleTypeLabel','n/a');

                res.add((Object)objMap);
            }

        }
            return res;
    }

    /**
    * @description
    *   returns a map {articlePrexix, articleLabel}
    * @return @type Map<String,String>
    **/
    private static Map<String,String> kavDescribeMap() {
        Map<String,String> result = new Map<String,String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('ka') || key.endsWith('kb')) {
                result.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
            }
        }

        return result;
    }


}