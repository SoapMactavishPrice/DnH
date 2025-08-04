global class TradeIndia_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        TradeIndia_API.callApi();
    }
}