public with sharing class Perfection 
{
    
    Date today = Date.today();
    String Ts, Os, Ass, Cts, Cps, Es, Cs, Qts;

    public String getTs(){return Ts;}
    public String getOs(){return Os;}
    public String getAss(){return Ass;}
    public String getCts(){return Cts;}
    public String getEs(){return Es;}
    public String getCps() { return Cps;} 
    public String getCs() { return Cs;} 
    public String getQts() { return Qts;}

    public PageReference all() 
    {
        doTasks();
        doAssets();
        doContracts();
        doCampaigns();
        doEvents();
        doCases();
        doQuotes();
        doOpps();      
    
    return null;
    }
    
    
    public PageReference doTasks()
    {
        Task[] tasks = [Select ActivityDate, DB_Days__c from Task Where DB_Days__c != null 
                                                                    and isDeleted = false 
                                                                    and ActivityDate != null];
                    
        for(Task t: tasks)
        {
            t.ActivityDate = today.addDays(t.DB_Days__c.intValue());
        }
        
        update tasks;   
        Ts = 'Tasks are Perfect!';  
        return null;                                                                                            
    }
    
    public PageReference doOpps()
    {
        Opportunity[] opps = [Select CloseDate, DB_Days__c from Opportunity where DB_Days__c != null and CloseDate != null];
        
        for(Opportunity o: opps)
        {
            o.CloseDate = today.addDays(o.DB_Days__c.intValue());
        }   
        
        update opps;
        Os = 'Opportunities are Perfect!';
        return null;
    }   
    
    public PageReference doAssets()
    {
    
        Asset[] assets = [Select UsageEndDate, DB_Days__c from Asset where DB_Days__c != null and UsageEndDate != null];
        
        for( Asset a : assets)
        {
            a.UsageEndDate = today.addDays(a.DB_Days__c.intValue());
            a.PurchaseDate = a.UsageEndDate.addDays(-365);  
        } 
        
        update assets;
        Ass = 'Assets are Perfect!';
        return null;
    }
    
    public PageReference doContracts()
    {
    
        Contract[] contracts = [Select StartDate, DB_Days__c from contract where DB_Days__c != null and StartDate != null];
        
        for( Contract c: contracts)
        {
            c.startdate = today.addDays(c.DB_Days__c.intValue()); 
        }
        
        update contracts;
        Cts = 'Contracts are Perfect!';
        return null;
    }
    
     public PageReference doCampaigns()
     {
    
        Campaign[] campaigns = [Select EndDate, DB_Days__c from Campaign where DB_Days__c != null and EndDate != null];
        
        for(Campaign c: campaigns)
        {
            c.EndDate = today.addDays(c.DB_Days__c.intValue()); 
            c.StartDate = c.EndDate.addDays(-30); 
        } 
        
        update campaigns;
        Cps = 'Campaigns are Perfect!';
        return null;
    }
    
    public PageReference doEvents()
    {
    
        Event[] events = [Select ActivityDateTime, DB_Days__c from Event where DB_Days__c != null and isdeleted = false and ActivityDateTime != null ALL ROWS];
        
        for( Event e: Events)
        {
            DateTime dtoday = DateTime.newInstance(today.year(),today.month(),today.day(),e.ActivityDateTime.hour(),e.ActivityDateTime.minute(),e.ActivityDateTime.second());
            e.ActivityDateTime = dtoday.addDays(e.DB_Days__c.intValue()); 
        } 
        
        update events;
        Es = 'Events are Perfect!';
        return null;
    }
    
     public PageReference doCases()
     {
    
        Case[] cases = [Select DateTime_Opened__c, DateTime_Closed__c, DB_Hours__c, DB_Case_Duration_Hours__c from Case where DB_Hours__c != null or DB_Case_Duration_Hours__c != null];
        
        for( Case c: cases)
        {
             
            DateTime openDate = DateTime.now()-20;    
            
            if(c.DB_Hours__c != null)
            {    
                c.DateTime_Opened__c = openDate.addHours(c.DB_Hours__c.intValue()); 
            }
            
            if(c.DB_Case_Duration_Hours__c != null)
            {
                c.DateTime_Closed__c = c.DateTime_Opened__c.addHours(c.DB_Case_Duration_Hours__c.intValue());
            }  
        } 
        
        update cases;
        Cs = 'Cases are Perfect!';
        return null;
    }
    
    public PageReference doQuotes()
    {
        Quote[] quotes = [Select id,DB_Days__c from Quote where DB_Days__c != null];
        
        for( Quote q: quotes)
        {
            q.ExpirationDate = today.addDays(q.DB_Days__c.intValue()); 
        } 
         
        update quotes;
        Qts = 'Quotes are Perfect!';
        return null; 
    }

}