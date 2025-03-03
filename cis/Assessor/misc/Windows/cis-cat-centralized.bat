@ECHO OFF

::
:: Centralized CIS-CAT Wrapper v4.0.0
::
:: This batch file assists in executing CIS-CAT on a population of Microsoft
:: Windows targets from a centralized location. Please review the CIS-CAT
:: User Guide for detailed instructions on how to leverage this file.
::
:: Acknowledgements:
::
::    Michael Morton introduced the concept of invoking CIS-CAT via a
::    centralized batch file and provided the original batch file.
::
::    Gary King of Atlas Pipeline introduced the concept of including
::    detection logic to determine which benchmark and profile to execute.
::
:: Please send questions/comments/improvements to feedback@cisecurity.org.
::


::
:: Toggle Debugging Information
::

SET DEBUG=0

::
:: Setting AUTODETECT=1 will cause this script to detect the following:
::             - Which CIS Windows Benchmark to run
::             - Which Benchmark Profile to select
::             - Which JRE to leverage (32- or 64-bit). Defaults to 32-bit
::

SET AUTODETECT=1

::
:: Setting SSLF=1 will cause CIS-CAT to execute the SSLF (high security)
:: profile in place of the Enterprise Profile.
::
:: 	Note: This variable is only significant when AUTODETECT=1
::

SET SSLF=0

::
:: UNC path to the network share where the base CIS assessment bundle resides
::

SET NetworkShare=\\NETWORK_SHARE\CIS

::
:: Path to debug log when DEBUG=1
::

SET DebugLogFile=%NetworkShare%\cis-cat-debug-log.txt


::
:: The path to the CIS-CAT archive, relative to the path set in NetworkShare
::

SET CisCatPath=Assessor

::
:: The path to the 32-bit JRE, relative to the path set in NetworkShare
:: Use http://www.java.com/en/download/manual.jsp (Windows Offline (32-bit)
:: 		Direct: http://javadl.sun.com/webapps/download/AutoDL?BundleId=61043
:: Modify the line below to point at a different directory/file if you
:: would like to use your own JAVA/JRE and not the bundled one
::

::SET JavaPath="%CisCatPath%\jre"

::
:: The path to the 64-bit JRE, relative to the path set in NetworkShare
:: Modify the lines below to point at a different directory/file if you
:: would like to use your own JAVA/JRE and not the bundled one
::
SET JavaPath64="%CisCatPath%\jre"

::
:: Configure the maximum heap size to be allocated by the JRE, in Megabytes
::

SET JavaMaxMemoryMB=2048

::
:: The path to location where CIS-CAT reports should be placed, relative to
:: the path set in NetworkShare
::

SET ReportsPath=Reports

::
:: Configure CIS-CAT report generation options:
::
::	-html : Generate an HTML report
::	-txt  : Generate a Text report
::	-csv  : Generate a CSV report
::	-narf : Do NOT generate an Asset Reporting Format (ARF) report
::  -json : Generate a JSON report
::  -npr  : Generate the "non-passing results" report in JSON
::  -nts  : Do NOT append the timestamp to the report names
::

SET CISCAT_OPTS=-html -txt -csv

:: ---------------------------------------------
:: START BENCHMARK DETECTION
:: ---------------------------------------------

::
:: The file name of the CIS Benchmark to run. It is assumed this file resides
:: under CisCatPath\benchmarks\.
::
:: 	Note: This value will be overridden if AUTODETECT=1.
:: 	Note: This value will be overridden if a benchmark is specified via the
:: 	      command line.
::

::  SET Benchmark

::
:: The Benchmark Profile to execute. A list of profiles, delimited by a
:: space (" ") can be provided to evaluate multiple profiles.
::
:: 	Note: This value will be overridden if AUTODETECT=1.
:: 	Note: This value will be overridden if a benchmark is specified via
:: 	      the command line.
::

::  SET Profiles

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                           ::
:: No need to change anything below here                                     ::
::                                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO.
ECHO Centralized CIS-CAT Wrapper

SET ARCH=UNKNOWN
SET OS=UNKNOWN
SET DOMAINROLE=UNKNOWN

IF %AUTODETECT%==0 GOTO NODETECTOS

::
:: Detect Windows OS Version
::

ECHO.
ECHO Detecting OS...

