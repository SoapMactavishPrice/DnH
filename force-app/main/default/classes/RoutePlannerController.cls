public with sharing class RoutePlannerController {
	
	public RoutePlannerController() {

	}

	@AuraEnabled
	public static string getStateList(String accessAllRecords, String entityType) {
		try {
			String fields = '';
			String whr = '';
			String grpBy = '';
			String ordBy = '';

			Id userId = UserInfo.getUserId();

			switch on entityType {
				when 'Account' {
					fields += ' SELECT BillingState state ' +
							' FROM Account ';
					// whr += ' WHERE Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += 'WHERE OwnerId =: userId ';
					}
					grpBy += ' GROUP BY BillingState ';
					ordBy += ' ORDER BY BillingState ';
				}
                when 'Contact' { fields += ' SELECT MailingState state ' + ' FROM Contact '; if(accessAllRecords == 'false') { whr += 'WHERE OwnerId =: userId ';} grpBy += ' GROUP BY MailingState '; ordBy += ' ORDER BY MailingState '; }
					
					
					// whr += ' WHERE Route_Planner__c = \'\' ';
							
		
				when 'Lead__c' { fields += ' SELECT State state ' + ' FROM Lead__c ';if(accessAllRecords == 'false') { whr += 'WHERE OwnerId =: userId '; } grpBy += ' GROUP BY State '; ordBy += ' ORDER BY State ';}
					

		/*		when 'Asset' {
					fields += ' SELECT State__c state ' +
							' FROM Asset ';
					// whr += ' WHERE Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += 'WHERE OwnerId =: userId ';
					}
					grpBy += ' GROUP BY State__c ';
					ordBy += ' ORDER BY State__c ';
				}		*/
			}

			List<Object> finalList = new List<Object>();
			System.debug(fields + whr + grpBy + ordBy);

			for(AggregateResult result : Database.query(fields + whr + grpBy + ordBy)) {
				Map<String, Object> tempMap = new Map<String, Object>();
				System.debug(result + '' + result.get('state'));
				if(String.isBlank(String.valueOf(result.get('state')))) { finalList.add(new Map<String, Object> {'value' => '', 'label' => '--Blank--'});
					
				}
				else {
					finalList.add(new Map<String, Object> {'value' => result.get('state'), 'label' => result.get('state')});
				}
			}
			// if(finalList.size() > 0)
				// finalList.add(0, new Map<String, Object> {'value' => 'None', 'label' => '--None--'});
			
			return JSON.serialize(finalList);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}


	@AuraEnabled
	public static string getCityList(String accessAllRecords, String entityType, String stateName) {
		try {
			String fields = '';
			String whr = '';
			String grpBy = '';
			String ordBy = '';

			Id userId = UserInfo.getUserId();

			switch on entityType {
				when 'Account' {
					fields += ' SELECT BillingCity city ' +
							' FROM Account ';
					whr += ' WHERE BillingState =: stateName ';
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					grpBy += ' GROUP BY BillingCity ';
					ordBy += ' ORDER BY BillingCity ';
				}
                
                when 'Contact' {
					fields += ' SELECT MailingCity city ' +
							' FROM Contact ';
					whr += ' WHERE MailingState =: stateName ';
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					grpBy += ' GROUP BY MailingCity ';
					ordBy += ' ORDER BY MailingCity ';
				}
				when 'Lead__c' {
					fields += ' SELECT City city ' +
							' FROM Lead__c ';
					whr += ' WHERE State =: stateName ';
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					grpBy += ' GROUP BY City ';
					ordBy += ' ORDER BY City ';
				}
		/*		when 'Asset' {
					fields += ' SELECT City__c city ' +
							' FROM Asset ';
					whr += ' WHERE State__c =: stateName ';
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					grpBy += ' GROUP BY City__c ';
					ordBy += ' ORDER BY City__c ';
				}	*/
			}

			List<Object> finalList = new List<Object>();
			System.debug(fields + whr + grpBy + ordBy);

			for(AggregateResult result : Database.query(fields + whr + grpBy + ordBy)) {
				Map<String, Object> tempMap = new Map<String, Object>();
				System.debug(result + '' + result.get('city'));
				if(String.isBlank(String.valueOf(result.get('city')))) { finalList.add(new Map<String, Object> {'value' => '', 'label' => '--Blank--'});
					
				}
				else {
					finalList.add(new Map<String, Object> {'value' => result.get('city'), 'label' => result.get('city')});
				}
			}
			if(finalList.size() > 0)
				finalList.add(0, new Map<String, Object> {'value' => '', 'label' => 'All'});

			return JSON.serialize(finalList);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}


/*	@auraEnabled
	public static String getLocationList(String accessAllRecords, String entityType, String stateName, String cityName) {
		try {
			if(entityType == 'Asset') {
				Id userId = UserInfo.getUserId();

				String fields = ' SELECT Site_Location__c ' +
							' FROM Asset ';
				String whr = ' WHERE State__c =: stateName ';
				if(String.isNotBlank(cityName)) {
					whr += ' AND City__c =: cityName ';
				}
				// whr += ' AND Route_Planner__c = \'\' ';
				if(accessAllRecords == 'false') {
					whr += ' AND OwnerId =: userId ';
				}
				String grpBy = ' GROUP BY Site_Location__c ';
				String ordBy = ' ORDER BY Site_Location__c ';

				List<Object> finalList = new List<Object>();
				System.debug(fields + whr + grpBy + ordBy);

				for(AggregateResult result : Database.query(fields + whr + grpBy + ordBy)) {
					Map<String, Object> tempMap = new Map<String, Object>();
					if(String.isBlank(String.valueOf(result.get('Site_Location__c')))) {
						finalList.add(new Map<String, Object> {'value' => result.get('Site_Location__c'), 'label' => '--Blank--'});
					}
					else {
						finalList.add(new Map<String, Object> {'value' => result.get('Site_Location__c'), 'label' => result.get('Site_Location__c')});
					}
				}
				if(finalList.size() > 0)
					finalList.add(0, new Map<String, Object> {'value' => '', 'label' => 'All'});

				return JSON.serialize(finalList);
			}
			else {
				throw new CustomException('Location is assigned with Asset only');
			}
		}
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}		*/


	@AuraEnabled
	public static Object getEntityRecords(String recordId, String accessAllRecords, String entityType, String stateName, String cityName, String locationName) {
		try {
			String fields = '';
			String whr = '';
			String ordBy = '';

			Id userId = UserInfo.getUserId();

			List<Object> finalList = new List<Object>();

			switch on entityType {
				when 'Account' {
					fields += ' SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, Owner.Name, '+
					'(SELECT Id FROM Route_Planner_Junction__r where Route_Planner__c =: recordId) FROM Account ';
					whr += ' WHERE BillingState =: stateName ';
					if(String.isNotBlank(cityName)) {
						whr += ' AND BillingCity =: cityName ';
					}
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					ordBy += ' ORDER BY Name ';

					System.debug(fields + whr + ordBy);
					for(Account acc : Database.query(fields + whr + ordBy)) {
						finalList.add(new Map<String, Object> {
							'Id' => acc.Id,
							'Column1' => acc.Name,
							'Column2' => acc.BillingStreet,
							'Column3' => acc.BillingCity,
							'Column4' => acc.BillingPostalCode,
							'Column5' => acc.Owner.Name,
							'isSelected' => acc.Route_Planner_Junction__r.size() == 0 ? false : true
						});
					}
				}

                when 'Contact' {
					fields += ' SELECT Id, Name, MailingStreet, MailingCity, MailingPostalCode, Owner.Name, '+
					'(SELECT Id FROM Route_Planner_Junction__r where Route_Planner__c =: recordId) FROM Contact ';
					whr += ' WHERE MailingState =: stateName ';
					if(String.isNotBlank(cityName)) {
						whr += ' AND MailingState =: cityName ';
					}
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					ordBy += ' ORDER BY Name ';

					System.debug(fields + whr + ordBy);
					for(Contact acc : Database.query(fields + whr + ordBy)) {
						finalList.add(new Map<String, Object> {
							'Id' => acc.Id,
							'Column1' => acc.Name,
							'Column2' => acc.MailingStreet,
							'Column3' => acc.MailingCity,
							'Column4' => acc.MailingPostalCode,
							'Column5' => acc.Owner.Name,
							'isSelected' => acc.Route_Planner_Junction__r.size() == 0 ? false : true
						});
					}
				}

				when 'Lead__c' {
					fields += ' SELECT Id, Name, Company_Name__c, Lead_Status__c, MobilePhone, Email, Lead_Source__c, Lead_For_Sub__c, Owner.Name, '+
					'(SELECT Id FROM Route_Planner_Junction__r where Route_Planner__c =: recordId) FROM Lead__c ';
					whr += ' WHERE State =: stateName ';
					if(String.isNotBlank(cityName)) {
						whr += ' AND City =: cityName ';
					}
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					ordBy += ' ORDER BY FirstName ';

					System.debug(fields + whr + ordBy);
					for(Lead__c ld : Database.query(fields + whr + ordBy)) {
						finalList.add(new Map<String, Object> {
							'Id' => ld.Id,
							'Column1' => ld.Name,
							'Column2' => ld.Company_Name__c,
							'Column3' => ld.Lead_Status__c,
							'Column4' => ld.Lead_Source__c,
					//		'Column5' => ld.Lead_For_Sub__c,
							'Column6' => ld.Owner.Name,
							'isSelected' => ld.Route_Planner_Junction__r.size() == 0 ? false : true
						});
					}
				}

	/*			when 'Asset' {
					fields += ' SELECT Id, Name, Account.Name, Street__c, Site_Location__c, City__c, Product2.Name, Owner.Name, '+
							'(SELECT Id FROM Route_Planner_Junction__r where Route_Planner__c =: recordId) FROM Asset ';
					whr += ' WHERE State__c =: stateName ';
					if(String.isNotBlank(cityName)) {
						whr += ' AND City__c =: cityName ';
					}
					if(String.isNotBlank(locationName)) {
						whr +='AND Site_Location__c =: locationName ';
					}
					// whr += ' AND Route_Planner__c = \'\' ';
					if(accessAllRecords == 'false') {
						whr += ' AND OwnerId =: userId ';
					}
					ordBy += ' ORDER BY Name ';

					System.debug(fields + whr + ordBy);

				}		*/
			}

			return finalList;
		}
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}


	
	@AuraEnabled
	public static string updateEntities(String entityType, String routeMapperId, String selectedRows, String notSelectedRows) {
		System.debug(selectedRows);
		try {
			List<Route_Planner_Junction__c> rpjsToUpsert = new List<Route_Planner_Junction__c>();

			Map<String, String> mapEntityIdRPJId = new Map<String, String>();
			for(Route_Planner_Junction__c rpj : [SELECT Id, Account__c, Lead__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routeMapperId]) {
				if(String.isNotBlank(rpj.Account__c)) {
					mapEntityIdRPJId.put(rpj.Account__c, rpj.Id);
				}
				if(String.isNotBlank(rpj.Lead__c)) {
					mapEntityIdRPJId.put(rpj.Lead__c, rpj.Id);
				}
		/*		if(String.isNotBlank(rpj.Asset__c)) {
					mapEntityIdRPJId.put(rpj.Asset__c, rpj.Id);
                }    */
            }
            
            switch on entityType {
                when 'Account' {
                    List<Object> selectedIds = (List<Object>) JSON.deserializeUntyped(selectedRows);
                    for(Object accId : selectedIds) {
                        Route_Planner_Junction__c rpj = new Route_Planner_Junction__c();
                        if(mapEntityIdRPJId.containsKey(String.valueOf(accId))) {
                            rpj.Id = mapEntityIdRPJId.get(String.valueOf(accId));
                        }
                        rpj.Route_Planner__c = routeMapperId;						
                        rpj.Account__c = String.valueof(accId);
                        rpjsToUpsert.add(rpj);
                    }
                }
                when 'Contact' {
                    List<Object> selectedIds = (List<Object>) JSON.deserializeUntyped(selectedRows);
                    for(Object accId : selectedIds) {
                        Route_Planner_Junction__c rpj = new Route_Planner_Junction__c();
                        if(mapEntityIdRPJId.containsKey(String.valueOf(accId))) {
                            rpj.Id = mapEntityIdRPJId.get(String.valueOf(accId));
                        }
                        rpj.Route_Planner__c = routeMapperId;						
                        rpj.Account__c = String.valueof(accId);
                        rpjsToUpsert.add(rpj);
                    }
                }
                when 'Lead__c' {
                    List<Object> selectedIds = (List<Object>) JSON.deserializeUntyped(selectedRows);
                    for(Object ldId : selectedIds) {						
                        Route_Planner_Junction__c rpj = new Route_Planner_Junction__c();
                        if(mapEntityIdRPJId.containsKey(String.valueOf(ldId))) {
                            rpj.Id = mapEntityIdRPJId.get(String.valueOf(ldId));
                        }
                        rpj.Route_Planner__c = routeMapperId;						
                        rpj.Lead__c = String.valueof(ldId);
                        rpjsToUpsert.add(rpj);
                    }
                }
           
            }
            
			if(rpjsToUpsert.size() > 0) {
				upsert rpjsToUpsert;
			}
            
            
            Set<String> entityIds = new Set<String>();
            for(Object obj : (List<Object>) JSON.deserializeUntyped(notSelectedRows)) {
                entityIds.add(String.valueOf(obj));
            }
            
            delete [SELECT Id FROM Route_Planner_Junction__c
                    WHERE
                    Route_Planner__c =: routeMapperId AND
                    (
                        Account__c IN: entityIds OR
                        Lead__c IN: entityIds)
                       // Asset__c IN: entityId
                    
                   ];
            
            return '';
        }
        catch (DMLException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
		}
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}


	
	private class CustomException extends Exception { }

}