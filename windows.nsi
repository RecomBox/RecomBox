!include "MUI2.nsh"

# Use "RecomBox" for the installer UI and folder naming
Name "RecomBox"
OutFile "dist\${APP_NAME}-windows-x86_64.exe"
InstallDir "$PROGRAMFILES64\RecomBox"
RequestExecutionLevel admin

# App Icon
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
    
    # Grabs all flutter build files
    File /r "${BUILD_DIR}\*"
    
    # --- SHORTCUTS ---
    # This creates the icon on the Desktop named "RecomBox"
    CreateShortCut "$DESKTOP\RecomBox.lnk" "$INSTDIR\recombox.exe"
    
    # This creates the Start Menu folder and shortcut named "RecomBox"
    CreateDirectory "$SMPROGRAMS\RecomBox"
    CreateShortCut "$SMPROGRAMS\RecomBox\RecomBox.lnk" "$INSTDIR\recombox.exe"
    
    # --- REGISTRY FOR UNINSTALLER ---
    # This makes "RecomBox" appear in the Windows Control Panel / Settings
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "DisplayName" "RecomBox"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox" "DisplayIcon" "$INSTDIR\recombox.exe"
    
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Uninstall"
    # Clean up shortcuts
    Delete "$DESKTOP\RecomBox.lnk"
    RMDir /r "$SMPROGRAMS\RecomBox"
    
    # Clean up files and folder
    RMDir /r "$INSTDIR"
    
    # Clean up registry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RecomBox"
SectionEnd