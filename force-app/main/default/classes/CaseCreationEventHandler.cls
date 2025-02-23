public with sharing class CaseCreationEventHandler extends TriggerFrameWork {

    List<CaseCreatorEvent__e> newList;

    public CaseCreationEventHandler() {
        this.newList=Trigger.new;
    }
    
    /**
    * @description: overided handler method 
    * @author:Aravind
    * @params:N/A
    **/
    public override void afterInsert(){
        CaseCreationEventUtitily.createCaseBasedOnEvent(newList);
    }
}