WMIC OS GET "Name" | FINDSTR /C:" 2008 R2" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2008R2
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2008" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2008
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 8.1" > NUL
IF %ERRORLEVEL%==0 SET OS=WIN81
IF %ERRORLEVEL%==0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 8" > NUL
IF %ERRORLEVEL%==0 SET OS=WIN8
IF %ERRORLEVEL%==0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 10" > NUL
IF %ERRORLEVEL%==0 SET OS=WIN10
IF %ERRORLEVEL%==0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 11" > NUL
IF %ERRORLEVEL%==0 SET OS=WIN11
IF %ERRORLEVEL%==0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2012 R2" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2012R2
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2012" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2012
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2016" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2016
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2019" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2019
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

WMIC OS GET "Name" | FINDSTR /C:" 2022" > NUL
IF %ERRORLEVEL% == 0 SET OS=WIN2022
IF %ERRORLEVEL% == 0 GOTO FOUNDOS

ECHO "Critical Error: Unable to Detect OS."
GOTO EXIT

:FOUNDOS

ECHO Found OS %OS%.

:NODETECTOS

IF %AUTODETECT%==0 GOTO NODETECTARCH

::
:: Detect Architecture
::

ECHO.
ECHO Detecting Architecture...

:: The %ProgramW6432% environment variable is only set on 64-bit systems.
:: It will be expanded to a value other than NULL if it is set.

ECHO %ProgramW6432% | FINDSTR /C:"Program Files"

IF %ERRORLEVEL% == 0 SET ARCH=64
IF %ERRORLEVEL% == 1 SET ARCH=32

ECHO Found %ARCH% bit Architecture.

:NODETECTARCH

IF %AUTODETECT%==0 GOTO NODETECTROLE

::
:: Detect Domain Role
::

ECHO.
ECHO Detecting Domain Role...

:: http://msdn.microsoft.com/en-us/library/aa394102%28v=vs.85%29.aspx

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 0 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=WORKSTATION_STANDALONE
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 1 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=WORKSTATION_DOMAIN_JOINED
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 2 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=SERVER_STANDALONE
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 3 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=SERVER_DOMAIN_JOINED
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 4 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=SERVER_DOMAIN_CONTROLLER
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

WMIC COMPUTERSYSTEM GET "DomainRole" | FINDSTR 5 > NUL
IF %ERRORLEVEL% == 0 SET DOMAINROLE=SERVER_DOMAIN_CONTROLLER
IF %ERRORLEVEL% == 0 GOTO FOUNDROLE

ECHO "Critical Error: Unable to Detect Domain Role."
GOTO EXIT

:FOUNDROLE

ECHO Found Role %DOMAINROLE%

:NODETECTROLE

::
:: Test if Benchmark and Profile are provided via command line. If so, disable
:: AUTODETECT and use those values instead of the values hardcoded above.
::

IF %1.==. GOTO NOARG
IF %2.==. GOTO NOARG

SET AUTODETECT=0

SET Benchmark=%1
SET Profiles=%2

:NOARG

ECHO.
ECHO Setting up Environment...

PUSHD .

PUSHD %NetworkShare% > nul 2> nul

IF NOT %ERRORLEVEL% == 0 GOTO ERRORDRIVE
SET MapDrive=%cd%

:: Modify the line below to point at a different directory/file if you
:: would like to use your own JAVA/JRE and not the bundled one
::
SET mJavaPath="%MapDrive%\%CisCatPath%\jre"
SET JAVA_HOME="%MapDrive%\%CisCatPath%\jre"

SET mCisCatPath=%MapDrive%\%CisCatPath%
SET mReportsPath=%MapDrive%\%ReportsPath%


::
:: Fixup JAVA_HOME and Java Location based on ARCH if AUTODETECT is enabled.
::

IF %AUTODETECT%==0 GOTO NOJAVAFIXUP

:: Modify the line below to point at a different directory/file if you
:: would like to use your own JAVA/JRE and not the bundled one
::
::IF %ARCH%==64 SET JAVA_HOME=%MapDrive%\%JavaPath64%
::IF %ARCH%==64 SET mJavaPath=%MapDrive%\%JavaPath64%

:NOJAVAFIXUP

IF %DEBUG%==1 ECHO %mJavaPath% points to %JavaPath%
IF %DEBUG%==1 ECHO %mCisCatPath% points to %NetworkShare%\%CisCatPath%
IF %DEBUG%==1 ECHO %mReportsPath% points to %NetworkShare%\%ReportsPath%
IF %DEBUG%==1 ECHO %JAVA_HOME% points to %JavaPath%

