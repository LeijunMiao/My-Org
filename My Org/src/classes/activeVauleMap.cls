public with sharing class activeVauleMap {
	    public static list<activeValue__c> getActives() {
	        return activeValue__c.getall().values();
	    }
	    public Map<string,string> getactiveVauleMap(){
	    	list<activeValue__c> list_allActives = getActives();
	    	Map<string,string> map_name_value=new Map<string,string> {};
	    	for(activeValue__c active:list_allActives){
	    	Boolean b=active.active__c;
	    	if(active.value__c!=null && b){	    		
	    		map_name_value.put(active.Name,active.value__c);
	    	}
	    	}
	    	return map_name_value;
	    }
}