package ch.beteo.ppmc.enhanced.requests;

import java.io.*;
import java.sql.*;
import java.text.*;
import java.util.*;
import java.util.Date;

public class updateRequests {
	
	  private static final SimpleDateFormat YYYY_MM_DD_HH_MM_SS = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	  public static void main( String[] args )
	  {
	    // Lies 'Key=Value'-Paare aus Property-Datei fuer Voreinstellungen:
	    String propFile = "DbZuCsvOderHtml.properties";
	    if( 0 < args.length && args[0].startsWith( "prop=") )
	      propFile = args[0].substring( 5 );
	    Properties prop = new Properties();
	    try {
	      prop.load( new FileInputStream( propFile ) );
	    } catch( FileNotFoundException ex ) {
	      System.out.println( "Fehler: Property-Datei '" +
	                          propFile + "' fuer Voreinstellungen fehlt." );
	    } catch( IOException ex ) {
	      System.out.println( "Fehler beim Lesen der Datei '" +
	                          propFile + "': " + ex.getMessage() );
	    }
	    // Lies 'Key=Value'-Paare aus Kommandozeilenparametern
	    // (können Parameter aus obiger Property-Datei überschreiben):
	    for( int i=0; i<args.length; i++ ) {
	      int delim = args[i].indexOf( '=' );
	      if( delim > 0 && delim <= args[i].length()-2 ) {
	        prop.put( args[i].substring( 0, delim ), args[i].substring( delim+1 ) );
	      }
	    }
	    // Pruefe die wichtigsten Properties:
	    String dbDrv = (String) prop.get( "dbDrv" );
	    String dbUrl = (String) prop.get( "dbUrl" );
	    String dbUsr = (String) prop.get( "dbUsr" );
	    String sql1  = (String) prop.get( "sql1"  );
	    if( null == dbDrv )
	      System.out.println( "Fehler: dbDrv muss gesetzt sein, " +
	                          "z.B.: dbDrv=com.mysql.jdbc.Driver" );
	    if( null == dbUrl )
	      System.out.println( "Fehler: dbUrl muss gesetzt sein, " +
	                          "z.B.: dbUrl=jdbc:mysql://localhost:3306/MeineDb" );
	    if( null == sql1 )
	      System.out.println( "Fehler: sql1 muss gesetzt sein, " +
	                          "z.B.: sql1=select * from MeineTestTabelle" );
	    if( null == dbDrv || null == dbUrl || null == sql1 )
	      System.exit( 1 );
	    System.out.println( "\npropFile: " + propFile + "\ndbDrv: " + dbDrv
	                        + "\ndbUrl: " + dbUrl + "\ndbUsr: " + dbUsr );

	    // Lies Datenbanktabelle:
	    Connection        cn = null;
	    PreparedStatement st = null;
	    ResultSet         rs = null;
	    try {
	      // Datenbank-Connection:
	      Class.forName( dbDrv );
	      cn = DriverManager.getConnection( dbUrl, dbUsr, (String) prop.get( "dbPwd" ) );
	      int idxSql = 0;
	      while( true ) {
	        // PrepareStatement:
	        String sql = (String) prop.get( "sql" + ++idxSql );
	        if( null == sql || 0 >= sql.trim().length() ) break;
	        System.out.println( "\nsql" + idxSql + ": " + sql );
	        st = cn.prepareStatement( sql );
	        int idxParm = 0;
	        while( true ) {
	          String parm = (String) prop.get( "sql" + idxSql + ".parm" + ++idxParm );
	          if( null == parm || 0 >= parm.trim().length() ) break;
	          System.out.println( "sql" + idxSql + ".parm" + idxParm + ": " + parm );
	          st.setObject( idxParm, parm );
	        }
	        // ResultSet zu String-Array:
	        rs = st.executeQuery();
	        ResultSetMetaData rsmd = rs.getMetaData();
	        int i, n = rsmd.getColumnCount();
	        Vector vec = new Vector();
	        String[] row = new String[n];
	        for( i=0; i<n; i++ )
	          row[i] = rsmd.getColumnName( i+1 );
	        vec.add( row );
	        while( rs.next() ) {
	          row = new String[n];
	          for( i = 0; i<n; i++ ) {
	            Object obj = rs.getObject( i+1 );
	            if( null != obj && obj instanceof Date )
	              row[i] = YYYY_MM_DD_HH_MM_SS.format( (Date) obj );
	            else {
	              String s = rs.getString( i+1 );
	              row[i] = ( null != s ) ? s.replace( '\n', ' ' ) : "null";
	            }
	          }
	          vec.add( row );
	        }
	        String[][] ss = (String[][]) vec.toArray( new String[vec.size()][n] );
	        // Ausgabe auf Konsole, als CSV-Datei oder als HTML-Datei:
	        String console  = (String) prop.get( "console" );
	        String csvFile  = (String) prop.get( "csvFile" );
	        String htmlFile = (String) prop.get( "htmlFile" );
	        if( null == console || !console.equalsIgnoreCase( "false" ) )
	          ausgabeKonsole( ss, 20 );
	        if( null != csvFile && 0 < csvFile.length() )
	          ausgabeCsv( ss, csvFile + idxSql + ".csv" );
	        if( null != htmlFile && 0 < htmlFile.length() ) {
	          String htmlFileWithoutHtmlTag = (String) prop.get( "htmlFileWithoutHtmlTag" );
	          ausgabeHtml( ss, htmlFile + idxSql + ".html",
	                       "true".equalsIgnoreCase( htmlFileWithoutHtmlTag ) );
	        }
	        rs.close();
	        rs = null;
	        st.close();
	        st = null;
	      }
	    } catch( Exception ex ) {
	      System.out.println( "Fehler beim Lesen der Datenbank: " + ex );
	      ex.printStackTrace();
	    } finally {
	      try { if( null != rs ) rs.close(); } catch( Exception ex ) {}
	      try { if( null != st ) st.close(); } catch( Exception ex ) {}
	      try { if( null != cn ) cn.close(); } catch( Exception ex ) {}
	    }
	  }

