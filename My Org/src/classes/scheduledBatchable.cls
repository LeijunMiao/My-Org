global class scheduledBatchable implements Schedulable{
   global void execute(SchedulableContext sc) {
      BatchClsAddUser_Test b = new BatchClsAddUser_Test(); 
      database.executebatch(b);
   }
}