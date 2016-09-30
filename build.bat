@ECHO OFF
REM Immediately retrieve the program's entire path
SET "ProgramDirPath=%~dp0"
REM Start the program
GOTO :Main




REM # ================================================================================================
REM # Documentation
REM #     Spine of the program; this makes sure that the execution works as intended.
REM # ================================================================================================
:Main
REM Update the terminal window title
TITLE WolfenDoom EZBake Oven: Now with Nazi Cupcakes!
REM Check if Git executable is available on the host
CALL :GitFeature_DependencyCheck
CALL :MainMenu
GOTO :TerminateProcess




REM # ================================================================================================
REM # Documentation
REM #     Displays the main menu - which the user selects how the build is compiled into an archive file.
REM #     Default Compression = Type: ZIP ; Method: Deflate ; Compression: 5
REM #     Best Compression    = Type: ZIP ; Method: LZMA    ; Compression: 9
REM #     No Compression      = Type: ZIP ; Method: Deflate ; Compression: 0
REM # ================================================================================================
:MainMenu
REM Thrash the terminal buffer
CLS
REM Display the title on the buffer
CALL :BufferHeader
ECHO Main Menu
ECHO ------------
ECHO.
ECHO Choose how to compile this project:
ECHO ---------------------
ECHO  [1] Default Build
ECHO  [2] Best Compression
ECHO  [3] No Compression
REM ----
REM  Special Features
REM   Only draw these options if its possible
IF %featuresGit% EQU True (ECHO  [U] Update Repository)
REM ----
ECHO  [X] Exit
ECHO ---------------------
ECHO.
REM Capture the user input
CALL :PromptUserInput
REM Inspect the input
GOTO :MainMenu_STDIN




REM # ================================================================================================
REM # Documentation
REM #     Inspect the user's input and execute their desired action
REM # ================================================================================================
:MainMenu_STDIN
IF "%STDIN%" EQU "1" (
    CALL :CompactProject ZIP DEFLATE 5 NORMAL
    GOTO :MainMenu
)
IF "%STDIN%" EQU "2" (
    CALL :CompactProject ZIP LZMA 9 NORMAL
    GOTO :MainMenu
)
IF "%STDIN%" EQU "3" (
    CALL :CompactProject ZIP DEFLATE 0 NORMAL
    GOTO :MainMenu
)
IF /I "%STDIN%" EQU "X" (
    GOTO :EOF
)
IF /I "%STDIN%" EQU "U" (
    REM Avoid the end-user from selecting a choice that may not be
    REM  available to them.
    
    REM Try to detect if Git features is NOT available
    IF %featuresGit% NEQ True CALL :MainMenu_STDIN_BadInput
    REM Try to detect if Git features IS available
    IF %featuresGit% EQU True CALL :GitFeature_UpdateBranch
    GOTO :MainMenu
)
IF "%STDIN%" EQU "" (
    CALL :CompactProject ZIP DEFLATE 5 NORMAL
    GOTO :MainMenu
) ELSE (
    CALL :MainMenu_STDIN_BadInput
    GOTO :MainMenu
)




