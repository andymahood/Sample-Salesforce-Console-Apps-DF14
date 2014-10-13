/*
    Author:         ben@tquila.com
    Description:    Controller for SPM_TimeDelete. This override is required for the clickjack
    				issue with iframing standard SF pages
*/
public with sharing class SPM_TimeDeleteController {

	public SPM_TimeDeleteController(ApexPages.StandardController controller) {}

	public void deleteTimeRecord()
	{
		delete [Select Id From Time__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
	}
}