cd %mCisCatPath%

IF NOT EXIST %mJavaPath% GOTO ERROR_JAVA_PATH
IF NOT EXIST %mJavaPath%\bin\java.exe GOTO ERROR_JAVAEXE_PATH
IF NOT EXIST %mCisCatPath% GOTO ERROR_CISCAT_PATH
IF NOT EXIST %mCisCatPath%\Assessor-CLI.jar GOTO ERROR_CISCATJAR_PATH
IF NOT EXIST %mReportsPath% GOTO ERROR_REPORTS_PATH

ECHO.
ECHO	Local Drive: 	%MapDrive%
ECHO	  JAVA_HOME:	%JAVA_HOME%
ECHO	    CIS-CAT:	%NetworkShare%\%CisCatPath%
ECHO	    Reports:	%NetworkShare%\%ReportsPath%
ECHO.

::
:: Select the correct benchmark based on AUTODETECT
::

IF %AUTODETECT%==0 GOTO NOBENCHMARKFIXUP

::
:: Test for WIN8
::

IF NOT %OS%==WIN8 GOTO NOTWIN8

SET Benchmark=CIS_Microsoft_Windows_8_Benchmark_v1.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1__BitLocker

IF %SSLF%==1 GOTO WIN8SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1

GOTO NOBENCHMARKFIXUP

:WIN8SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1__BitLocker
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1__BitLocker

GOTO NOBENCHMARKFIXUP

:NOTWIN8

::
:: Test for WIN 8.1
::

IF NOT %OS%==WIN81 GOTO NOTWIN81

SET Benchmark=CIS_Microsoft_Windows_8.1_Workstation_Benchmark_v2.4.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1__BitLocker

IF %SSLF%==1 GOTO WIN81SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1

GOTO NOBENCHMARKFIXUP

:WIN81SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2

GOTO NOBENCHMARKFIXUP

:NOTWIN81

::
:: Test for WIN 10
::

IF NOT %OS%==WIN10 GOTO NOTWIN10

::
:: Detect Windows 10 "flavor"
::

ECHO.
ECHO Detecting Windows 10 Build...

:: wmic os get BuildNumber | findstr /C:"[the build number]"
::   Version 1507 (RTM) (OS build 10240)
::   Version 1511 (OS build 10586)
::   Version 1607 (OS build 14393)
::   Version 1703 (OS build 15063)
::   Version 1709 (OS build 16299)
::   Version 1803 (OS build 17134)
::   Version 1809 (OS build 17763)
::   Version 1903 (OS build 18362)
::   Version 1909 (OS build 18363)
::   Version 2004 (OS build 19041)
::   Version 20H2 (OS build 19042)
::   Version 21H1 (OS build 19043)
::

wmic os get BuildNumber | findstr /C:"10240" > NUL
IF %ERRORLEVEL%==0 GOTO FIFTEENOHSEVEN

wmic os get BuildNumber | findstr /C:"10586" > NUL
IF %ERRORLEVEL%==0 GOTO FIFTEENELEVEN

wmic os get BuildNumber | findstr /C:"14393" > NUL
IF %ERRORLEVEL%==0 GOTO SIXTEENOHSEVEN

wmic os get BuildNumber | findstr /C:"15063" > NUL
IF %ERRORLEVEL%==0 GOTO SEVENTEENOHTHREE

wmic os get BuildNumber | findstr /C:"16299" > NUL
IF %ERRORLEVEL%==0 GOTO SEVENTEENOHNINE

wmic os get BuildNumber | findstr /C:"17134" > NUL
IF %ERRORLEVEL%==0 GOTO EIGHTEENOHTHREE

wmic os get BuildNumber | findstr /C:"17763" > NUL
IF %ERRORLEVEL%==0 GOTO EIGHTEENOHNINE

wmic os get BuildNumber | findstr /C:"18362" > NUL
IF %ERRORLEVEL%==0 GOTO NINETEENOHTHREE

wmic os get BuildNumber | findstr /C:"18363" > NUL
IF %ERRORLEVEL%==0 GOTO NINETEENOHNINE

wmic os get BuildNumber | findstr /C:"19041" > NUL
IF %ERRORLEVEL%==0 GOTO TWOTHOUSANDFOUR

wmic os get BuildNumber | findstr /C:"19042" > NUL
IF %ERRORLEVEL%==0 GOTO TWENTYH2

