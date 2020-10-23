// Blade of Agony Launcher.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "Blade of Agony Launcher.h"
#include <Windows.h>
#include <stdio.h>

#define MAX_LOADSTRING 100

// Global Variables:
HINSTANCE hInst;                                // current instance
WCHAR szTitle[MAX_LOADSTRING];                  // The title bar text
WCHAR szWindowClass[MAX_LOADSTRING];            // the main window class name

LauncherSettings settings;

// Forward declarations of functions included in this code module:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

bool shiftkeypressed = false;

inline void BOA_FillComboBox(HWND dlg, int what, int max, LPARAM init, TCHAR list[][50])
{
	HWND controlhwnd = GetDlgItem(dlg, what);
	TCHAR A[100];
	int  k = 0;

	memset(&A, 0, sizeof(A));
	for (k = 0; k < max; k++)
	{
		wcscpy_s(A, sizeof(A) / sizeof(TCHAR), (TCHAR*)list[k]);

		// Add string to combobox.
		SendMessage(controlhwnd, CB_ADDSTRING, (WPARAM)0, (LPARAM)A);
	}
	SendMessage(controlhwnd, CB_SETCURSEL, (WPARAM)init, (LPARAM)0);
}

inline void BOA_CheckBox(HWND dlg, int what, bool state)
{
	SendMessage(GetDlgItem(dlg, what), BM_SETCHECK, state ? BST_CHECKED : BST_UNCHECKED, 0);
}

inline void BOA_LaunchGZDoom(int detail, int displacement, int language, int devcomments, int texfilt)
{
	STARTUPINFO si = { sizeof(si) };
	PROCESS_INFORMATION pi;
	TCHAR GZFinalCmdLine[200];

	_snwprintf_s(GZFinalCmdLine, 199, 199, TEXT("%s -iwad %s %s %s %s %s %s"),
		SourcePortName,
		IWadName,
		DetailSettingsCmd[detail],
		DisplacementTexturesCmd[displacement],
		LanguagesCmd[language],
		DeveloperCommentaryCmd[devcomments],
		TexFilterSettingsCmd[texfilt]);

	CreateProcess(NULL,   // No module name (use command line)
		GZFinalCmdLine,        // Command line
		NULL,           // Process handle not inheritable
		NULL,           // Thread handle not inheritable
		FALSE,          // Set handle inheritance to FALSE
		0,              // No creation flags
		NULL,           // Use parent's environment block
		NULL,           // Use parent's starting directory 
		&si,            // Pointer to STARTUPINFO structure
		&pi);
	//MessageBox(NULL, GZFinalCmdLine, TEXT("Debug"), MB_OK | MB_ICONINFORMATION);
}

