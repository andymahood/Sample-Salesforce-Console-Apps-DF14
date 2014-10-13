@isTest
public class TquilaCommunityTest {

    public static testMethod void testMyController() {
        PageReference pageRef = Page.TquilaCommunityHome;
        Test.setCurrentPage(pageRef);
        TquilaCommunityHome tch = new TquilaCommunityHome();
    }
        
}