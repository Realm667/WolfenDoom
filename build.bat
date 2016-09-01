@ECHO OFF
REM Update the terminal window title
TITLE WolfenDoom EZBake Oven: Now with Nazi Cupcakes!
REM Immediately retrieve the program's entire path
SET "ProgramDirPath=%~dp0"
REM Start the program
GOTO :Main




REM # ================================================================================================
REM # Documentation
REM #     Spine of the program; this makes sure that the execution works as intended.
REM # ================================================================================================
:Main
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
CALL :CompactProject_CheckResources || EXIT /B 1
CALL :CompactProject_Execute %1 %2 %3 %4 || EXIT /B 1
CALL :CompactProject_WindowsExplorer || EXIT /B 1
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
START "WolfenDoom Compile: 7Zip" /B /%4 /WAIT "%ProgramDirPath%tools\7za.exe" a -t%1 -mm=%2 -mx=%3 -x@"%ProgramDirPath%tools\7zExcludeListDir.txt" -xr@"%ProgramDirPath%tools\7zExcludeList.txt" "%ProgramDirPath%..\wolf_boa.pk3" "%ProgramDirPath%*"
REM Because I couldn't use the error-pipes with 'Start', we'll have to check the ExitCode in a conditional statement
IF %ERRORLEVEL% GEQ 1 (
    CALL :CompactProject_Execute_ErrMSG %ERRORLEVEL%
    EXIT /B 1
) ELSE (
    EXIT /B 0
)




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
ECHO  * Does the project file already exist?  If so, please delete it and try again.
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
EXPLORER /select,"%ProgramDirPath%..\wolf_boa.pk3"
EXIT /B 0




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
REM #     When called, this function will update the master branch of the GIT local repo.
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