REM # ================================================================================================
REM # Documentation
REM #     This function displays a message to the user that the STDIN was illegal and not supported
REM # ================================================================================================
:MainMenu_STDIN_BadInput
ECHO.
ECHO ERROR: INVALID OPTION
ECHO The provided input from the user is not either valid or supported.  Please select from the choices provided.
ECHO.
PAUSE
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     This function captures the standard input from the user.
REM # ================================================================================================
:PromptUserInput
SET /P STDIN=^>^>^>^> 
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Displays the title of the program.
REM # ================================================================================================
:BufferHeader
ECHO WolfenDoom Compiler
ECHO =====================
ECHO ---------------------
ECHO =====================
ECHO.&ECHO.&ECHO.
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     This function well walk through the protocol before and during the compiling process.
REM # Parameters
REM #     ArchiveType [String] = %1
REM #             Contains the archive file type.  For example: zip [PK3] or 7zip [PK7]
REM #     ArchiveMethod [String] = %2
REM #             Contains the method type of the archive file.  For example: DEFLATE, DEFLATE64, PPMD, or LZMA.
REM #     CompressionLevel [int] = %3
REM #             Upholds the compression level of the archive file.  Range is from 0-9
REM #     PriorityLevel [String] = %4
REM #             Manages how much processing time the task has within the process-ribbon managed by the OS.
REM # ================================================================================================
:CompactProject
CALL :ProcessingInterface 0 "Compiling project"
CALL :CompactProject_CheckResources || EXIT /B 1
CALL :CompactProject_Execute_ProjectName
CALL :CompactProject_Execute %1 %2 %3 %4 || EXIT /B 1
CALL :CompactProject_WindowsExplorer || EXIT /B 1
CALL :ProcessingInterface 1
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Before we compile the project, first make sure that the resources exist - and that there will not be any issues.
REM #     NOTE: This function does a clean scan each time this is executed.
REM # ================================================================================================
:CompactProject_CheckResources
REM -----------
REM Under construction
EXIT /B 0
REM -----------
REM Check to make sure that the 'Tools' directory exists or is accessible
CALL :CompactProject_CheckResources_ToolsDirExists || (EXIT /B 1)
REM Check to see if the files exists within the project's filesystem.
CALL :CompactProject_CheckResources_FilesExists || (EXIT /B 1)
REM Check the file permission of necessary files
CALL :CompactProject_CheckResources_FilePermissions || (EXIT /B 1)
EXIT /B 0





REM # ================================================================================================
REM # Documentation
REM #     Check to see if the required files exists within the filesystem structure of the project.
REM #       If one or more files were not found, then abort the entire process and display an error
REM #       on the buffer.
REM # Return
REM #     EvaluationStatus [bool]
REM #        0 = Everything is okay; everything was located successfully
REM #        1 = Files do not exist within the project's filesystem or not accessible
REM # ================================================================================================
:CompactProject_CheckResources_FilesExists
SET "ErrorBool="
SET "ErrorString="
REM Try to check if the resources could be found; if not - prepare an error message.
IF NOT EXIST "%ProgramDirPath%tools\7za.exe" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find 7Zip!&ECHO."
)
IF NOT EXIST "%ProgramDirPath%tools\7zExcludeListDir.txt" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find Exclude Directory List!&ECHO."
)
IF NOT EXIST "%ProgramDirPath%tools\7zExcludeList.txt" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find Exclude List!&ECHO."
)
IF %ErrorBool% EQU True (
    CALL :CompactProject_CheckResources_ErrMSG 1 "%ErrorString%"
    EXIT /B 1
)
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Check to make sure that the directories are accessible; we do this by viewing the inside of
REM #        the directories which requires the user to have not only the necessary privileges but must
REM #        also have the directory available and ready.
REM # Return
REM #     EvaluationStatus [bool]
REM #        0 = Everything is okay
REM #        1 = Directory is not accessible
REM # ================================================================================================
:CompactProject_CheckResources_ToolsDirExists
REM Does the directory exists?
IF NOT EXIST "%ProgramDirPath%tools" (
    CALL :CompactProject_CheckResources_ErrMSG_ToolsDirUnaccessible 0 "Unable to locate the {PROJECT_ROOT}\Tools} directory."
    EXIT /B 1
)
REM Is there permission issues?
CALL :CompactProject_CheckResources_CheckPermissions_ToolsDir
IF %ERRORLEVEL% NEQ 0 (
    CALL :CompactProject_CheckResources_ErrMSG_ToolsDirUnaccessible 0 "Insufficent permissions or no data found in the {PROJECT_ROOT}\Tools} directory."
    EXIT /B 1
)
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Check to see if the required files are accessible by checking if the user can access\read\execute
REM #        the files.
REM # Return
REM #     EvaluationStatus [bool]
REM #        0 = Everything is okay; everything was located successfully
REM #        1 = Files do not exist within the project's filesystem or not accessible
REM # ================================================================================================
:CompactProject_CheckResources_FilePermissions
CALL :CompactProject_CheckResources_7ZipExecutableInternal
IF %ERRORLEVEL% NEQ 0 (
    CALL :CompactProject_CheckResources_ErrMSG_PermissionIssue 2 "Unable to execute {PROJECT_ROOT}\Tools\7za.exe} due to insufficent privileges!"
    EXIT /B 1
)
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Test the internal 7Zip program and check for possible errors.  This can be helpful to detect
REM #      for permission issues or other ambiguous complications.
REM # Return
REM #     ExitCode [Int]
REM #           Returns the exit code reported by the system or 7Zip.
REM # ================================================================================================
:CompactProject_CheckResources_7ZipExecutableInternal
%ProgramDirPath%tools\7za.exe 2> NUL 1> NUL
EXIT /B %ERRORLEVEL%




