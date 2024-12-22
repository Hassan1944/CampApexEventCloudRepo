trigger CAMPX_Event_Trigger on CAMPX__Event__c (before insert,after insert,before update,after update,before delete ,after delete, after undelete) {
    //adding for deployment 
    EventTriggerHandlerFactory eventhandler= new EventTriggerHandlerFactory();
        eventhandler.doAction();
}