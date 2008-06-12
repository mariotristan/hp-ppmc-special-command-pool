package hpPPMC;

import java.sql.*;

public class CreateRequest
{
  public static void main( String[] argv )
  {
    String sDbDrv="oracle.jdbc.driver.OracleDriver",
    	sDbUrl="jdbc:oracle:thin:@16.55.43.33:1521:orcl",
    	sTable="kcrt_requests_v", sUsr="ppmc1", sPwd="ppmc1";
    if( 3 <= argv.length ) {
      sDbDrv = argv[0];
      sDbUrl = argv[1];
      sTable = argv[2];
      if( 4 <= argv.length )  sUsr = argv[3];
      if( 5 <= argv.length )  sPwd = argv[4];
    } else {
      Connection cn = null;
      Statement  st = null;
      ResultSet  rs = null;
      try {
        // Select fitting database driver and connect:
        Class.forName( sDbDrv );
        cn = DriverManager.getConnection( sDbUrl, sUsr, sPwd );
        st = cn.createStatement();
        rs = st.executeQuery( "select * from " + sTable );
        // Get meta data:
        ResultSetMetaData rsmd = rs.getMetaData();
        int i, n = rsmd.getColumnCount();
        // Print table content:
        for( i=1; i<=n; i++ )    // Attention: first column with 1 instead of 0
          System.out.print(" " + extendStringTo14( rsmd.getColumnName( i ) ) );
        for( i=0; i<n; i++ )
        	while( rs.next() ) {
        		for( i=1; i<=n; i++ )  // Attention: first column with 1 instead of 0
        			System.out.print(" " + extendStringTo14( rs.getString( i ) ) );
        			System.out.println( "|" );
        	}
      } catch( Exception ex ) {
        System.out.println( ex );
      } finally {
        try { if( null != rs ) rs.close(); } catch( Exception ex ) {}
        try { if( null != st ) st.close(); } catch( Exception ex ) {}
        try { if( null != cn ) cn.close(); } catch( Exception ex ) {}
      }
    }
  }

  // Extend String to length of 14 characters
  private static final String extendStringTo14( String s )
  {
    if( null == s ) s = "";
    final String sFillStrWithWantLen = "                           ";
    final int iWantLen = 21; //sFillStrWithWantLen.length();
    final int iActLen  = s.length();
    if( iActLen < iWantLen )
      return (s + sFillStrWithWantLen).substring( 0, iWantLen );
    if( iActLen > 2 * iWantLen )
      return s.substring( 0, 2 * iWantLen );
    return s;
  }
}
