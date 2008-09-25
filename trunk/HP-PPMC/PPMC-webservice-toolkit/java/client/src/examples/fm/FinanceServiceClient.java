package examples.fm;

import java.io.File;
import java.math.BigInteger;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;

import com.mercury.itg.ws.fm.client.CostFactor;
import com.mercury.itg.ws.fm.client.CostFactorValue;
import com.mercury.itg.ws.fm.client.CostRate;
import com.mercury.itg.ws.fm.client.CostRule;
import com.mercury.itg.ws.fm.client.CreateCostRulesDocument;
import com.mercury.itg.ws.fm.client.CreateCostRulesResponseDocument;
import com.mercury.itg.ws.fm.client.DeleteCostRulesDocument;
import com.mercury.itg.ws.fm.client.FinanceServiceStub;
import com.mercury.itg.ws.fm.client.GetCostFactorsDocument;
import com.mercury.itg.ws.fm.client.GetCostRulesDocument;
import com.mercury.itg.ws.fm.client.GetCostRulesResponseDocument;
import com.mercury.itg.ws.fm.client.SearchCostRulesDocument;
import com.mercury.itg.ws.fm.client.SetCostFactorsDocument;
import com.mercury.itg.ws.fm.client.UpdateCostRulesDocument;
import com.mercury.itg.ws.fm.client.GetCostFactorsResponseDocument.GetCostFactorsResponse;
import com.mercury.itg.ws.fm.client.SearchCostRulesResponseDocument.SearchCostRulesResponse;
import com.mercury.itg.ws.fm.client.SetCostFactorsDocument.SetCostFactors;

public class FinanceServiceClient {


	public static final String REGION, PROJECT, REQUEST_TYPE, PACKAGE_WORKFLOW, MISC_WORK_ITEMS, RESOURCE_TYPE, ROLE, DEPARTMENT, RESOURCE, ORG_UNIT; 	

	static {
		REGION = "Region"; 
		PROJECT = "Project"; 
		REQUEST_TYPE = "Request Type";
		PACKAGE_WORKFLOW = "Package Workflow"; 
		MISC_WORK_ITEMS = "Misc. Work Items";
		RESOURCE_TYPE = "Resource Type";
		ROLE = "Role";
		DEPARTMENT = "Department"; 
		RESOURCE = "Resource";
		ORG_UNIT = "Org Unit";
	}

	public static final String[] COST_FACTORS = new String[] {REGION, PROJECT, REQUEST_TYPE, PACKAGE_WORKFLOW, MISC_WORK_ITEMS, RESOURCE_TYPE, ROLE, DEPARTMENT, RESOURCE, ORG_UNIT};

	protected ConfigurationContext ctx = null;
	protected String WSURL = "";
	protected boolean VERBOSE = false;

	
	public FinanceServiceClient() {
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
			System.out.println("Usage: java FinanceServiceClient <service URL> [true/false]");
			System.exit(1);
		}

		System.out.println("Starting Finance Service tests...");
		FinanceServiceClient fm = new FinanceServiceClient();		
		fm.WSURL = args[0];
		if (args.length > 1 && args[1].equalsIgnoreCase("true")) {
			fm.VERBOSE = true;
		}

		// Test Get/Set Cost Factors
		System.out.println("Test reading and writing cost factors...");
		fm.testGetSetCostFactors();
		
		// Test create cost rule
		System.out.println("Test creating cost rule...");
		fm.testCreateCostRule();
		

