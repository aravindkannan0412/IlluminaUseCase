public with sharing class CaseCreationEventUtitily {

    public static final String CASES_OBJECT = 'Case';
    public static final String DEFAULT_QUEUE_NAME = 'InternalSupport_Queue';

    private static Id defaultQueueId;
    private static Id assignmentRuleId;

    // Query Assignment Rule or Default Queue assigns only once per execution
    static {
        initializeDefaults();
    }

    /**
    * @description: initializations metthods
    * @author:Aravind
    * @params:N/A
    **/
    private static void initializeDefaults() {
        //using Coalescing Operator  to skip the list has no rows to assign Errors
        AssignmentRule ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = :CASES_OBJECT AND Active = TRUE LIMIT 1] ?? null;
        assignmentRuleId = ar != null ? ar.Id : null;

        // If no assignment rule, fetch default queue
        if (assignmentRuleId == null || Test.isRunningTest()) {
            QueueSobject defaultQueue = [SELECT QueueId FROM QueueSobject WHERE SobjectType = :CASES_OBJECT 
                                        AND Queue.DeveloperName = :DEFAULT_QUEUE_NAME LIMIT 1] ?? null;
            defaultQueueId = defaultQueue != null ? defaultQueue.QueueId : null;
        }

    }

    /**
    * @description: create case based on the published events
    * @author:Aravind
    * @params:caseEventList
    **/
    public static void createCaseBasedOnEvent(List<CaseCreatorEvent__e> caseEventList) {
        //no try catch blocks as exceptions are handled in run time
        if (caseEventList == null || caseEventList.isEmpty()) return; 

        List<Case> caseList = new List<Case>();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.optAllOrNone = false;

        if (assignmentRuleId != null) {
            dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRuleId;
        }

        for (CaseCreatorEvent__e caseEvent : caseEventList) {
            Case caseobj=new Case();
            caseobj.AccountId = caseEvent.AccountId__c;
            caseobj.Subject = caseEvent.Subject__c;
            caseobj.Description = caseEvent.Description__c;
            caseobj.Origin = caseEvent.Origin__c;
            caseobj.Priority = caseEvent.Priority__c;
            if(defaultQueueId != null){
               caseobj.OwnerId=defaultQueueId;
            }
            caseList.add(caseobj);
        }

        if (!caseList.isEmpty()) {
            List<Database.SaveResult> srList = Database.insert(caseList, dmlOpts);
            logErrors(srList, caseList);
        }
    }

    /**
    * @description: log errors on the case creation
    * @author:Aravind
    * @params:caseEventList
    **/
    private static void logErrors(List<Database.SaveResult> srList, List<Case> caseList) {
        for (Integer i = 0; i < srList.size(); i++) {
            if (!srList[i].isSuccess() && i < caseList.size()) {
                Database.Error error = srList[i].getErrors().get(0);
                System.debug('Error on Account Id ' + caseList[i].AccountId + ' - ' + error.getMessage());
            }
        }
    }
}