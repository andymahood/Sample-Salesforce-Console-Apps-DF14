public with sharing class UserTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    private final static String ACCOUNT_CHECKIN = 'AccountCheckin';
    private final static String CONTACT_CHECKIN = 'ContactCheckin';
    private final static String CASE_CHECKIN = 'CaseCheckin';
    private final static String LOCATION_CHECKIN = 'LocationCheckin';
    
    
    public UserTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeUpdate(List<User> oldUsers, List<User> updatedUsers, Map<Id, User> oldUserMap, Map<Id, User> updatedUserMap) {
        //Identify all the users that have just checked in somewhere
        Set<Id> checkedInUserIDs = new Set<Id>();
        Set<Id> checkedInObjectIDs = new Set<Id>();
            Notification__c notification;
            List<Notification__c> notifications = new List<Notification__c>();
            List<Account> accountsToUpdate = new List<Account>();
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Case> casesToUpdate = new List<Case>();
            
        try {
            for(User userOld : oldUsers) {
                User userUpd = updatedUserMap.get(userOld.Id);
                if(userUpd != null && userOld != null) {
                  
                    if(fieldChanged(userOld.CheckInCity__c, userUpd.CheckInCity__c) ||
                     fieldChanged(userOld.CheckInCountry__c, userUpd.CheckInCountry__c) ||
                     fieldChanged(userOld.CheckInPostalCode__c, userUpd.CheckInPostalCode__c) ||
                     fieldChanged(userOld.CheckInRecordId__c, userUpd.CheckInRecordId__c) ||
                     fieldChanged(userOld.CheckInState__c, userUpd.CheckInState__c) ||
                     fieldChanged(userOld.CheckInStreet__c, userUpd.CheckInStreet__c) ||
                     fieldChanged(userOld.CheckInCity__c, userUpd.CheckInCity__c) ||
                     userOld.Latitude__c != userUpd.Latitude__c ||
                     userOld.Longitude__c != userUpd.Longitude__c) {
                        checkedInUserIDs.add(userOld.Id);
                        checkedInObjectIDs.add(userUpd.CheckInRecordId__c);
                    }
                }
            }
            log(''+checkedInUserIDs);
            
            // Get all the followers of the checked in users
            List<EntitySubscription> allFollowers = [select Id, Subscriberid, Subscriber.Name, ParentId 
                FROM EntitySubscription
                WHERE parentid IN :checkedInUserIDs 
                LIMIT 500];
                // AND Subscriber.IsActive = true 
                //  AND (Subscriber.IsNotificationEnabled__c = null OR Subscriber.IsNotificationEnabled__c = true)];
            log(''+allFollowers);
            
            //Define a mapping between the just checked in users and their subscribers (people who follow them)
            Map<Id, Set<Id>> usersFollowersMap = new Map<Id, Set<Id>>();
            for(EntitySubscription follower : allFollowers) {
                Id parent = follower.ParentId;
                Id subscriber = follower.SubscriberId;
                Set<Id> userFollowers = usersFollowersMap.containsKey(parent) ? usersFollowersMap.get(parent) : new Set<Id>();
                userFollowers.add(subscriber);
                
                usersFollowersMap.put(parent, userFollowers);
            }
            log(''+usersFollowersMap);
            
            // Fetch users info - apparentely SF don't fecth name and smallphotoUr;
            Map<Id, User> freshUsers = new Map<Id, User>([SELECT Name, SmallPhotoUrl FROM User WHERE Id IN :updatedUserMap.keySet()]);
            
            //Query all the considered objects to understand the right type of checkin
            Map<Id, Account> checkedAccountMap = new Map<Id, Account>([SELECT Name,NumberOfCheckin__c,Mayor__c FROM Account WHERE Id IN :checkedInObjectIDs]);
            Map<Id, Contact> checkedContactMap = new Map<Id, Contact>([SELECT Name,NumberOfCheckin__c,Mayor__c FROM Contact WHERE Id IN :checkedInObjectIDs]);
            Map<Id, Case> checkedCaseMap = new Map<Id, Case>([SELECT CaseNumber, Subject,NumberOfCheckin__c,Mayor__c FROM Case WHERE Id IN :checkedInObjectIDs]);
            
            //Create the notifications

            notifications = new List<Notification__c>();
            accountsToUpdate = new List<Account>();
            contactsToUpdate = new List<Contact>();
            casesToUpdate = new List<Case>();
             
            for(Id justCheckedInUserID : checkedInUserIDs) {
                User justCheckedInUser = updatedUserMap.get(justCheckedInUserID);
                
                // On what the user has just checked in
                String notificationType = '', notificationParentID = null, notificationTargetObjectName = '';
                if(justCheckedInUser.CheckInRecordId__c == null || justCheckedInUser.CheckInRecordId__c.length() == 0) {
                    notificationType = LOCATION_CHECKIN;
                    notificationParentID = null;
                    notificationTargetObjectName = '';
                } else {
                    notificationParentID = justCheckedInUser.CheckInRecordId__c;
                    
                    Id checkedUserID = justCheckedInUser.CheckInRecordId__c;
                    if(checkedAccountMap.containsKey(checkedUserID)) {
                        notificationType = ACCOUNT_CHECKIN;
                        
                        Account checkedAccount = checkedAccountMap.get(checkedUserID);
                        notificationTargetObjectName = checkedAccount.Name;
                        
                        //Gamification fields
                        checkedAccount.NumberOfCheckin__c = incCheckinCounter(checkedAccount.NumberOfCheckin__c);
                        checkedAccount.Mayor__c = justCheckedInUser.Id;
                        accountsToUpdate.add(checkedAccount);
                        
                    } else if(checkedContactMap.containsKey(checkedUserID)) {
                        notificationType = CONTACT_CHECKIN;
                        
                        Contact checkedContact = checkedContactMap.get(checkedUserID);
                        notificationTargetObjectName = checkedContact.Name;
                        
                        //Gamification fields
                        checkedContact.NumberOfCheckin__c = incCheckinCounter(checkedContact.NumberOfCheckin__c);
                        checkedContact.Mayor__c = justCheckedInUser.Id;
                        contactsToUpdate.add(checkedContact);
                    } else if(checkedCaseMap.containsKey(checkedUserID)) {
                        notificationType = CASE_CHECKIN;
                        
                        Case checkedCase = checkedCaseMap.get(checkedUserID);
                        String sbj = checkedCase.Subject;
                        notificationTargetObjectName = checkedCase.CaseNumber 
                            + (sbj != null && sbj.length() > 0 ? ' ' + sbj : '');
                        
                        //Gamification fields
                        checkedCase.NumberOfCheckin__c = incCheckinCounter(checkedCase.NumberOfCheckin__c);
                        checkedCase.Mayor__c = justCheckedInUser.Id;
                        casesToUpdate.add(checkedCase);
                    }
                }
                
                Set<Id> userFollowersMap = usersFollowersMap.get(justCheckedInUserID);
                if(userFollowersMap != null && userFollowersMap.size() > 0) { 
                    for(Id userFollower : userFollowersMap) {
                        notification = new Notification__c();
                
                        notification.Type__c = notificationType;
                        notification.ParentId__c = notificationParentID;
                        notification.TargetObjectName__c = notificationTargetObjectName;
                
                        // User to be notify
                        notification.AlreadyNotified__c = false;
                        notification.UserToNotifyID__c = userFollower;
                        
                        notification.TargetObjectAddressCity__c = justCheckedInUser.CheckInCity__c;
                        notification.TargetObjectAddressStreet__c = justCheckedInUser.CheckInStreet__c;
                        
                        // User who has just done the check in
                        notification.UserCheckedIn__c = justCheckedInUser.Id;
                        notification.UserCheckedInName__c = freshUsers.get(justCheckedInUser.Id).Name;
                        notification.UserCheckedInPhotoURL__c = freshUsers.get(justCheckedInUser.Id).SmallPhotoUrl;
                        
                        notifications.add(notification);            
                    }
                }
                
                //Inc gamification check in counter
                justCheckedInUser.NumberOfCheckin__c = incCheckinCounter(justCheckedInUser.NumberOfCheckin__c);
            }
            
            log(''+notifications);
        } catch(Exception e) {
            log('Some error occurred: ' + e.getMessage());
        }
        if(notifications.size() > 0) {
            try {
                insert notifications;
            } catch(Exception e) {
                log('UserTrigger: Exception on saving notifications ' + notification + ' Error: ' + e.getMessage());
            }
        }
        
        try {
            //Update related objects for gamification - if any 
            update accountsToUpdate;
            update contactsToUpdate;
            update casesToUpdate;
        } catch (Exception e) {
            log('Some error occurred: ' + e.getMessage());        
        }
    }
    
    private boolean fieldChanged(String f, String fa) {
        return (f == null && fa != null)    
            || (f != null && fa == null)
            || (f != null && fa != null && !f.equalsIgnoreCase(fa));
    }
    
    private Decimal incCheckinCounter(Decimal numberOfCheckin) {
        return numberOfCheckin == null ? 1 : numberOfCheckin + 1;
    }
    
    private void log(String msg) {
        System.debug('*** ' + msg);
    }
}