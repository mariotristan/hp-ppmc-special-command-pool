package examples.rm;

import java.io.File;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.Calendar;

import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;
import org.apache.xmlbeans.XmlObject;

import com.mercury.itg.ws.common.client.Note;
import com.mercury.itg.ws.rm.client.CreateResourcePoolsDocument;
import com.mercury.itg.ws.rm.client.CreateResourcePoolsResponseDocument;
import com.mercury.itg.ws.rm.client.GetResourceParticipationDocument;
import com.mercury.itg.ws.rm.client.GetResourcePoolsDocument;
import com.mercury.itg.ws.rm.client.GetResourcePoolsResponseDocument;
import com.mercury.itg.ws.rm.client.ResourceDistributionGroup;
import com.mercury.itg.ws.rm.client.ResourceParticipation;
import com.mercury.itg.ws.rm.client.ResourcePool;
import com.mercury.itg.ws.rm.client.ResourcePoolDistribution;
import com.mercury.itg.ws.rm.client.ResourcePoolReference;
import com.mercury.itg.ws.rm.client.ResourcePoolSearchFilter;
import com.mercury.itg.ws.rm.client.ResourceReference;
import com.mercury.itg.ws.rm.client.ResourceServiceStub;
import com.mercury.itg.ws.rm.client.SearchResourcePoolsDocument;
import com.mercury.itg.ws.rm.client.SetResourceParticipationDocument;
import com.mercury.itg.ws.rm.client.UpdateResourcePoolsDocument;
import com.mercury.itg.ws.rm.client.CreateResourcePoolsResponseDocument.CreateResourcePoolsResponse;
import com.mercury.itg.ws.rm.client.GetResourcePoolsDocument.GetResourcePools;
import com.mercury.itg.ws.rm.client.SearchResourcePoolsResponseDocument.SearchResourcePoolsResponse;

/**
 * Exercise the Resource Pool web service.
 */
public class ResourceServiceClient {

	protected ConfigurationContext ctx = null;
	protected String WSURL = "";
	protected boolean DEBUG = false;
	
	public ResourceServiceClient() {
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
	 * http://server:port/itg/ppmservices/ResourceService
	 * 
	 */
	public static void main(String[] args) throws Exception {
		// check parameter
		if (args.length < 1) {
			System.out.println("Usage: java ResourceServiceClient <service URL> [<true/false>]");
			System.exit(1);
		}

		System.out.println("Starting Resource Service tests...");
		ResourceServiceClient rm = new ResourceServiceClient();
		rm.WSURL = args[0];
		if (args.length > 1 && args[1].equalsIgnoreCase("true")) {
			rm.DEBUG = true;
		}

		// Test Create resourc pool
		System.out.println("Test creating resource pool...");
		long poolId = rm.testCreateResourcePool();
		
		// Test update resoruce pool - an existing resource pool id required
		System.out.println("Test updating resource pool...");
		rm.testUpdateResourcePool(poolId);

		// Test set resource participation
		System.out.println("Test updating resource participation...");
		rm.testSetResourceParticipation();
		
		System.out.println("Resource Service tests complete.");
	}


	/**
	 * Test creating a resource pool with values for all fields, reading it back out and searching for it.
	 */
	public long testCreateResourcePool() throws Exception {
		
		// create the resource pool object
		ResourcePool resourcePool1 = createTestResourcePoolObject("TestResourcePool1");
		ResourcePool resourcePool2 = createTestResourcePoolObject("TestResourcePool2");
		
		// call the service
		ResourcePoolReference[] resourcePoolReference = createResourcePools(new ResourcePool[] { resourcePool1, resourcePool2 });

		// return  first pool id
		return resourcePoolReference[0].getId();

	}

	/**
	 * Test updating a resource pool. 
	 */
	public void testUpdateResourcePool(long poolId) throws Exception {

		// query the resource pool
		ResourcePool[] resourcePools = getResourcePools(new long[] {poolId});
		ResourcePool pool = resourcePools[0];
		
		// update the pool object
		pool.setDescription("New version of the pool");
		
		// remove existing manager
		pool.setManagerArray(new ResourceReference[0]);
		
		// add new manager
		pool.addNewManager().setName("user1"); 

		// remove note	
		pool.setNoteArray(new Note[] {}); 
		
		// set the permissions in the ACL of the "seed data" user to all false		
		// ResourcePoolAccessControlBean acb = pool.getACEsArray(0);
		// acb.setCanEditHeader(false);
		// acb.setCanEditSecurity(false);
		// acb.setCanEditUnnamedHeadCount(false);

		// call the service
		updateResourcePools(new ResourcePool[] { pool} );

	}


	/**
	 * Test creating a resource participation for a resource and then modifying it. 
	 */
	public void testSetResourceParticipation() throws Exception {
		String resource = "user1";

		// create participation object
		ResourceParticipation p = ResourceParticipation.Factory.newInstance();
		p.addNewResource().setName(resource);		
		
		ResourceDistributionGroup group1 = ResourceDistributionGroup.Factory.newInstance();
		group1.setStart(calendar("Jan 1, 2005"));
		group1.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution("TestResourcePool1", 25),
				createDistribution("TestResourcePool2", 50)
		});
		
