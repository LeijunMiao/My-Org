/**
*  Batch class used to delete user outof account team
*
*  
@author Leijun Miao
@created 2013-03-22
@version 1.0
@since 20.0
*
@changelog
2013-03-22 Leijun Miao <leijun.miao@itbconsult.com>
* - Created
*/
global class batchClsDeleteUser_Test implements Database.Batchable<SObject>{
	User user=[select Id from User where Id!=:UserInfo.getUserId() limit 1];
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([select Id from AccountShare where UserOrGroupId=:user.Id]);
	}
	global void execute(Database.BatchableContext BC,list<AccountTeamMember> scope){
		User user=[select Id from User where Id!=:UserInfo.getUserId() limit 1];
		list<AccountTeamMember> list_ATMs=[select Id from AccountTeamMember where UserId=:'00590000001FuoGAAS'];
		list<AccountShare> Shares=new list<AccountShare>();
		delete list_ATMs;
		delete scope;
	}
	global void finish(Database.BatchableContext BC){ 
	}
}