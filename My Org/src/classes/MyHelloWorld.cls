// This class updates the Hello field on account records that are
// passed to it.
public class MyHelloWorld {
public static void addHelloWorld(Position__c[] accs){
for (Position__c a:accs){
if (a.Hello__c != 'World') {
a.Hello__c = 'World';
}
}
}
}