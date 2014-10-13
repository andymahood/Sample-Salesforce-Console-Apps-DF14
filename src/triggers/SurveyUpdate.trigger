trigger SurveyUpdate on Case (before insert) {
  for(Case myCase : trigger.new)
    {
        if (myCase.subject == null)
        {
            return;
        }
        if (myCase.Subject.startsWith('Data Collected') && myCase.Description.contains('DialledNbr = ') && myCase.Description.contains('CLID'))
        {
            Integer indexOfClid = myCase.Description.indexOf('CLID');
            String descriptionFromClid = myCase.Description.substring(indexofClid + 7);
            string clid = descriptionFromClid.substring(0, descriptionFromClid.indexOf('\n'));
            
            Integer indexOfGuid = myCase.Description.indexOf('Guid');
            String descriptionFromGuid = myCase.Description.substring(indexofGuid + 7);
            string guid = descriptionFromGuid.substring(0, descriptionFromGuid.indexOf('\n'));

            Integer indexOfAgent = myCase.Description.indexOf('Agent');
            String descriptionFromAgent = myCase.Description.substring(indexofAgent + 11);
            string agent = descriptionFromAgent.substring(0, descriptionFromAgent.indexOf('\n'));
                
            Boolean badRecommend = myCase.Description.contains('Recommend the service = 2');
            Boolean badOutcome = myCase.Description.contains('Satisfied With Outcome = 2');
            String surveyDate = myCase.Subject.substring(myCase.Subject.indexOf(' at ') + 4, myCase.Subject.length());
                
            String[] dateAndTime = surveyDate.split(' ');

            String[] dateParts = dateAndTime[0].split('/');
            String year = dateParts[2];
            String month = dateParts[1];
            String day = dateParts[0];
              
            String[] timeParts = dateAndTime[1].split(':');
            String hour = timeParts[0];
            String minute = timeParts[1];
            String second = timeParts[2];               
               
            String stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute +  ':' + second;
            DateTime theDateTime = datetime.valueOf(stringDate);
                                
            List<List<SObject>> searchList = [FIND :clid IN phone FIELDS RETURNING Account(Id)];
            Account [] accounts = ((List<Account>)searchList[0]);
            
            for(Account foundAccount : accounts)
            {
                myCase.AccountId = foundAccount.Id;
                if (badRecommend)
                {
                    foundAccount.Recommend_to_Friend__c = 'No';
                }
                else
                {
                    foundAccount.Recommend_to_Friend__c = 'Yes';
                }
                if (badOutcome)
                {
                    foundAccount.Call_Outcome__c = 'Bad';
                }
                else
                {
                    foundAccount.Call_Outcome__c = 'Good';
                }
                if(badRecommend || badOutcome)
                {
                    foundAccount.Poor_Previous_Experience__c = true;
                }
                else
                {
                    foundAccount.Poor_Previous_Experience__c = false;
                }
                
                foundAccount.Survey_Date__c = theDateTime;
                foundAccount.Survey_Agent__c = agent;                   

                update foundAccount;
            }
        }
    }
}