public with sharing class AccountTriggerUtility {

    public static final string ORIGINFORCASE='InternalAccount';
    public static final string IMPACTED='Impacted';
    public static final string HYPEN='-';
    public static final string HIGH='High';
    public class CustomException extends Exception {}

    /**
    * @description: This method is used to publish PE whenever the Risk is High
    * @author:Aravind
    * @params:accList,accMap
    **/
    public static void createCaseOnHighPriorityAccounts(List<Account> accList, Map<Id,Account> accMap){

        try{
            List<CaseCreatorEvent__e> caseEventList=new List<CaseCreatorEvent__e>();
            //CaseCreationEventFailure is to call the failure callback when the even has failed in the event bus
            List<CaseCreationEventFailure.CaseEventInfo> cbDataLst=new List<CaseCreationEventFailure.CaseEventInfo>();
            // using a wrapper instead of map for faster execution and reduced heap size

            for(Account currAcc:accList){ 
                Account oldAcc=accMap.get(currAcc.Id);
                if(currAcc.Risk__c==HIGH && currAcc.Risk__c!=oldAcc.Risk__c){
                    CaseCreatorEvent__e caseEvent=(CaseCreatorEvent__e) CaseCreatorEvent__e.sObjectType.newSObject(null, true);
                    caseEvent.AccountId__c=currAcc.Id;
                    caseEvent.Origin__c= ORIGINFORCASE;
                    caseEvent.Priority__c=currAcc.Risk__c;   
                    caseEvent.Subject__c=currAcc.AccountNumber+HYPEN+IMPACTED;
                    caseEvent.Description__c=currAcc.Description; 
                    caseEventList.add(caseEvent); 
                    CaseCreationEventFailure.CaseEventInfo cbInfo=new CaseCreationEventFailure.CaseEventInfo(caseEvent.EventUuid,currAcc.Id);
                    cbDataLst.add(cbInfo);
                }    
            }   
            if(caseEventList.size()>0){
                List<Database.SaveResult> srList=EventBus.publish(caseEventList,new CaseCreationEventFailure(cbDataLst));    
            }
        }
        catch(Exception ex){
            throw new CustomException('error :'+ex.getMessage());
        }        
    }
}