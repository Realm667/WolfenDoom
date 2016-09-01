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
SET "ErrorString="
SET "ErrorBool=False"
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
    CALL :CompactProject_CheckResources_ErrMSG "%ErrorString%"
    EXIT /B 1
)
EXIT /B 0




REM # ================================================================================================
REM # Documentation
REM #     Display an error that some of the required dependencies that is used during the compiling process
REM #         could not be located.
REM # Parameters
REM #     ErrorMSG [String] = %1
REM #             Contains the error message that is to be displayed on the screen.
REM # ================================================================================================
:CompactProject_CheckResources_ErrMSG
ECHO.
ECHO CRITICAL ERROR: RESOURCES NOT FOUND!
ECHO %~1
ECHO Program Path: %ProgramDirPath%
ECHO User Path: %CD%
ECHO.
ECHO Please report this error to the WolfenDoom project team!
EXPLORER https://github.com/Realm667/WolfenDoom/issues
ECHO.
PAUSE
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
    IF "%featuresGit%" NEQ "wolf_boa" SET "projectName=wolf_boa"
    GOTO :EOF
)
REM Assume Git features are available for us to utilize
REM  Attach the hash to the file name.
CALL :GitFeature_FetchCommitHash
SET "projectName=wolf_boa-%GitCommitHash%"
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
REM #     Make sure that the host system is able to utilize 'Git' features
REM #      before we automatically use it.
REM #     To perform this, we merely check if 'git' was detected during an
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
REM # ================================================================================================
:GitFeature_DependencyCheck
REM Silently perform an invoktion test
GIT 2> NUL 1> NUL
IF %ERRORLEVEL% EQU 1 (
    SET featuresGit=True
) ELSE (
    SET featuresGit=False
)
GOTO :EOF




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