BOOL CALLBACK DialogProc(HWND hwndDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_INITDIALOG:
		BOA_FillComboBox(hwndDlg, IDC_COMBO1, DETAIL_END, LPARAM(DETAIL_UNCHANGED), DetailSettingsStrings);
		BOA_FillComboBox(hwndDlg, IDC_COMBO2, DIS_END, LPARAM(settings.DisplacementTextures), DisplacementTexturesStrings);
		BOA_FillComboBox(hwndDlg, IDC_COMBO3, LANGUAGE_MAX, LPARAM(settings.Language), LanguagesList);
		BOA_FillComboBox(hwndDlg, IDC_COMBO4, TEXFILT_END, LPARAM(TEXFILT_UNCHANGED), TexFilterSettingsStrings);
		BOA_CheckBox(hwndDlg, IDC_CHECK1, settings.DontShow);
		BOA_CheckBox(hwndDlg, IDC_CHECK3, settings.DevCommentary);

		if (shiftkeypressed) // by default shift key makes the window not have focus
		{
			// when I tested, I needed both of these, so...
			SetFocus(GetDlgItem(hwndDlg, IDOK));
			SetFocus(hwndDlg);
		}
		return TRUE;

    case WM_COMMAND:
        switch (LOWORD(wParam))
        {
        case IDOK:
			TCHAR check[50];
			
			GetDlgItemText(hwndDlg, IDC_COMBO1, check, 49);
			for (int i = 0; i < DETAIL_END; i++)
				if (_tcscmp(check, DetailSettingsStrings[i]) == 0)
					settings.Detail = i;

			GetDlgItemText(hwndDlg, IDC_COMBO2, check, 49);
			for (int i = 0; i < DIS_END; i++)
				if (_tcscmp(check, DisplacementTexturesStrings[i]) == 0)
					settings.DisplacementTextures = i;

			GetDlgItemText(hwndDlg, IDC_COMBO3, check, 49);
			for (int i = 0; i < LANGUAGE_MAX; i++)
				if (_tcscmp(check, LanguagesList[i]) == 0)
					settings.Language = i;

			GetDlgItemText(hwndDlg, IDC_COMBO4, check, 49);
			for (int i = 0; i < TEXFILT_END; i++)
				if (_tcscmp(check, TexFilterSettingsStrings[i]) == 0)
					settings.TexFilter = i;

			settings.DontShow = SendDlgItemMessage(hwndDlg, IDC_CHECK1, BM_GETCHECK, 0, 0);
			settings.DevCommentary = SendDlgItemMessage(hwndDlg, IDC_CHECK3, BM_GETCHECK, 0, 0);

			if (settings.DontShow)
				MessageBox(NULL, TEXT("You can hold down SHIFT when starting in the future to get this box back"), TEXT("Notice"), MB_OK | MB_ICONINFORMATION);
			
			TCHAR setting[20];

			_itow_s(settings.DontShow, setting, 19);
			WritePrivateProfileString(TEXT("Launcher"), TEXT("DontShow"), setting, SettingsFile);

			_itow_s(settings.DevCommentary, setting, 19);
			WritePrivateProfileString(TEXT("Launcher"), TEXT("DevCommentary"), setting, SettingsFile);

			_itow_s(settings.DisplacementTextures, setting, 19);
			WritePrivateProfileString(TEXT("Launcher"), TEXT("DisplacementTextures"), setting, SettingsFile);

			_itow_s(settings.Language, setting, 19);
			WritePrivateProfileString(TEXT("Launcher"), TEXT("Language"), setting, SettingsFile);

			BOA_LaunchGZDoom(settings.Detail, settings.DisplacementTextures, settings.Language, settings.DevCommentary, settings.TexFilter);
			
			DestroyWindow(hwndDlg);
            return TRUE;

        case IDCANCEL:
            DestroyWindow(hwndDlg);
            return TRUE;
        }
        return FALSE;

    case WM_CLOSE:
        DestroyWindow(hwndDlg);
        return TRUE;

    default:
        return FALSE;
    }
}

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // TODO: Place code here.

    // Initialize global strings
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_BLADEOFAGONYLAUNCHER, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

	settings.DontShow =				GetPrivateProfileInt(TEXT("Launcher"), TEXT("DontShow"),				(INT)settings.DontShow, SettingsFile);
	settings.DevCommentary =		GetPrivateProfileInt(TEXT("Launcher"), TEXT("DevCommentary"),			(INT)settings.DevCommentary, SettingsFile);
	settings.DisplacementTextures =	GetPrivateProfileInt(TEXT("Launcher"), TEXT("DisplacementTextures"),	(INT)settings.DisplacementTextures, SettingsFile);
	settings.Language =				GetPrivateProfileInt(TEXT("Launcher"), TEXT("Language"),				(INT)settings.Language, SettingsFile);

	if (!!(GetKeyState(0x10) & 0x8000))
		shiftkeypressed = true;

	if (!settings.DontShow || shiftkeypressed)
		DialogBox(hInstance, MAKEINTRESOURCE(IDD_DIALOG1), 0, (DLGPROC)DialogProc);
	else
		BOA_LaunchGZDoom(settings.Detail, settings.DisplacementTextures, settings.Language, settings.DevCommentary, settings.TexFilter);

	return 0;
}


//
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = (WNDPROC)DialogProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_BLADEOFAGONYLAUNCHER));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_BLADEOFAGONYLAUNCHER);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_BLADEOFAGONYLAUNCHER));

    return RegisterClassExW(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Store instance handle in our global variable

   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}
