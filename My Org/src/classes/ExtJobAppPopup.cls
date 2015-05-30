public with sharing class ExtJobAppPopup {
	public list<String> list_code {get; set;}
public string searchString {get; set;}
private Map<String, String> map_urlParams;
public ExtJobAppPopup(){
map_urlParams = ApexPages.currentPage().getParameters();
		if(map_urlParams != null && map_urlParams.containsKey('SearchString')){
			searchString = map_urlParams.get('SearchString');
		}
		if(list_code == null) list_code = new list<String>();
    	init();
		
}
	public void init(){
	if(list_code == null){
    		list_code = new list<String>();
    	}
    	else if(!list_code.isEmpty()){
    		list_code.clear();
    	}
    	String codeQuery ='SELECT Id,Name FROM Position__c';//'SELECT  Name__c,Id FROM Partner_Role__c';
    	if(searchString != null && searchString.trim() != ''){codeQuery += ' where Name LIKE \'%' + searchString.trim()+ '%\' ';}
    	for(Position__c eng : DataBase.query(codeQuery)){
    			list_code.add(eng.Name);
    	}
	} 
	public PageReference searchCode(){
		if(list_code == null){
    		list_code = new list<String>();
    	}
    	else if(!list_code.isEmpty()){
	    	list_code.clear();
    	}
    	if(searchString != null && searchString.trim() != ''){
    		searchString ='%' + searchString.trim() + '%';
	    	for(Position__c eng :[select Id,Name from Position__c where  Name like :searchString ]){
	    		list_code.add(eng.Name);
	    	}
    	}
    	else{
	    	for(Position__c eng :[select Id,Name from Position__c where Name != null ]){
	    		list_code.add(eng.Name);
	    	}
    	}
    	
    	if(list_code.isEmpty()){
    		String errMsg = 'No matching Project Code found.'; 
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errMsg));
    	}
		return null;}
    public class ClsProjectCode {
    	public string codeName {get; set;}
    	public boolean isChecked {get; set;}
    	
    	public ClsProjectCode(string codeName, boolean isChecked){
    		this.codeName = codeName;
    		this.isChecked = isChecked;
    	}
    }
}