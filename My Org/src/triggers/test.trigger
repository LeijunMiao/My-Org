/**
*	Contains a set of static methods used in invoice creation triggers and VF pages
*
@author Maic Stohr
@created 2009-09-08
@version 2.0
@since 23.0 (Force.com ApiVersion)
*
@changelog
* 2011-07-12 Maic Stohr <maic.stohr@itbconsult.com>
* - Migrated from old system
* - Added ...
*
* 2009-09-09 Maic Stohr <maic.stohr@itbconsult.com>
* - Created
*/

trigger test on Account (before insert) {
    /**
	 * string to store the trigger name
	 */
	String triggerName = 'test'; 
	//************************* BEGIN Pre-Processing **********************************************
	//System.debug('************************* ' + triggerName + ': BEGIN Pre-Processing ********');

	//fetch Record Types
	//currently only for after update, after delete
	if (Trigger.isInsert) {		
        for (Account a : Trigger.new) {        
            if(a.Name == 'text') {
            	a.Name = 'text123';
            }
        } 
	}
	//************************* END Pre-Processing ************************************************
	//System.debug('************************* ' + triggerName + ': END Pre-Processing **********');
	
	//************************* BEGIN Before Trigger **********************************************
	if(Trigger.isBefore) {
		System.debug('************************* ' + triggerName + ': Before Trigger ************');
	}
	//************************* END Before Trigger ************************************************
	
	//************************* BEGIN After Trigger ***********************************************
	if(Trigger.isAfter) {
		System.debug('************************* ' + triggerName + ': After Trigger *************');
	}
	//************************* END After Trigger *************************************************

}