/**
* @author Vijai
* @date 14/06/2024
* @description Defines the interface for trigger handlers. Logic for the first time events are placed under the mainEntry 
*				method and the logic for the subsequent events raised on the same transaction (reentrant) are placed under 
*				the inProgressEntry method.
*/
public interface ITriggerHandler {
	/** 
    * @author Vijai
    * @date 14/06/2024
	* @description Called for the first time in the execution context.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void mainEntry(TriggerParameters tp);
	
	/** 
    * @author Vijai
    * @date 14/06/2024
	* @description Called for the subsequent times in the same execution context.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void inProgressEntry(TriggerParameters tp);
	
	/** 
    * @author Vijai
    * @date 14/06/2024
	* @description Updates the objects, if any.
	*/
	void updateObjects();
}