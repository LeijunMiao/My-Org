/**
 * 
 *   This is used to operate CampaignMember
 *
 * @author     leijun Miao
 * @created     2013-07-17
 * @since       28.0    
 * @version     1.0                                                                
 * 
 * @changelog
 * 2013-07-17 leijun Miao <leijun.miao@itbconsult.com>
 * - Created
 *    
 */
global with sharing class ExtAccount {
	//********************************* -=BEGIN public members=- ************************************
	public Account account{get;set;}
	public Map<Integer,list<contactCls>> map_numListContact{get;set;}
	public list<contactCls> list_c{get;set;}
	public Integer pageListNum{get;set;}
	public Integer pageNum{get;set;}
	public Integer pageclickednumber{get;set;}
	public Integer listSize{get;set;}
	public Id contactId{get;set;}
	//********************************* -=END public members=- ************************************
	//********************************* -=BEGIN private members=- ************************************
	private final ApexPages.StandardController theController;
	///////////////////////////////
	//          Test            *** 
	//////////////////////////////
	/*
	public Integer pageListNum=1;
	public void setPageListNum(Integer s){
		this.pageListNum=s;
	}
	public Integer getPageListNum(){
		return pageListNum;
	}*/
	//********************************* -=END private members=- ************************************
	//********************************* -=BEGIN CONSTRUCTOR=- ************************************
	public ExtAccount(ApexPages.StandardController con){
		this.theController=con;
		try{
			account=(Account)this.theController.getRecord();
			pageListNum=3;
			init();
		}
		catch(Exception e){
			ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR,e+''));
		}
	}
	//********************************* -=END CONSTRUCTOR=- ************************************
	//********************************* -=Start Public Methods =- ******************************
	public void init(){		
		try{
			pageclickednumber=1;			
			list_c=new list<contactCls>();
			String sql=' SELECT ';
			for(Schema.FieldSetMember f : this.getContactClsFields()){
				sql+=f.getFieldPath()+',';
			}
			sql+=' Id From Contact where AccountId = \''+account.Id+'\'';
			sql+=' order by CreatedDate asc';
			for(Contact c : database.query(sql)){
				contactCls cc=new contactCls(false,c); 
				list_c.add(cc);
			}
		    listSize=list_c.size();
		    Integer listCurrent=0;
			pageNum=listSize/pageListNum+1;
			if(math.mod(listSize, pageListNum) ==0)pageNum--;
			system.debug('pageNum:::'+pageNum);
			map_numListContact=new Map<Integer,list<contactCls>>();
			for(Integer i=1;i<=pageNum;i++){
				map_numListContact.put(i,new list<contactCls>());
				for(Integer j=1;j<=pageListNum;j++){
					if(listCurrent<listSize){
						map_numListContact.get(i).add(list_c.get(listCurrent));
						listCurrent++;
					}
					else{
						system.debug('map_numListContact:::'+map_numListContact);
						return;
					}
				}
			}			
			
		}catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Page number is invalid'));
		}
			
	}
	public void getPageNum(){
		//	pageListNum=2;
			//init();
		system.debug('pageclickednumber:::'+pageclickednumber);
	}
	public void getPageListNum(){
		//	pageListNum=2;
			init();
		system.debug('pageclickednumber:::'+pageclickednumber);
	}
	public void Go(){

	}
	public void deleteContact(){
		Contact c=[SELECT Id FROM Contact where Id =: contactId];
		system.debug('c:::::'+c);
		delete c;
		init();
	}
	public void editContact(){
		
	}
	public void delAll(){
		
	}
	public PageReference test() {
		init();
            return null;
        }
   	@RemoteAction
    global static void delEvent(string str) {
    	
    }
	//********************************* -=End Public Methods =- ******************************
	
	
	//********************************* -=Start Private Methods =- ******************************
	private list<Schema.FieldSetMember> getContactClsFields(){
		return SObjectType.Contact.fieldSets.contact_Information.getFields();
	}
	//********************************* -=End Private Methods =- ******************************
	
	
	//********************************* -=Start inner class =- ******************************
	public class contactCls{
		public boolean isCheck{get;set;}
		public Contact contact{get;set;}
		public contactCls(boolean isCheck,Contact contact){
			this.isCheck=isCheck;
			this.contact=contact;
		}
	}
	//********************************* -=End inner class =- ******************************
}