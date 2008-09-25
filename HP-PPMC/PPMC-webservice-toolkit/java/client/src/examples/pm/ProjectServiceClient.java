package examples.pm;

import java.io.File;
import java.rmi.RemoteException;
import java.util.Calendar;

import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;

import com.mercury.itg.ws.pm.client.AddTaskResultType;
import com.mercury.itg.ws.pm.client.AddTasksToExistingWorkPlanDocument;
import com.mercury.itg.ws.pm.client.AddTasksToExistingWorkPlanResponseDocument;
import com.mercury.itg.ws.pm.client.AnchorType;
import com.mercury.itg.ws.pm.client.AssignmentType;
import com.mercury.itg.ws.pm.client.CreateBlankWorkPlanDocument;
import com.mercury.itg.ws.pm.client.CreateProjectDocument;
import com.mercury.itg.ws.pm.client.CreateProjectResponseDocument;
import com.mercury.itg.ws.pm.client.CreateProjectResultType;
import com.mercury.itg.ws.pm.client.ExecuteWorkflowTransitionDocument;
import com.mercury.itg.ws.pm.client.ProjectInputType;
import com.mercury.itg.ws.pm.client.ProjectServiceStub;
import com.mercury.itg.ws.pm.client.ProjectType;
import com.mercury.itg.ws.pm.client.ReadTasksDocument;
import com.mercury.itg.ws.pm.client.ReadTasksResponseDocument;
import com.mercury.itg.ws.pm.client.ResourceType;
import com.mercury.itg.ws.pm.client.ScheduleInfo;
import com.mercury.itg.ws.pm.client.SearchTaskPreferenceType;
import com.mercury.itg.ws.pm.client.SearchTasksDocument;
import com.mercury.itg.ws.pm.client.SearchTasksResponseDocument;
import com.mercury.itg.ws.pm.client.TaskAnchors;
import com.mercury.itg.ws.pm.client.TaskType;
import com.mercury.itg.ws.pm.client.UpdateProjectDocument;
import com.mercury.itg.ws.pm.client.UpdateTaskActualsDocument;
import com.mercury.itg.ws.pm.client.WorkPlanInputType;
import com.mercury.itg.ws.pm.client.AddTasksToExistingWorkPlanDocument.AddTasksToExistingWorkPlan;
import com.mercury.itg.ws.pm.client.CreateBlankWorkPlanDocument.CreateBlankWorkPlan;
import com.mercury.itg.ws.pm.client.ExecuteWorkflowTransitionDocument.ExecuteWorkflowTransition;
import com.mercury.itg.ws.pm.client.ReadTasksDocument.ReadTasks;
import com.mercury.itg.ws.pm.client.ScheduleInfo.ConstraintType;
import com.mercury.itg.ws.pm.client.SearchTasksDocument.SearchTasks;
import com.mercury.itg.ws.pm.client.UpdateProjectDocument.UpdateProject;
import com.mercury.itg.ws.pm.client.UpdateTaskActualsDocument.UpdateTaskActuals;

public class ProjectServiceClient {
	
	protected ConfigurationContext ctx = null;
	protected String WSURL = "";

