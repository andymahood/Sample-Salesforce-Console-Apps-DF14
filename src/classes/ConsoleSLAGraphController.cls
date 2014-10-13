public with sharing class ConsoleSLAGraphController {

    public String CaseId  { get; set; }
    public Boolean ShowWarning { get;set; }
    private Decimal TARGET_DURATION = 50;

    public List<SLAData> getSLAData() {
        Map<Id, SLAData> data = new Map<Id, SLAData>();

        //query all the cases split by owner
        AggregateResult[] groupedResults = [SELECT OwnerId, Owner.Alias alias, AVG(DB_Case_Duration_Hours__c) aveDuration
                                            FROM Case 
											WHERE DateTime_Closed__c!=null AND Owner.Alias!=null
                                            GROUP BY OwnerId, Owner.Alias];

        //where we find a caseId value find the details of this case to overlay on the chart
        Decimal selectedCaseDuration = 0;
        system.debug('CaseId...'+CaseId);
        if (CaseId!=null) {
            List<Case> selectedCase = [SELECT Id, OwnerId, DB_Case_Duration_Hours__c FROM Case WHERE Id = :CaseId];
            if (selectedCase!=null && !selectedCase.isempty()) {
                selectedCaseDuration = selectedCase[0].DB_Case_Duration_Hours__c; 
                ShowWarning = (selectedCaseDuration>=TARGET_DURATION);//set flag when the duration of selected case is over the target
            }
        }
		
        //build the dataset to populate the visualforce chart
		for (AggregateResult ar : groupedResults)  {
		    data.put((Id)ar.get('OwnerId'), 
                    new SLAData((Id)ar.get('OwnerId'), (String)ar.get('alias'), (Decimal)ar.get('aveDuration'), TARGET_DURATION, selectedCaseDuration));
		}

        return data.values();
    }

    // Wrapper class for the visualforce chart
    public class SLAData {
        public Id OwnerId { get; set; }
        public String Alias { get; set; }
        public Decimal AveCloseDuration { get; set; }
        public Decimal TargetCloseDuration { get; set; }
        public Decimal CurrentCaseDuration { get; set; }

        public SLAData(Id oId, String alias, Decimal aveClose, Decimal targetClose, Decimal currentCase) {
            this.OwnerId = oId;
            this.Alias = alias;
            this.AveCloseDuration = aveClose;
            this.TargetCloseDuration = targetClose;
            this.CurrentCaseDuration = currentCase;
        }
    }
}