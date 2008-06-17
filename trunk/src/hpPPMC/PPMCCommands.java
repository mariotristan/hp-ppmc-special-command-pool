package hpPPMC;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

public class PPMCCommands {
	
	public static final String sDbDrv = "oracle.jdbc.driver.OracleDriver";
	public static final String sDbUrl = "jdbc:oracle:thin:@16.55.43.33:1521:orcl";
	public static final String sUsr = "ppmc1";
	public static final String sPwd = "ppmc1";
	
	public static final String pFile = "C:" + File.separatorChar + "Documents and Settings" + File.separatorChar + "mayerhof" + File.separatorChar + "workspace" + File.separatorChar + "PPMC" + File.separatorChar + "src" + File.separatorChar + "hpPPMC" + File.separatorChar + "PropertyFile";
	
	int returnValue;
	String logFile;	
	String querry = null;	
		
	public static void main(String[] args) {		
		if( args.length > 0 ) {
			PPMCCommands ppmc = new PPMCCommands();
			ppmc.loadPropertyFile(pFile);
			//AddNotes addN = new AddNotes();
			//addN.addNote(args);
			CreatedBy cb = new CreatedBy();
			cb.changeCreater(args);
		}
	}
	
	public void loadPropertyFile(String pFile) {				
		try {			
			Properties defaultProps = new Properties();
			FileInputStream in = new FileInputStream(pFile);
			defaultProps.load(in);
			logFile = defaultProps.getProperty("LogFile");
			in.close();			
		} catch(Exception e) {
			System.err.println(e);
		}
	}
}
