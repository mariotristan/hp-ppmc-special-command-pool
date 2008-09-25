package examples.dm;

import java.io.File;
import java.util.Calendar;

import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.Options;
import org.apache.axis2.client.ServiceClient;
import org.apache.axis2.client.Stub;
import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.axis2.transport.http.HttpTransportProperties;

import com.mercury.itg.ws.dm.client.Note;
import com.mercury.itg.ws.dm.client.Identifier;
import com.mercury.itg.ws.dm.client.RemoteReference;
import com.mercury.itg.ws.dm.client.Request;
import com.mercury.itg.ws.dm.client.SimpleField;
import com.mercury.itg.ws.dm.client.CreateRequestDocument;
import com.mercury.itg.ws.dm.client.CreateRequestResponseDocument;
import com.mercury.itg.ws.dm.client.DeleteRequestsDocument;
import com.mercury.itg.ws.dm.client.DeleteRequestsResponseDocument;
import com.mercury.itg.ws.dm.client.GetRequestsDocument;
import com.mercury.itg.ws.dm.client.GetRequestsResponseDocument;
import com.mercury.itg.ws.dm.client.SetRequestFieldsDocument;
import com.mercury.itg.ws.dm.client.SetRequestFieldsResponseDocument;
import com.mercury.itg.ws.dm.client.DemandServiceStub;

public class DemandServiceClient {

	protected ConfigurationContext ctx = null;

