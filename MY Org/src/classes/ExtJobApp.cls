public with sharing class ExtJobApp {
private final ApexPages.standardController theController;
public Job_Application__c JobApplication{get;set;}	 
public Candidate__c status{get;set;}
		
	//********************************* -=BEGIN CONSTRUCTOR=- ************************************
	public ExtJobApp(ApexPages.StandardController con){
		this.theController = con;
		try{

			this.JobApplication=(Job_Application__c)this.theController.getRecord();			
		//	if(id!=null){
			//this.campaign_Member =getCampaignMember(this.campaign_Member.id);
		//}
		}
		catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e+''));
        }		
	}
		public PageReference customCancel(){
    	Pagereference pg = theController.cancel();
    	return pg;
    }
    public PageReference customSaveNew(){
    	Pagereference pg = theController.cancel();
    	return pg;
    }
    public PageReference customSave(){
    	Pagereference pg = theController.save();
    	Job_Application__c ja=new Job_Application__c();
    	ja=JobApplication.clone();
    	update ja;
    	//if(JobApplication.id!=null)
    	//delete JobApplication;
    	return pg;
    }
}