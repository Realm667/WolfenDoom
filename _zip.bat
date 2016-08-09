@ECHO OFF
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
    GOTO :MainMenu
)




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
REM     This function is dedicated to compiling the project into the appropriate archive settings.
REM Parameters
REM     ArchiveType [String]
REM             Contains the archive file type.  For example: zip [PK3] or 7zip [PK7]
REM     ArchiveMethod [String]
REM             Contains the method type of the archive file.  For example: DEFLATE, DEFLATE64, PPMD, or LZMA.
REM     CompressionLevel [int]
REM             Upholds the compression level of the archive file.  Range is from 0-9
REM ================================================================================================
:CompactProject
tools\7za a -t%1 -mm=%2 -mx=%3 -x!".git*" -x!"*.bat*" -x!".sh*" -x!"tools*" -x!"maps\*.backup*" -x!"maps\*.dbs*" ..\wolf_boa.pk3 *
EXIT /B 0




REM ================================================================================================
REM Documentation
REM     Terminate the program without destroying the console process if invoked via CUI.
REM ================================================================================================
:TerminateProcess
ECHO Closing program. . .
EXIT /B 0