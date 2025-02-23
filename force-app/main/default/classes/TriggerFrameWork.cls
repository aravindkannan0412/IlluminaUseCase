/**
* @description: This Trigger Framework is used to work with default logic and overidden logic using polymorphism and inheritance
* @author:Aravind
**/

public virtual with sharing class TriggerFrameWork {
    
    TriggerOperation context;
    
    public TriggerFrameWork() {
        this.context=Trigger.operationType;
    }


    public void runAllTriggerContext(){
        switch on this.context{

            when BEFORE_UPDATE{
                beforeUpdate();
            }

            when AFTER_UPDATE{
                afterUpdate();
            }

            when AFTER_INSERT{
                afterInsert();
            }
        }
    }
    
    protected virtual void beforeUpdate(){
        defaultLogicIfNotOverriden();
    }

    protected virtual void afterInsert(){
        defaultLogicIfNotOverriden();
    }

    protected virtual void afterUpdate(){
        defaultLogicIfNotOverriden();
    }

    private void defaultLogicIfNotOverriden(){
        system.debug('I am in common'+this.context);
    }
}