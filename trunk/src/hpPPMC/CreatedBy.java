package hpPPMC;
// Parameter fuer Probeaufruf: "changeCreater" "30932" "100079"
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CreatedBy {
		
	Connection cn = null;
    Statement  st = null;
    ResultSet  rs = null;
    String querry = null;
        
    public void changeCreater(String args[]) {
    	
    	int returnValue;
    	
    	if(args.length == 3) {
			
    		String request_id = args[1];
    		String user_id	  = args[2];
    		
    		try {
		    	// Select fitting database driver and connect:
		        Class.forName( PPMCCommands.sDbDrv );
		        cn = DriverManager.getConnection( PPMCCommands.sDbUrl, PPMCCommands.sUsr, PPMCCommands.sPwd );
		        st = cn.createStatement();
		        
		        // Find out the user id
		        querry = "update kcrt_requests r set r.entity_last_update_date = sysdate, r.created_by = '" + user_id + "' where r.request_id = '" + request_id + "'";
		        System.out.println(querry);
		        returnValue = st.executeUpdate(querry);
		        System.out.println(returnValue + " rows updated");
		        
			} catch(Exception e) {
				System.err.println(e);
			}
    	}
    	else {
    		System.out.println("Wrong number of Arguments");
    	}
    }
}
