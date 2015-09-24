public without sharing class CtrlTestPDFToImg {
	public string pdfbase64{get;set;}
	public string name{get;set;}
	public string conType{get;set;}
	public CtrlTestPDFToImg(){
		for(Attachment a: [SELECT Id, Body,ContentType, Name FROM Attachment where id='00P9000000apNlhEAE']){
			pdfbase64 =   EncodingUtil.base64Encode(a.Body);
			name = a.Name;
			conType = a.ContentType;
		}
	}
}