		ResourceDistributionGroup group2 = ResourceDistributionGroup.Factory.newInstance();
		group2.setStart(calendar("Jan 1, 2006"));
		group2.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution("TestResourcePool1", 5)
		});
		
		ResourceDistributionGroup group3 = ResourceDistributionGroup.Factory.newInstance();
		group3.setStart(calendar("Jan 1, 2007"));
		group3.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution("TestResourcePool1", 90),
				createDistribution("TestResourcePool2", 10)
		});

		p.setDistributionGroupArray(new ResourceDistributionGroup[] { group1, group2, group3 });		
		
		// call service					
		setResourceParticipation(new ResourceParticipation[] { p });
		
		// read and check participation
		// ResourceParticipation[] ps = getResourceParticipation(new ResourceReference[] { resourceRef(null, resource) });
		
	}		

	public static ResourcePool createTestResourcePoolObject(String name) {

		ResourcePool resourcePool = ResourcePool.Factory.newInstance();

		// resource pool name
		resourcePool.setName(name);

		// description
		resourcePool.setDescription("A resource pool created programatically through web services ");

		// region
		resourcePool.addNewRegion().setName("America");

		// pool managers
		resourcePool.addNewManager().setName("admin");

		// set parent pool
		// resourcePool.addNewParent().setName("parent pool name");

		// add children pool
		// resourcePool.addNewChild().setName("child pool name");
		

		// org unit
		// resourcePool.addNewOrgUnit().setName(" org unit name");

		// add notes
		// Note note = resourcePool.addNewNote();
		// note.setContent("Note content");
		// note.setAuthor("admin");  // the value set here is ignored by the RM service layer and replaced with the user executing the operation, which is probably admin 

		// set access control list
		/*
		for (int i = 0; i < usersInACL.length; i++) {
			ResourcePoolAccessControlBean acb = resourcePool.addNewACEs();
			ResourceReference aceUser = acb.addNewUser();
			aceUser.setName(usersInACL[i]);
			acb.setCanEditHeader(true);
			acb.setCanEditSecurity(true);
			acb.setCanEditUnnamedHeadCount(false);
		}
		*/
		
		return resourcePool;


	}

	/**
	 * Create a sample resource participation. Although this looks like a generic method, it expects exactly three resource pools 
	 * and really is meant to be used by the testSetResourceParticipation() method only.
	 *  
	 * @param resource				The username of the resource in the participatio.
	 * @param resourcePoolNames		An array of three resource pool names.
	 * @return						A resource participation.
	 */
	public ResourceParticipation createOriginalParticipation(String resource, String[] resourcePoolNames) {
		if (resourcePoolNames.length != 3) {
			throw new IllegalArgumentException("resourcePoolNames array must contain exactly three names... sorry");
		}
		
		ResourceParticipation p = ResourceParticipation.Factory.newInstance();
		p.addNewResource().setName(resource);		
		
		ResourceDistributionGroup group1 = ResourceDistributionGroup.Factory.newInstance();
		group1.setStart(calendar("Jan 1, 2005"));
		group1.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 25),
				createDistribution(resourcePoolNames[1], 50)
		});
		
		ResourceDistributionGroup group2 = ResourceDistributionGroup.Factory.newInstance();
		group2.setStart(calendar("Jan 1, 2006"));
		group2.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 5),
				createDistribution(resourcePoolNames[1], 10),
				createDistribution(resourcePoolNames[2], 15)
		});
		
		ResourceDistributionGroup group3 = ResourceDistributionGroup.Factory.newInstance();
		group3.setStart(calendar("Jan 1, 2007"));
		group3.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 25),
				createDistribution(resourcePoolNames[2], 15)
		});

		ResourceDistributionGroup group4 = ResourceDistributionGroup.Factory.newInstance();
		group4.setStart(calendar("Feb 1, 2007"));
		group4.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 100)
		});
		
		p.setDistributionGroupArray(new ResourceDistributionGroup[] { group1, group2, group3, group4 });		
		return p;
	}
	
	/**
	 * Return a modified version of the resource participation created by the createOriginalParticipation() method above 
	 * that is used to test the updating of resource participations through the setResourceParticipation web service.
	 *  
	 * @param resource				The username of the resource in the participatio.
	 * @param resourcePoolNames		An array of three resource pool names.
	 * @return						A resource participation.
	 */
	public ResourceParticipation createModifiedParticipation(String resource, String[] resourcePoolNames) {
		if (resourcePoolNames.length != 3) {
			throw new IllegalArgumentException("resourcePoolNames array must contain exactly three names... sorry");
		}
		
		ResourceParticipation p = ResourceParticipation.Factory.newInstance();
		p.addNewResource().setName(resource);		
		
		ResourceDistributionGroup group1 = ResourceDistributionGroup.Factory.newInstance();
		group1.setStart(calendar("Jan 1, 2005"));
		group1.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 25),
				createDistribution(resourcePoolNames[1], 42),
				createDistribution(resourcePoolNames[2], 7)
		});
		
		ResourceDistributionGroup group2 = ResourceDistributionGroup.Factory.newInstance();
		group2.setStart(calendar("Jan 1, 2006"));
		group2.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 5),
				createDistribution(resourcePoolNames[1], 10),
				createDistribution(resourcePoolNames[2], 15)
		});
		
		ResourceDistributionGroup group3 = ResourceDistributionGroup.Factory.newInstance();
		group3.setStart(calendar("Jan 1, 2007"));
		group3.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[2], 100)
		});

		ResourceDistributionGroup group4 = ResourceDistributionGroup.Factory.newInstance();
		group4.setStart(calendar("Jan 2, 2007"));
		group4.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[0], 11),
				createDistribution(resourcePoolNames[1], 22),
				createDistribution(resourcePoolNames[2], 44)
		});
		
		ResourceDistributionGroup group5 = ResourceDistributionGroup.Factory.newInstance();
		group5.setStart(calendar("Feb 1, 2008"));
		group5.setDistributionArray(new ResourcePoolDistribution[] {
				createDistribution(resourcePoolNames[2], 97)
		});
		
		p.setDistributionGroupArray(new ResourceDistributionGroup[] { group1, group2, group3, group4, group5 });		
		return p;
	}
	
	public ResourcePoolDistribution createDistribution(String resourcePoolName, float percent) {
		ResourcePoolDistribution dist = ResourcePoolDistribution.Factory.newInstance();
		dist.setResourcePool(resourcePoolRef(null, resourcePoolName));
		dist.setPercent(percent);
		return dist;
	}
	
	/**
	 * This is a wrapper method around the searchResourcePools web service, which reads resource pools based 
	 * on filter criteria. This method handles the details of creating the document, invoking the service and 
	 * unwrapping the response.
	 * 
	 * @param filter		A bunch of filter fields to narrow down the search.
	 * @return				Zero or more resource pools that match the search criteria.
	 * @throws Exception
	 */
	ResourcePool[] searchResourcePools(ResourcePoolSearchFilter filter) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);
		SearchResourcePoolsDocument searchResourcePoolsDoc = SearchResourcePoolsDocument.Factory.newInstance();
		searchResourcePoolsDoc.addNewSearchResourcePools().setFilter(filter);
		debugPrint(searchResourcePoolsDoc, "search request");
		SearchResourcePoolsResponse searchResponse = service.searchResourcePools(searchResourcePoolsDoc).getSearchResourcePoolsResponse();
		debugPrint(searchResponse, "search response");
		return searchResponse.getResourcePoolArray();
	}

	/**
	 * This is a wrapper method around the getResourcePools web service, which reads resource pools by id. This 
	 * method handles the details of creating the document, invoking the web service and unwrapping the response.
	 * 
	 * @param ids			The primary keys of the resource pools to retrieve.
	 * @return				The resource pools that match the given primary keys; primary keys that don't 
	 *               		correspond to entities in the database are silently ignored.
	 * @throws Exception
	 */
	ResourcePool[] getResourcePools(long[] ids) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);
		GetResourcePoolsDocument getResourcePoolsDoc = GetResourcePoolsDocument.Factory.newInstance();
		GetResourcePools getResourcePools = getResourcePoolsDoc.addNewGetResourcePools();
		getResourcePools.setResourcePoolIdArray(ids);
		GetResourcePoolsResponseDocument responseGet = service.getResourcePools(getResourcePoolsDoc);
		debugPrint(responseGet, "get response");
		return responseGet.getGetResourcePoolsResponse().getResourcePoolArray();
	}

	/**
	 * This is a wrapper method around the createResourcePools web service. It handles the details of creating 
	 * the document, invoking the web service and unwrapping the response.
	 * 
	 * @param resourcePools		Zero or more resource pools to create in PPM.
	 * @return					A resource pool reference for each object that was sucessfully created.
	 * @throws Exception
	 */
	ResourcePoolReference[] createResourcePools(ResourcePool[] resourcePools) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);
		CreateResourcePoolsDocument createResourcePoolsDoc = CreateResourcePoolsDocument.Factory.newInstance();
		createResourcePoolsDoc.addNewCreateResourcePools().setResourcePoolArray(resourcePools);
		CreateResourcePoolsResponseDocument responseDocCreate = service.createResourcePools(createResourcePoolsDoc);
		CreateResourcePoolsResponse responseCreate = responseDocCreate.getCreateResourcePoolsResponse();
		debugPrint(responseCreate, "create response");
		return responseCreate.getResourcePoolRefArray();
	}

	/**
	 * This is a wrapper method around the updateResourcePools web service, which modifies existing resource 
	 * pools. This method handles the details of creating the document, invoking the web service and unwrapping 
	 * the response.
	 * 
	 * @param resourcePools		The changes that should be made to existing resource pools. Resource pools are
	 *  						identified by primary key, so the id of each resource pool must be non-null.
	 * @throws Exception
	 */
	void updateResourcePools(ResourcePool[] resourcePools) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);
		UpdateResourcePoolsDocument updateResourcePoolsDoc = UpdateResourcePoolsDocument.Factory.newInstance();
		updateResourcePoolsDoc.addNewUpdateResourcePools().setResourcePoolArray(resourcePools);
		service.updateResourcePools(updateResourcePoolsDoc);
	}

	/**
	 * This is a wrapper method around the setResourceParticipation web service, which manages the participation of
	 * resources in resource pools. This method handles the details of creating the document, invoking the web service
	 * and unwrapping the response.
	 * 
	 * @param participation		Zero or more ResourceParticipation objects, which encapsulate the participation details
	 * 							for a resource.
	 * @throws Exception
	 */
	public void setResourceParticipation(ResourceParticipation[] participation) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);		
		SetResourceParticipationDocument setParticipationDoc = SetResourceParticipationDocument.Factory.newInstance();
		setParticipationDoc.addNewSetResourceParticipation().setResourceParticipationArray(participation);
		service.setResourceParticipation(setParticipationDoc);
	}
	
	/**
	 * This is a wrapper method around the getResourceParticipation web service, which reads the participation of
	 * resources in resource pools. This method handles the details of creating the document, invoking the web service
	 * and unwrapping the response.
	 * 
	 * @param participation		Zero or more ResourceParticipation objects, which encapsulate the participation details
	 * 							for a resource.
	 * @throws Exception
	 */
	public ResourceParticipation[] getResourceParticipation(ResourceReference[] resources) throws Exception {
		ResourceServiceStub service = new ResourceServiceStub(ctx, WSURL);		
		GetResourceParticipationDocument getParticipationDoc = GetResourceParticipationDocument.Factory.newInstance();
		getParticipationDoc.addNewGetResourceParticipation().setResourceArray(resources);
		return service.getResourceParticipation(getParticipationDoc).getGetResourceParticipationResponse().getResourceParticipationArray();
	}


	/**
	 * Create a search filter with all fields set to match the non-null fields of a specific resource 
	 * pool, thereby creating a search filter that should match only that one resource pool.
	 * 
	 * @param target	The resource pool that the filter will be made for.
	 * @return the search filter.
	 */
	ResourcePoolSearchFilter createSearchFilter(ResourcePool target) {
		ResourcePoolSearchFilter filter = ResourcePoolSearchFilter.Factory.newInstance();
		filter.setName(target.getName());	// required field
		filter.setDescription(target.getDescription());
		filter.addNewRegion().setName(target.getRegion().getName());  // required field
		if (target.sizeOfManagerArray() > 0) {
			// use the first of the resource pool's managers in the search query
			filter.addNewManager().setName(target.getManagerArray(0).getName());   
		}
		if (target.getOrgUnit() != null) {
			filter.addNewOrgUnit().setName(target.getOrgUnit().getName());
		}
		if (target.getParent() != null) {
			filter.addNewParent().setName(target.getParent().getName());
		}		
		return filter;
	}
	
	/**
	 * Create a distribution group with just one resource pool distribution.
	 * 
	 * @param date					The start date of the group.
	 * @param resourcePoolName		The name of the resource pool in the resource pool 
	 * 								distribution. The distribution percentage will be 100%.
	 * @return a distribution group.
	 */
	ResourceDistributionGroup createSimpleDistGroup(String date, String resourcePoolName) {
		return createSimpleDistGroup(date, resourcePoolName, 100);
	}

	/**
	 * Create a distribution group with just one resource pool distribution.
	 * 
	 * @param date					The start date of the group.
	 * @param resourcePoolName		The name of the resource pool in the resource pool distribution.
	 * @param percent				The percentage of the resource's capacity allocated toward that 
	 * 								resource pool.
	 * @return a distribution group.
	 */
	ResourceDistributionGroup createSimpleDistGroup(String date, String resourcePoolName, float percent) {
		ResourceDistributionGroup group = ResourceDistributionGroup.Factory.newInstance();
		group.setStart(calendar(date));
		ResourcePoolDistribution dist = group.addNewDistribution();
		dist.setPercent(percent);
		ResourcePoolReference resourcePool = dist.addNewResourcePool();
		resourcePool.setName(resourcePoolName);
		return group;
	}
	
	/**
	 * Return a resource pool reference object based on a name and id.
	 */
	ResourcePoolReference resourcePoolRef(Long id, String name) {
		ResourcePoolReference ref = ResourcePoolReference.Factory.newInstance();
		if (id != null) ref.setId(id.longValue());
		ref.setName(name);
		return ref;
	}
	
	/**
	 * Return a resource reference object with the given name and id.
	 */
	ResourceReference resourceRef(Long id, String name) {
		ResourceReference ref = ResourceReference.Factory.newInstance();
		if (id != null) ref.setId(id.longValue());
		ref.setName(name);
		return ref;		
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
	
	private void debugPrint(XmlObject obj, String what) throws IOException {
		if (DEBUG) {
			System.out.println("----------------------------------- " + what + " -----------------------------------");
			obj.save(System.out);
			System.out.println();
		}
	}
}
