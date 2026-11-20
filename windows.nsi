!include "MUI2.nsh"

# Basic metadata
Name "RecomBox"
OutFile "dist\${APP_NAME}-windows-x86_64.exe"
InstallDir "$PROGRAMFILES64\RecomBox"

InstallDirRegKey HKLM "Software\RecomBox" "Install_Dir"

RequestExecutionLevel admin

# Use the app icon
!define MUI_ICON "windows\runner\resources\app_icon.ico"

# Pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

# Finish page with "Launch RecomBox" checkbox (defines must come before the page macro)
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_NAME}.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch RecomBox"
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"


# Kill the running app and WAIT until it has actually exited.
# taskkill returns immediately; without waiting, File /r hits files that are
# still locked by the dying process and NSIS shows "Error opening file for writing".
!macro KillAppAndWait
    nsExec::ExecToStack 'taskkill /F /T /IM "${APP_NAME}.exe"'
    Pop $0
    Pop $1
    StrCpy $2 0
    wait_app_exit_loop:
        # find exits 0 while the process is still listed
        nsExec::ExecToStack 'cmd /c tasklist /FI "IMAGENAME eq ${APP_NAME}.exe" /NH | find /I "${APP_NAME}.exe"'
        Pop $0
        Pop $1
        StrCmp $0 "0" 0 wait_app_exit_done
        IntOp $2 $2 + 1
        IntCmp $2 50 wait_app_exit_done   # give up after ~10s
        Sleep 200
        Goto wait_app_exit_loop
    wait_app_exit_done:
    # Small grace period for Windows to release file handles
    Sleep 500
!macroend

Section "MainSection" SEC01

    SetOutPath "$INSTDIR"

    !insertmacro KillAppAndWait
    
    # Grabs all flutter build files recursively
    File /r "${BUILD_DIR}\*"
    
    # Create Shortcuts - "RecomBox" for display, lowercase for target exe
    CreateShortCut "$DESKTOP\RecomBox.lnk" "$INSTDIR\${APP_NAME}.exe"
    CreateDirectory "$SMPROGRAMS\RecomBox"
    CreateShortCut "$SMPROGRAMS\RecomBox\RecomBox.lnk" "$INSTDIR\${APP_NAME}.exe"
    
    # Add to Windows Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "DisplayName" "RecomBox"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "DisplayIcon" "$INSTDIR\${APP_NAME}.exe"
    
    WriteRegStr HKLM "Software\RecomBox" "Install_Dir" "$INSTDIR"

    WriteUninstaller "$INSTDIR\uninstall.exe"

    IfSilent 0 +2
        Exec '"$INSTDIR\${APP_NAME}.exe"'


SectionEnd

Section "Uninstall"
    !insertmacro KillAppAndWait
    
    Delete "$DESKTOP\RecomBox.lnk"
    RMDir /r "$SMPROGRAMS\RecomBox"
    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox"

    DeleteRegKey HKLM "Software\RecomBox"

SectionEnd