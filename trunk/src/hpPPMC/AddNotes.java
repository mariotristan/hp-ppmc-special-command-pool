package hpPPMC;

import java.sql.*;

public class AddNotes {	
	public static void main(String[] args) {

		int returnValue;
		String querry = null;
		String request_id = null, username = null, note_text = null, status_name = null, status_id = null;
				
		if( args.length == 5 ) {
			
			request_id = args[0];
		    username = args[1];
		    note_text = args[2];
		    status_name = args[3]; 
		    status_id = args[4];
		      
			String sDbDrv="oracle.jdbc.driver.OracleDriver",
	    	sDbUrl="jdbc:oracle:thin:@16.55.43.33:1521:orcl",
	    	sUsr="ppmc1", sPwd="ppmc1";
			
			Connection cn = null;
		    Statement  st = null;
		    ResultSet  rs = null;
		    
		    try {
		    	// Select fitting database driver and connect:
		        Class.forName( sDbDrv );
		        cn = DriverManager.getConnection( sDbUrl, sUsr, sPwd );
		        st = cn.createStatement();
		        		        
		        querry = "select u.user_id from knta_users u where u.username='" + username + "'";
		        System.out.println(querry);
		        rs = st.executeQuery(querry);
		        rs.next();
		        String user_id = rs.getString("USER_ID");
		        System.out.println("USER_ID " + user_id);
		        
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
		    	  System.out.println("Error (SQL): " + e);
		      }
		      catch(Exception ex) {
		    	  System.out.println("Error: " + ex);
		      }
		}
		else {
			System.out.println("Wrong number of Arguments");		
		}
	}
}