wmic os get BuildNumber | findstr /C:"19043" > NUL
IF %ERRORLEVEL%==0 GOTO TWENTYONEH1

wmic os get BuildNumber | findstr /C:"19044" > NUL
IF %ERRORLEVEL%==0 GOTO TWENTYONEH2

:: If execution gets here, the Windows build is beyond what we have a
:: benchmark for, so just use the latest.
GOTO UNKNOWNWINDOWS10

:: -----------------------------------------------------------------
:FIFTEENOHSEVEN
ECHO.
ECHO Discovered Windows 10 1507
GOTO USETHELATEST

:: -----------------------------------------------------------------
:FIFTEENELEVEN
ECHO.
ECHO Discovered Windows 10 1511
GOTO USETHELATEST

:: -----------------------------------------------------------------
:SIXTEENOHSEVEN
ECHO.
ECHO Discovered Windows 10 1607
GOTO USETHELATEST

:: -----------------------------------------------------------------
:SEVENTEENOHTHREE
ECHO.
ECHO Discovered Windows 10 1703
GOTO USETHELATEST

:: -----------------------------------------------------------------
:SEVENTEENOHNINE
ECHO.
ECHO Discovered Windows 10 1709
GOTO USETHELATEST

:: -----------------------------------------------------------------
:EIGHTEENOHTHREE
ECHO.
ECHO Discovered Windows 10 1803
GOTO USETHELATEST

:: -----------------------------------------------------------------
:EIGHTEENOHNINE
ECHO.
ECHO Discovered Windows 10 1809
GOTO USETHELATEST

:: -----------------------------------------------------------------
:NINETEENOHTHREE
ECHO.
ECHO Discovered Windows 10 1903
GOTO USETHELATEST

:: -----------------------------------------------------------------
:NINETEENOHNINE
:UNKNOWNWINDOWS10
ECHO.
ECHO Discovered Windows 10 1909
GOTO USETHELATEST

:: -----------------------------------------------------------------
:TWOTHOUSANDFOUR
ECHO.
ECHO Discovered Windows 10 2004
GOTO USETHELATEST

:: -----------------------------------------------------------------
:TWENTYH2
ECHO.
ECHO Discovered Windows 10 20H2
GOTO USETHELATEST

:: -----------------------------------------------------------------
:TWENTYONEH1
ECHO.
ECHO Discovered Windows 10 21H1
GOTO USETHELATEST

:: -----------------------------------------------------------------
:TWENTYONEH2
ECHO.
ECHO Discovered Windows 10 21H2 (or higher)
:USETHELATEST

SET Benchmark=CIS_Microsoft_Windows_10_Enterprise_Benchmark_v3.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_L1_-_CorporateEnterprise_Environment_general_use
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_2_L2_-_High_SecuritySensitive_Data_Environment_limited_functionality
:: There are also:
::   - xccdf_org.cisecurity.benchmarks_profile_Level_1_L1__BitLocker_BL
::   - xccdf_org.cisecurity.benchmarks_profile_Level_2_L2__BitLocker_BL
::   - xccdf_org.cisecurity.benchmarks_profile_Level_1_L1__Next_Generation_Windows_Security_NG
::   - xccdf_org.cisecurity.benchmarks_profile_Level_2_L2__Next_Generation_Windows_Security_NG
::   - xccdf_org.cisecurity.benchmarks_profile_Level_1_L1__BitLocker_BL__Next_Generation_Windows_Security_NG
::   - xccdf_org.cisecurity.benchmarks_profile_Level_2_L2__BitLocker_BL__Next_Generation_Windows_Security_NG
::   - xccdf_org.cisecurity.benchmarks_profile_BitLocker_BL_-_optional_add-on_for_when_BitLocker_is_deployed
::   - xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_NG_-_optional_add-on_for_use_in_the_newest_hardware_and_configuration_environments

IF %SSLF%==1 GOTO TWENTYONEH2SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_L1_-_CorporateEnterprise_Environment_general_use
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_L1_-_CorporateEnterprise_Environment_general_use

GOTO NOBENCHMARKFIXUP

:TWENTYONEH2SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_L2_-_High_SecuritySensitive_Data_Environment_limited_functionality
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_L2_-_High_SecuritySensitive_Data_Environment_limited_functionality

GOTO NOBENCHMARKFIXUP

:NOTWIN10

