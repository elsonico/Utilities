import java.io.*;
/*
 * This Class is used to deletegs archived DB2 logs (to be used with older DB2 versions).
 */ 
class DeleteLogs {
	// Create connection in main method
	public static void main(String args[]) throws
	SQLException, IOException {

		int argok = 0;
		String dbname = "";
		String port = "60000";
		String hostname = "";
		String username = "";
		String password = "";

		for ( int i = 0 ; i < args.length ; i++) {
			if ( args[i].equals("-db")) {
				argok++;
				dbname = args[i+1];
			}
			if ( args[i].equals("-u")) {
				argok++;
				username = args[i+1];
			}
			if ( args[i].equals("-h")) {
				argok++;
				hostname = args[i+1];
			}
			if ( args[i].equals("-w")) {
				argok++;
				password = args[i+1];
			}
			if ( args[i].equals("-p")) {
				argok++;
				port = args[i];
			}
		}
		if (argok != 5) {
			System.out.println("Usage: java DeleteLogs -db [DBNAME} -h [HOSTNAME] -p [PORTNAME]-u [USERNAME] -w [PASSWORD]");
			System.exit(-1);
		}
		try { Class.forName ("com.ibm.db2.jcc.DB2Driver");
		}
		catch (ClassNotFoundException cnfe) {
			System.out.println("Driver not found!");

		}

		Connection conn = DriverManager.getConnection(
				"jdbc:db2://" + hostname + ":" + port + "/" + dbname + ":user=" + username + ";password=" + password +";");
		// Call the method which deletes the logs.
		ArrayList<String> logs = deleteLogs(conn);
		logs.add("Strng");

		for ( int i = 0 ; i < logs.size() ; i++) {
			System.out.println(logs.get(i));
		}
	}
	// This method gets the db connections as input and deletes the logs.
	public static ArrayList<String> deleteLogs(Connection konnu) throws
	SQLException, IOException {
		try { Class.forName ("com.ibm.db2.jcc.DB2Driver");
		}
		catch (ClassNotFoundException cnfe) {
			System.out.println("Driver not found");
		}
		// Define parameters.
		ArrayList<String> logs = new ArrayList<String>();
		// Create the SQL.
		String query = "select substr(FIRSTLOG,1,12) from SYSIBMADM.DB_HISTORY " +
				"where operation ='X' AND (DATE(CURRENT TIMESTAMP) - DATE(TIMESTAMP(START_TIME))) > 0";
		Statement stmt = konnu.createStatement();
		// Read line by line
		ResultSet res = stmt.executeQuery(query);
		while (res.next()) {
			// Store the fielfs
			logs.add(res.getString(1));								
		}
		// Be a good citizen and close the connection.
		res.close(); konnu.close();
		return logs;
	}
}
