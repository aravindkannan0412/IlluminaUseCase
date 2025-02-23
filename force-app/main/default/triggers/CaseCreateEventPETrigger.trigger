trigger CaseCreateEventPETrigger on CaseCreatorEvent__e (after Insert) {
    TriggerFrameWork trg=new CaseCreationEventHandler();
    trg.runAllTriggerContext();
}