	public DemandServiceClient() {
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
	 * http://server:port/itg/ppmservices/DemandService
	 * 
	 */
	public static void main(String[] args) throws Exception {
		// check parameter
		if (args.length < 1) {
			System.out.println("Usage: java DemandServiceClient <service URL>");
			System.exit(1);
		}

		System.out.println("Starting Demand Service tests...");

		// get server URL
		String serviceURL = args[0];

		// Test Create Request
		DemandServiceClient dm = new DemandServiceClient();
		String requestId = dm.createRequest(serviceURL);

		// Test Get Request
		dm.getRequests(serviceURL,requestId);

		// Test Update Fields
		dm.setRequestFields(serviceURL,requestId);

		// Test Delete Requests
		dm.deleteRequests(serviceURL,requestId);

		System.out.println("Demand Service tests complete.");
	}

	private String createRequest(String serviceURL) throws Exception {

		// Construct a request object
		Request oRequest = Request.Factory.newInstance();
		oRequest.setRequestType("Bug");
		SimpleField[] fields = new SimpleField[6];

		// Set values for the fields of the request object

		// Set field 'Description'
		SimpleField field_A = SimpleField.Factory.newInstance();
		field_A.setToken("REQ.DESCRIPTION");
		field_A.setStringValue1Array(new String[] { "WebService Test" });
		fields[0] = field_A;

		// Set field 'Department'
		SimpleField field_B = SimpleField.Factory.newInstance();
		field_B.setToken("REQ.DEPARTMENT_NAME");
		field_B.setStringValue1Array(new String[] { "Finance" });
		fields[1] = field_B;

		// Set field 'Module'
		SimpleField field_C = SimpleField.Factory.newInstance();
		field_C.setToken("REQD.VP.MODULE");
		field_C.setStringValue1Array(new String[] { "Module A" });
		fields[2] = field_C;

		// Set field 'Platform'
		SimpleField field_D = SimpleField.Factory.newInstance();
		field_D.setToken("REQD.VP.PLATFORM");
		field_D.setStringValue1Array(new String[] { "Unix" });
		fields[3] = field_D;

		// Set field 'Impact'
		SimpleField field_E = SimpleField.Factory.newInstance();
		field_E.setToken("REQD.VP.IMPACT");
		field_E.setStringValue1Array(new String[] { "Warning" });
		fields[4] = field_E;

		// Set field 'Reproducible'
		SimpleField field_F = SimpleField.Factory.newInstance();
		field_F.setToken("REQD.VP.REPRO");
		field_F.setStringValue1Array(new String[] { "Y" });
		fields[5] = field_F;

		// Add all the fields to request object
		oRequest.setSimpleFieldsArray(fields);

		// Set Notes
		Note[] notes = new Note[1];
		Note note = Note.Factory.newInstance();
		note.setAuthor("admin");
		note.setContent("WebService Test Note");
		Calendar calendar = Calendar.getInstance();
		note.setCreationDate(calendar);
		notes[0] = note;
		oRequest.setNotesArray(notes); 

		// Get web service
		DemandServiceStub stub = new DemandServiceStub(ctx, serviceURL);
		setHttpBasicAuthHeader(stub, serviceURL);	

		// Construct message to send
		CreateRequestDocument inDoc = CreateRequestDocument.Factory
				.newInstance();
		CreateRequestDocument.CreateRequest createRequest = inDoc
				.addNewCreateRequest();
		createRequest.setRequestObj(oRequest);

		// Invoke web service
		CreateRequestResponseDocument outDoc = stub.createRequest(inDoc);

		// Process return message
		RemoteReference ref = outDoc.getCreateRequestResponse().getReturn();
		return ref.getIdentifier().getId();
	}

	private void getRequests(String serviceURL, String requestId)
			throws Exception {

		// Set Identifier
		Identifier[] ids = new Identifier[1];
		Identifier reqId = Identifier.Factory.newInstance();
		reqId.setId(requestId);
		reqId.setServerURL(serviceURL);
		ids[0] = reqId;

		// Call Webservice
		DemandServiceStub stub = new DemandServiceStub(ctx, serviceURL);

		setHttpBasicAuthHeader(stub, serviceURL);
		GetRequestsDocument inDoc = GetRequestsDocument.Factory.newInstance();
		GetRequestsDocument.GetRequests getRequests = inDoc.addNewGetRequests();
		getRequests.setRequestIdsArray(ids);
		GetRequestsResponseDocument outDoc = stub.getRequests(inDoc);
		Request[] requests = outDoc.getGetRequestsResponse().getReturnArray();
		System.out.println("getRequests Succeeded");
		System.out.println("Returned Request: " + requests[0].getId());
	}

	private void setRequestFields(String serviceURL, String requestId)
			throws Exception {
		System.out.println("Start setRequestFields...");
		// Set Identifier
		Identifier reqId = Identifier.Factory.newInstance();
		reqId.setId(requestId);
		reqId.setServerURL(serviceURL);
		// Set Fields
		SimpleField[] fields = new SimpleField[3];
		// Description
		SimpleField field_A = SimpleField.Factory.newInstance();
		field_A.setToken("REQ.DESCRIPTION");
		field_A.setStringValue1Array(new String[] { "WebService Test Update" });
		fields[0] = field_A;
		// Department
		SimpleField field_B = SimpleField.Factory.newInstance();
		field_B.setToken("REQ.DEPARTMENT_NAME");
		field_B.setStringValue1Array(new String[] { "Manufacturing" });
		fields[1] = field_B;
		// Module
		SimpleField field_C = SimpleField.Factory.newInstance();
		field_C.setToken("REQD.VP.MODULE");
		field_C.setStringValue1Array(new String[] { "Module B" });
		fields[2] = field_C;
		// Call Webservice
		DemandServiceStub stub = new DemandServiceStub(ctx, serviceURL);
		setHttpBasicAuthHeader(stub, serviceURL);
		SetRequestFieldsDocument inDoc = SetRequestFieldsDocument.Factory
				.newInstance();
		SetRequestFieldsDocument.SetRequestFields setRequestFields = inDoc
				.addNewSetRequestFields();
		setRequestFields.setRequestId(reqId);
		setRequestFields.setFieldsArray(fields);
		SetRequestFieldsResponseDocument outDoc = stub.setRequestFields(inDoc);
		int retCode = outDoc.getSetRequestFieldsResponse().getReturn();
		System.out.println("setRequestFields Succeeded");
		System.out.println("Return Code: " + retCode);
	}

	private void deleteRequests(String serviceURL, String requestId)
			throws Exception {
		System.out.println("Start deleteRequests...");
		// Set Identifier
		Identifier[] ids = new Identifier[1];
		Identifier reqId = Identifier.Factory.newInstance();
		reqId.setId(requestId);
		reqId.setServerURL(serviceURL);
		ids[0] = reqId;
		// Call Webservice
		DemandServiceStub stub = new DemandServiceStub(ctx, serviceURL);
		setHttpBasicAuthHeader(stub, serviceURL);
		DeleteRequestsDocument inDoc = DeleteRequestsDocument.Factory
				.newInstance();
		DeleteRequestsDocument.DeleteRequests deleteRequests = inDoc
				.addNewDeleteRequests();
		deleteRequests.setRequestIdsArray(ids);
		DeleteRequestsResponseDocument outDoc = stub.deleteRequests(inDoc);
		int retCode = outDoc.getDeleteRequestsResponse().getReturn();
		System.out.println("deleteRequests Succeeded");
		System.out.println("Number of requests deleted: " + retCode);
	}
	
    /**
	 * Set http basic auth headers
	 * @param stub
	 */
	public void setHttpBasicAuthHeader(Stub stub, String serviceURL) {
		Options options = new Options();
		HttpTransportProperties.Authenticator auth = new
			HttpTransportProperties.Authenticator();
		auth.setUsername("admin"); 
		auth.setPassword("admin"); 
		auth.setPreemptiveAuthentication(true);
		options.setProperty(HTTPConstants.AUTHENTICATE, auth);
		options.setTo(new EndpointReference(serviceURL));
		stub._getServiceClient().setOptions(options);
	}
	
}
