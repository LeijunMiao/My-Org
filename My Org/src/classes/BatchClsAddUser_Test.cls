/**
*  Batch class used to add user into account team
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
global class BatchClsAddUser_Test implements Database.Batchable<SObject>{
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([select Id from Account]);
	}
	global void execute(Database.BatchableContext BC,list<Account> scope){
		User user=[select Id from User where Id!=:UserInfo.getUserId() limit 1];
		list<AccountTeamMember> list_ATMs=new list<AccountTeamMember>();
		list<AccountShare> Shares=new list<AccountShare>();
		for(Account a:scope){
			AccountTeamMember ATM=new AccountTeamMember();
			AccountShare Share=new AccountShare();
    		Share.AccountAccessLevel='Edit';
    		Share.AccountId=a.Id;
			Share.UserOrGroupId=user.Id;
			ATM.AccountId=a.Id;
			ATM.UserId=user.Id;	
			list_ATMs.add(ATM);
			Shares.add(Share);
		}
		upsert list_ATMs;
		upsert Shares;
	}
	global void finish(Database.BatchableContext BC){ 
 		if(UserInfo.getUserId() != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Add success.');
            mail.setPlainTextBody(' one user added into account team of all account of your personal org, with access level "Edit". ');
            mail.setSaveAsActivity(false); //If "yes" Activity will be created for Visit Report, If "no" no Activity will be created
            mail.setUseSignature(false); //Sender Signature from SFDC           
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
	}
}