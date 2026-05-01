!include "MUI2.nsh"

# Basic metadata
Name "RecomBox"
OutFile "dist\${APP_NAME}-windows-x86_64.exe"
InstallDir "$PROGRAMFILES64\RecomBox"
RequestExecutionLevel admin

# Use the app icon
!define MUI_ICON "windows\runner\resources\app_icon.ico"

# Pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

# Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
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
    
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Uninstall"
    Delete "$DESKTOP\RecomBox.lnk"
    RMDir /r "$SMPROGRAMS\RecomBox"
    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox"
SectionEnd