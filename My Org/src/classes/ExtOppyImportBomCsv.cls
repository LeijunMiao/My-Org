public with sharing class ExtOppyImportBomCsv {
	public FileInfo fileInfo{get;set;}
    public string taskId{get;set;}
    public String importInfo{get;set;}
    public list<string> list_errorlines{get;set;} //added by leijun 2014 5 15
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //private final ApexPages.standardController stdCtrl;
    private string oppyId;
    private string strTest;
	public ExtOppyImportBomCsv(){
         fileInfo = new FileInfo();
         //oppyId = ApexPages.currentPage().getParameters().get('id');
    }
    public void importCsvFile(){
        //check whether file type is csv - begin
        string result = '';
        try{
            string fileExt = fileInfo.fileName;
            fileExt = fileExt.substring(fileExt.lastIndexOf('.')+1,fileExt.length());
            if(fileExt != fileInfo.FILETYPE || fileInfo.contentFile == null){throw new CustomException();}
        }catch(CustomException e){
            result = 'Exception';
        }
        //check whether file type is csv - end
        //import - begin
        if(result == ''){
                list_errorlines=new list<string>();
                //establish oppy line items with csv
                String fileString = fileInfo.contentFile.toString();
                map<String, Integer> map_data = new map<String, Integer>();
                //list<list<String>> list_data = parseCSV(fileString,false);
                List<List<string>> list_data = CSVReader.Parse(fileString);
                system.debug('list_data-->'+list_data[6][0]);
                list<list<String>> list_data2 = new list<list<String>>();
                list<String> test = new list<String>();
                test.add('"Pre-Requisite, KEYMILE assumes:"');
                test.add('test');
                list_data2.add(test);
                system.debug('list_data2-->'+list_data2[0][0]);
                
        }
    }
	
    private List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        //find the seperator -- begin
        string str;
        if(contents.length() > 2000) str = contents.substring(0,2000);
        else str = contents;
        integer count4Comma = str.countMatches(',');
        integer count4Semicolon = str.countMatches(';');
        str = null;
        //if it happen that count4Comma == count4Semicolon, 
        //it is really difficult to tell what the seperator should be.

        string columnSeperator = count4Comma > count4Semicolon ? ',':';'; 
        //find the seperator -- end
        //string s =columnSeperator+ '(?=[^"]*"(?:[^"]*"[^"]*")*[^"]*$)';
        string s = columnSeperator+'(?=([^\"]*\"[^\"]*\")*[^\"]*$)';       
		/*
		pattern myPattern = pattern.compile(s);
		matcher myMatcher = myPattern.matcher(contents);
		system.debug('myMatcher-->'+myMatcher);
		while(myMatcher.find()) {
		}
		*/
        List<List<String>> allFields = new List<List<String>>();
        contents = contents.replaceAll(columnSeperator+'"""',columnSeperator+'"DBLQT').replaceall('"""'+columnSeperator,'DBLQT"'+columnSeperator);
        contents = contents.replaceAll('""','DBLQT');
        List<String> lines = new List<String>();
        List<string> items = new List<String>();
        try {
            // using carriage return accomodates Linux  (LF '\n' , ASCII code 10, 0x0A.)
            // using carriage return accomodates windows, unix, and mac files (CR '\r', ASCII 13, 0x0D.)
            // contents.split('\\r\\n|\\n|\\r');
            //items = contents.split(columnSeperator);
            Pattern p = Pattern.compile(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
        		items = p.split(contents);
            //items = contents.split(s);
        } catch (System.ListException e) { 
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getStackTraceString()+e.getMessage()));
        }
        str = '';
        integer status = 0;
        for(string item : items){
            if(item.indexOf('Quantity')!=-1) system.debug('quentity:::::::::begin'+item);
            boolean startDQ = item.startsWith('"DBQT');
            boolean endDQ = item.endsWith('DBQT"');
            boolean startQ = item.startsWith('"');
            boolean endQ = item.endsWith('"');
            boolean startWithRN = item.endsWith('\r')||item.endsWith('\n');
            if(item!='') {
            	system.debug('item:::::::::'+item);
            	system.debug('startDQ:::::::::'+startDQ);
            	system.debug('endDQ:::::::::'+endDQ);
            	system.debug('startQ:::::::::'+startQ);
            	system.debug('endQ:::::::::'+endQ);
            	system.debug('startWithRN:::::::::'+startWithRN);
            }
            if(str == ''){//no previous uncomplete quote
                if(!startQ){
                    if(startWithRN){
                           List<String> tempAray = item.split('\r\n|\r|\n');
                           if(!tempAray.isEmpty() && tempAray[0]!='') lines.add(tempAray[0]);                         
                        allFields.add(lines);
                        lines = new List<String>();
                        lines.add('');
                    }else{
                        List<String> tempAray = item.split('\r\n|\r|\n');
                        system.debug('>>>>>>>>>>>>> tempAray size:'+tempAray.size()+' str >>'+item+'<<');
                        integer len = tempAray.size();
                        system.debug('len:::::::::'+len);
                        if(len == 1)
                            lines.add(item);
                        else if(len >1){
                            lines.add(tempAray[0]);
                            allFields.add(lines);
                            lines = new List<String>();
                            lines.add(tempAray[1]);
                        }
                    }
                    status = 0;
                }else if(!startDQ){//start with "
                	system.debug('dou:::::::::1'+item);
                    if(endQ){
                        if(startWithRN){
                                system.debug('quentity:::::::::startWithRN'+item);
                            allFields.add(lines);
                            lines = new List<String>();
                            lines.add('');
                        }else{
                                system.debug('quentity:::::::::startWithRN'+item);
                            item = item.substring(1,item.length()-1);//remove the begin and end quote
                            List<String> tempAray = item.split('"\\r\\n"|"\\r"|"\\n"');
                            integer len = tempAray.size();
                            system.debug('quentity:::::::::len'+len);
                            if(len == 1)
                                lines.add(item);
                            else if(len > 1){
                                lines.add(tempAray[0]);
                                allFields.add(lines);
                                lines = new List<String>();
                                lines.add(tempAray[1]);
                            }
                        }
                        
                        status = 0;
                    }
                    //added by leijun 2014 06 10 begin
                    else if( item.substring(1,item.length()).contains('"') && startWithRN) {
                    		system.debug('dou:::::::::1'+item);
                            List<String> tempAray = item.split('\r\n|\r|\n');
                            lines.add(tempAray[0].substring(1,tempAray[0].length()-1));
                            allFields.add(lines);
                            lines = new List<String>();
                            status = 0;
                    }
                    else if( item.substring(1,item.length()).containsOnly('0123456789.')){
                        str += item;
                        status = 3;
                    }
                    //added by leijun 2014 06 10 end
                    
                    else{ // has no end quote
                        system.debug('dou:::::::::1'+item);
                        str += item;
                        status = 1;
                    }
                }else{//start with "DBQT
                    if(endDQ){
                        item = item.substring(1,item.length()-1);
                        List<String> tempAray = item.split('"\\r\\n"|"\\r"|"\\n"');
                        if(tempAray.size() == 1){
                            item = item.replaceAll('DBQT','"');
                            lines.add(item);
                        }
                        else{
                            lines.add(tempAray[0].replaceAll('DBQT','"'));
                            allFields.add(lines);
                            lines = new List<String>();
                            lines.add(tempAray[1].replaceAll('DBQT','"'));
                        }
                        status = 0;
                    }else{
                        str += item;
                        status = 2;
                    }
                }
            }else{
                if(status == 1){
                	system.debug('str:::::::::1'+str);
                    if(endQ){
                        str = str.substring(1,str.length()-1);//remove the begin and end quote

                        List<String> tempAray = str.split('"\\r\\n"|"\\r"|"\\n"');
                        if(tempAray.size() == 1)
                            lines.add(item);
                        else{
                            lines.add(tempAray[0]);
                            allFields.add(lines);
                            lines = new List<String>();
                            lines.add(tempAray[1]);
                        }
                        system.debug('lines:::::::::1'+lines);
                        system.debug('allFields:::::::::1'+allFields);
                        
                        status = 0;
                        str = '';
                    }else{ // has no end quote
                        str += item;
                        system.debug('str:::::::::1'+str);
                    }
                }else if(status == 2){
                    if(endDQ){
                        str = str.substring(1,str.length()-1);

                        List<String> tempAray = str.split('"\\r\\n"|"\\r"|"\\n"');
                        if(tempAray.size() == 1){
                            str = str.replaceAll('DBQT','"');
                            lines.add(str);
                        }
                        else{
                            lines.add(tempAray[0].replaceAll('DBQT','"'));
                            allFields.add(lines);
                            lines = new List<String>();
                            lines.add(tempAray[1].replaceAll('DBQT','"'));
                        }
                        status = 0;
                        str = '';
                    }else{
                        str += item;
                    }
                }
                //added by leijun 2014 06 10 begin
                else if(status== 3){
                     if(endQ){
                        str = str.substring(1,str.length());//remove the begin quote
                        item=item.substring(0,item.length()-1);
                        if(item.containsOnly('0123456789')){
                            str+=','+item;
                            lines.add(str);
                        }
                        else{
                            str = str.substring(0,str.length()-1);//remove the begin and end quote
                            List<String> tempAray = str.split('"\\r\\n"|"\\r"|"\\n"');
                            if(tempAray.size() == 1)
                                lines.add(item+'\'');
                            else{
                                lines.add(tempAray[0]);
                                allFields.add(lines);
                                lines = new List<String>();
                                lines.add(tempAray[1]);
                            }
                        }
                        status = 0;
                        str = '';
                    }else{ // has no end quote
                        str += item;
                        status = 1;
                    }
                }
                //added by leijun 2014 06 10 end
            }
            //boolean hasRN = item.containsAny('\r\n');
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }
     public class FileInfo{
        public final String COMMA = ',';
        public final String SEMICOLON = ';';
        public final String QUOTE = '"';
        public final String BLANK = ' ';
        public final String FILETYPE = 'csv';
        public final String NEWLINE = '\r\n';
        public final String SPLITTYPE = '___';
        public String contentType{get;set;}
        public String fileName{get;set;}
        public Blob contentFile{get;set;}
        public String richText{get;set;}
        public String richValues{get;set;}
        public Boolean saveType{get;set;}
    }
    public class CustomException extends Exception{}
    public class tempOpportunityLineItem{
            public String tempNum{get;set;} 
            public OpportunityLineItem oLI{get;set;}
    }
}