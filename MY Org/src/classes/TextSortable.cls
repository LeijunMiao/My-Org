public with sharing class TextSortable {
	private final ApexPages.StandardController theController;
	public Job_Application__c JobApplication{get;set;}
	public list<string> list_item{get;set;}
	public String json{get;set;}
	public TextSortable(ApexPages.StandardController con){
		this.theController = con;
		try{
			this.JobApplication=(Job_Application__c)this.theController.getRecord();	
			list_item=new list<string>();
			for(Job_Application__c j:[SELECT id,  testItem__c FROM Job_Application__c where testItem__c!=null])	
			{
				list_item.add(j.testItem__c);
			}
			system.debug('list1:'+list_item);
		//	if(id!=null){
			//this.campaign_Member =getCampaignMember(this.campaign_Member.id);
		//}
		}
		catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e+''));
        }		
	}
	public String[] getStrings() {
		String[] s=new String[]{};
		system.debug('list2:'+list_item);
for(String s2:list_item){s.add(s2);}
        return  s;

    }
    
}