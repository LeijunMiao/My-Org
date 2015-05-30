public with sharing class ExtContactManagement_Test {
	private final Account acct;
     public string mode {get; set;}
     public List<Contact> Contacts{get;set;}
     public List<Contact> contactsAll{get;set;} 
     public Integer currentPgNum {get;set;}
     public Integer currentPgNum2 {get;set;}
     public Integer dataNum{get;set;}
     public Integer pageNumber{get;set;}
     public Integer totalRow{get;set;}
    public ExtContactManagement_Test(ApexPages.StandardController stdController) {
    	this.acct = (Account)stdController.getRecord();
    	Contacts = new List<Contact>();
       // Contacts.addAll([SELECT Id, Email,FirstName,Phone,LastName FROM Contact where accountId =: acct.Id]);
        currentPgNum = 1;
        currentPgNum2 = 1;
        dataNum = 5;
        getContactsAll();
        dataView();
        mode = 'view';
    }

    public void edit2(){
        mode = 'edit';
        system.debug('edit############################'+mode);
    }
    
    public void cancel(){ 
      mode = 'view';   
    }
    
    public void save2(){       
      upsert Contacts;
      mode = 'view';   
    }
    
     public void add(){
    //  getContacts1(); 
      mode = 'edit';   
    }
    
    public void del(){  
         mode='edit';  
    }
    public void previousPage(){
    	if(currentPgNum2!=currentPgNum)currentPgNum=currentPgNum2;
    	currentPgNum--;   	
    	if(currentPgNum<1)currentPgNum=1;
    	currentPgNum2 = currentPgNum;
    	dataView();
    	mode = 'view';
    }
    public void nextPage(){
    	if(currentPgNum2!=currentPgNum)currentPgNum=currentPgNum2;
    	currentPgNum++;
    	if(currentPgNum>pageNumber)currentPgNum=pageNumber;
    	dataView();
    	currentPgNum2 = currentPgNum;
    	mode = 'view';
    }
    public void dataView(){
    	if(currentPgNum>pageNumber)currentPgNum=pageNumber;
    	pageNum();
    	Integer i = 1;
    	Contacts.clear();
    	for(Contact c:contactsAll){
    		/*if(i<6)Contacts.add(c);
    		if(i==3){
    			Contacts.clear();
    			system.debug('clear I############################'+i+'currentPgNum:'+currentPgNum);
    		}
    		i++;
    		system.debug('I############################'+i+'currentPgNum:'+currentPgNum);*/
    		if(i<currentPgNum*dataNum && currentPgNum<=pageNumber)Contacts.add(c);
    		if(i==((currentPgNum-1)*dataNum)){
    			Contacts.clear();
    		}
    		i++;
    	}
    }
    public void pageNum(){
    	totalRow = contactsAll.size();
    	pageNumber = (Math.mod(totalRow,dataNum)==0)?( totalRow / dataNum ):(totalRow / dataNum + 1);
    }
    public void getContactsAll(){
    	contactsAll = new list<Contact>();
    	ContactsAll.clear();
    	contactsAll.addAll([SELECT Id, Email,FirstName,Phone,LastName FROM Contact where accountId =: acct.Id]);
    }
    public void changePg(){
    	
    }
    
}