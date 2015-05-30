/**
 *   Controller for showing data in page
 * 
 * @author leijun Miao
 * @created 2013-04-24
 * @version 1.0
 * @since 23.0(ForceIDE Version)
 * 
 * 
 *
 * @changelog
 * 2013-04-24 leijun Miao <leijun.miao@itbconsult.com>
 * - Created   
 *
 */ 
public with sharing class CtrJQueryGantt {
	public string show{get;set;}
	public string csSource{get;set;}		
	//********************************* -=BEGIN inner classes=- ***********************************
	public class Gantt
	{
    public List<Item> items { get; set; }
	}
 
	public class Item
	{
	    public string name { get; set; }
	    public string des { get; set; }
	    public List<Bar> values { get; set; }
	}
	 
	public class Bar
	{
	    public string id { get; set; }
	    public string fro { get; set; }
	    public string to { get; set; }
	    public string label { get; set; }
	    public string customClass { get; set; }
	}
	//********************************* -=END inner classes=- ***********************************
	//time to second	 
	private static string DateTimeToSecond(datetime dt)
	{
	    dt = dt.addDays(-1);
	    long timeStamp = (dt.addHours(8).getTime()-datetime.newInstance(1970, 1, 1).getTime())/1000;
	    return '/Date('+timeStamp+'000)/';//String.Format('/Date({0}000)/', timeStamp);
	}
	public CtrJQueryGantt()
	{	
		show=DateTimeToSecond(datetime.now());	
	    Item item;
	    Gantt gantt = new Gantt();
	    gantt.items = new List<Item>();
	    list<Bar> list_pos = new list<Bar>();
		for(Position__c po:[select Id,Close_Date_c__c,Open_Date_c__c,Name from Position__c WHERE Close_Date_c__c!=null and Open_Date_c__c!=null]) {
			Bar bar = new Bar();
			bar.id = po.Id;
			bar.fro = DateTimeToSecond(po.Open_Date_c__c);
			bar.to = DateTimeToSecond(po.Close_Date_c__c);
			bar.label = po.Name;
			bar.customClass = 'ganttRed';
			list_pos.add(bar);	
		}
		 for(Opportunity opp :[select Id,CloseDate,Name from Opportunity]) {
		 	item = new Item();
			item.name = opp.Name;
			item.values = new List<Bar>();
		 	for(Bar bar:list_pos) {
			 	if(DateTimeToSecond(opp.CloseDate) > bar.fro && DateTimeToSecond(opp.CloseDate) < bar.to) {			 	
			 	item.values.Add(bar);			 	
			 	}
		 	}
		 	if(!item.values.isEmpty()) gantt.items.Add(item);		 	
		 }
		system.debug('@@@@gantt.items'+gantt.items);
	    string json = '[';
	    integer i = 0;
	    integer j;
		for(Item item1:gantt.items) {
			json += (i > 0 ? ',' : '') +
                '{\"name\":\"' + item1.name +
                    '\", \"desc\":\"' + item1.des +
                    '\", \"values\":[' ;
                     j = 0;
                    for(Bar bar:item1.values) {
                    	json += (j > 0 ? ',' : '') +
                    	'{\"id\":\"' + bar.id +
	                    '\", \"from\":\"' + bar.fro +
	                    '\", \"to\":\"' + bar.to +
	                    '\", \"label\":\"' + bar.label +
	                    '\", \"customClass\":\"' + bar.customClass +
	                    '\"}'
	                    ;
	                    j++;
                    }
                json += ']}';
            i++;
		}
		json += ']';
	    csSource = json;
	   // csSource='[{"name": "Opportunitie 1","desc": "Product 1","values": [{"id": "t111","from": "/Date(1357027200000)/","to": "/Date(1357718400000)/","label": "plan","customClass": "ganttRed"}]}]';	  
	    system.debug('@@@@json'+ json);
	}
}