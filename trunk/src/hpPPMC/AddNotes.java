package hpPPMC;

import java.sql.*;

public class AddNotes {
	
	public static void main(String[] args) {
		
//			p_request_id kcrt_requests.request_id%type,
//			p_username   knta_users.username%type,
//			p_note_text  varchar2)
		String request_id = null, username = null, note_text = null;
		String status_name = "in Erstellung", status_id = "30285";
		if( true ) {
		      request_id = args[0];
		      username = args[1];
		      note_text = args[2];
		      
		      
			String sDbDrv="oracle.jdbc.driver.OracleDriver",
	    	sDbUrl="jdbc:oracle:thin:@16.55.43.33:1521:orcl",
	    	sTable="kcrt_requests_v", sUsr="ppmc1", sPwd="ppmc1";
			
			Connection cn = null;
		    Statement  st = null;
		    ResultSet  rs = null;
		    try {
		    	// Select fitting database driver and connect:
		        Class.forName( sDbDrv );
		        cn = DriverManager.getConnection( sDbUrl, sUsr, sPwd );
		        st = cn.createStatement();
		        
		        rs = st.executeQuery("select u.user_id " +
		        		"from knta_users u where u.username = 'mayerhof'");
		        rs.next();
		        String user_id = rs.getString("USER_ID");
		        System.out.println("Output " + user_id);
		        
		        String querry = "insert into knta_note_entries (note_entry_id, creation_date, created_by, last_update_date, last_updated_by, parent_entity_id, parent_entity_primary_key, author_id, authored_date, note_context_value, note_context_visible_value, note)" +
				  "values (knta_note_entries_s.nextval, sysdate, " + user_id + ", sysdate, " + user_id + ", 20 , " + request_id + ", " + user_id + ", sysdate, " + status_id + ", '" + status_name + "', '" + note_text + "' )";
			
		        System.out.println(querry);
		        
		        rs = st.executeQuery(querry);
		        
		        System.out.println(rs);
			       querry = "update kcrt_requests r set r.entity_last_update_date = sysdate, r.last_update_date = sysdate, r.last_updated_by = " + user_id + " where r.request_id = " + request_id;
			       System.out.println(querry);
			       rs = st.executeQuery(querry);
		      } catch(Exception e)
		      {
		    	  System.out.println("Fehler " + e);
		      }
		}
	}
}
