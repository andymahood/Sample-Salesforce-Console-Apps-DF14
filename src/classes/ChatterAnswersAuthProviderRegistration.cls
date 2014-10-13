global class ChatterAnswersAuthProviderRegistration implements Auth.RegistrationHandler{
global User createUser(Id portalId, Auth.UserData data){
	Savepoint sp = Database.setSavepoint();
	String accountId = null;
	try { 
		accountId = new ChatterAnswersRegistration().createAccount(data.firstname, data.lastname, Site.getAdminId());
	} catch (Exception e) {
		Database.rollback(sp);
		return null;
	}
	User u = new User();
	u.FirstName = data.firstname;
	u.LastName = data.lastname;
	u.Username = accountId + '@facebook.com';
	u.Email = data.email;
	u.CommunityNickname = data.email.substring(0,  data.email.indexOf('@')) + System.currentTimeMillis();
	u.UserPermissionsChatterAnswersUser = true;
	//If using this registration handler with Salesforce Community registration then specify the profileid to associated with the new user.
	//This profile is used only for Salesforce Community site registration and not for standalone Force.com site registration.
	//u.profileId = '';
	Site.setPortalUserAsAuthProvider(u, accountId);
	return u;
}

global void updateUser(Id userId, Id portalId, Auth.UserData data){
	Savepoint sp = Database.setSavepoint();
	User u = [SELECT Contact.email, Contact.firstName, Contact.lastName FROM User WHERE id=:userId];
	u.Contact.email = data.email;
	u.Contact.firstName = data.firstName;
	u.Contact.lastName = data.lastName;
	u.firstName = data.firstName;
	u.lastName = data.lastName;
	u.email = data.email;
	try {
		update u;
		update u.Contact;
	 } catch (Exception e) {
		Database.rollback(sp);
	}
}
}