::
:: Test for WIN11
::

IF NOT %OS%==WIN11 GOTO NOTWIN11

SET Benchmark=CIS_Microsoft_Windows_11_Enterprise_Benchmark_v3.0.0-xccdf.xml

IF %SSLF%==1 GOTO WIN11SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_L1_-_CorporateEnterprise_Environment_general_use
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_L1_-_CorporateEnterprise_Environment_general_use

GOTO NOBENCHMARKFIXUP

:WIN11SSLF

IF %DOMAINROLE%==WORKSTATION_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_L2_-_High_SecuritySensitive_Data_Environment_limited_functionality
IF %DOMAINROLE%==WORKSTATION_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_L2_-_High_SecuritySensitive_Data_Environment_limited_functionality

GOTO NOBENCHMARKFIXUP

:NOTWIN11

::
:: Test for WIN2008R2
::

IF NOT %OS%==WIN2008R2 GOTO NOT2008R2

SET Benchmark=CIS_Microsoft_Windows_Server_2008_R2_Benchmark_v3.3.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
:: [5]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Domain_Controller
:: [6]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Member_Server

IF %SSLF%==1 GOTO SSLF2008R2

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2008R2

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2008R2

::
:: Test for WIN2008
::

IF NOT %OS%==WIN2008 GOTO NOT2008

SET Benchmark=CIS_Microsoft_Windows_Server_2008_Benchmark_v3.1.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server

IF %SSLF%==1 GOTO SSLF2008

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2008

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP


:NOT2008

::
:: Test for WIN2012R2
::

IF NOT %OS%==WIN2012R2 GOTO NOT2012R2

SET Benchmark=CIS_Microsoft_Windows_Server_2012_R2_Benchmark_v3.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server

IF %SSLF%==1 GOTO SSLF2012R2

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2012R2

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2012R2

::
:: Test for WIN2012
::

IF NOT %OS%==WIN2012 GOTO NOT2012

SET Benchmark=CIS_Microsoft_Windows_Server_2012_(non-R2)_Benchmark_v3.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server

IF %SSLF%==1 GOTO SSLF2012

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2012

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2012

::
:: Test for WIN2016
::

IF NOT %OS%==WIN2016 GOTO NOT2016

SET Benchmark=CIS_Microsoft_Windows_Server_2016_Benchmark_v3.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server

IF %SSLF%==1 GOTO SSLF2016

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2016

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2016

::
:: Test for WIN2019
::

IF NOT %OS%==WIN2019 GOTO NOT2019

SET Benchmark=CIS_Microsoft_Windows_Server_2019_Benchmark_v3.0.1-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
:: [5]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Domain_Controller
:: [6]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Member_Server

IF %SSLF%==1 GOTO SSLF2019

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2019

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2019

::
:: Test for WIN2022
::

IF NOT %OS%==WIN2022 GOTO NOT2022

SET Benchmark=CIS_Microsoft_Windows_Server_2022_Benchmark_v3.0.0-xccdf.xml

:: [1]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller
:: [2]  xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
:: [3]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller
:: [4]  xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
:: [5]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Domain_Controller
:: [6]  xccdf_org.cisecurity.benchmarks_profile_Next_Generation_Windows_Security_-_Member_Server

IF %SSLF%==1 GOTO SSLF2022

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_1_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:SSLF2022

IF %DOMAINROLE%==SERVER_STANDALONE SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_JOINED SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Member_Server
IF %DOMAINROLE%==SERVER_DOMAIN_CONTROLLER SET Profiles=xccdf_org.cisecurity.benchmarks_profile_Level_2_-_Domain_Controller

GOTO NOBENCHMARKFIXUP

:NOT2022

:NOBENCHMARKFIXUP

:: ---------------------------------------------
:: END BENCHMARK SELECTION
:: ---------------------------------------------

IF NOT DEFINED Benchmark GOTO ERROR_NO_BENCHMARK_GIVEN
IF NOT EXIST %mCisCatPath%\benchmarks\%Benchmark% GOTO ERROR_BENCHMARK_PATH

