/**
 * 
 *   This is 
 *
 * @author     leijun Miao
 * @created     2013-07-02
 * @since       25.0    
 * @version     1.0                                                                
 * 
 * @changelog
 * 2013-07-02 leijun Miao <leijun.miao@itbconsult.com>
 * - Created
 *    
 */
public with sharing class ExtCampaignMember {
	//********************************* -=BEGIN public members=- ************************************
   /* public Id accountId{get;set;}
	public list<Schema.FieldSetMember> list_FieldSetMember{get;set;}
	public CT_Campaign_Member__c campaign_Member{get;set;}
	public String contact_Name{get;set;}
	public String partenerRole_Name{get;set;}
	public list<String> list_code {get; set;}
	
	public String searchString {get; set;}
	public String searchType {get;set;}
	public SelectOptionCls soc {get;set;}
	public Id strType {get;set;}
	public Boolean b=false;
	public list<ContactPartnerRoleCls> list_cprc{get;set;}
	//********************************* -=END public members=- ************************************
	private final ApexPages.standardController theController;	 
	private final String contactLabe = 'External Contact';
	private final String partnerRoleLabe = 'Partner Role';
	
	//********************************* -=BEGIN CONSTRUCTOR=- ************************************
	public ExtCampaignMember(ApexPages.StandardController con){
		this.theController = con;
		initCampaignMember();
		try{

			this.campaign_Member=(CT_Campaign_Member__c)this.theController.getRecord();	
			accountId=campaign_Member.Account__c;
			//if(this.campaign_Member.Id  != null){
			//	this.soc.val = this.campaign_Member.Contact_or_Partner_Role__c;
			//}
			if(this.campaign_Member.Contact__c!=null)
			{
				Contact c=[select Id,Name from Contact where Id=:this.campaign_Member.Contact__c];
				contact_Name=c.Name;
				this.strType = c.Id;
				this.soc.val=contactLabe;
			}
			if(this.campaign_Member.Partner_Role__c!=null)
			{
				Partner_Role__c pr=[select Id,Name from Partner_Role__c where Id=:this.campaign_Member.Partner_Role__c];
				partenerRole_Name=pr.Name;	
				this.strType = pr.Id;
				this.soc.val=partnerRoleLabe;
			}			
		}
		catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e+''));
        }		
	}
	//********************************* -=END CONSTRUCTOR=- ************************************
	//********************************* -=Start Public Methods =- ******************************

	public void searchCode(){
		this.list_cprc.clear();
		String accId='';
		if(String.valueOf(accountId).trim() != ''&&accountId != null)accId=accountId;
		system.debug('accId:::::::::'+accId);
		String sql = 'select id,Name from ', likeSql = '', objectName = ' Contact ',equalSql='';
		
		if(searchString != null && searchString != ''){
			likeSql = ' where name like \'%' + searchString.trim() + '%\'';
		}
		if(accId !=null && accId!=''){
			if(likeSql!=''){
				likeSql+='and';
			}else equalSql+='where';
			if(searchType==contactLabe)equalSql+=' AccountId=\'' + accId + '\'';
			if(searchType==partnerRoleLabe)equalSql+=' Account__c=\'' + accId + '\'';
		}

		if(searchType != contactLabe){
			objectName = ' Partner_Role__c ';			
		}
		sql += (objectName + likeSql +equalSql+ ' limit 500');
		
		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, accountId+''));
		
		try{
			for(Sobject o : database.query(sql)){
				list_cprc.add( new ContactPartnerRoleCls(o.get('id')+'', o.get('Name')+'' ) );
			}
			if(list_cprc.isEmpty()){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, system.label.CT_Campaign_Member_title_Alert));
	    	}
		}catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e+''));
		}

	}
	
	public PageReference customCancel(){
    	Pagereference pg = theController.cancel();
    	return pg;
    }
    public PageReference customSaveNew(){
    	save();
    	if(campaign_Member.Id!=null&&b==true){
    		CT_Campaign__c c=[Select Id, Name from CT_Campaign__c where Id=:campaign_Member.Campaign__c];
	    	String CampaignName=c.Name; 
	    	PageReference pRef=new PageReference('/apex/ExtCampaignMember?CF00NW0000000iLKj='+CampaignName+'&CF00NW0000000iLKj_lkid='+campaign_Member.Campaign__c+'&scontrolCaching=1&retURL=%2F'+campaign_Member.Campaign__c+'&sfdc.override=1');
	    	pRef.setRedirect(true);
			return pRef ;
    	}
    	else return null;    	
    }
    public PageReference customSave(){    	   	
    	save();
    	if(campaign_Member.Id!=null&&b==true)return new PageReference('/'+campaign_Member.Id);
    	else return null;
	}
    	
    	
    public list<Schema.FieldSetMember> getContactFields() {
        return SObjectType.Contact.fieldSets.contact_Information.getFields();
    }
    public List<Schema.FieldSetMember> getPartnerRoleFields() {
        return SObjectType.Partner_Role__c.fieldSets.partnerRole_Information.getFields();
    }
    //********************************* -=End Public Methods =- ******************************
	//********************************* -=Start Private Methods =- ************************************	
	private void save(){
		try{   		    
			if((soc.val==contactLabe&&contact_Name==null||contact_Name=='')||(soc.val==partnerRoleLabe&&partenerRole_Name==null||partenerRole_Name=='')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact or Partner:You must enter a value'));
				return;
				}
			//if(String.valueOf(strType).trim() == '')
			String sobjectName=strType.getSObjectType().getDescribe().getName();
	    	campaign_Member.Contact_or_Partner_Role__c=sobjectName;
	    	//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strType+''));
	    	if(sobjectName == 'Contact'){
				campaign_Member.Contact__c=strType;
				campaign_Member.Partner_Role__c=null;
			}else if(sobjectName == 'Partner_Role__c'){
				campaign_Member.Partner_Role__c=strType;
				campaign_Member.Contact__c=null;
			}
			
	    	if(this.campaign_Member.Id!=null){
	    		update 	campaign_Member; 
	    		b=true;
	    	}   
	    	else{
	    		insert 	campaign_Member;
	    		b=true;
	    	}  	
    	}catch(DmlException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)+''));
    	}
	}	
	/*private void checkContactOrPartnerRole(){
		system.debug('soc.val::::'+soc.val);
		system.debug('contact_Name::::'+contact_Name);
		system.debug('partenerRole_Name::::'+partenerRole_Name);
		if(soc.val==contactLabe&&contact_Name!=null&&contact_Name!=''){
						system.debug('strType::::'+strType);
			Contact c=[select Id,Name from Contact where Name=:contact_Name];
			if(c==null){
					return;
				}
			Id cn=c.Id;
			if(cn!=strType){
				strType=cn;
			}
		}
		else if(soc.val==partnerRoleLabe&&partenerRole_Name!=null&&partenerRole_Name!=''){
						system.debug('strType2::::'+strType);
				Partner_Role__c pr=[select Id,Name from Partner_Role__c where Name=:partenerRole_Name];
				if(pr==null){
					return;
				}
				Id prId=pr.Id;
				if(prId!=strType){
					strType=prId;
				}
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact or Partner:You must enter a value'));
			return;
			}
		//if(String.valueOf(strType).trim() == '')
		String sobjectName=strType.getSObjectType().getDescribe().getName();
    	campaign_Member.Contact_or_Partner_Role__c=sobjectName;
    	//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strType+''));
    	if(sobjectName == 'Contact'){
			campaign_Member.Contact__c=strType;
			campaign_Member.Partner_Role__c=null;
		}else if(sobjectName == 'Partner_Role__c'){
			campaign_Member.Partner_Role__c=strType;
			campaign_Member.Contact__c=null;
		}
	}*/
	
	/*
	private void initCampaignMember(){
	//	this.strType = '';
		this.searchString = '';
		this.searchType = '';
		this.list_cprc = new list<ContactPartnerRoleCls>();
		this.soc = new SelectOptionCls();
		
		list<String> list_tmp = new list<String>();
		setFieldsSetMember(list_tmp);
		this.theController.addFields(list_tmp);
	}
	
	private void setFieldsSetMember(list<String> list_tmp){
		List<Schema.FieldSetMember> list_fsm = SObjectType.CT_Campaign_Member__c.fieldSets.CampaignMember_Layout.getFields();
		for(Schema.FieldSetMember f : list_fsm) {
			list_tmp.add(f.getFieldPath());
        }
	}

	
    
    private list<Contact> getlist_Contact(){
    	String query='SELECT';
    	for(Schema.FieldSetMember f : this.getContactFields()){
    		query+=f.getFieldPath() + ', ';
    	}
    	query += 'Id FROM Contact';
    	return Database.query(query);
    }
    
    
    
    public List<Schema.FieldSetMember> getCampaignMemberFields() {
    	return SObjectType.CT_Campaign_Member__c.FieldSets.Edit_CampaignMember_Information.getFields();
    }
    
    private list<Partner_Role__c> getlist_PartnerRole(){
    	String query='SELECT';
    	for(Schema.FieldSetMember f : this.getPartnerRoleFields()){
    		query+=f.getFieldPath() + ', ';
    	}
    	query += 'Id FROM Partner_Role__c';
    	return Database.query(query);
    }
    //********************************* -=End Private Methods =- **************************************
    
    
    public class ContactPartnerRoleCls{
    	
    	public String cId {get;set;}
    	public String cName {get;set;}
    	
    	public ContactPartnerRoleCls(String cId, String cName){
    		this.cId = cId;
    		this.cName = cName;
    	}
    }
    
    
    
    
    public class SelectOptionCls{
	    public String val {get;set;}
	 
		 public SelectOptionCls(){
		  this.val = '';
		 }
		 
		public List<SelectOption> getContactPartnerRole(){
			list<SelectOption> list_tmp = new list<SelectOption>();
			Schema.DescribeFieldResult desResult = CT_Campaign_Member__c.Contact_or_Partner_Role__c.getDescribe();
			//list_tmp.add(new SelectOption('', 'none')); 
			for(Schema.PicklistEntry pri : desResult.getPicklistValues()){          
				list_tmp.add(new SelectOption(pri.getValue(), pri.getLabel()));
			}
			return list_tmp;
		}
	}
    */

}