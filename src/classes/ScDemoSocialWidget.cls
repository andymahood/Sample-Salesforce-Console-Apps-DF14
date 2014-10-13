/* 
------------------------------------------------------------
// Name:		bcsSocialCaseController
// Author: 		Tquila(Klea Kolaric)
// Function:	Controller for the social case widget
// History:		19/02/2014 Created
------------------------------------------------------------
 */
global with sharing class ScDemoSocialWidget {
	
	private final integer TEXT_SIZE = 150;
    global final static integer LIST_SIZE = 10; //sets the number of rows
    public integer total_size; //used to show user the total size of the list
    public Id userId;
    public List<Case> socialCases {get; set;}
    public Boolean showCases {get; set;}
    public Boolean chooseSuccess {get; private set;}
    
    // unfortuntelly, apex:commandLink cannot recognise the apex:pageBlockTable var in the "oncomplete" call (???)
    // this is a workaround
    public Id chooseCaseId {get; set;}
    public String chooseCaseNumber {get; set;}
        
    public string selectedPage{get;set{selectedPage=value;}
    }
    
    public ScDemoSocialWidget()
    {
    	userId = System.Userinfo.getUserId();
    	chooseSuccess = true;
        loadCases();
    }
    
    public void loadCases() 
    {
        try
        {
        	
        	socialCases = ScDemoSocialWidgetHelper.getSocialCases(false, LIST_SIZE, userId);
        	total_size = socialCases.size();
        	
        	//trunkate desc to reduce view state and style display - DO NOT UPDATE RECORDS
        	for(Case sc : socialCases)
        	{
        		if(sc.Description != null && sc.Description.length() > TEXT_SIZE)
        		{
        			sc.Description = sc.Description.substring(0,TEXT_SIZE) + '...';
        		}
        	}
               
            if(socialCases.isEmpty()){
            	showCases = false;
            } else {
            	showCases = true;
            }
        
        } 
        catch (exception e)
        {                            
                ApexPages.addMessages(e);                   
        }        
    }
    
    @RemoteAction
    global static Integer getCaseAmount()
    {
    	return ScDemoSocialWidgetHelper.getSocialCases(true, LIST_SIZE, System.Userinfo.getUserId()).size();	
    }
    
    public void assignCase()
    {
    	//Id caseId = (Id) ApexPages.currentPage().getParameters().get('caseId');
    	Id caseId = chooseCaseId;
    	
    	try
    	{
    		chooseSuccess = ScDemoSocialWidgetHelper.assignCase(caseId,userId);
    		// if assign failed due to update conflict
    		if(!chooseSuccess)
	    	{
	    		ApexPages.addMessage(
	    			new ApexPages.Message(ApexPages.Severity.ERROR,'Could not obtain right to assign record - conflict with another agent.')
	    		);
	    	}
    	}
    	catch(exception e) 
    	{
    		ApexPages.addMessages(e); 
    	}
    	
    	loadCases();
    }
    
    public void spamCase()
    {
    	//Id caseId = (Id) ApexPages.currentPage().getParameters().get('caseId');
    	Id caseId = chooseCaseId;
    	
    	try
    	{
    		chooseSuccess = ScDemoSocialWidgetHelper.spamCase(caseId,userId);
    		// if assign failed due to update conflict
    		if(!chooseSuccess)
	    	{
	    		ApexPages.addMessage(
	    			new ApexPages.Message(ApexPages.Severity.ERROR,'Could not obtain right to assign record - conflict with another agent.')
	    		);
	    	}
    	}
    	catch(exception e) 
    	{
    		ApexPages.addMessages(e); 
    	}
    	
    	loadCases();
    }
    
    public void refresh()
    {
    	loadCases();
    }

}