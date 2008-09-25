            -------------------------------------------------------------------------------------------------
			Sample .NET consumer for HP Project and Portfolio Management Center 7.1

				(c) 2007 Mercury Interactive. All rights reserved.

This document describes how to use the sample .NET consumer project to demonstrate and test the
Demand Service webservice for HP Project and Portfolio Management Center 7.1.

-------------------
System Requirements
-------------------
Microsoft .NET framework 2.0 or later
Microsoft Visual Studio 2005 or later
HP Project and Portfolio Management Center 7.1 running on "localhost"
	- on port 8080
	- with webservices enabled
	- not using SSL (i.e. service accessible using "http", not "https")

---------------------
How to Use The Sample
---------------------
Just run the project and watch the progress of the application as it performs the various operations.

-------------------
How to Make Changes
-------------------
If you want to make changes to the application to add your own code, make modifications to the
"Program.cs" file as necessary.
If you want to change the host URL of the webservice which the code should consume, modify the
properties of the "localhostDemandService" web reference under "Web References" in solution explorer.

-----
Notes
-----
This is a console application written using C#. There is no input required from the user while the
application is running, except for a keystroke to confirm exiting when done.
All output will be visible on the console - there is no GUI.