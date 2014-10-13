/**
 * @author Altimetrik
 * @description
 *      started at 9/11/2013
 *      Unit Tests for umController
 **/
@isTest
private class umControllerTest {

    
    @isTest(SeeAllData=true)
    static  void test_getUserDetails() {

        umProxy.Response response = null;
        String testRequestJson = '';
        umProxy.RequestItem testRequestItem = new umProxy.RequestItem();

        testRequestItem.operationType = 'getUserProfileDetail';
        Map<String,Object> opD = new Map<String,Object>();
        opD.put('userId', UserInfo.getUserId());
        testRequestItem.operationData = opD;
        umTestEnvironment.initData();

        Test.startTest();

        umProxy.Response o = umController.processResponse(testRequestItem);

        system.debug('\n============= :'+o);

        Test.stopTest();
    }

 
    @isTest(SeeAllData=false)
    static  void test_topicsForDataCategories() {

        String qString = 'books:fiction#music:all:Awards#';
        umProxy.CAM_ROOT_GROUP_NAME = 'TEST_ROOT_NAME';

        Test.startTest();

        String o = umController.topicsForDataCategories(qString);

        system.debug('\n============= :'+o);

        Test.stopTest();
    }



//coverage

 @isTest(SeeAllData=true)
    static  void test_processRequests() {

        umTestEnvironment.initData();

        Test.startTest();

        umProxy.Response response = null; 
        umProxy.RequestItem testRequestItem = new umProxy.RequestItem();

        set<String> allValidOps = new set<String>();
        allValidOps.addAll(umController.validOpsQA);
        allValidOps.addAll(umController.validOpsPKB);
        allValidOps.addAll(umController.validOpsCases);
        allValidOps.addAll(umController.validOps);

        for(String option : allValidOps){
            testRequestItem.operationType = option; 
            response=umController.processResponse(testRequestItem);
        }
 

        Test.stopTest();
    }




}