REM # ================================================================================================
REM # Documentation
REM #     Test to see if the {PROJECT_ROOT}\Tools dir. exists on the system and if the user has sufficient
REM #       privileges to access the directory.
REM # Return
REM #     ExitCode [Int]
REM #           Returns the exit code reported by the system or DIR [intCMD].
REM # ================================================================================================
:CompactProject_CheckResources_CheckPermissions_ToolsDir
DIR /B %ProgramDirPath%tools 2> NUL 1> NUL
EXIT /B %ERRORLEVEL%




REM # ================================================================================================
REM # Documentation
REM #     Display an error that some of the required dependencies that is used during the compiling process
REM #         could not be located.
REM # Parameters
REM #     ErrorCode [int] = %1
REM #             Specify the error code that should be presented on the screen.
REM #               0 = Tools Dir Unaccessible
REM #               1 = Missing Files
REM #               2 = Permission Issue
REM #     ErrorMSG [String] = %2
REM #             Contains the error message that is to be displayed on the screen.
REM # ================================================================================================
:CompactProject_CheckResources_ErrMSG
REM Figure out what error message to display on the screen
IF %1 EQU 0 CALL :CompactProject_CheckResources_ErrMSG_ToolsDirUnaccessible "%~2"
IF %1 EQU 1 CALL :CompactProject_CheckResources_ErrMSG_MissingFiles "%~2"
IF %1 EQU 2 CALL :CompactProject_CheckResources_ErrMSG_PermissionIssue "%~2"
REM Allow the user to read the message
PAUSE
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Display an error message that some of the resources were not successfully located.
REM # Parameters
REM #     ErrorMSG [String] = %1
REM #             Contains the error message that is to be displayed on the screen.
REM # ================================================================================================
:CompactProject_CheckResources_ErrMSG_MissingFiles
ECHO.
ECHO CRITICAL ERROR: RESOURCES NOT FOUND!
ECHO %~1
ECHO Program Path: %ProgramDirPath%
ECHO User Path: %CD%
ECHO.
ECHO Please report this error to the WolfenDoom project team!
EXPLORER https://github.com/Realm667/WolfenDoom/issues
ECHO.
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Display an error message that there is permission complications and the user needs to resolve.
REM # Parameters
REM #     ErrorMSG [String] = %1
REM #             Contains the error message that is to be displayed on the screen.
REM # ================================================================================================
:CompactProject_CheckResources_ErrMSG_PermissionIssue
ECHO.
ECHO CRITICAL ERROR: INSUFFICIENT PERMISIONS
ECHO %~1
ECHO.
ECHO Please inspect the file permissions or contact your administrator for assistance.
ECHO.
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Display an error message that the {PROJECT_ROOT}\Tools} is not accessible; either the directory
REM #       does not exist or there is a permission issue that the user needs to resolve.
REM # Parameters
REM #     ErrorMSG [String] = %1
REM #             Contains the error message that is to be displayed on the screen.
REM # ================================================================================================
:CompactProject_CheckResources_ErrMSG_ToolsDirUnaccessible
ECHO.
ECHO CRITICAL ERROR: TOOLS DIR. UNACCESSIBLE
ECHO %~1
ECHO.
ECHO Check to make sure that the path exists and that you have enough permissions.
ECHO.
GOTO :EOF





