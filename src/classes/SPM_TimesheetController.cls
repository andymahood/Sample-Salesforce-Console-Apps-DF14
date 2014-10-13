/*
    Author:         ben@tquila.com
    Description:    Controller for the SPM_Timesheet page.
                    Contains logic to query time sheet records for the logged in
                    user, or the user selected from the page
*/
global with sharing class SPM_TimesheetController {   

    // Get all the Records retrieved in Json Format
    @RemoteAction
    public static String getMyObjectAsJson(String userId, String startDate) 
    {
        // Instantiate JSON array for page
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
        // Loop through each record to create relevant Json structure
        for (Time__c timeRecord :queryTimeRecords(userId, startDate))
        {

            gen.writeStartObject();

                gen.writeStringField('id', timeRecord.Id);

                // Generate the event title to display on calendar
                String eventTitle;
                if (timeRecord.name != null)
                {
                    eventTitle = timeRecord.project__r.project_name__c;
                }
                else
                {
                    eventTitle = timeRecord.Activity__c;
                }

                if (timeRecord.name != null)
                {
                    eventTitle += '\n' + timeRecord.Name;
                }

                for (Integer i = 1; i <= timeRecord.Hours__c;i++)
                {
                    eventTitle += '\n';
                }

                eventTitle += 'Hours: ' + timeRecord.Hours__c;

                // Populate other fields
                gen.writeStringField('title', eventTitle);
                gen.writeDateField('start', timeRecord.Date__c);

                if (timeRecord.Hours__c != null)
                    gen.writeNumberField('hours', timeRecord.Hours__c);
                else gen.writeNumberField('hours', 0);
                
                gen.writeStringField('color', getColour(timeRecord));
                
                // Append desciption
                if (timeRecord.Description__c != null)
                {
                    gen.writeStringField('description', timeRecord.Description__c);
                }
                else
                {
                    gen.writeStringField('description', '');
                }
                
            gen.writeEndObject();
        }

        gen.writeEndArray();
        return gen.getAsString();
    }
    
    // Parse the Given Json into Salesforce Objects and Save them to Salesforce
    @RemoteAction
    public static String saveEventObject(String eventId, String startDate)
    {
        try 
        {
            update new Time__c(
                Id      = eventId,
                Date__c = date.valueOf(startDate)
            );
            return 'success';
        }
        catch (Exception ex)
        {
            system.debug('### Error saving time entry: ' + ex);
            return 'Error saving event: ' + ex;
        }

    }
    
    // Obtain a list of users that the current user has permission
    // to view
    public List<User> timesheetUsers
    {
        get
        {
            if (timesheetUsers == null)
            {
                timesheetUsers = [Select Id
                                        , FirstName
                                        , LastName
                                        , SmallPhotoUrl
                            From        User 
                            Where       isActive = true 
                                And     Id IN   (Select Timesheet_User__c 
                                                From    Timesheet_Access__c
                                                Where   Access_User__c = :UserInfo.getUserId())
                            Order by    FirstName];
            }
            return timesheetUsers;
        } 
        set;
    }

    private static String getColour(Time__c timeRecord)
    {
        String colour;
        if (timeRecord.Name != null)
        {
            colour = '#79B627';
        }
        else if (timeRecord.Name != null)
        {
            colour = '#9b9b9b';
        }
        else
        {
            colour = '#004976';
        }

        return colour;
    }

    // Build the time sheet query
    private static List<Time__c> queryTimeRecords(String userId, String startDate) 
    {
        return [Select  Id
                       , Name
                       , Hours__c
                       , Date__c
                       , End_Date__c
                       , Description__c 
                       , Activity__c
                       , project__c
                       , project__r.project_name__c
                From   Time__c 
                Where  OwnerId = :userId
                  And  Date__c > :date.valueOf(startDate).addMonths(-3)];
    }
    
}