public with sharing class SponserEventHelper {
    public static boolean isRunning = false;

    public static void defaultValuesAssign(list<CAMPX__Sponsor__c> triggernew){
        for(CAMPX__Sponsor__c spnr : triggernew){
            if(spnr.CAMPX__Status__c == null || spnr.CAMPX__Status__c == ''){
                spnr.CAMPX__Status__c = 'Pending';
            }
            if(spnr.CAMPX__Email__c == null || spnr.CAMPX__Email__c == ''){
                spnr.addError('A sponsor can not be created without an email address');
            }
        }
    }
//adding for the deployment
    public static void assignTierToSponser(list<CAMPX__Sponsor__c> triggerNew){
        for(CAMPX__Sponsor__c nspr : triggerNew){
            if(nspr.CAMPX__ContributionAmount__c == 0 || nspr.CAMPX__ContributionAmount__c == null || nspr.CAMPX__ContributionAmount__c <= 0){
                nspr.CAMPX__Tier__c = '';
            } else if(nspr.CAMPX__ContributionAmount__c < 1000){
                nspr.CAMPX__Tier__c = 'Bronze';
            } else if(nspr.CAMPX__ContributionAmount__c <= 5000){
                nspr.CAMPX__Tier__c = 'Silver';
            } else {
                nspr.CAMPX__Tier__c = 'Gold';
            }
        }
    }

    public static void verifySponserEvents(list<CAMPX__Sponsor__c> triggerNew){
        
        for(CAMPX__Sponsor__c nspr : triggerNew){
            if(nspr.CAMPX__Status__c == 'Accepted' && nspr.CAMPX__Event__c == null){
                nspr.addError('A Sponsor must be associated with an event before being Accepted.');
            }
        }
    }

    public static void validateSponsorEvent(List<CAMPX__Sponsor__c> triggerNew) {
        for (CAMPX__Sponsor__c spnr : triggerNew) {
            // If sponsor status is 'Accepted' and no event is associated, throw an error
            if (spnr.CAMPX__Status__c == 'Accepted' && spnr.CAMPX__Event__c == null) {
               spnr.addError('A Sponsor must be associated with an event before being Accepted.');
            }
        }
    }

    public static void updateEventAmount(List<CAMPX__Sponsor__c> triggerNew) {
        Map<Id, Decimal> mapForEvnttoUpdate = new Map<Id, Decimal>();
        List<CAMPX__Event__c> toupdateEvnt = new List<CAMPX__Event__c>();

        if (!triggerNew.isEmpty()) {
            // Loop through all sponsor records that were updated or inserted
            for (CAMPX__Sponsor__c spnr : triggerNew) {
                // Check if the sponsor is accepted and has a valid contribution amount
                if (spnr.CAMPX__Event__c != null && spnr.CAMPX__Status__c == 'Accepted' && spnr.CAMPX__ContributionAmount__c != null) {
                    // If the event already has a contribution, add the new one
                    if (mapForEvnttoUpdate.containsKey(spnr.CAMPX__Event__c)) {
                        mapForEvnttoUpdate.put(spnr.CAMPX__Event__c, mapForEvnttoUpdate.get(spnr.CAMPX__Event__c) + spnr.CAMPX__ContributionAmount__c);
                    } else {
                        mapForEvnttoUpdate.put(spnr.CAMPX__Event__c, spnr.CAMPX__ContributionAmount__c);
                    }
                }
            }

            // If there are any events to update
            if (mapForEvnttoUpdate.size() > 0) {
                List<CAMPX__Event__c> existingEvent = [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id IN :mapForEvnttoUpdate.keySet()];

                for (CAMPX__Event__c event : existingEvent) {
                    Decimal accumulatedContrib = mapForEvnttoUpdate.get(event.Id);
                    event.CAMPX__GrossRevenue__c = (event.CAMPX__GrossRevenue__c != null ? event.CAMPX__GrossRevenue__c : 0) + accumulatedContrib;
                    toupdateEvnt.add(event);
                }

                // Update events with new gross revenue
                if (!toupdateEvnt.isEmpty()) {
                    update toupdateEvnt;
                }
            }
        }
    }

    public static void UpdateGRInEvnt(Map<Id, CAMPX__Sponsor__c> Triggernewmap, Map<Id, CAMPX__Sponsor__c> Triggeroldmap) {
        Map<Id, Decimal> toStoreNewGR = new Map<Id, Decimal>();
        List<CAMPX__Event__c> toUpdateEvt = new List<CAMPX__Event__c>();

        // Loop through the new map of sponsors
        for (CAMPX__Sponsor__c spnr : Triggernewmap.values()) {
            // Check if the status of the sponsor changed from "Accepted" to another status or if the Event lookup was changed
            if ((Triggeroldmap.containsKey(spnr.Id) && Triggeroldmap.get(spnr.Id).CAMPX__Status__c == 'Accepted' &&
                 spnr.CAMPX__Status__c != 'Accepted') || 
                (spnr.CAMPX__Event__c != Triggeroldmap.get(spnr.Id).CAMPX__Event__c)) {

                // Get the old event from Trigger.oldMap to subtract the contribution
                CAMPX__Sponsor__c oldSponsor = Triggeroldmap.get(spnr.Id);
                if (oldSponsor != null && oldSponsor.CAMPX__Event__c != null) {
                    Id eventId = oldSponsor.CAMPX__Event__c;

                    // Track the gross revenue to subtract the sponsor's contribution from the old event
                    if (!toStoreNewGR.containsKey(eventId)) {
                        toStoreNewGR.put(eventId, 0);
                    }
                    if (oldSponsor.CAMPX__ContributionAmount__c != null) {
                        toStoreNewGR.put(eventId, toStoreNewGR.get(eventId) - oldSponsor.CAMPX__ContributionAmount__c);
                    }
                }
            }
        }

        // Query the events we need to update based on the map of events affected
        if (!toStoreNewGR.isEmpty()) {
            List<CAMPX__Event__c> eventsToUpdate = [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id IN :toStoreNewGR.keySet()];

            for (CAMPX__Event__c evt : eventsToUpdate) {
                Decimal newGrossRevenue = evt.CAMPX__GrossRevenue__c != null ? evt.CAMPX__GrossRevenue__c : 0;
                newGrossRevenue += toStoreNewGR.get(evt.Id);
                evt.CAMPX__GrossRevenue__c = newGrossRevenue;
                toUpdateEvt.add(evt);
            }

            if (!toUpdateEvt.isEmpty()) {
                update toUpdateEvt;
            }
        }
    }
}