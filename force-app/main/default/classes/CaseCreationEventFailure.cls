public with sharing class CaseCreationEventFailure implements EventBus.EventPublishFailureCallback{

    List<CaseEventInfo> events;
    public CaseCreationEventFailure(List<CaseEventInfo> events) {
        this.events=events;
    }
    /**
    * @description: This method is a callback method and triggers when a platform event is failed
    * @author:Aravind
    * @params:EventBus.FailureResul
    **/
    public void onFailure(EventBus.FailureResult result) {

        try{
            List<String> eventUuids = result.getEventUuids();
            Map<String,Id> caseUuidsMap = new Map<String,Id>();

            for(CaseEventInfo caseEventInfo: events) {
                caseUuidsMap.put(caseEventInfo.eventUuid,caseEventInfo.accountId);
            }

            Map<Id,Account> accountMap=new Map<Id,Account>([SELECT Id,OwnerId FROM Account where Id IN :caseUuidsMap.values() WITH SYSTEM_MODE]);
            //Incase of failed platform events creates a task to the account owner
            List<task> tasks=new List<task>();
            for(String uuid:eventUuids){
                Id failedAccount=caseUuidsMap.get(uuid);
                Account acc=accountMap.get(failedAccount);
                Task t = new Task();
                t.WhatId = acc.Id;
                t.ActivityDate = Date.today().addDays(1);
                t.Subject = 'Follow up on event publishing failure.';
                t.Description ='Events failed to publish. Event UUID: ' + uuid +'Please Create the case manually';
                t.OwnerId = acc.OwnerId;
                tasks.add(t);
            }
           
            List<Database.SaveResult> srList= Database.insert(tasks,false,AccessLevel.SYSTEM_MODE);

        }
        catch(Exception ex){
            system.debug('error :'+ex.getMessage()+' on line '+ex.getLineNumber());
        }
   }    

    /**
    * @description: This class is used to hold the event information
    * @author:Aravind
    * @params:N/A
    **/
   public class CaseEventInfo {
        public String eventUuid;
        public Id accountId;

        public CaseEventInfo(String eventUuid, Id accountId) {
            this.eventUuid = eventUuid;
            this.accountId = accountId;
        }
    }
}