package examples.tm;

import java.io.File;
import java.util.Calendar;

import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;

import com.mercury.itg.ws.tm.client.GetActualTimeDocument;
import com.mercury.itg.ws.tm.client.GetActualTimeResponseDocument;
import com.mercury.itg.ws.tm.client.TimeFilter;
import com.mercury.itg.ws.tm.client.TimeServiceStub;
import com.mercury.itg.ws.tm.client.WorkItemActualTime;

public class TimeServiceClient {

	protected ConfigurationContext ctx = null;
	protected String WSURL = "";
	protected boolean VERBOSE = false;

	
	public TimeServiceClient() {
		String repositoryPath = System.getProperty("client.repository.dir");
		String axis2 = repositoryPath + "/conf/client-axis2.xml";
		File file = new File(axis2);
		if (file.exists()) {
			try {
				ctx = ConfigurationContextFactory
						.createConfigurationContextFromFileSystem(
								repositoryPath, axis2);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * The main program
	 * 
	 * Parameter: args[0] - service URL. e.g.
	 *            args[1] - whether to show the message (optional)
	 * http://server:port/itg/ppmservices/FinanceService
	 * 
	 */
	public static void main(String[] args) throws Exception {
		// check parameter
		if (args.length < 1) {
			System.out.println("Usage: java TimeServiceClient <service URL>");
			System.exit(1);
		}

		System.out.println("Starting Time Service tests...");
		TimeServiceClient tm = new TimeServiceClient();		
		tm.WSURL = args[0];
		
		// test get actual time
		System.out.println("Test getting actual time ...");	
		tm.testGetActualTime();
		
		System.out.println("Time Service tests complete.");
		
	}
	
	/**
	 * Test getting actual time
	 */
	public void testGetActualTime() throws Exception {
		// get stub
		TimeServiceStub stub = new TimeServiceStub(ctx, WSURL);
		
		// create input message
		GetActualTimeDocument getActualTimeDoc = GetActualTimeDocument.Factory.newInstance();
		
		// set filter
		TimeFilter filter = getActualTimeDoc.addNewGetActualTime().addNewParam0();

		// setup the filters
		Calendar startDate = Calendar.getInstance();
		Calendar endDate = Calendar.getInstance();
		endDate.add(Calendar.DATE, 14);
		filter.setStartDate(startDate);
		filter.setEndDate(endDate);
		filter.setPeriodTypeName("Semi-Monthly");
		filter.setIncludeActualCost(true);
		filter.addResources("admin");
		//filter.addTimeSheetLineStatuses("UNSUBMITTED");
		//filter.addTimeSheetStatuses("UNSUBMITTED");
		
		// invoke the service
		GetActualTimeResponseDocument response = stub.getActualTime(getActualTimeDoc);
		
		// process response
		System.out.println("Read " + response.getGetActualTimeResponse().sizeOfReturnArray() + " work item rows");
		WorkItemActualTime[] workItems = response.getGetActualTimeResponse().getReturnArray();
		if (workItems.length > 0) {
			WorkItemActualTime workItem = workItems[0];
			System.out.println("total hours for misc. item = " + workItem.getHours());
		}
	}
	
}
