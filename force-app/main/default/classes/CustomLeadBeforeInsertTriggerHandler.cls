public class CustomLeadBeforeInsertTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		system.debug('**We are Inside Before Insert Lead__c Trigger**');

		Set<String> cloneSet = new Set<String>();
		Map<Id, Boolean> cloneMap = new Map<Id, Boolean>();
		List<Lead__c> customLeadList =(List<Lead__c>)tp.newList;

		for(Lead__c ld : customLeadList){
			cloneSet.add(ld.getCloneSourceId());
		}

		system.debug('cloneSet-->' +cloneSet);

		if(cloneSet!=null){
			List<Lead__c> ClonedLeadList = [SELECT Id, IsCreatedFromStandardLead__c FROM Lead__C WHERE Id IN :cloneSet];
			if(ClonedLeadList.size()>0){
				for(Lead__c ld : ClonedLeadList){
					cloneMap.put(ld.Id, ld.IsCreatedFromStandardLead__c);
				}
			}
		}

		for(Lead__c ld : customLeadList){

			if(!cloneMap.IsEmpty()){

				if(cloneMap.containsKey(ld.getCloneSourceId())){					ld.IsCreatedFromStandardLead__c = false;
					system.debug('IsCreatedFromStandardLead__c is set as False in Before Insert During Clone -> ' +ld.IsCreatedFromStandardLead__c);
				}
			}
		}
		
	}
}