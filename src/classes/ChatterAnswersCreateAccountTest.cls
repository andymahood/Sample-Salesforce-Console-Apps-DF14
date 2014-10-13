@isTest
private class ChatterAnswersCreateAccountTest {
	static testMethod void validateAccountCreation() {
		Profile[] p = [SELECT Id FROM Profile WHERE UserType = 'Standard'];
		User[] user = [SELECT Id, Firstname, Lastname FROM User WHERE IsActive = true and ProfileId =: p[0].Id];
		// We cannot create account without a user.
		if (user.size() == 0) { return; }
		String firstName = user[0].FirstName;
		String lastName = user[0].LastName;
		String userId = user[0].Id;
		String accountId = new ChatterAnswersRegistration().createAccount(firstName, lastName, userId);
		Account account = [SELECT name, ownerId from Account where Id =: accountId];
		System.assertEquals(firstName + ' ' + lastName, account.name);
		System.assertEquals(userId, account.ownerId);
	}
}