	public ProjectServiceClient() {
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
	 * http://server:port/itg/ppmservices/ProjectService
	 * 
	 */
	public static void main(String[] args) throws Exception {
		// check parameter
		if (args.length < 2) {
			System.out.println("Usage: java ProjectServiceClient <service URL> <test project name>");
			System.exit(1);
		}

		System.out.println("Starting Project Service tests...");
		ProjectServiceClient pm = new ProjectServiceClient();		
		pm.WSURL = args[0];
		String projectName = args[1];

		// test create project
		System.out.println("Test creating project ...");
		pm.createProject(projectName);
		
		// update project
		System.out.println("Test updating project ...");
		pm.updateProject(projectName);
		
		// crete blank workplan
		System.out.println("Test creating blank workplan ...");
		pm.createBlankWorkPlan(projectName);
		
		// add task
		System.out.println("Test adding task ...");
		pm.addTaskToExistingWorkPlanWithTopAnchor(projectName);
		
		// search task, read task, and update task actual
		System.out.println("Test search/read/update task ...");
		long[] taskIds = pm.searchTasks(projectName);
		if (taskIds.length > 0) {
			for (int i=0;i<taskIds.length;i++) {
				pm.readTasks(taskIds[i]);
				//pm.updateTaskActuals(taskIds[i]);
			}
		}
		
		// execute workflow transition
		System.out.println("Test workflow transition ...");
		pm.executeWorkflowTransition(projectName, "Launch");
		
		System.out.println("Project Service tests complete.");
		
	}

	private CreateProjectResultType createProject(String projectName) throws java.rmi.RemoteException {
	    
		// create project object
		CreateProjectDocument createProjDoc = CreateProjectDocument.Factory.newInstance();
		ProjectType projectBean = createProjDoc.addNewCreateProject().addNewProjectBean();
		
		
		//set project type
		projectBean.setProjectTypeName("Enterprise");
		//set region
		projectBean.setRegionName("US West Coast");
		//Set the project managers
		projectBean.addProjectManagerUserName("user1");
		//set start period
		projectBean.setPlannedStartPeriodFullName("January 2007");
		//set the finish period
		projectBean.setPlannedFinishPeriodFullName("June 2007");

		
		//set project name
		projectBean.setProjectName(projectName);
		
		//All other non-required properties of projectBean can be set the same way as above.
		
		//Calling creatProject web service api to create the project
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		CreateProjectResponseDocument createProjectResponseDoc = stub.createProject(createProjDoc);
		
		//get the response
		CreateProjectResultType cpResult = createProjectResponseDoc.getCreateProjectResponse().getReturn();
		
		return cpResult;
	}
	

	private void updateProject(String projectName) throws RemoteException {	    
		
		// create the update project object
		UpdateProjectDocument updateProjDoc = UpdateProjectDocument.Factory.newInstance();
		UpdateProject up = updateProjDoc.addNewUpdateProject();
		ProjectInputType pit = up.addNewProjectInput();
		pit.setProjectName(projectName);
		
		//Create projectBean input
		ProjectType pb = up.addNewProjectBean();
		
		//Populate any fields/properties need to be changed.
		//For simplest case, let us just change the probject manager name;
		pb.addProjectManagerUserName("admin");
		pb.setPlannedStartPeriodFullName("March 2007");

		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		stub.updateProject(updateProjDoc);
	}
	
	private void executeWorkflowTransition(String projectName, String transition) throws RemoteException {		
		
		ExecuteWorkflowTransitionDocument updateProjStatusDoc = ExecuteWorkflowTransitionDocument.Factory.newInstance();
		ExecuteWorkflowTransition ups = updateProjStatusDoc.addNewExecuteWorkflowTransition();

		//create projectInputType
		ProjectInputType pit = ups.addNewProjectInput();
		pit.setProjectName(projectName);		
		ups.setTransition(transition);
		
		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		stub.executeWorkflowTransition(updateProjStatusDoc);
	}


	private void createBlankWorkPlan(String projectName) throws RemoteException {		
		//Create inpput document
		CreateBlankWorkPlanDocument crtblkWpDoc = CreateBlankWorkPlanDocument.Factory.newInstance();
		
		//create and add an empty CreateBlankWorkPlan element
		CreateBlankWorkPlan cbwp = crtblkWpDoc.addNewCreateBlankWorkPlan();
		
		//Create and add an empty WorkPlanInputType element
		WorkPlanInputType wpit = cbwp.addNewProjectInput();
		
		//Set the value for this element
		wpit.setProjectName(projectName);
		
		//Calling web service 
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		stub.createBlankWorkPlan(crtblkWpDoc);
	}

	private void addTaskToExistingWorkPlanWithTopAnchor(String projectName) throws RemoteException {
		//Create inpput document
		AddTasksToExistingWorkPlanDocument addTWPDoc = AddTasksToExistingWorkPlanDocument.Factory.newInstance();
		
		//create and add an empty ImportWorkPlanTasks element
		AddTasksToExistingWorkPlan  addTWP = addTWPDoc.addNewAddTasksToExistingWorkPlan();
		
		//Create and add an empty WorkPlanInputType element
		WorkPlanInputType wpit = addTWP.addNewWorkPlanInput();
		
		//Set the value for WorkPlanInput element's projectName
		wpit.setProjectName(projectName);
		
		//create and set anchors,
		TaskAnchors anchors = addTWP.addNewAnchors();
		AnchorType topAnchor = anchors.addNewTopAnchor();
		
		//will add tasks after the root task.
		topAnchor.setOutLineLevel(1);
		topAnchor.setTaskSequeceNumber(0);
		
		//Create and add an empty tasks element
		TaskType task1 = addTWP.addNewTasks();
		
		//Set required properties for task
		//set outline level
		task1.setOutlineLevel(2);
		//set sequence
		task1.setTaskSequence(1);
		//set task name
		task1.setTaskName("pm ws test adddTask");
		
		//creat and add task scheduling bean to task.
		ScheduleInfo sif = task1.addNewSchedulingBean();
		//No need to set schedule duration if both startdate and enddate are set. 
		//If duration is set, the value has to be correct.
		//sif.setScheduledDuration(4);
		sif.setScheduledEffort(34);
		Calendar taskScheduleStart = Calendar.getInstance();
		taskScheduleStart.add(Calendar.DATE, -14);
    	Calendar taskScheduleFinish = Calendar.getInstance();
		taskScheduleStart.add(Calendar.DATE, 14);
		sif.setScheduledStart(taskScheduleStart);
		sif.setScheduledFinish(taskScheduleFinish);
		sif.setConstraintType(ConstraintType.AS_SOON_AS_POSSIBLE);
		
		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		AddTasksToExistingWorkPlanResponseDocument addTaskResponseDoc = stub.addTasksToExistingWorkPlan(addTWPDoc);
		
		//Check the response and make sure we are getting it back ok
		AddTaskResultType[] addedTasks = addTaskResponseDoc.getAddTasksToExistingWorkPlanResponse().getReturnArray();

		if (addedTasks.length <=0) {
			System.out.println("failed to add task.");
		}
	}



	private void updateTaskActuals(long taskId) throws RemoteException {
		//Create inpput document
		UpdateTaskActualsDocument updActDoc = UpdateTaskActualsDocument.Factory.newInstance();
		
		//create and add an empty UpdateTaskActuals element
		UpdateTaskActuals  addTWP = updActDoc.addNewUpdateTaskActuals();
		
		//create the assignment information for which needs to be updated
		AssignmentType assignment = addTWP.addNewAssignments();
		
		//TaskId is required for updateActuals, due to jibx constraint, this
		//restriction is not reflected in preoject.xsd.
		assignment.setTaskId(taskId);
		
		//set up the resource for which we want the actuals to be updated
		ResourceType resource = assignment.addNewResource();
		resource.setResourceId(30130);  // internal user id of the resource
		
		//set other actual values if any
		assignment.setScheduledEffort(36);
		assignment.setActualEffort(13);
		assignment.setActualDuration(2);

		Calendar taskScheduleStart = Calendar.getInstance();
		taskScheduleStart.add(Calendar.DATE, -7);
    	Calendar taskScheduleFinish = Calendar.getInstance();
		taskScheduleStart.add(Calendar.DATE, 7);
		assignment.setEstimatedFinish(taskScheduleFinish);
		assignment.setEstimatedRemainingEffort(0);
		assignment.setActualStart(taskScheduleStart);
		assignment.setActualFinish(taskScheduleFinish);
		assignment.setPercentComplete(100);
		
		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		stub.updateTaskActuals(updActDoc);				
	}



	private void readTasks(long taskId) throws RemoteException {
		//Create inpput document
		ReadTasksDocument readTskDoc = ReadTasksDocument.Factory.newInstance();
		
		//create and add an empty readTasks element
		ReadTasks  readTsks = readTskDoc.addNewReadTasks();
		
		//provide the task ids to be read
		readTsks.addTaskId(taskId);
		
		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		ReadTasksResponseDocument readTskresponseDoc = stub.readTasks(readTskDoc);
		
		TaskType[] tasks = readTskresponseDoc.getReadTasksResponse().getReturnArray();
		
		for (int i =0; i < tasks.length; i++) {
			TaskType task = tasks[i];
			System.out.println("Get task with name: " + task.getTaskName());
			
		}	
	}
	
	private long[] searchTasks(String projectName) throws RemoteException {
		//Create inpput document
		SearchTasksDocument schTsksDoc = SearchTasksDocument.Factory.newInstance();
		
		//create and add an empty SearchTasks element
		SearchTasks  schTsks = schTsksDoc.addNewSearchTasks();
		
		//Create SearchPreference element
		SearchTaskPreferenceType searchPreference = schTsks.addNewSearchPreferences();
		
		searchPreference.setProjectNamesArray(new String[] {projectName});
		
		//searchPreference
		searchPreference.setMaximumTasksToShow(10);
		searchPreference.setStartSearchPosition(1);
		
		//Calendar taskScheduleStart = Calendar.getInstance();
		//taskScheduleStart.add(Calendar.DATE, 20);		
		//searchPreference.setScheduledStartFrom(taskScheduleStart);
		
		
		//Calling web service
		ProjectServiceStub stub = new ProjectServiceStub(ctx, WSURL);
		SearchTasksResponseDocument schTskRespDoc = stub.searchTasks(schTsksDoc);

		// process response
		return schTskRespDoc.getSearchTasksResponse().getTaskIdArray();
	}

}
