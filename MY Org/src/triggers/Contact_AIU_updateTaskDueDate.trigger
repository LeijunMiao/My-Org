trigger Contact_AIU_updateTaskDueDate on Contact (after insert, after update) {
	set<Id> set_cid= new set<Id>();
	set_cid=trigger.newMap.keyset();
	system.debug('set_cid: '+set_cid);
	list<Task> list_t=new list<Task>();
	list_t=[select id,ActivityDate from Task where WhoId in :set_cid];
	if(list_t.size()!=0){
		for(Task t:list_t){
			t.ActivityDate=date.today().addDays(-1);			
		}
		update list_t;
	}
}