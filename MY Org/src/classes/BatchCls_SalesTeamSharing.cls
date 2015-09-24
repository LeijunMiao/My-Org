/**
*  Batch class used to add user into account team
*
*  
@author Leijun Miao
@created 2013-04-09
@version 1.0
@since 27.0
*
@changelog
2013-04-09 Leijun Miao <leijun.miao@itbconsult.com>
* - Created
*/
global class BatchCls_SalesTeamSharing implements Database.Batchable<SObject> {
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([select Id, ShippingPostalCode from Account]);
	}
	global void execute(Database.BatchableContext BC,list<Account> scope) {
		/*map<Id,Territory_Mapping_Table> map_Id_TerrMapTable = new map<Id,Territory_Mapping_Table>();
		for(Territory_Mapping_Table TerrMapTable：[SELECT Active__c, Account_Access__c, Case_Access__c, Opportunity_Access__c, Id, Role__c, Territory__c, User__c, ZIP_End__c, ZIP_Start__c FROM Territory_Mapping_Table__c]) {			
			map_Id_TerrMapTable.put(TerrMapTable.Id,TerrMapTable);
		}
		for(Account acc:scope) {
			if(acc.territory__c == ){
				
		}
	}*/
	}
	global void finish(Database.BatchableContext BC) { 
		
	}
}