IF %DEBUG%==1 ECHO Start: Computer = %COMPUTERNAME% >> %DebugLogFile%
IF %DEBUG%==1 ECHO mJavaPath = %mJavaPath% >> %DebugLogFile%
IF %DEBUG%==1 ECHO mCisCatPath = %mCisCatPath% >> %DebugLogFile%
IF %DEBUG%==1 ECHO mReportsPath = %mReportsPath% >>  %DebugLogFile%
IF %DEBUG%==1 ECHO JAVA_HOME = %JAVA_HOME% >> %DebugLogFile%
IF %DEBUG%==1 ECHO Benchmark = %Benchmark% >> %DebugLogFile%
IF %DEBUG%==1 ECHO ARCH = %ARCH% >> %DebugLogFile%
IF %DEBUG%==1 ECHO OS = %OS% >> %DebugLogFile%
IF %DEBUG%==1 ECHO DOMAINROLE = %DOMAINROLE% >> %DebugLogFile%

::
:: Put all the options together and form the CIS-CAT command-line
::
SET FULL_CISCAT_CMD=%mJavaPath%\bin\java.exe -Xmx%JavaMaxMemoryMB%M -jar %mCisCatPath%\Assessor-CLI.jar %CISCAT_OPTS% -b "%mCisCatPath%\benchmarks\%Benchmark%"

ECHO	  Benchmark:	%Benchmark%
ECHO	 Profile(s):	%Profiles%
ECHO.
ECHO Starting Assessment(s)...
FOR %%P IN (%Profiles%) DO (
	ECHO  + %FULL_CISCAT_CMD% -p "%%P" -rd "%mReportsPath%"
	ECHO  + Running Profile %%P...
	ECHO.
	ECHO [[ CIS-CAT ASSESSMENT START ]]
	IF %DEBUG%==1 ECHO CMDLINE = %FULL_CISCAT_CMD% -p "%%P" -rd "%mReportsPath%" >> %DebugLogFile%
	%FULL_CISCAT_CMD% -p "%%P" -rd "%mReportsPath%"
	ECHO [[  CIS-CAT OUTPUT END  ]]
	ECHO.
)

ECHO Testing Complete.
ECHO Reports can be found at %NetworkShare%\%ReportsPath%

GOTO EXIT

:ERRORDRIVE
ECHO Critical Error: Unable to Map %NetworkShare%.
ECHO Ensure the directory exists and has the appropriate permissions set.
IF %DEBUG%==1 ECHO ERRORDRIVE >> %DebugLogFile%
GOTO EXIT

:ERROR_JAVA_PATH
ECHO Critical Error: One of the directories %JavaPath% or %JavaPath64% does not exist.
ECHO Ensure the JavaPath and JavaPath64 variables are set correctly.
IF %DEBUG%==1 ECHO ERROR_JAVA_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_JAVAEXE_PATH
ECHO Critical Error: java.exe can not be found at %JavaPath%\bin\.
ECHO Ensure the JavaPath and JavaPath64 variables are set correctly.
IF %DEBUG%==1 ECHO ERROR_JAVAEXE_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_CISCAT_PATH
ECHO Critical Error: The directory %NetworkShare%\%CisCatPath% does not exist.
ECHO Ensure the CisCatPath variable is set correctly.
IF %DEBUG%==1 ECHO ERROR_CISCAT_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_REPORTS_PATH
ECHO Critical Error: The directory %NetworkShare%\%ReportsPath% does not exist.
ECHO Ensure the ReportsPath variable is set correctly.
IF %DEBUG%==1 ECHO ERROR_REPORTS_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_BENCHMARK_PATH
ECHO Critical Error: Benchmark %NetworkShare%\%CisCatPath%\benchmarks\%Benchmark% does not exist.
ECHO Ensure the Benchmark is set correctly.
ECHO Ensure the command line arguments passed to this script are accurate.
IF %DEBUG%==1 ECHO ERROR_BENCHMARK_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_CISCATJAR_PATH
ECHO Critical Error: Assessor-CLI.jar does not exist at %NetworkShare%\%CisCatPath%\.
ECHO Ensure the CisCatPath variable is set correctly.
IF %DEBUG%==1 ECHO ERROR_CISCATJAR_PATH >> %DebugLogFile%
GOTO EXIT

:ERROR_NO_BENCHMARK_GIVEN
ECHO Critical Error: Script was unable to successfully detect Operating System, so no benchmark was selected..
IF %DEBUG%==1 ECHO ERROR_NO_BENCHMARK_GIVEN >> %DebugLogFile%
GOTO EXIT

:EXIT
IF %DEBUG%==1 ECHO Stop: Computer = %COMPUTERNAME% >> %DebugLogFile%
POPD


