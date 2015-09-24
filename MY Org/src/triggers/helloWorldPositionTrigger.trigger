trigger helloWorldPositionTrigger on Position__c (before insert) {
Position__c[] accs = Trigger.new;
MyHelloWorld.addHelloWorld(accs);
}