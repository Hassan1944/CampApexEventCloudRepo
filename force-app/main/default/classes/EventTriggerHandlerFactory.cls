public with sharing class EventTriggerHandlerFactory {
    list<CAMPX__Event__c> Triggernew;
    list<CAMPX__Event__c> Triggerold;
    map<Id, CAMPX__Event__c> Triggernewmap;
    map<Id, CAMPX__Event__c> Triggeroldmap;

    public EventTriggerHandlerFactory() {
        // Constructor to get the data of trigger Context Variables
        Triggernew = (list<CAMPX__Event__c>) Trigger.new;
        Triggerold = (list<CAMPX__Event__c>) Trigger.old;
        Triggernewmap = (map<Id, CAMPX__Event__c>) Trigger.newMap;
        Triggeroldmap = (map<Id, CAMPX__Event__c>) Trigger.oldMap;
    }

    // Main Method for handling the Actions
    public void doAction() {
        switch on Trigger.OperationType {
            when BEFORE_INSERT  {
                onBeforeInsert();
            }
            when AFTER_INSERT {
                onAfterInsert();
            }
            when BEFORE_UPDATE {
                onBeforeUpdate();
            }
            when AFTER_UPDATE {
                onAfterUpdate();
            }
            when BEFORE_DELETE {
                onBeforeDelete();                
            }
            when AFTER_DELETE {
                onAfterDelete();
            }
            when AFTER_UNDELETE {
                onAfterUndelete();
            }
        }
    }

    public void onBeforeInsert() {
        // Handle before insert logic
        validateEventinsert();
        // add a comment to retrigger
        updateFinace(Triggernew);
    }

    public void onAfterInsert(){
        // Handle after insert logic if needed
        // to handele after insert logic
    }

    public void onAfterUpdate() {
        // Capture the date when the status changes
       
    }

    public void onBeforeUpdate() {
        // Before update logic if needed
        validatedatechangeofstatus();
        updateFinace(Triggernew);
        
    }

    public void onBeforeDelete() {
        // Before delete logic if needed
    }

    public void onAfterDelete() {
        // After delete logic if needed
    }

    public void onAfterUndelete() {
        // After undelete logic if needed
    }

    // Ensures that the status is set to 'Planning' before insert
    public void validateEventinsert() {
        for(CAMPX__Event__c evt : Triggernew){
            evt.CAMPX__StatusChangeDate__c=System.now();
            if(evt.CAMPX__Status__c != 'Planning'){
                evt.CAMPX__Status__c = 'Planning';
            }
        }
    }

    // Validates if the status has changed and captures the current timestamp
    public void validatedatechangeofstatus() {
        for (CAMPX__Event__c event : Triggernew) {
            // Check if the status has changed
            if (event.CAMPX__Status__c != TriggeroldMap.get(event.Id).CAMPX__Status__c) {
                // Set the current date and time in the StatusChangeDate field
                event.CAMPX__StatusChangeDate__c = System.now();
            }
        }
    }
    
    public static void updateFinace(List<CAMPX__Event__c> Tnew){
        for(CAMPX__Event__c nevnt: Tnew){
            // Check if CAMPX__GrossRevenue__c and CAMPX__TotalExpenses__c are null, and handle accordingly
            if(nevnt.CAMPX__GrossRevenue__c == null && nevnt.CAMPX__TotalExpenses__c == null){
                nevnt.CAMPX__NetRevenue__c = null;
            } else if (nevnt.CAMPX__GrossRevenue__c == null){
                nevnt.CAMPX__NetRevenue__c = -nevnt.CAMPX__TotalExpenses__c; // If only TotalExpenses are available, net revenue is negative of expenses
            } else if (nevnt.CAMPX__TotalExpenses__c == null){
                nevnt.CAMPX__NetRevenue__c = nevnt.CAMPX__GrossRevenue__c; // If only GrossRevenue is available, assume net revenue equals gross revenue
            } else {
                nevnt.CAMPX__NetRevenue__c = nevnt.CAMPX__GrossRevenue__c - nevnt.CAMPX__TotalExpenses__c; // Perform the normal calculation
            }
        }
    }
}
