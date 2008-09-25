using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Web.Services3;
using Microsoft.Web.Services3.Design;
using ProjectServiceTest.localhostProjectService;

namespace ProjectServiceTest
{
	class Program
	{
		static void Main(string[] args)
		{
			string hostURL;

			Console.Write("Please enter the URL of the webservice host, without the path name of the service file, and press Enter.");
			Console.WriteLine(" [Leave blank for http://localhost:8080]");
			hostURL = Console.ReadLine().Trim();

			if (hostURL.Length == 0) hostURL = "http://localhost:8080";
			if (!hostURL.EndsWith("/")) hostURL += "/";
			hostURL += "itg/ppmservices/ProjectService?wsdl";

			Console.WriteLine("\nCreating service proxy...");
			ProjectServiceWse serviceProxy = new ProjectServiceWse();
			serviceProxy.Url = hostURL;

			Console.WriteLine("\nSetting authentication policy...");
			UsernameOverTransportAssertion policyAssertion = new UsernameOverTransportAssertion();
			policyAssertion.UsernameTokenProvider = new UsernameTokenProvider("admin", "admin");
			Policy p = new Policy(policyAssertion);
			serviceProxy.SetPolicy(p);

			Console.WriteLine("\nCalling createProject service...");
			CreateProject cp = new CreateProject();
			cp.projectBean = new projectType();
			cp.projectBean.Item = "Enterprise";
			cp.projectBean.plannedFinishPeriodFullName = "May 2007";
			cp.projectBean.plannedStartPeriodFullName = "May 2007";
			cp.projectBean.projectName = "Test webservices project " + DateTime.Now.Ticks;
			cp.projectBean.regionName = "America";
			cp.projectBean.projectManagerUserName = new string[1] { "admin" };
			CreateProjectResponse cpr = serviceProxy.createProject(cp);
			Console.WriteLine("Project created with ID={0}; Name={1}", cpr.@return.projectId, cp.projectBean.projectName);


			Console.WriteLine("\nCalling createBlankWorkPlan service...");
			CreateBlankWorkPlan cbwp = new CreateBlankWorkPlan();
			cbwp.projectInput = new workPlanInputType();
			cbwp.projectInput.Item = cp.projectBean.projectName;
			CreateBlankWorkPlanResponse cbwpr = serviceProxy.createBlankWorkPlan(cbwp);
			Console.WriteLine("Blank work plan created with response={0}", cbwpr.ToString());

			Console.WriteLine("\nAdding a task to the blank work plan (addTasksToExistingWorkPlan)...");
			AddTasksToExistingWorkPlan attewp = new AddTasksToExistingWorkPlan();
			attewp.workPlanInput = new workPlanInputType();
			attewp.workPlanInput.Item = cp.projectBean.projectName;

			//Create and add an empty task element
			taskType task1 = new taskType();

			attewp.tasks = new taskType[1];
			attewp.tasks[0] = task1;

			//Set required properties for task
			//set outline level
			task1.outlineLevel = 2;
			//set sequence
			task1.taskSequence = 1;
			//set task name
			task1.taskName = "pm ws test addTask 1";

			//create and add task scheduling bean to task.
			scheduleInfo si = new scheduleInfo();
			si.scheduledDuration = 4;
			si.scheduledEffort = 34;
			si.scheduledStart = new DateTime(2007, 2, 21);
			si.scheduledFinish = new DateTime(2007, 2, 22);
			si.constraintType = scheduleInfoConstraintType.assoonaspossible;
			task1.schedulingBean = si;

			attewp.anchors = new taskAnchors();
			attewp.anchors.topAnchor = new anchorType();
			attewp.anchors.topAnchor.outLineLevel = 1;
			attewp.anchors.topAnchor.taskSequeceNumber = 0;

			//All other data is optional, but can be set up the same way as above.
			//Calling service layer api
			addTaskResultType[] addedTasks = serviceProxy.addTasksToExistingWorkPlan(attewp);
			//Check the response and make sure we are getting it back ok
			for (int i = 0; i < addedTasks.Length; i++)
			{
				addTaskResultType addedTask = addedTasks[i];
				Console.WriteLine("Task added: ID={0}; Sequence={1}", addedTask.taskId, addedTask.taskSequenceNumber);
			}
			Console.WriteLine();



			Console.WriteLine("\nAdding two more tasks to the work plan (addTasksToExistingWorkPlan)...");
			attewp = new AddTasksToExistingWorkPlan();
			attewp.workPlanInput = new workPlanInputType();
			attewp.workPlanInput.Item = cp.projectBean.projectName;

			attewp.tasks = new taskType[2];
			attewp.tasks[0] = new taskType();
			attewp.tasks[1] = new taskType();

			//Set required properties for task
			//set outline level
			attewp.tasks[0].outlineLevel = 2;
			//set sequence
			attewp.tasks[0].taskSequence = 2;
			//set task name
			attewp.tasks[0].taskName = "pm ws test addTask 2";

			//set outline level
			attewp.tasks[1].outlineLevel = 3;
			//set sequence
			attewp.tasks[1].taskSequence = 3;
			//set task name
			attewp.tasks[1].taskName = "pm ws test addTask 3";


			//create and add task scheduling bean to task.
			si = new scheduleInfo();
			si.scheduledDuration = 4;
			si.scheduledEffort = 34;
			si.scheduledStart = new DateTime(2007, 2, 21);
			si.scheduledFinish = new DateTime(2007, 2, 22);
			si.constraintType = scheduleInfoConstraintType.assoonaspossible;
			attewp.tasks[0].schedulingBean = si;

			si = new scheduleInfo();
			si.scheduledDuration = 4;
			si.scheduledEffort = 34;
			si.scheduledStart = new DateTime(2007, 2, 21);
			si.scheduledFinish = new DateTime(2007, 2, 22);
			si.constraintType = scheduleInfoConstraintType.assoonaspossible;
			attewp.tasks[1].schedulingBean = si;


			attewp.anchors = new taskAnchors();
			attewp.anchors.topAnchor = new anchorType();
			attewp.anchors.topAnchor.outLineLevel = 1;
			attewp.anchors.topAnchor.taskSequeceNumber = 0;
			attewp.anchors.bottomAnchor = new anchorType();
			attewp.anchors.bottomAnchor.outLineLevel = 2;
			attewp.anchors.bottomAnchor.taskSequeceNumber = 1;

			//All other data is optional, but can be set up the same way as above.
			//Calling service layer api
			addedTasks = serviceProxy.addTasksToExistingWorkPlan(attewp);

			//Check the response and make sure we are getting it back ok
			for (int i = 0; i < addedTasks.Length; i++)
			{
				addTaskResultType addedTask = addedTasks[i];
				Console.WriteLine("Task added: ID={0}; Sequence={1}", addedTask.taskId, addedTask.taskSequenceNumber);
			}
			Console.WriteLine();


			Console.WriteLine("\nCalling searchTasks service...");
			SearchTasks searchTasks = new SearchTasks();
			searchTasks.searchPreferences = new searchTaskPreferenceType();
			searchTasks.searchPreferences.projectNames = new string[] { cp.projectBean.projectName };

			searchTasks.searchPreferences.maximumTasksToShow = 10;

			long[] searchTasksResponse = serviceProxy.searchTasks(searchTasks);

			//Check the response and make sure we are getting it back ok
			for (int i = 0; i < searchTasksResponse.Length; i++)
			{
				Console.WriteLine("SearchTasks returned: {0}", searchTasksResponse[i]);
			}
			Console.WriteLine();



			Console.WriteLine("\nCalling readTasks service...");
			taskType[] readTasksResponse = serviceProxy.readTasks(searchTasksResponse);
			//Check the response and make sure we are getting it back ok
			for (int i = 0; i < readTasksResponse.Length; i++)
			{
				taskType taskResponse = readTasksResponse[i];
				Console.WriteLine("ReadTasks returned: Name={0}; Sequence={1}; Start={2}; Finish={3}", taskResponse.taskName, taskResponse.taskSequence, taskResponse.schedulingBean.scheduledStart, taskResponse.schedulingBean.scheduledFinish);
			}
			Console.WriteLine();


			Console.WriteLine("\nDone. Press any key to exit.");
			Console.ReadKey();
		}
	}
}
