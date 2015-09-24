public with sharing class pattern_matcher {
	public String pattern_matcher(){
		String s='dsf§$%GefE56 <table> text xml text 46fdf<xls<79df>';
		Pattern P = Pattern.compile('!<*>');
		String result = p.matcher(s).replaceAll('');
		return result;
	}
}