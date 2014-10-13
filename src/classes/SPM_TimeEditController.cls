/*
    Author:         ben@tquila.com
    Description:    Controller for the SPM_TimeEdit page.
                    Contains logic to handle a standard sObject save, as well 
                    as create multiple time entry records when a date range
                    is inputted.
*/
public with sharing class SPM_TimeEditController {
    
    // Time record for the page
    public final Time__c timeRecord {get;set;}

    // Constructor
    public SPM_TimeEditController(ApexPages.StandardController controller) 
    {
        timeRecord = (Time__c)controller.getRecord();
        
        // If new record and opened from the timesheet calendar, populate
        // the date (which comes from the calendar click itself)
        if (timeRecord.Id == null && ApexPages.currentPage().getParameters().get('date') != null)
        {
            try
            {
                timeRecord.Date__c = date.valueOf(ApexPages.currentPage().getParameters().get('date'));
            }
            catch (Exception ex)
            {
                system.debug('### Error parsing date from URL: ' + ex);
            }
        }
    }

    // Custom save method
    public PageReference save()
    {
        // If the end date is populated and more than the start date, create mulitple
        // records, based on the number of days
        List<Time__c> timeEntries = new List<Time__c>();
        if (timeRecord.Id == null && timeRecord.End_Date__c != null && timeRecord.End_Date__c > timeRecord.Date__c)
        {
            // Create a new record for the number of days between
            for (Integer i = 0; i < timeRecord.Date__c.daysBetween(timeRecord.End_Date__c); i++)
            {
                Time__c newTimeEntry = timeRecord.clone(
                    false, // preserve id
                    true, // deep clone
                    false, // preserve read only
                    false // preserve auto-number
                );
                newTimeEntry.Date__c = timeRecord.Date__c.addDays(i + 1);
                newTimeEntry.End_Date__c = newTimeEntry.Date__c;
                timeEntries.add(newTimeEntry);
            }
        }

        // Upsert current record, and any additional records generated from logic above
        try
        {
            timeRecord.End_Date__c = timeRecord.Date__c;
            upsert timeRecord;
            insert timeEntries;
            return new PageReference('/' + timeRecord.Id);
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
            system.debug('### Error saving time entry: ' + ex);
            return null;
        }

    }

}