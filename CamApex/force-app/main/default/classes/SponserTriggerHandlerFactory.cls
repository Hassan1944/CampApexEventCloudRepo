public with sharing class SponserTriggerHandlerFactory {
    // Directly using trigger context variables
    List<CAMPX__Sponsor__c> Triggernew;
    List<CAMPX__Sponsor__c> Triggerold;
    Map<Id, CAMPX__Sponsor__c> Triggernewmap;
    Map<Id, CAMPX__Sponsor__c> Triggeroldmap;

    public SponserTriggerHandlerFactory() {
        // Initialize the trigger context variables
        Triggernew = (List<CAMPX__Sponsor__c>) Trigger.new;
        Triggerold = (List<CAMPX__Sponsor__c>) Trigger.old;
        Triggernewmap = (Map<Id, CAMPX__Sponsor__c>) Trigger.newMap;
        Triggeroldmap = (Map<Id, CAMPX__Sponsor__c>) Trigger.oldMap;
    }

    // Main Method for handling the Actions
    public void doAction() {
        if (Trigger.isBefore) {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    onBeforeInsert();
                }
                when BEFORE_UPDATE {
                    onBeforeUpdate();
                }
                when BEFORE_DELETE {
                    onBeforeDelete();
                }
            }
        } else if (Trigger.isAfter) {
            switch on Trigger.operationType {
                when AFTER_INSERT {
                    onAfterInsert();
                }
                when AFTER_UPDATE {
                    onAfterUpdate();
                }
                when AFTER_DELETE {
                    onAfterDelete();
                }
                when AFTER_UNDELETE {
                    onAfterUndelete();
                }
            }
        }
    }

    public void onBeforeInsert() {
         
        // Validate and assign default values before insert
        SponserEventHelper.defaultValuesAssign(Trigger.new);
        SponserEventHelper.assignTierToSponser(Trigger.new);
        SponserEventHelper.verifySponserEvents(Trigger.new);
                SponserEventHelper.validateSponsorEvent(Trigger.new);

    }

    public void onAfterInsert() {
        // After insert: Update event gross revenue
        SponserEventHelper.updateEventAmount(Trigger.new);
    }

    public void onBeforeUpdate() {
        // Validate before update: Check if sponsor is associated with event
        SponserEventHelper.validateSponsorEvent(Trigger.new);

        // Ensure correct tier assignments before update
        SponserEventHelper.assignTierToSponser(Trigger.new);
    }

    public void onAfterUpdate() {
        // After update: Update event gross revenue
        
        SponserEventHelper.UpdateGRInEvnt(Triggernewmap, Triggeroldmap);
        SponserEventHelper.updateEventAmount(Trigger.new);
    }

    public void onBeforeDelete() {
        // Before delete: Optionally, handle any required pre-delete logic
    }

    public void onAfterDelete() {
        // After delete: Optionally, handle any required post-delete logic
    }

    public void onAfterUndelete() {
        // After undelete: Optionally, handle any required post-undelete logic
    }
}