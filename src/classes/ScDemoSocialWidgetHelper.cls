/* 
------------------------------------------------------------
// Name:        bcsSocialCaseHelper
// Author:      Tquila(Klea Kolaric)
// Function:    helper for the social case widget
// History:     19/02/2014 Created
------------------------------------------------------------
 */
public without sharing class ScDemoSocialWidgetHelper {
    
    public static final String SOCIAL_QUEUE_DEV_NAME = 'bcsGlobalSocialQueue';
    // query executes only on first invocation
    public static Id queueId = [select id from Group where Type = 'Queue' and DeveloperName = :SOCIAL_QUEUE_DEV_NAME limit 1].id;
    
    public static List<Case> getSocialCases(Boolean doCount, Integer limitSize, Id userId)
    {
        List<Case> retCases = new List<Case>();
        
        // find user skills
        List<String> languages = new List<String>();
        for(ScDemoUserSettings__c us : [select Primary_Language__c, Secondary_Languages__c
                                            from ScDemoUserSettings__c
                                            where Specialities__c includes ('Social')
                                                and User__c = :userId])
        {
            if(us.Primary_Language__c != null) languages.add(us.Primary_Language__c);
            if(us.Secondary_Languages__c != null) languages.addAll(us.Secondary_Languages__c.split(';'));
        }
        
        // find social cases witch match skill language
        if(!languages.isEmpty())
        {
            String caseFields = 'id, CaseNumber, Description, Priority, R6Service__MediaIcon__c';
            
            String queryStr = 'SELECT '
                                + (doCount ? 'id' : caseFields)
                                + ' FROM Case WHERE '
                                + 'OwnerId = \'' + (String) queueId + '\''
                              
                                + ' ORDER BY CreatedDate ASC'
                                + ' LIMIT ' + (doCount ? 40000 : limitSize);
                                
            retCases = (List<Case>) Database.query(queryStr);
        }
        
        return retCases;
    }
    
    // only one case can be assigned at once 
    // we're using FOR UPDATE to avoid agents stealing cases from each other
    public static Boolean assignCase(Id caseId, Id userId)
    {
        try
        {
            Case c = [select id, OwnerId from Case where id = :caseId and OwnerId = :queueId for update];
            c.Status = 'In Progress';
            c.OwnerId = userId;
            update c;
            return true;
        }
        catch(System.QueryException e)
        {
            // case has been taken by another agent
            return false;
        }
    }
    
    // only one case can be assigned at once 
    // we're using FOR UPDATE to avoid agents stealing cases from each other
    public static Boolean spamCase(Id caseId, Id userId)
    {
        try
        {
            Case c = [select id, OwnerId, Status, Reason_Code__c, Reason_Description__c 
                        from Case where id = :caseId and OwnerId = :queueId for update];
            // TODO do we have constants for this somewhere?
            c.Status = 'Closed';
            c.OwnerId = userId;
            update c;
            return true;
        }
        catch(System.QueryException e)
        {
            // case has been taken by another agent
            return false;
        }
    }

}