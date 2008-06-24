package hpPPMC;

import java.io.File;
import java.io.FileInputStream;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

public class PPMCCommands {
	
	public static final String SDBDRV = "oracle.jdbc.driver.OracleDriver";
	public static final String SDBURL = "jdbc:oracle:thin:@16.55.43.33:1521:orcl";
	public static final String SUSR = "ppmc1";
	public static final String SPWD = "ppmc1";
	
	private static final String COMMAND_ADD_NOTES = "addNote";
	private static final String COMMAND_CHANGE_CREATER = "changeCreater";
	private static final String [] ALL_COMMANDS = {COMMAND_ADD_NOTES, COMMAND_CHANGE_CREATER};
	private static final List ALL_COMMANDS_LIST = Arrays.asList(ALL_COMMANDS);
	
	
	public static final String pFile = "C:" + File.separatorChar + "Documents and Settings" + File.separatorChar + "mayerhof" + File.separatorChar + "workspace" + File.separatorChar + "PPMC" + File.separatorChar + "src" + File.separatorChar + "hpPPMC" + File.separatorChar + "PropertyFile";
	
	int returnValue;
	String logFile;	
			
	public static void main(String[] args) {		
				
		if( args.length > 0 ) {
			PPMCCommands ppmc = new PPMCCommands();
			ppmc.loadPropertyFile(pFile);
			
			if(COMMAND_ADD_NOTES.equalsIgnoreCase(args[0])) {			
				AddNotes addN = new AddNotes();
				addN.addNote(args);
			}
			else if(COMMAND_CHANGE_CREATER.equalsIgnoreCase(args[0])) {
				CreatedBy cb = new CreatedBy();
				cb.changeCreater(args);
			}
			else {
				System.out.println("Wrong number of arguments");
				System.out.println("The first argument has to be one of the following commands: ");
				System.out.println(getCommandList());
			}						
		}
		else {
			System.out.println("Wrong number of arguments");
			System.out.println("The first argument has to be one of the following commands: ");
			System.out.println(getCommandList());
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
	
	private static String getCommandList() {
		Iterator it = ALL_COMMANDS_LIST.iterator();
		StringBuffer buf = new StringBuffer();
		while (it.hasNext()) {
			buf.append(it.next());
			if (it.hasNext()) {
				buf.append(", ");
			}
		}
		return buf.toString();
	}
}
