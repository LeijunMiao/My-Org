public class soslTest {
	public void SearchRecords(Account acc){
	String s='a';
	//list<list<Account>> a=[Find :'%a%'+s IN Contact.Name FIELDS RETURNING Account(Id,Name)];
	list<Account> a=[select Id,Name from Account where Name like '%a%'];
	for(Account ac:a){
		acc.Name=ac.Name;}
	}
}