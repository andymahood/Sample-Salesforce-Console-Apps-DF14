public with sharing class ProfileTabUserController {
// Purpose: Custom Chatter profile page
private ApexPages.StandardController c;
// Getter methods you can call from your Visualforce page, e.g. {!viewingMyProfile} 
public User subjectUser { get; set; }
public boolean viewingMyProfile { get; set; } // Whether or not I’m viewing my profile
public String viewerID { get; set; } // UID string for the viewing user
public String subjectID { get; set; } // UID string for the subject user (being viewed)
// Constructor method for the controller
public ProfileTabUserController(ApexPages.StandardController
stdController) {
c = stdController;
subjectID = getTargetSFDCUID();
// If we're operating inside a tab running inside of a profile...
if (subjectID != null) {
// Inject the sfdc.userId URL parameter value into the id param
// so the std User controller loads the right User record
ApexPages.currentPage().getParameters().put('id',
subjectID);
}
// Load the User record for the user whose profile we’re viewing
this.subjectUser = (User)stdController.getRecord();
Id viewer = Id.valueOf(UserInfo.getUserId());
Id subject = Id.valueOf(subjectID);
viewingMyProfile = (viewer == subject);
viewerID = UserInfo.getUserId();
}
// Fetches URL parameter passed into a profile tab indicating which user is being viewed
private String getTargetSFDCUID() {
return
ApexPages.currentPage().getParameters().get('sfdc.userId');
}
// Overrides StandardController save method to force reload of current page afterwards
public PageReference save() {
c.save();
return ApexPages.currentPage();
}
// Overrides StandardController cancel method to force page reload
public PageReference cancel() {
c.cancel();
return ApexPages.currentPage();
}
}