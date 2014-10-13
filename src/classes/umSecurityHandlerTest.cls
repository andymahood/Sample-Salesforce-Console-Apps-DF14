/**
 * @author Altimetrik
 * @description
 *      started at 7/5/2013
 *      Unit Tests for umSecurityHandler
 **/
@isTest
private class umSecurityHandlerTest {

    public static testMethod void testSecurityEnabled() {
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {

                u[0].profileId = p.id;
                update u;
                System.assertEquals(umSecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
                System.assertEquals(umSecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
                System.assertEquals(umSecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(umSecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());

                System.assertEquals(umSecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
                System.assertEquals(umSecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
                System.assertEquals(umSecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

                System.assertEquals(umSecurityHandler.isAccessible(Question.sObjectType), Question.sObjectType.getDescribe().isAccessible());
                System.assertEquals(umSecurityHandler.isCreateable(Question.sObjectType), Question.sObjectType.getDescribe().isCreateable());
                System.assertEquals(umSecurityHandler.isUpdateable(Question.sObjectType), Question.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(umSecurityHandler.isDeletable(Question.sObjectType), Question.sObjectType.getDescribe().isDeletable());

                System.assertEquals(umSecurityHandler.isAccessible(Question.Title), Question.Title.getDescribe().isAccessible());
                System.assertEquals(umSecurityHandler.isCreateable(Question.Title), Question.Title.getDescribe().isCreateable());
                System.assertEquals(umSecurityHandler.isUpdateable(Question.Title), Question.Title.getDescribe().isUpdateable());

                if (Case.sObjectType.getDescribe().isAccessible())
                    umSecurityHandler.canAccess(Case.sObjectType);
                else
                    try {
                        umSecurityHandler.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.sObjectType.getDescribe().isCreateable())
                    umSecurityHandler.canCreate(Case.sObjectType);
                else
                    try {
                        umSecurityHandler.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.sObjectType.getDescribe().isUpdateable())
                    umSecurityHandler.canUpdate(Case.sObjectType);
                else
                    try {
                        umSecurityHandler.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.sObjectType.getDescribe().isDeletable())
                    umSecurityHandler.canDelete(Case.sObjectType);
                else
                    try {
                        umSecurityHandler.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.subject.getDescribe().isAccessible())
                    umSecurityHandler.canAccess(Case.subject);
                else
                    try {
                        umSecurityHandler.canAccess(Case.subject);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.subject.getDescribe().isCreateable())
                    umSecurityHandler.canCreate(Case.subject);
                else
                    try {
                        umSecurityHandler.canCreate(Case.subject);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}

                if (Case.subject.getDescribe().isUpdateable())
                    umSecurityHandler.canUpdate(Case.subject);
                else
                    try {
                        umSecurityHandler.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (umSecurityHandler.SecurityException e) {}
            }
        }
    }

    public static testMethod void testSecurityDisabled() {
        umSecurityHandler.securityEnabled = false;
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(umSecurityHandler.isAccessible(Case.sObjectType), true);
                System.assertEquals(umSecurityHandler.isCreateable(Case.sObjectType), true);
                System.assertEquals(umSecurityHandler.isUpdateable(Case.sObjectType), true);
                System.assertEquals(umSecurityHandler.isDeletable(Case.sObjectType), true);

                System.assertEquals(umSecurityHandler.isAccessible(Case.subject), true);
                System.assertEquals(umSecurityHandler.isCreateable(Case.subject), true);
                System.assertEquals(umSecurityHandler.isUpdateable(Case.subject), true);

                System.assertEquals(umSecurityHandler.isAccessible(Question.sObjectType), true);
                System.assertEquals(umSecurityHandler.isCreateable(Question.sObjectType), true);
                System.assertEquals(umSecurityHandler.isUpdateable(Question.sObjectType), true);
                System.assertEquals(umSecurityHandler.isDeletable(Question.sObjectType), true);

                System.assertEquals(umSecurityHandler.isAccessible(Question.Title), true);
                System.assertEquals(umSecurityHandler.isCreateable(Question.Title), true);
                System.assertEquals(umSecurityHandler.isUpdateable(Question.Title), true);

                umSecurityHandler.canAccess(Case.sObjectType);
                umSecurityHandler.canCreate(Case.sObjectType);
                umSecurityHandler.canUpdate(Case.sObjectType);
                umSecurityHandler.canDelete(Case.sObjectType);

                umSecurityHandler.canAccess(Case.subject);
                umSecurityHandler.canCreate(Case.subject);
                umSecurityHandler.canUpdate(Case.subject);

                umSecurityHandler.canAccess(Question.sObjectType);
                umSecurityHandler.canCreate(Question.sObjectType);
                umSecurityHandler.canUpdate(Question.sObjectType);
                umSecurityHandler.canDelete(Question.sObjectType);

                umSecurityHandler.canAccess(Question.Title);
                umSecurityHandler.canCreate(Question.Title);
                umSecurityHandler.canUpdate(Question.Title);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add( Question.Title );
                fieldList.add( Case.subject );
                umSecurityHandler.toString(fieldList);

                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add( Question.sObjectType );
                objectTypeList.add( Case.sObjectType );
                umSecurityHandler.toString(objectTypeList);
            }
        }
    }


}