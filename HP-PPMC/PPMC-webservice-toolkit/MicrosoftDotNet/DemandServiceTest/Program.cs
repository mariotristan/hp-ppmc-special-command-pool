using System;
using System.Collections.Generic;
using System.Text;
using DemandServiceTest.localhostDemandService;
using Microsoft.Web.Services3;
using Microsoft.Web.Services3.Design;
using Microsoft.Web.Services3.Security;
using Microsoft.Web.Services3.Security.Tokens;

namespace DemandServiceTest
{
	class Program
	{
		static DemandServiceWse serviceProxy;

		static void Main(string[] args)
		{
			Console.WriteLine("PPM Webservices test with a Microsoft .NET (C#) consumer.");

			Console.Write("\nCreating service proxy...");
			// create service proxy 
			serviceProxy = new DemandServiceWse();
			UsernameOverTransportAssertion policyAssertion = new UsernameOverTransportAssertion();
			Console.WriteLine("done");

			Console.Write("\nSetting authentication policies...");
			// setup WS-Security credentials
			policyAssertion.UsernameTokenProvider = new UsernameTokenProvider("admin", "admin");
			Policy policy = new Policy(policyAssertion);
			serviceProxy.SetPolicy(policy);
			Console.WriteLine("done");

			TestDemandService();

			Console.WriteLine("\nTests completed. Press any key to exit.");
			Console.ReadKey();

		}

		static void TestDemandService()
		{
			Console.WriteLine("\nStarting Demand Service tests...");

			//Test Create Request
			String requestID = CreateRequest();
			//Test Get Request
			GetRequests(requestID);
			//Test Update Fields
			SetRequestFields(requestID);
			//Test Delete Requests
			DeleteRequests(requestID);
			Console.WriteLine("\nDemand Service tests complete.");
		}
		
		static string CreateRequest()
		{
			Console.WriteLine("\nIn CreateRequest");

			//Convert request bean to the client stub
			Request request = new Request();
			request.requestType = "Bug";
			
			//Set Required Fields
			SimpleField[] fields = new SimpleField[6];
			//Description
			fields[0] = new SimpleField();
			fields[0].token = "REQ.DESCRIPTION";
			fields[0].stringValue = new String[] { "WebService Test" };

			//Department
			fields[1] = new SimpleField();
			fields[1].token = "REQ.DEPARTMENT_NAME";
			fields[1].stringValue = new String[] { "Finance" };

			//Module
			fields[2] = new SimpleField();
			fields[2].token = "REQD.VP.MODULE";
			fields[2].stringValue = new String[] { "Module A" };

			//Platform
			fields[3] = new SimpleField();
			fields[3].token = "REQD.VP.PLATFORM";
			fields[3].stringValue = new String[] { "Unix" };

			//Impact
			fields[4] = new SimpleField();
			fields[4].token = "REQD.VP.IMPACT";
			fields[4].stringValue = new String[] { "Warning" };

			//Reproducible
			fields[5] = new SimpleField();
			fields[5].token = "REQD.VP.REPRO";
			fields[5].stringValue = new String[] { "Y" };

			//Add fields to request
			request.simpleFields = fields;

			//Set Notes
			Note[] notes = new Note[1];
			notes[0] = new Note();
			notes[0].author =  "admin";
			notes[0].content = "WebService Test Note";
			notes[0].creationDate = DateTime.Now;

			//Add notes to request
			request.notes = notes;
			
			//Call Webservice
			createRequest cr = new createRequest();
			cr.requestObj = request;
			createRequestResponse response = serviceProxy.createRequest(cr);

			Console.WriteLine("createRequest Succeeded");
			Console.WriteLine("Request: " + response.@return.identifier.id + " Status: " + response.@return.status);
			return response.@return.identifier.id;
		}
		
		static void GetRequests(string requestId)
		{
			Console.WriteLine("\nIn GetRequests");
			
			//Set Identifier
			localhostDemandService.Identifier[] ids = new localhostDemandService.Identifier[1];

			ids[0] = new DemandServiceTest.localhostDemandService.Identifier();
			ids[0].id = requestId;
			
			//Call Webservice
			Request[] requests = serviceProxy.getRequests(ids);

			Console.WriteLine("GetRequests Succeeded");
			Console.WriteLine("Returned Request: "+ requests[0].id);
		}
		
		static void SetRequestFields(string requestId)
		{
			Console.WriteLine("\nIn SetRequestFields");

			//Set Identifier
			localhostDemandService.Identifier reqId = new localhostDemandService.Identifier();
			reqId.id = requestId;

			//Set Fields
			SimpleField[] fields = new SimpleField[3];
			//Description
			fields[0] = new SimpleField();
			fields[0].token = "REQ.DESCRIPTION";
			fields[0].stringValue = new String[] { "WebService Test Update" };

			//Department
			fields[1] = new SimpleField(); 
			fields[1].token = "REQ.DEPARTMENT_NAME";
			fields[1].stringValue = new String[] { "Manufacturing" };

			//Module
			fields[2] = new SimpleField(); 
			fields[2].token = "REQD.VP.MODULE";
			fields[2].stringValue = new String[] { "Module B" };

			//Set the dateValue for each field to a valid value instead of NULL.
			foreach (SimpleField field in fields)
				field.dateValue = DateTime.Now;

			//Call Webservice
			setRequestFields srf = new setRequestFields();
			srf.requestId = reqId;
			srf.fields = fields;
			setRequestFieldsResponse response = serviceProxy.setRequestFields(srf);

			Console.WriteLine("SetRequestFields Succeeded");
			Console.WriteLine("Return Code: " + response.@return);
		}
		
		static void DeleteRequests(string requestId)
		{
			Console.WriteLine("\nIn DeleteRequests");

			//Set Identifier
			localhostDemandService.Identifier[] ids = new localhostDemandService.Identifier[1];
			ids[0] = new DemandServiceTest.localhostDemandService.Identifier();
			ids[0].id = requestId;

			//Call Webservice
			deleteRequestsResponse response = serviceProxy.deleteRequests(ids);
			
			Console.WriteLine("deleteRequests Succeeded");
			Console.WriteLine("Number of requests deleted: " + response.@return);
		}

	}
}
