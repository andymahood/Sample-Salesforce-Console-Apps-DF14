public class TquilaCommunityHome{
   
    public User currentUser {get; set;}
    public List<Case> listCases {get; set;}
    public List<Idea> listIdeas {get; set;}
    
    public TquilaCommunityHome(){
        currentUser = [Select FirstName, LastName, ContactId, Phone, Email, SmallPhotoURL, FullPhotoURL, City, Street, Country, PostalCode from User where id = :UserInfo.getUserId()];
        listCases = [SELECT Id, CaseNumber, Subject, Status, LastModifiedDate FROM Case WHERE ContactId = : currentUser.ContactId ORDER BY LastModifiedDate DESC LIMIT 5];
        listIdeas = [SELECT Id, Title, VoteTotal FROM Idea ORDER BY VoteTotal DESC LIMIT 5];
    }
    
}