REM # ================================================================================================
REM # Documentation
REM #     Before we compile the project, first make sure that the resources exist - and that there will not be any issues.
REM #     Priorities:
REM #         LOW - BELOWNORMAL - NORMAL - ABOVENORMAL - HIGH - REALTIME [AKA Ludicrous Speed - Spaceballs reference]
REM # Parameters
REM #     ArchiveType [String] = %1
REM #             Contains the archive file type.  For example: zip [PK3] or 7zip [PK7]
REM #     ArchiveMethod [String] = %2
REM #             Contains the method type of the archive file.  For example: DEFLATE, DEFLATE64, PPMD, or LZMA.
REM #     CompressionLevel [int] = %3
REM #             Upholds the compression level of the archive file.  Range is from 0-9
REM #     PriorityLevel [String] = %4
REM #             Manages how much processing time the task has within the process-ribbon managed by the OS.
REM #             Do note that 'Normal' is the default value, and 'RealTime' can cause the system to slow-down in favor
REM #                 of the program that has the 'RealTime' flag.  Meaning, if executed with 'RealTime', the user might
REM #                 notice that their normal activities will be greatly delayed until the program with 'RealTime' is completed.
REM # ================================================================================================
:CompactProject_Execute
START "WolfenDoom Compile: 7Zip" /B /%4 /WAIT "%ProgramDirPath%tools\7za.exe" a -t%1 -mm=%2 -mx=%3 -x@"%ProgramDirPath%tools\7zExcludeListDir.txt" -xr@"%ProgramDirPath%tools\7zExcludeList.txt" "%ProgramDirPath%..\%projectName%.pk3" "%ProgramDirPath%*"
REM Because I couldn't use the error-pipes with 'Start', we'll have to check the ExitCode in a conditional statement
IF %ERRORLEVEL% GEQ 1 (
    CALL :CompactProject_Execute_ErrMSG %ERRORLEVEL%
    EXIT /B 1
) ELSE (
    EXIT /B 0
)



REM # ================================================================================================
REM # Documentation
REM #     Determine what project filename to use.
REM #      IIF Git features are enabled, then attach the commit hash to
REM #       the filename.
REM #      Else use the generic file name without a hash.
REM # ================================================================================================
:CompactProject_Execute_ProjectName
REM If git features is not available, then just use the generic name.
REM  No hash will be used.
IF %featuresGit% NEQ True (
    REM Avoid redundancy
    IF "%projectName%" NEQ "wolf_boa" SET "projectName=wolf_boa"
    GOTO :EOF
)
REM Assume Git features are available for us to utilize
REM  Attach the hash to the file name.
CALL :GitFeature_FetchCommitHash
REM Avoid redundancy
IF "%projectName%" NEQ "wolf_boa-%GitCommitHash%" SET "projectName=wolf_boa-%GitCommitHash%"
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     If 7Zip returned an error, let the user know that the process was terminated prematurely or failed.
REM # Parameters
REM #     ExitCode [Int] = %1
REM #             Holds the value of the ExitCode from 7Zip
REM # ================================================================================================
:CompactProject_Execute_ErrMSG
ECHO.
ECHO CRITICAL ERROR: 7ZIP FAILED!
ECHO 7Zip was unable to complete the operation and closed with an Exit Code: %1.
ECHO.
ECHO Tips:
ECHO  * Make sure you have enough permission to run applications.
ECHO  * Make sure that the system has enough memory to perform the operation.
ECHO  * Make sure that the files are not locked by other applications.
ECHO  * Examine any warning messages provided and try to address them as much as possible.
ECHO.
ECHO If this issue reoccurs please let us know.
PAUSE
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Create a new window and highlight the newly created build.
REM # ================================================================================================
:CompactProject_WindowsExplorer
EXPLORER /select,"%ProgramDirPath%..\%projectName%.pk3"
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Provide a simple interface for incoming operations.
REM #      The borders in between the actual update is only for readability
REM #      to the users.
REM # Parameters
REM #     InterfaceHeadOrTail [Int] = %1
REM #             Displays either the header or footer on the screen
REM #              when processing a task.
REM #              0 = Header
REM #              1 = Footer
REM #     TaskString [String] = %2
REM #             Displays the message on the screen of the main operation.
REM # ================================================================================================
:ProcessingInterface
IF %1 EQU 0 (
    CLS
    CALL :BufferHeader
    ECHO %~2. . .
    ECHO -------------------------------------
) ELSE (
    ECHO -------------------------------------
    PAUSE
)
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #   Check to see if we can be able to utilize Git features within this program.
REM # ================================================================================================
:GitFeature_DependencyCheck
CALL :GitFeature_DependencyCheck_GitExecutable
IF %ERRORLEVEL% EQU 1 (
    REM Could not detect the git executable
    SET featuresGit=False
    GOTO :EOF
)
CALL :GitFeature_DependencyCheck_RepoGitDB
IF %ERRORLEVEL% EQU 1 (
    REM Could not find the .git directory
    SET featuresGit=False
    GOTO :EOF
)
REM Safe to use git features; found the .git directory and the git executable.
SET featuresGit=True
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #      Check to see if the git executable exists within the host system.
REM #      To do this, we merely check if 'git' was detected during an
REM #      invoktion test - which requires 'git' to be in %PATH% within the
REM #      environment - if git was _NOT_ detected then we can't use git
REM #      features, but we can use the features if it was detected.
REM #
REM # Cautionaries:
REM #     If git.exe is in the console's environment but failed the
REM #      detection phase, the permissions may need to be checked
REM #      as well as the network if routing via UNC - I doubt CMD allows
REM #      UNC anyways.
REM #     IIF %ERRORLEVEL% EQU 9009, then git is not available in the
REM #      environment.
REM #     IIF %ERRORLEVEL% EQU 1, git was invoked and it successfully
REM #      executed by outputting the main menu to NULL.
REM #     IIF any other exit code, see documentation for the proper
REM #      termination fault.
REM #
REM # Return
REM #   ReturnCode [Bool]
REM #       0 = Git executable detected.
REM #       1 = Git executable not detected.
REM # ================================================================================================
:GitFeature_DependencyCheck_GitExecutable
GIT 2> NUL 1> NUL
IF %ERRORLEVEL% EQU 1 (
    REM Found the git executable
    EXIT /B 0
)
REM Could not find the git executable
EXIT /B 1




