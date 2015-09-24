trigger addPrefix on Contact (before insert, before update) {
/*if(trigger.isInsert||trigger.isUpdate){
	string prefix;
	for(contact c:trigger.new){
		if(c.firstname.length()<5){c.firstname='ITB-'+c.firstname;}
		else{		
		prefix=c.firstname.substring(0,4);
		if(prefix!='ITB-')
		{c.firstname='ITB-'+c.firstname;}}
	}}*/
}