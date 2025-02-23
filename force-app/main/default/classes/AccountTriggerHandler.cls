public with sharing class AccountTriggerHandler extends  TriggerFrameWork {
    
    private List<Account> newList;
    private List<Account> oldList;
    private Map<Id,Account> newMap;
    private Map<Id,Account> oldMap;
    
    public AccountTriggerHandler() {
        this.newList=Trigger.new;
        this.oldList=Trigger.old;
        this.newMap=(Map<Id,Account>)Trigger.newMap;
        this.oldMap=(Map<Id,Account>)Trigger.oldMap;
    }
     /**
    * @description: overided handler method 
    * @author:Aravind
    * @params:N/A
    **/
    public override void afterUpdate(){
        AccountTriggerUtility.createCaseOnHighPriorityAccounts(this.newList, this.oldMap);
    }

    /**
    * @description: overided handler method 
    * @author:Aravind
    * @params:N/A
    **/
    public override void afterInsert(){
        AccountTriggerUtility.createCaseOnHighPriorityAccounts(this.newList, new Map<Id,Account>());
    }

}