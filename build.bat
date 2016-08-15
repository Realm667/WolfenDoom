@ECHO OFF
REM Immediately retrieve the program's entire path
SET "ProgramDirPath=%~dp0"
REM Start the program
GOTO :Main




REM ================================================================================================
REM Documentation
REM     Spine of the program; this makes sure that the execution works as intended.
REM ================================================================================================
:Main
CALL :MainMenu
GOTO :TerminateProcess




REM ================================================================================================
REM Documentation
REM     Displays the main menu - which the user selects how the build is compiled into an archive file.
REM     Default Compression = Type: ZIP ; Method: Deflate ; Compression: 5
REM     Best Compression    = Type: ZIP ; Method: LZMA    ; Compression: 9
REM     No Compression      = Type: ZIP ; Method: Deflate ; Compression: 0
REM ================================================================================================
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




REM ================================================================================================
REM Documentation
REM     Inspect the user's input and execute their desired action
REM ================================================================================================
:MainMenu_STDIN
IF "%STDIN%" EQU "1" (
    CALL :CompactProject ZIP DEFLATE 5
    GOTO :MainMenu
)
IF "%STDIN%" EQU "2" (
    CALL :CompactProject ZIP LZMA 9
    GOTO :MainMenu
)
IF "%STDIN%" EQU "3" (
    CALL :CompactProject ZIP DEFLATE 0
    GOTO :MainMenu
)
IF /I "%STDIN%" EQU "X" (
    GOTO :EOF
)
IF "%STDIN%" EQU "" (
    CALL :CompactProject ZIP DEFLATE 5
    GOTO :MainMenu
) ELSE (
    CALL :MainMenu_STDIN_BadInput
    GOTO :MainMenu
)




REM ================================================================================================
REM Documentation
REM     This function displays a message to the user that the STDIN was illegal and not supported
REM ================================================================================================
:MainMenu_STDIN_BadInput
ECHO.
ECHO ERROR: INVALID OPTION
ECHO The provided input from the user is not either valid or supported.  Please select from the choices provided.
ECHO.
PAUSE
GOTO :EOF




REM ================================================================================================
REM Documentation
REM     This function captures the standard input from the user.
REM ================================================================================================
:PromptUserInput
SET /P STDIN=^>^>^>^> 
GOTO :EOF




REM ================================================================================================
REM Documentation
REM     Displays the title of the program.
REM ================================================================================================
:BufferHeader
ECHO WolfenDoom Compiler
ECHO =====================
ECHO ---------------------
ECHO =====================
ECHO.&ECHO.&ECHO.
GOTO :EOF




REM ================================================================================================
REM Documentation
REM     This function well walk through the protocol before and during the compiling process.
REM Parameters
REM     ArchiveType [String]
REM             Contains the archive file type.  For example: zip [PK3] or 7zip [PK7]
REM     ArchiveMethod [String]
REM             Contains the method type of the archive file.  For example: DEFLATE, DEFLATE64, PPMD, or LZMA.
REM     CompressionLevel [int]
REM             Upholds the compression level of the archive file.  Range is from 0-9
REM ================================================================================================
:CompactProject
CALL :CompactProject_CheckResources || EXIT /B 1
CALL :CompactProject_Execute %1 %2 %3 || EXIT /B 1
EXIT /B 0




REM ================================================================================================
REM Documentation
REM     Before we compile the project, first make sure that the resources exist - and that there will not be any issues.
REM     NOTE: This function does a clean scan each time this is executed.
REM ================================================================================================
:CompactProject_CheckResources
SET "ErrorString="
SET "ErrorBool=False"
REM Try to check if the resources could be found; if not - prepare an error message.
IF NOT EXIST "%ProgramDirPath%\tools\7za.exe" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find 7Zip!&ECHO."
)
IF NOT EXIST "%ProgramDirPath%\tools\7zExcludeListDir.txt" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find Exclude Directory List!&ECHO."
)
IF NOT EXIST "%ProgramDirPath%\tools\7zExcludeList.txt" (
    SET ErrorBool=True
    SET "ErrorString=%ErrorString%Could Not Find Exclude List!&ECHO."
)
IF %ErrorBool% EQU True (
    CALL :CompactProject_CheckResources_ErrMSG "%ErrorString%"
    EXIT /B 1
)
EXIT /B 0




REM ================================================================================================
REM Documentation
REM     Display an error that some of the required dependencies that is used during the compiling process
REM         could not be located.
REM Parameters
REM     ErrorMSG [String]
REM             Contains the error message that is to be displayed on the screen.
REM ================================================================================================
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




REM ================================================================================================
REM Documentation
REM     Before we compile the project, first make sure that the resources exist - and that there will not be any issues.
REM Parameters
REM     ArchiveType [String]
REM             Contains the archive file type.  For example: zip [PK3] or 7zip [PK7]
REM     ArchiveMethod [String]
REM             Contains the method type of the archive file.  For example: DEFLATE, DEFLATE64, PPMD, or LZMA.
REM     CompressionLevel [int]
REM             Upholds the compression level of the archive file.  Range is from 0-9
REM ================================================================================================
:CompactProject_Execute
tools\7za a -t%1 -mm=%2 -mx=%3 -x@".\tools\7zExcludeListDir.txt" -xr@".\tools\7zExcludeList.txt" ..\wolf_boa.pk3 *
EXIT /B 0




REM ================================================================================================
REM Documentation
REM     Terminate the program without destroying the console process if invoked via CUI.
REM ================================================================================================
:TerminateProcess
ECHO Closing program. . .
EXIT /B 0