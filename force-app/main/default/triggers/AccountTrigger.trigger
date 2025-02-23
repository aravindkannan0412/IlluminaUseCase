trigger AccountTrigger on Account (before update,after insert,after update) {

    TriggerFrameWork trg=new AccountTriggerHandler();
    trg.runAllTriggerContext();

}