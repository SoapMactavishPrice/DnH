@isTest
public class AccDetailsTest {

    @isTest
    public static void testAccDetails() {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        String accID = acc.Id;

        Map<String, Object> result = AccDetails.fetchData(accID);
        Account fetchedAcc = AccDetails.fetchAccountData(accID);
        Integer taskCount = AccDetails.getTaskCount(accID);
        Integer eventCount = AccDetails.getEventCount(accID);
        Integer daysSinceLastOrder = AccDetails.getDaysSinceLastOrder(accID);
        Integer totalOrders = AccDetails.getTotalSalesOrders(accID);
        Integer totalEnquiries = AccDetails.getTotalEnquiries(accID);
    }
}