	  // Ausgabe als CSV-Datei (Comma Separated Values, z.B. fuer Excel)
	  private static final void ausgabeCsv( String[][] ss, String csvFile )
	  {
	    if( null == ss || 0 >= ss.length || null == ss[0] ||
	        null == csvFile || 0 >= csvFile.length() ) return;
	    try {
	      BufferedWriter out = new BufferedWriter( new OutputStreamWriter(
	          new FileOutputStream( csvFile ) ) );
	      int n = ss[0].length;
	      for( int j=0; j<ss.length; j++ ) {
	        for( int i=0; i<n; i++ )
	          out.write( ss[j][i] + ";" );
	        out.newLine();
	      }
	      out.close();
	      System.out.println( csvFile + " erzeugt." );
	    } catch( Exception ex ) {
	      System.out.println( "Fehler beim Erzeugen der CSV-Datei '" +
	                          csvFile + "': " + ex );
	    }
	  }

	  // Ausgabe als HTML-Datei
	  private static final void ausgabeHtml( String[][] ss, String htmlFile,
	                                         boolean htmlFileWithoutHtmlTag )
	  {
	    if( null == ss || 0 >= ss.length || null == ss[0] ||
	        null == htmlFile || 0 >= htmlFile.length() ) return;
	    try {
	      BufferedWriter out = new BufferedWriter( new OutputStreamWriter(
	          new FileOutputStream( htmlFile ) ) );
	      int i, j, n = ss[0].length;
	      if( !htmlFileWithoutHtmlTag ) out.write( "<html>\n" );
	      out.write( "<table border=1 cellspacing=0 cellpadding=2>\n<tr bgcolor='#EBEEEE'>" );
	      for( i=0; i<n; i++ )
	        out.write( "<th>" + ss[0][i] + "</th>" );
	      for( j=1; j<ss.length; j++ ) {
	        out.write( "</tr>\n<tr>" );
	        for( i=0; i<n; i++ )
	          out.write( "<td>" + ss[j][i] + "</td>" );
	      }
	      out.write( "</tr>\n</table>\n" );
	      if( !htmlFileWithoutHtmlTag ) out.write( "</html>\n" );
	      out.close();
	      System.out.println( htmlFile + " erzeugt." );
	    } catch( Exception ex ) {
	      System.out.println( "Fehler beim Erzeugen der HTML-Datei '" +
	                          htmlFile + "': " + ex );
	    }
	  }

	  // Ausgabe auf Konsole (Kommandozeilenfenster)
	  private static final void ausgabeKonsole( String[][] ss, int maxZeilen )
	  {
	    String leerString  = "                     ";
	    String minusString = "---------------------";
	    if( null == ss || 0 >= ss.length || null == ss[0] ) return;
	    int i, j, m = ss.length, n = ss[0].length;
	    if( m > ++maxZeilen ) {
	      m = maxZeilen;
	      System.out.println( "Achtung: Begrenzt auf " + (m-1) + " Zeilen.\n" );
	    }
	    int maxLength = 0;
	    for( j=0; j<m; j++ )
	      for( i=0; i<n; i++ )
	        if( null != ss[j][i] && maxLength < ss[j][i].length() )
	          maxLength = ss[j][i].length();
	    maxLength++;
	    if( maxLength > leerString.length() )
	        maxLength = leerString.length();
	    if( maxLength > minusString.length() )
	        maxLength = minusString.length();
	    leerString  = leerString.substring( 0, maxLength );
	    minusString = minusString.substring( 0, maxLength );
	    for( i=0; i<n; i++ )
	      System.out.print( "+-" + minusString );
	    System.out.println( "+" );
	    for( j=0; j<m; j++ ) {
	      for( i=0; i<n; i++ )
	        System.out.print( "| " + extendString( ss[j][i], leerString ) );
	      System.out.println( "|" );
	      if( 0 == j ) {
	        for( i=0; i<n; i++ )
	          System.out.print( "+-" + minusString );
	        System.out.println( "+" );
	      }
	    }
	    for( i=0; i<n; i++ )
	      System.out.print( "+-" + minusString );
	    System.out.println( "+" );
	  }

	  private static final String extendString( String s, String maxLeerString )
	  {
	    if( null == s )
	      s = "";
	    final int iWantLen = maxLeerString.length();
	    final int iActLen = s.length();
	    if( iActLen < iWantLen )
	      return (s + maxLeerString).substring( 0, iWantLen );
	    if( iActLen > 2 * iWantLen )
	      return s.substring( 0, 2 * iWantLen );
	    return s;
	  }
	}
