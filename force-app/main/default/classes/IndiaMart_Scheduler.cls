global class IndiaMart_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        IndiaMart_API.callApi();
    }
}