package hpPPMC;
// Parameter fuer Probeaufruf: "addNote" "30932" "mayerhof"  "ich bin ein lustiger NoteText2" "in Erstellung" "30285"
import java.sql.*;

// Executing the AddNotes Class allows to add a note to a specific Request.
// The following parameters are needed to execute the class: 
// 		Parameter 1: request_id		->  ID of the Request
//		Parameter 2: username		->	Name of the user who wants to add the note
//		Parameter 3: note_text		->	The text of the note
//		Parameter 4: status_name	->	Name of the current Request-Status
//		Parameter 5: status_id		->	ID of the current Request-Status

public class AddNotes {	
	
		public void addNote(String args[]) {				
			
			Connection cn = null;
		    Statement  st = null;
		    ResultSet  rs = null;
		    
		    int returnValue;
		    String querry = null;
		    		    
		    if(args.length == 6) {
		    	
		    	String request_id 	= args[1];
		    	String username 	= args[2];
		    	String note_text 	= args[3];
		    	String status_name 	= args[4];
		    	String status_id 	= args[5];
		    			    	
		    	try {
			    	// Select fitting database driver and connect:
			        Class.forName( PPMCCommands.sDbDrv );
			        cn = DriverManager.getConnection( PPMCCommands.sDbUrl, PPMCCommands.sUsr, PPMCCommands.sPwd );
			        st = cn.createStatement();
			        
			        // Find out the user id
			        querry = "select u.user_id from knta_users u where u.username='" + username + "'";
			        System.out.println(querry);
			        rs = st.executeQuery(querry);
			        rs.next();
			        String user_id = rs.getString("USER_ID");
			        System.out.println("USER_ID " + user_id);
			        
			        // Insert the note into the database
			        querry = "insert into knta_note_entries (note_entry_id, creation_date, created_by, last_update_date, last_updated_by, parent_entity_id, parent_entity_primary_key, author_id, authored_date, note_context_value, note_context_visible_value, note)" +
			        		 "values (knta_note_entries_s.nextval, sysdate, " + user_id + ", sysdate, " + user_id + ", 20 , " + request_id + ", " + user_id + ", sysdate, " + status_id + ", '" + status_name + "', '" + note_text + "' )";
				
			        System.out.println(querry);
			      		        
			        returnValue = st.executeUpdate(querry);
			                
			        System.out.println(returnValue + " rows inserted");
				      
			        querry = "update kcrt_requests r set r.entity_last_update_date = sysdate, r.last_update_date = sysdate, r.last_updated_by = " + user_id + " where r.request_id = " + request_id;
				    System.out.println(querry);
				    returnValue = st.executeUpdate(querry);
				   			   
				    cn.close();
				    st.close();
				    
				    System.out.println(returnValue + " rows updated");				    
			      } catch(SQLException e)
			      {
			    	  System.err.println(e);
			      }
			      catch(Exception e) {
			    	  System.err.println(e);
			      }
		}
		else {
			System.out.println("Wrong number of Arguments");		
		}
	}
}
