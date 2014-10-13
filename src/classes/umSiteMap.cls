/**
 * @author Altimetrik
 * @description
 *    started on 10/02/2013
 *     Controller of um Sitemap and SitemapIndex pages
 **/
public with sharing class umSiteMap {


	public  static map<String,String>  zonesNativeNames{
		get{
			if (null == zonesNativeNames ) {
				zonesNativeNames = new map<String,String>{
						'id_VAL' =>'zone_home_page'
				};
			}
			return zonesNativeNames;
		}
		private set;
	}
	/**
	* @description this list declares all ArticleTypes in the org
	**/
	public list<String> availableArticleTypes { get; private set;}
	/**
	* @description this list declares all available languages
	**/
	public list<String> availableLanguages { get; private set;}

	public static final Integer MAX_ITEMS = 5;
	public static String DEFAULT_PUBLISH_STATUS = 'online';

	public String lang {get; set;}
	public Integer offset {get; set;}
	public String type {get; set;}

	public umSiteMap() {

		init();
		//populate offset for queries
		this.offset = 0;
		String tmpOffset = ApexPages.currentPage().getParameters().get('offset');
		if (String.isNotBlank(tmpOffset) && tmpOffset.isNumeric()){
			tmpOffset = String.escapeSingleQuotes(tmpOffset);
			this.offset = Integer.valueOf(tmpOffset);
		}
		//populate language option
		this.lang = String.valueOf(ApexPages.currentPage().getParameters().get('lang'));
		if ( String.isNotBlank(this.lang)){
			this.lang  = String.escapeSingleQuotes(this.lang );
		}else{
			this.lang = availableLanguages.get(0);
		}
		//populate type option
		this.type = String.valueOf(ApexPages.currentPage().getParameters().get('type'));
		if ( String.isNotBlank(this.type)){
			this.type  = String.escapeSingleQuotes(this.type );
		}else{
			this.type = 'a';
		}
	}

	/**
	* @description populates available articles and languages
	* using the schema of the KnowledgeArticleVersion object
	**/
	private void init(){

		availableArticleTypes = new List<String>();
		for (Schema.PicklistEntry a : KnowledgeArticleVersion.ArticleType.getDescribe().getPickListValues()){
			availableArticleTypes.add( a.getValue());
		}

		availableLanguages = new List<String>();
		for (Schema.PicklistEntry a : KnowledgeArticleVersion.Language.getDescribe().getPickListValues()){
			availableLanguages.add( a.getValue());
		}

	}

	// A property to return the proper Sites URL, used to build our full URL later
	public string siteUrl{
		get{
			String surl = site.getcustomwebaddress();
			if ( !String.isNotBlank(surl) ) {
				surl = site.getcurrentsiteurl();
				String pref = site.getPrefix();
				if (pref != null && String.isNotBlank(pref) )
					surl = surl.removeEndIgnoreCase(site.getPrefix()+'/');
				else
					surl = surl.removeEndIgnoreCase('/');
			}
			return surl;//.substring(0, (surl.length()-1));
		}
		set;
	}

	/**
	*		SITEMAP INDEX METHODS
	**/
	public list<SMWrapper> getSiteMapsList(){

		list< SMWrapper> results = new list<SMWrapper>();
		list< SMWrapper> tmp;
		for( String l : availableLanguages){
			tmp =getSiteMapsList(l);
			if (!tmp.isEmpty())
				results.addAll( tmp);
		}
		tmp = null;
		tmp =getSiteMapsQAList();
			if (!tmp.isEmpty())
				results.addAll( tmp);
		return results;
	}

	/**
	* @description returns list of siteMapIndes Items for KAV
	**/
	public list<SMWrapper> getSiteMapsList(String lang){

		list< SMWrapper> results = new list<SMWrapper>();
		String q = ' SELECT  count() ' +
						' FROM KnowledgeArticleVersion ' +
						' WHERE ' +
						' (PublishStatus = \''+DEFAULT_PUBLISH_STATUS+'\' AND IsVisibleInPkb = true AND Language=\''+ lang+'\' )  ' +
						' LIMIT '+ Limits.getLimitQueryRows();
		Integer max  =  Database.countQuery(q);
		Long l = Math.mod( max,MAX_ITEMS);
		Double numPages = Math.floor(max/MAX_ITEMS);
		if (  l>0){
			numPages = numPages+ 1;
		}

		for( Integer i=0 ; i< numPages ; i++){
			results.add( new SMWrapper( lang, (i* MAX_ITEMS ),'a' ));
		}
		return results;
	}


	public with sharing  class SMWrapper {
		public Integer offset	   { get; set; }
		public String lastModDate  { get; set; }
		public String lang		   { get; set; }
		public String type		   { get; set; }

		public SMWrapper(String l , Integer o, String t) {
			this.offset = o;
			Datetime aux = Datetime.now();
			this.lastModDate	= aux.format('yyyy-MM-dd');
			this.lang = l;
			this.type = t;
		}
	}


	/**
	*		KNOWLEDGE SITEMAP  METHODS
	**/

	public  list<KAWrapper> getarticleList(){

		list< KAWrapper> results = new list<KAWrapper>();

		Integer offs =  this.offset;
		String qry =	' SELECT  id, knowledgearticleid, lastpublisheddate , title , UrlName , LastModifiedDate '+
					'   FROM KnowledgeArticleVersion'+
					'   WHERE '+
					'   (PublishStatus = \''+DEFAULT_PUBLISH_STATUS+'\' AND IsVisibleInPkb = true AND Language=\''+this.lang+'\' ) '+
					'   ORDER BY LastPublishedDate DESC '+
					'   LIMIT: MAX_ITEMS  '+
					'   OFFSET : offs';

		for( sObject iK : database.query(qry)){
			results.add( new KAWrapper( iK));
		}
		return results;
	}

	public with sharing  class KAWrapper {
		public Id id					{ get; set; } // note this is the ID of the KnowledgeArticle record, not the ID of the KAV record
		public Id knowledgearticleid	{ get; set; }
		public String lastpublisheddate	 { get; set; }
		public String aType				{ get; set; }
		public String UrlName			{ get; set; }


		public KAWrapper(sObject ka) {
			this.knowledgearticleid	 = String.valueOf(ka.get('id')); //CHANGE THIS
			Datetime aux;
			if (!Test.isRunningTest()){
				aux = Datetime.valueOf(ka.get('LastModifiedDate'));
			}else{
				aux = Datetime.now();
			}

			this.lastpublisheddate	  = aux.format('yyyy-MM-dd');

			Schema.SObjectType token = this.knowledgearticleid.getSObjectType();
			// Using the token, do a describe
			// and construct a query dynamically.
			Schema.DescribeSObjectResult dr = token.getDescribe();
			this.aType  = dr.getName().replace('__kav','');

			this.UrlName = String.valueOf(ka.get('UrlName'));
		}
	}

	/**
	*		CHATTER ANSWERS SITEMAP  METHODS
	**/
	public  list<QAWrapper> getquestionList(){

		list< QAWrapper> results = new list<QAWrapper>();

		Integer offs =  this.offset;
		String qry =	' SELECT  id,  title , CreatedDate, CommunityId, Community.Name '+
					'   FROM Question '+
					'   ORDER BY CreatedDate DESC '+
					'   LIMIT: MAX_ITEMS  '+
					'   OFFSET : offs';

		for( sObject iK : database.query(qry)){
			results.add( new QAWrapper( iK));
		}
		return results;
	}


	/**
	* @description returns list of siteMapIndes Items for Q&A
	**/
	public list<SMWrapper> getSiteMapsQAList(){

		list< SMWrapper> results = new list<SMWrapper>();
		String q = ' SELECT  count() ' +
						' FROM Question ' +
						' LIMIT '+ Limits.getLimitQueryRows();
		Integer max  =  Database.countQuery(q);
		Long l = Math.mod( max,MAX_ITEMS);
		Double numPages = Math.floor(max/MAX_ITEMS);
		if (  l>0){
			numPages = numPages+ 1;
		}

		for( Integer i=0 ; i< numPages ; i++){
			results.add( new SMWrapper( lang, (i* MAX_ITEMS ),'q' ));
		}
		return results;
	}



	public with sharing  class QAWrapper {
		public Id id					{ get; set; }
		public String createdDate		{ get; set; }
		public String zoneName			{ get; set; }
		public String UrlName			{ get; set; }


		public QAWrapper(sObject q) {
			Datetime aux;
			if (!Test.isRunningTest()){
				aux = Datetime.valueOf(q.get('CreatedDate'));
			}else{
				aux = Datetime.now();
			}
			Question qObj = (Question) q;
			this.createdDate	= aux.format('yyyy-MM-dd');
			/* in case the zone homepage is customized*/
			if (zonesNativeNames.containsKey(qObj.Community.id)){
				this.zoneName 		= zonesNativeNames.get(qObj.Community.id);
			}else{
				this.zoneName 		= qObj.Community.Name+'_main';
			}
			this.id 			= qObj.id;
			this.UrlName		= qObj.title;
		}
	}

}