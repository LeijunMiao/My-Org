public with sharing class ExtContactManagement {
private final Account acct;
  
     public string mode {get;private set;}
     public List<Contact> Contacts{get;set;} 
     public List<Contact> ContactsAll{get;set;}
     public List<Contact> ContactsBeforeAdd{get;set;}
     public Integer num{get;set;}
     public Integer dateNum{get;set;}
     public Integer pageNum{get;set;}
     public String delName{get;set;}
     public Integer totalRow{get;set;}
     public Integer currentPgNum{get;set;} 
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    
   /*contructor*/  
    public ExtContactManagement(ApexPages.StandardController stdController) {
                this.acct = (Account)stdController.getRecord();
                Contacts = new List<Contact>();
                //进入首页后默认选择五条数据
                Contacts.addAll([SELECT Id, Email,FirstName,Phone,LastName FROM Contact where accountId =: acct.Id limit 5]);
                currentPgNum = 1;
                getContactsAll();
                mode = 'view';
    }
    //用于显示选择后每页显示的个数
    public List<Contact> getContacts1(){
        ContactsBeforeAdd = Contacts.clone();
        for(Integer i = 0; i < num;i++){
                Contact c = new Contact();
                c.AccountId = acct.Id;  
                Contacts.add(c);
                }
        return Contacts;
    }
    
    //得到所有的数据
    public void getContactsAll(){
        ContactsAll = new List<Contact>();
        ContactsAll.clear();
                ContactsAll.addAll([SELECT Id, Email,FirstName,Phone,LastName FROM Contact where accountId =: acct.Id]); 
    }
    
    //增加空数据的行数
     public List<Contact> getListContact(){
        Contacts = new List<Contact>();
        for(Contact cc:ContactsAll){
                if(Contacts.size()<dateNum)
                        Contacts.add(cc); 
        }
                return Contacts;
    }
    //得到增加几条空数据的条数
    public List<SelectOption> getListnumbers(){
        List<SelectOption> Listnumbers = new List<SelectOption>();
        Listnumbers.add(new SelectOption('1','1'));
        Listnumbers.add(new SelectOption('2','2'));
        Listnumbers.add(new SelectOption('5','5'));
        return Listnumbers;
    }
    //得到显示数据条数
     public List<SelectOption> getDateNumbers(){ 
        List<SelectOption> DateNumbers = new List<SelectOption>();
        DateNumbers.add(new SelectOption('5','5'));
        DateNumbers.add(new SelectOption('10','10'));
        return DateNumbers;
    } 
    
     //保存数据 方便取消按钮的使用/缺点 只有返回取消前的一次数据
     public List<Contact> resumeContact(){
        Contacts = ContactsBeforeAdd.clone();
        return Contacts;
     }
    
    //获得pageNum 
    public void pageNumber(){
                totalRow = ContactsAll.size();
                pageNum = (Math.mod(totalRow,dateNum)==0)?( totalRow / dateNum ):(totalRow / dateNum + 1); 
    }
    
    //获得需要显示的数据 
    public void dataView(){
        pageNumber();
        Contacts.clear();
        /* 
        for( Integer i=0;firstNum<i&i<lastNum;i++){
                Contacts.add();
                
        }
        */
        Integer i = 1;
        for(Contact c:ContactsAll){
                if(i <= currentPgNum  * dateNum & currentPgNum<=pageNum){
                        Contacts.add(c);
                        if(i == ((currentPgNum - 1) * dateNum)){
                                Contacts.clear();
                        }
                        i++;
                }
        } 
    }
    
    //获得之前一页的页码
   public void previousCount(){
                currentPgNum--;
                if(currentPgNum<1){currentPgNum = 1;}
                dataView();
                mode = 'view';  
   }
    
    //获得后一页的页码
    public void nextCount(){
        currentPgNum++;
        if(currentPgNum>pageNum){currentPgNum = pageNum;}
         
        dataView();
        mode = 'view';  
    }
    
    
    //编辑进入编辑模式
    public void edit(){
        mode = 'edit';
    }
    
     //按钮取消
    public void cancel(){ 
        resumeContact();
        mode = 'view';   
    }
    
    //保存数据
    public void save(){ 
        
        upsert Contacts;
        afterDelete(); 
        mode = 'view';   
    }
    
   //增加新数据
     public void add(){ 
        
        getContacts1();
        mode = 'edit';   
    }
    
    //删除数据
    public void del(){  
         afterDelete();
         mode='edit';  
    }
    //真正的删除数据
    public void trueDel(){
        ContactsBeforeAdd = Contacts.clone();
        pageNumber();
        Contacts.clear(); 
            Set<Id> ConDel = new Set<Id>();
        Integer i = 1;
        for(Contact c:ContactsBeforeAdd){
                if(c.Id!=delName) Contacts.add(c);
                ConDel.add(c.Id);
                        i++; 
        } 
        
    }
    //dataView里面将删除的数据清除掉
    public void  afterDelete(){
        ContactsBeforeAdd = Contacts.clone();
        pageNumber();
        Contacts.clear(); 
            Set<Id> ConDel = new Set<Id>();
        Integer i = 1;
        for(Contact c:ContactsBeforeAdd){
                if(c.Id!=delName) Contacts.add(c);
                ConDel.add(c.Id);
                        i++; 
        } 
    }
    
    //每页显示的数据条数
    public void sel(){
                getListContact();
                mode = 'view';   
    }
}