global class umAuthProviderRegistration implements Auth.RegistrationHandler{

global User createUser(Id portalId, Auth.UserData data){
    //Let's validate data from FB
    //create a unique key in case some values are not defined
    String key = String.valueOf((Datetime.now()).getTime());

    data.username   = data.username == null ? key+'cam' : data.username;
    data.firstName  = data.firstName == null ? key+'cam' : data.firstName; 
    data.lastName   = data.lastName == null ? key+'cam' : data.lastName;
    data.email      = data.email == null ? key+'cam@cam.com' : data.email;

    //Create account
    Account a = new Account();
    a.Name = data.username + '@cam.com';
    insert(a);
    
    //Create contact
    Contact c = new Contact();
    c.accountId = a.Id;
    c.email = data.email;
    c.firstName = data.firstName;
    c.lastName = data.lastName;
    insert(c);

    map<String,Object> siteSetup = (map<String,Object>)umCustomSettingModel.getCurrentSiteSetup();
    list<Object> siteSetupListObj = (list<Object>) siteSetup.get('Sites');
    siteSetup = (map<String,Object>) siteSetupListObj[0];
    //If setup has no signupProfile value just return as we can't complete the action
    if ( siteSetup.get('signUpProfile__c') == null ) return null;

    list<Profile> ps = [SELECT Id FROM profile WHERE Name = :String.valueOf(siteSetup.get('signUpProfile__c'))];
    //If collection has no rows it means bad data in config page, ergo finish execution
    if ( ps.size() == 0 ) return null;
    Profile p = ps[0];

    User u = new User();
    u.UserPermissionsChatterAnswersUser = true;
    u.username = data.username + '@cam.com';
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    String alias = data.username;
    //Alias must be 8 characters or less
    if(alias.length() > 8) {
        alias = alias.substring(0, 8);
    }
    u.alias = alias;
    u.languagelocalekey = UserInfo.getLocale();
    u.localesidkey = UserInfo.getLocale();
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'America/Los_Angeles';
    u.profileId = p.Id;
    u.contactId = c.Id;
    return u;
}

global void updateUser(Id userId, Id portalId, Auth.UserData data){
    User u = new User(id=userId);
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    update(u);
}
}