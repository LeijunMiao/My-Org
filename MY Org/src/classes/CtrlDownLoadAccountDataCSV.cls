public with sharing class CtrlDownLoadAccountDataCSV {
	public String jsonString {get;set;}
	public CtrlDownLoadAccountDataCSV() {
		getAccountData();
	}
	
	private void getAccountData() {
		/*
		jsonString = JSON.serialize('');
		list<innerAcc> list_a = new list<innerAcc>();
		list<innerAcc> list_b = new list<innerAcc>();
		for(Account a : [select Id,Name from Account limit 5]) {
			//innerAcc ia = new innerAcc(a.Id,a.Name);
			list_a.add(new innerAcc(a.Id,a.Name));
		} 
		integer i = 0;
		while( i <10000) {
			list_b.addAll(list_a);
			i++;
		}
		jsonString = JSON.serialize(list_b);
		*/
	}
	
	@RemoteAction
	public static String  getData() {
		string jsonString = JSON.serialize('');
		list<innerAcc> list_a = new list<innerAcc>();
		list<innerAcc> list_b = new list<innerAcc>();
		for(Account a : [SELECT ShippingCity, ShippingPostalCode, Description, Fax, Name, Id, Phone, Type, BillingCity, BillingCountry, BillingState, BillingStreet FROM Account limit 5]) {
			innerAcc ia = new innerAcc();
			ia.ShippingCity = a.ShippingCity;
			ia.ShippingPostalCode = a.ShippingPostalCode;
			ia.Description =  a.Description;
			ia.Fax =  a.Fax;
			ia.Name =  a.Name; 
			ia.accid =  a.Id;
			ia.Phone =  a.Phone; 
			ia.Type =  a.Type;
			ia.BillingCity =  a.BillingCity;
			ia.BillingCountry =  a.BillingCountry;
			ia.BillingState =  a.BillingState;
			ia.BillingStreet =  a.BillingStreet;
			list_a.add(ia);
		} 
		integer i = 0;
		while( i <2000) {
			list_b.addAll(list_a);
			i++;
		}
		jsonString = JSON.serialize(list_b);
		return 	jsonString;
	}
	
	public class innerAcc {
		public Id accid;
		public String Name;
		public String ShippingCity;
		public String ShippingPostalCode;
		public String Description;
		public String Fax;
		public String Phone;
		public String Type;
		public String BillingCity;
		public String BillingCountry;
		public String BillingState;
		public String BillingStreet;
		public innerAcc(id accid,String Name) {
			this.accid = accid;
			this.Name = Name;
		}
		public innerAcc() {
			
		}
	}
	
}