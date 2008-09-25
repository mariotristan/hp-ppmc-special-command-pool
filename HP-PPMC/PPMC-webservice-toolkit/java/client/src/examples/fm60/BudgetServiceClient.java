package examples.fm60;

import java.math.*;
import java.net.*;
import java.rmi.server.*;
import java.util.*;
import com.kintana.core.soap.stubs.*;
import com.kintana.core.soap.stubs.fm.*;

public class BudgetServiceClient {

	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
	   // check parameters
	   if (args.length != 5) {
	      System.out.println("Usage: java BudgetServiceClient <url> <user> <password> <action> <budget id/name>");
	      System.exit(0);
	   }
	   
	   // get parameters.
	   String url = args[0];
	   String user =  args[1];
	   String password = args[2];
	   String action = args[3];
	   String budgetName = args[4];
	
	   // test
	   if ("create".equalsIgnoreCase(action)) { // test create
	      testCreate(url, user, password, budgetName);
	   } else if ("update".equalsIgnoreCase(action)) { // test update
	      testUpdate(url, user, password, budgetName);
	   } else { // test read
	      testRead(url, user, password, budgetName);
	   }
	}
	/**
	 * @param args
	 */
	public static Integer testRead(String url, String user, String password, String budgetName) throws Exception {
		
		// get finance service
		FinanceServicesService locator = new FinanceServicesServiceLocator();
		FinanceServices svc = locator.getFinance(new URL(url));
		
		// Construct request header
		RequestHeader header = new RequestHeader();
		header.setAuditNote("Test");
		header.setOrigin("PPM on " + InetAddress.getLocalHost().getHostAddress());
		header.setCredentials(new LoginAccount(user, password));
		header.setTransactionName(new UID().toString());
		
		
		// Construct filter
		// if just pass the empty filter, all existing budget will be returned.
		BudgetFilters filter = new BudgetFilters(); 
		filter.setBudgetName(budgetName);

		// example of filter by user data
		//Field[] ud = new Field[2]; // specify two user data field
		//ud[0] = new Field();
		//ud[0].setToken("BGT.APPROVER"); // field token
		//ud[0].setValue(new SingleValue("FOO")); // field value
		//ud[1] = new Field();
		//ud[1].setToken("BGT.APPROVE_DATE");
		//ud[1].setValue(new DateValue(new java.util.GregorianCalendar()));
		//filter.setBudgetUserData(ud);
		
		// Construct read message
		ReadMessage readMsg = new ReadMessage(header, filter);
	
		// invoke service: read
		ReadResponse readResp = svc.read(readMsg);
		
		// print result
		Integer lastID = new Integer(0);
		Budget[] budgets = readResp.getBudget();
		if (budgets != null && budgets.length > 0) {
			for(int i=0;i<budgets.length;i++) {
            lastID = budgets[i].getBudgetID();				
				System.out.println("Get budget: " + budgets[i].getBudgetName() + "(" + budgets[i].getBudgetID() + ")");
			}
		} else {
			System.out.println("No budget found");
		}
		
		// return the budget id of the last one (test purpose only)
		return lastID;
		
	}

	public static void testCreate(String url, String user, String password, String budgetName) throws Exception {
		
		
		// get finance service
		FinanceServicesService locator = new FinanceServicesServiceLocator();
		FinanceServices svc = locator.getFinance(new URL(url));
		
		// Construct request header
		RequestHeader header = new RequestHeader();
		header.setAuditNote("Test");
		header.setOrigin("PPM on " + InetAddress.getLocalHost().getHostAddress());
		header.setCredentials(new LoginAccount(user, password));
		header.setTransactionName(new UID().toString());
		
		
		// Construct budget
		Budget budget = new Budget();
		budget.setBudgetName(budgetName); // required
		budget.setStartPeriodStartDate(new GregorianCalendar(2007, 2, 15)); // required
		budget.setEndPeriodStartDate(new GregorianCalendar(2007, 6, 15)); // required
		budget.setPeriodType("Fiscal Month"); // required: seems we only support fiscal month (confirmed)
		budget.setBudgetStatus("New"); // required
		budget.setRegionName("Enterprise"); // required

		// new budget line
		BudgetLine[] lines = new BudgetLine[1];
		lines[0] = new BudgetLine();
		lines[0].setTypeCode("NON_LABOR"); // value has to be either 'LABOR' or 'NON_LABOR', and can't be null
		lines[0].setExpenseTypeCode("CAPITAL"); // value has to be either 'CAPITAL' or 'OPERATING', and can't be null
		lines[0].setCategoryCode("HARDWARE");
		BudgetLineDetail[] details = new BudgetLineDetail[3];
		details[0] = new BudgetLineDetail("March 2007", new GregorianCalendar(2007, 2, 1), new BigDecimal(123000), new BigDecimal(77000));
		details[1] = new BudgetLineDetail("April 2007", new GregorianCalendar(2007, 3, 1), new BigDecimal(124000), null);
		details[2] = new BudgetLineDetail("May 2007", new GregorianCalendar(2007, 4, 1), new BigDecimal(125000), null);
		lines[0].setBudgetLineDetails(details);
		budget.setBudgetLines(lines);

		
		// Construct read message
		CreateMessage createMsg = new CreateMessage(header, budget);
	
		// invoke service: read
		CreateResponse createResp = svc.create(createMsg);
		
		// print result
		System.out.println("Budget created: id = " + createResp.getBudgetID());
		
	}

	public static void testUpdate(String url, String user, String password, String budgetName) throws Exception {
		
		
		// get finance service
		FinanceServicesService locator = new FinanceServicesServiceLocator();
		FinanceServices svc = locator.getFinance(new URL(url));
		
		// Construct request header
		RequestHeader header = new RequestHeader();
		header.setAuditNote("Test");
		header.setOrigin("PPM on " + InetAddress.getLocalHost().getHostAddress());
		header.setCredentials(new LoginAccount(user, password));
		header.setTransactionName(new UID().toString());
		
		// get budget id
		Integer budgetId = testRead(url, user, password, budgetName);
		
		// Construct budget
		Budget budget = new Budget();
		budget.setBudgetID(budgetId);    // must have it for update
		budget.setBudgetName(budgetName); 
		budget.setDescription("This is a test, please ignore"); // for update, description can not be null (maybe a defect :-)
		budget.setStartPeriodStartDate(new GregorianCalendar(2007, 2, 1)); // has to be exactly the same as in existing budget
		budget.setEndPeriodStartDate(new GregorianCalendar(2007, 6, 1)); // has to be exactly the same as in existing budget
		budget.setPeriodType("Fiscal Month"); // required: seems we only support fiscal month (confirmed)
		budget.setBudgetStatus("New"); // required
		budget.setRegionName("Enterprise"); // required
		BudgetLine[] lines = new BudgetLine[2];
		budget.setBudgetLines(lines);
		
		// new budget line
		lines[0] = new BudgetLine();
		lines[0].setTypeCode("NON_LABOR"); // value has to be either 'LABOR' or 'NON_LABOR', and can't be null
		lines[0].setExpenseTypeCode("CAPITAL"); // value has to be either 'CAPITAL' or 'OPERATING', and can't be null
		lines[0].setCategoryCode("SOFTWARE");
		BudgetLineDetail[] details = new BudgetLineDetail[3];
		details[0] = new BudgetLineDetail("March 2007", new GregorianCalendar(2007, 2, 1), new BigDecimal(123000), new BigDecimal(77000));
		details[1] = new BudgetLineDetail("April 2007", new GregorianCalendar(2007, 3, 1), new BigDecimal(124000), null);
		details[2] = new BudgetLineDetail("May 2007", new GregorianCalendar(2007, 4, 1), new BigDecimal(125000), null);
		lines[0].setBudgetLineDetails(details);
		
		// update existing budget line (with uncomment the set line id 
		lines[1] = new BudgetLine();
		// lines[1].setBudgetLineID(new Integer(34081));
		lines[1].setTypeCode("NON_LABOR"); // value has to be either 'LABOR' or 'NON_LABOR', and can't be null
		lines[1].setExpenseTypeCode("CAPITAL"); // value has to be either 'CAPITAL' or 'OPERATING', and can't be null
		lines[1].setCategoryCode("HARDWARE");
		details = new BudgetLineDetail[2];
		details[0] = new BudgetLineDetail("March 2007", new GregorianCalendar(2007, 2, 1), new BigDecimal(854000), null);
		details[1] = new BudgetLineDetail("April 2007", new GregorianCalendar(2007, 3, 1), new BigDecimal(744000), null);
		lines[1].setBudgetLineDetails(details);
		
		
		// Construct read message
		UpdateMessage updateMsg = new UpdateMessage(header, budget);
	
		// invoke service: read
		UpdateResponse updateResp = svc.update(updateMsg);
		
		// print result
		System.out.println("Budget updated: id = " + updateResp.getBudgetID());
		
	}

}