REM # ================================================================================================
REM # Documentation
REM #   When the end-user has the source code, it may or may not contain the .git DB directory.
REM #   This function is designed to check wither or not the directory exists within the source code.
REM #
REM # Return
REM #   ReturnCode [Bool]
REM #       0 = .git directory found.
REM #       1 = .git directory not found.
REM # ================================================================================================
:GitFeature_DependencyCheck_RepoGitDB
REM Silently perform a check to see if the source contains the .git directory
GIT --git-dir="%ProgramDirPath%.git" status 2> NUL 1> NUL
IF %ERRORLEVEL% EQU 0 (
    REM .git directory was successfully found
    EXIT /B 0
)
REM Could not find the .git directory within the source.
EXIT /B 1




REM # ================================================================================================
REM # Documentation
REM #     Retrieves and returns the HEAD commit hash of the project.
REM #     Sets the value of the commit hash to the variable 'GitCommitHash'.
REM #      To use this hash in other functions, first call this function and then use the variable
REM #      %GitCommitHash% in any function.  However, first make sure that the Git dependency is
REM #      available on the host.
REM # ================================================================================================
:GitFeature_FetchCommitHash
FOR /F %%a IN ('GIT --git-dir="%ProgramDirPath%.git" rev-parse --short HEAD') DO SET GitCommitHash=%%a
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Provide a simple interface and automatically update repository.
REM # ================================================================================================
:GitFeature_UpdateBranch
CALL :ProcessingInterface 0 "Updating project repository"
CALL :GitFeature_UpdateBranch_Master
CALL :ProcessingInterface 1
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     When called, this function will update the master branch of the GIT local repo.  However, first make sure that the Git dependency is
REM #      available on the host.
REM # ================================================================================================
:GitFeature_UpdateBranch_Master
GIT --git-dir="%ProgramDirPath%.git" pull origin master
GOTO :EOF




REM # ================================================================================================
REM # Documentation
REM #     Terminate the program without destroying the console process if invoked via CUI.
REM # ================================================================================================
:TerminateProcess
ECHO Closing program. . .
REM Restore the terminal window's title to something generic
TITLE Command Prompt
EXIT /B 0