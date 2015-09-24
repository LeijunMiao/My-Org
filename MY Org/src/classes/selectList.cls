public class selectList {
        String[] countries = new String[]{};
        
        public PageReference test() {
            return null;
        }
            
        public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('US','US'));
            options.add(new SelectOption('CANADA','Canada'));
            options.add(new SelectOption('MEXICO','Mexico'));
            return options;
        }
            
        public String[] getCountries() {
            return countries;
        }
            
        public void setCountries(String[] countries) {
            this.countries = countries;
        }
        ////////////////////////////////////////////////////////////////////////////////
        //                                                                            |/
        ////////////////////////////////////////////////////////////////////////////////
        String s = 'blue';
 
    public String getString() {
        return s;
    }
 			
    public void setString(String s) {
        this.s = s;
    }
    public Integer pageListNum=1;
	public void setPageListNum(Integer s){
		this.pageListNum=s;
	}
	public Integer getPageListNum(){
		return pageListNum;
	}
    }