;NSIS Modern User Interface
;ezPAARSE MUI script
;Written by ezPAARSE team 2013/03/20

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;Variables

  Var StartMenuFolder
  Var DefaultBrowser
  Var DefaultExcel
  Var DefaultLibreOffice

;--------------------------------
;Pages

!insertmacro MUI_PAGE_LICENSE $(license)
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ezPAARSE-Project" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

; ending image
!define MUI_WELCOMEFINISHPAGE_BITMAP "ezPAARSE-HeaderPageNSIS.bmp"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT $(finish_page+text)
!define MUI_FINISHPAGE_RUN_FUNCTION "RunEZPAARSE"

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
  

;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "French" ;first language is the default language
  !insertmacro MUI_LANGUAGE "English"

;custom translations 

  !insertmacro LANGFILE_INCLUDE "French.nsh"
  !insertmacro LANGFILE_INCLUDE "English.nsh"

LicenseLangString license ${LANG_FRENCH} "Licence-CeCILL-V2-fr.txt"
LicenseLangString license ${LANG_ENGLISH} "License-CeCILL-V2-en.txt"


;--------------------------------
;General

!define APP_NAME "ezPAARSE"
!define APP_VERSION "1.4.3"
!define APP_INST ""


;Name and file
Name "${APP_NAME}"
OutFile "${APP_NAME}-${APP_VERSION}-Setup.exe"

;Default installation folder
InstallDir "$LOCALAPPDATA\${APP_NAME}-${APP_VERSION}"

;Get installation folder from registry if available
InstallDirRegKey HKCU "Software\ezPAARSE-Project" "InstallDir"

;Request application privileges for Windows
RequestExecutionLevel user

;--------------------------------
;Detecting default browser and excel for shortcuts

Section

  FileOpen $0 "$PLUGINSDIR\dummy.htm" "w"
  FileClose $0
  System::Call "Shell32::FindExecutable(t '$PLUGINSDIR\dummy.htm', i 0, t .r1)"
  DetailPrint "Your Default Browser is:"
  DetailPrint $1
  StrCpy $DefaultBrowser $1

  FileOpen $0 "$PLUGINSDIR\dummy.xlsm" "w"
  FileClose $0
  System::Call "Shell32::FindExecutable(t '$PLUGINSDIR\dummy.xlsm', i 0, t .r1)"
  DetailPrint "Your Default Excel is:"
  DetailPrint $1
  StrCpy $DefaultExcel $1

  FileOpen $0 "$PLUGINSDIR\dummy.ots" "w"
  FileClose $0
  System::Call "Shell32::FindExecutable(t '$PLUGINSDIR\dummy.ots', i 0, t .r1)"
  DetailPrint "Your Default libreOffice is:"
  DetailPrint $1
  StrCpy $DefaultLibreOffice $1

SectionEnd

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING


;--------------------------------
;Installer Sections

Section $(install+ezPAARSErequired) secEZPAARSE

  SetOutPath "$INSTDIR"
  SectionIn RO
  
  ;All ezPAARSE files...
  File /r "ezpaarse-${APP_VERSION}\*.*"

  ;Store installation folder
  WriteRegStr HKCU "Software\ezPAARSE-Project" "InstallDir" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd


Section $(menu+ezPAARSEmenu) SecMenuEZPAARSE

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
    ;Create shortcuts
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+1_lancer)" "$INSTDIR\node.exe" "app.js" 0
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+2_utiliser)" "$DefaultBrowser" $(url_start) 0 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+3_tester)" "$WINDIR\explorer.exe" "$INSTDIR\test\dataset" 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+4a_visualiser)" "$DefaultExcel" "$INSTDIR\excel\$(excel_render)" 0 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+4b_visualiser)" "$DefaultLibreOffice" "$INSTDIR\libreoffice\$(libreoffice_render)" 0 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+5_documenter)" "$DefaultBrowser" $(url_doc) 0 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+6_doc_usage)" "$DefaultBrowser" $(url_usage) 0 
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(menu+7_analogist)" "$DefaultBrowser" "http://analogist.couperin.org" 0 
  !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd

;--------------------------------
;Descriptions

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${secEZPAARSE} $(sec+EZPAARSE)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  Delete "$INSTDIR\Uninstall.exe"

  RMDir /r "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
    
  RMDir /r "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey /ifempty HKCU "Software\ezPAARSE-Project"

SectionEnd

Function runEZPAARSE
  MessageBox MB_OK $(end+runMessage)
  ExecShell "" "$SMPROGRAMS\$StartMenuFolder\$(menu+1_lancer)"
  ExecShell "open" $(url_usage)
  Sleep 5000 ; wait for node startup
  ExecShell "open" $(url_start)
FunctionEnd

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
  ReadRegStr $R0 HKCU \
  "Software\ezPAARSE-Project" "InstallDir"
  StrCmp $R0 "" done

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  $(preinstall+already_installed) \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  Exec "$INSTDIR\Uninstall.exe"
 
  IfErrors no_remove_uninstaller done
    ;You can either use Delete /REBOOTOK in the uninstaller or add some code
    ;here to remove the uninstaller. Use a registry key to check
    ;whether the user has chosen to uninstall. If you are using an uninstaller
    ;components page, make sure all sections are uninstalled.
  no_remove_uninstaller:
 
done:
 
FunctionEnd
