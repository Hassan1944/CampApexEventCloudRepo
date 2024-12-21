trigger CAMPX_Sponsor_Trigger on CAMPX__Sponsor__c (before insert,after insert,before update,after update,before delete ,after delete, after undelete) {
 SponserTriggerHandlerFactory spnrhandler= new SponserTriggerHandlerFactory();
        spnrhandler.doAction();
}