		System.out.println("Finance Service tests complete.");
	}

	/**
	 * Test reading and writing cost factors.
	 */
	public void testGetSetCostFactors() throws Exception {
		deleteAllRules();

		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);

		int i = 0;
		do {
			// write
			SetCostFactorsDocument setCostFactorsDoc = SetCostFactorsDocument.Factory.newInstance();
			SetCostFactors setCostFactors = setCostFactorsDoc.addNewSetCostFactors();
			List newFactors = shuffleCostFactors();
			populate(setCostFactors, newFactors);
			if (VERBOSE) print(setCostFactors);
			FM.setCostFactors(setCostFactorsDoc);
			
			// read
			GetCostFactorsDocument getCostFactorsDoc = GetCostFactorsDocument.Factory.newInstance();
			getCostFactorsDoc.addNewGetCostFactors();
			GetCostFactorsResponse response = FM.getCostFactors(getCostFactorsDoc).getGetCostFactorsResponse();
			if (VERBOSE) print(response);
		} while (++i < 20);
	}

	public void testCreateCostRule() throws Exception {
		enableAllCostFactors();
		CostRule costRule = CostRule.Factory.newInstance();
		costRule.setFactorArray(new CostFactorValue[] {
				costFactorValue(DEPARTMENT, "Finance"),
				costFactorValue(REGION, "America"),
				costFactorValue(MISC_WORK_ITEMS, "Vacation"),
				costFactorValue(REQUEST_TYPE, "Bug")
		}
		);
		costRule.setRateArray(new CostRate[] {
				costRate(null, "Oct 13, 1994", 1.0f),
				costRate("Oct 14, 1994", "Jan 1, 2000", 2.0f),
				costRate("Jan 1, 2001", "Jan 1, 2001", 3.0f),
				costRate("Jan 2, 2001", "June 28, 2006", 3.7f)
		}
		);

		createCostRules(new CostRule[] { costRule });
	}


	CostRate costRate(String startDate, String endDate, float rate) {
		CostRate cr = CostRate.Factory.newInstance();
		if (startDate != null) { cr.setStartDate(calendar(startDate)); }
		if (endDate != null) { cr.setEndDate(endDate != null ? calendar(endDate) : null); }
		cr.setRate(rate);
		cr.setCurrencyCode("USD");
		return cr;
	}

	CostFactorValue costFactorValue(String factor, String name) {
		CostFactorValue val = CostFactorValue.Factory.newInstance();
		val.setFactor(factor);
		val.setName(name);
		return val;
	}

	CostFactor costFactor(String factor, int sortOrder) {
		CostFactor f = CostFactor.Factory.newInstance();
		f.setFactor(factor);
		f.setSortOrder(BigInteger.valueOf(sortOrder));
		return f;
	}

	CostRule[] createCostRules(CostRule[] costRules) throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);
		CreateCostRulesDocument createCostRulesDoc = CreateCostRulesDocument.Factory.newInstance();
		createCostRulesDoc.addNewCreateCostRules().setCostRuleArray(costRules);
		CreateCostRulesResponseDocument response = FM.createCostRules(createCostRulesDoc);
		return response.getCreateCostRulesResponse().getCostRuleArray();
	}

	CostRule[] getCostRules(long[] ids) throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);
		GetCostRulesDocument getCostRulesDoc = GetCostRulesDocument.Factory.newInstance();
		getCostRulesDoc.addNewGetCostRules().setCostRuleIdArray(ids);
		GetCostRulesResponseDocument response = FM.getCostRules(getCostRulesDoc);
		return response.getGetCostRulesResponse().getCostRuleArray();
	}

	void updateCostRules(CostRule[] costRules) throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);
		UpdateCostRulesDocument updateCostRulesDoc = UpdateCostRulesDocument.Factory.newInstance();
		updateCostRulesDoc.addNewUpdateCostRules().setCostRuleArray(costRules);
		FM.updateCostRules(updateCostRulesDoc);
	}

	void deleteCostRules(long[] ids) throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);
		DeleteCostRulesDocument deleteCostRulesDoc = DeleteCostRulesDocument.Factory.newInstance();
		deleteCostRulesDoc.addNewDeleteCostRules().setCostRuleIdArray(ids);
		FM.deleteCostRules(deleteCostRulesDoc);
	}


	/**
	 * Set the cost factors.
	 */
	void setCostFactors(CostFactor[] factors) throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);		
		SetCostFactorsDocument setCostFactorsDoc = SetCostFactorsDocument.Factory.newInstance();
		setCostFactorsDoc.addNewSetCostFactors().setCostFactorArray(factors);
		FM.setCostFactors(setCostFactorsDoc);		
	}

	void enableAllCostFactors() throws Exception {
		CostFactor[] factors = new CostFactor[COST_FACTORS.length];		
		for (int i = 0; i < COST_FACTORS.length; i++) {
			factors[i] = costFactor(COST_FACTORS[i], i);
		}
		setCostFactors(factors);
	}

	/**
	 * Retrieve all cost rules defined in PPM, including the default rule.
	 */
	CostRule[] findAllCostRules() throws Exception {
		FinanceServiceStub FM = new FinanceServiceStub(ctx, WSURL);		
		SearchCostRulesDocument searchCostRulesDoc = SearchCostRulesDocument.Factory.newInstance();
		searchCostRulesDoc.addNewSearchCostRules().addNewFilter();  // empty filter finds ALL rules
		SearchCostRulesResponse searchResponse = FM.searchCostRules(searchCostRulesDoc).getSearchCostRulesResponse();
		return searchResponse.getCostRuleArray();
	}

	/**
	 * Delete all rules in the system.
	 */
	void deleteAllRules() throws Exception {
		CostRule[] rules = findAllCostRules();
		long[] justIds = new long[rules.length];
		for (int i = 0; i < rules.length; i++) {
			justIds[i] = rules[i].getId();
		}
		deleteCostRules(justIds);		
	}

	List shuffleCostFactors() {
		List factors = new ArrayList();
		Random r = new Random();
		for (int i = 0; i < COST_FACTORS.length; i++) {			
			if (r.nextFloat() > .2) {  // more likeley to keep it then not
				factors.add(COST_FACTORS[i]);
			}
		}

		Collections.shuffle(factors);
		return factors;
	}

	void populate(SetCostFactors setCostFactors, List factors) {
		for (int i = 0; i < factors.size(); i++ ) {
			CostFactor f = setCostFactors.addNewCostFactor();
			f.setFactor((String) factors.get(i));
			f.setSortOrder(BigInteger.valueOf(i));
		}
	}

	void print(SetCostFactors setCostFactors) {
		System.out.println("set the following " + setCostFactors.sizeOfCostFactorArray() + " cost factors: ");
		for (int i = 0; i < setCostFactors.sizeOfCostFactorArray(); i++) {
			print(setCostFactors.getCostFactorArray(i));
		}		
	}

	void print(GetCostFactorsResponse getCostFactors) {
		System.out.println("read " + getCostFactors.sizeOfCostFactorArray() + " cost factors: ");
		for (int i = 0; i < getCostFactors.sizeOfCostFactorArray(); i++) {
			print(getCostFactors.getCostFactorArray(i));
		}
	}

	void print(CostFactor factor) {
		System.out.println("cost factor = " + factor.getFactor() + " sort order = " + factor.getSortOrder());
	}

	static Calendar calendar(String s) {
		try {
			Calendar cal = Calendar.getInstance();
			cal.setTime(DateFormat.getDateInstance().parse(s));
			return cal;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}


}
