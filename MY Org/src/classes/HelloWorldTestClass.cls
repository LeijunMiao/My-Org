@isTest
private class HelloWorldTestClass {
static testMethod void validateHelloWorld() {
Position__c a = new Position__c(name='T1 Position');
// Insert account
insert a;
// Retrieve account
a = [SELECT Hello__c FROM Position__c WHERE Id =:a.id];
// Test that HelloWorld program correctly added the value
// "World" to the Hello field
System.assertEquals('World', a.Hello__c);
}
}