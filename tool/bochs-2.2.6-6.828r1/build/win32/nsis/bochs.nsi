;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $Id: bochs.nsi.in,v 1.13 2006/01/15 21:00:50 vruppert Exp $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Setup Script for NSIS Installer
;
; Created: Michael Rich (istan)
;
; Based on Example Script by Joost Verburg
; also original BOCHS script by Robert (segra)
; updated for NSIS 2.12 by Volker Ruppert
;
;---------------------
;Include Modern UI

  !include "MUI.nsh"

;--------------------------------

!define VERSION 2.2.6 (6.828 rel 1)
!define NAME "Bochs ${VERSION}"


!define CURRENTPAGE $9

!define TEMP1 $R0
!define TEMP2 $R1

!define SRCDIR bochs-${VERSION}
!define PGDIR "$SMPROGRAMS\Bochs ${VERSION}"
!define DESKTOP_DLXLINK "$DESKTOP\Linux Demo in ${NAME}.lnk"
!define DESKTOP_DLX_PIF "$DESKTOP\Linux Demo in ${NAME}.pif"

;--------------------------------

  ;General
  Name "${NAME}"
  OutFile Bochs-${VERSION}.exe
  SetOverwrite on

  ; Installation Types
  InstType "Normal"
  InstType "Full (with DLX Linux demo)"

  ;Folder-select dialog
  InstallDir $PROGRAMFILES\Bochs-${VERSION}
  InstallDirRegKey HKLM "Software\${NAME}" ""

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_COMPONENTSPAGE_NODESC
  !define MUI_ICON "bochs.ico"
  !define MUI_UNICON "unbochs.ico"

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE ${SRCDIR}\COPYING.txt
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Bochs Program (required)" SecCore
  SectionIn 1 2 RO

  SetOutPath "$INSTDIR"

  File "${SRCDIR}\*.exe"
  File "${SRCDIR}\*.txt"
  File "*.ico"

  ; Install keymaps
  SetOutPath "$INSTDIR\keymaps"
  File "${SRCDIR}\keymaps\*"

SectionEnd

Section "ROM Images (required)" SecROMs
  SectionIn 1 2 RO

  SetOutPath "$INSTDIR"

  File "${SRCDIR}\BIOS-bochs-latest"
  File "${SRCDIR}\VGABIOS-*"
SectionEnd

Section "Documentation in HTML" SecDocs
  SectionIn 1 2 
  SetOutPath "$INSTDIR\docs"
  File "${SRCDIR}\share\doc\bochs\index.html"
  SetOutPath "$INSTDIR\docs\user"
  File "${SRCDIR}\share\doc\bochs\user\*"
  SetOutPath "$INSTDIR\docs\development"
  File "${SRCDIR}\share\doc\bochs\development\*"
  SetOutPath "$INSTDIR\docs\documentation"
  File "${SRCDIR}\share\doc\bochs\documentation\*"
  SetOutPath "$INSTDIR\docs\images"
  File "${SRCDIR}\share\doc\bochs\images\*"
SectionEnd

Section "DLX Linux Demo" SecDLX
  SectionIn 2

  SetOutPath "$INSTDIR\dlxlinux"
  File "${SRCDIR}\dlxlinux\*"

  ; Fix up the path to the Bochs executable
  FileOpen $1 "$INSTDIR\dlxlinux\run.bat" w
  FileWrite $1 'cd "$INSTDIR\dlxlinux"$\r$\n'
  FileWrite $1 "..\bochs -q -f bochsrc.bxrc$\r$\n"
  FileClose $1
SectionEnd

Section "Add Bochs to the Start Menu and Desktop" SecIcons
  SectionIn 1 2
  
  ; Set the Program Group as output to ensure it exists
  SetOutPath "${PGDIR}"

  ; Change the output back to the install folder so the "Start In" paths get set properly
  SetOutPath "$INSTDIR"

  CreateShortCut "${PGDIR}\${NAME}.lnk" "$INSTDIR\Bochs.exe" "" "$INSTDIR\bochs.ico" "0"

  CreateShortCut "${PGDIR}\Readme.lnk" \
                 "$INSTDIR\Readme.txt"

  CreateShortCut "${PGDIR}\Bochs Sample Setup.lnk" \
                 "$INSTDIR\bochsrc-sample.txt"

  CreateShortCut "${PGDIR}\Disk Image Creation Tool.lnk" \
                 "$INSTDIR\bximage.exe"

  CreateShortCut "${PGDIR}\NIC Lister.lnk" \
                 "$INSTDIR\niclist.exe"

  WriteINIStr "${PGDIR}\Help.url" \
	      "InternetShortcut" "URL" "file://$INSTDIR/docs/index.html"

  WriteINIStr "${PGDIR}\Home Page.url" \
	      "InternetShortcut" "URL" "http://bochs.sourceforge.net/"

  CreateShortCut "${PGDIR}\${NAME} Folder.lnk" \
                 "$INSTDIR"

  CreateShortCut "${PGDIR}\Uninstall Bochs.lnk" \
                 "$INSTDIR\Uninstall.exe" "" "$INSTDIR\unbochs.ico" "0"

  ; Create shortcut to DLX Linux if it was installed
  IfFileExists "$INSTDIR\dlxlinux\*" 0 no
	CreateShortCut "${PGDIR}\DLX Linux.lnk" "$INSTDIR\dlxlinux\run.bat" "" "$INSTDIR\penguin.ico" "0"

  ; Add a link to the DLX demo to the desktop
  CreateShortCut "${DESKTOP_DLXLINK}" "$INSTDIR\dlxlinux\run.bat" "" "$INSTDIR\bochs.ico" "0"
no:


SectionEnd

Section "Register .bxrc Extension" SecExtension
  SectionIn 1 2 RO
  
  ; back up old value of .bxrc
  ReadRegStr $1 HKCR ".bxrc" ""

  StrCmp $1 "" Label1
    StrCmp $1 "BochsConfigFile" Label1
    WriteRegStr HKCR ".bxrc" "backup_val" $1

  Label1:
  WriteRegStr HKCR ".bxrc" "" "BochsConfigFile"
  WriteRegStr HKCR "BochsConfigFile" "" "${NAME} Config File"
  WriteRegStr HKCR "BochsConfigFile\DefaultIcon" "" "$INSTDIR\bochs.ico,0"
  WriteRegStr HKCR "BochsConfigFile\shell" "" "Configure"
  WriteRegStr HKCR "BochsConfigFile\shell\Configure\command" "" '"$INSTDIR\Bochs.exe" -f "%1"'
  WriteRegStr HKCR "BochsConfigFile\shell" "" "Edit"
  WriteRegStr HKCR "BochsConfigFile\shell\Edit\command" "" 'C:\WINDOWS\NOTEPAD.EXE "%1"'
  WriteRegStr HKCR "BochsConfigFile\shell" "" "Debugger"
  WriteRegStr HKCR "BochsConfigFile\shell\Debugger\command" "" '"$INSTDIR\Bochsdbg.exe" -f "%1"'
  WriteRegStr HKCR "BochsConfigFile\shell" "" "Run"
  WriteRegStr HKCR "BochsConfigFile\shell\Run\command" "" '"$INSTDIR\Bochs.exe" -q -f "%1"'
SectionEnd


Section -post
  ; Register Uninstaller
  WriteRegStr HKLM "SOFTWARE\${NAME}" "" $INSTDIR
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayName" "${NAME} (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayIcon" "$INSTDIR\bochs.ico,0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "Publisher" "The Bochs Project"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "URLInfoAbout" "http://bochs.sourceforge.net"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "Readme" '$INSTDIR\Readme.txt'
  WriteRegDWord HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "NoModify" "1"
  WriteRegDWord HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "NoRepair" "1"
  WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "InstallLocation" '$INSTDIR\'
  WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "UninstallString" '"$INSTDIR\Uninstall.exe"'

  ; Write the uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
;Installer Functions

Function .onInstSuccess
  MessageBox MB_YESNO|MB_ICONQUESTION \
	     "Would you like to see a list of changes?" \
	     IDNO NoChanges
		ExecShell open '$INSTDIR\CHANGES.TXT'
  NoChanges:
  MessageBox MB_YESNO|MB_ICONQUESTION \
             "Setup has completed. Read readme now?" \
             IDNO NoReadme
    ExecShell open '$INSTDIR\readme.txt'

  NoReadme:
  DetailPrint "Thank you for installing Bochs, think inside the bochs."
FunctionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ReadRegStr $1 HKCR ".bxrc" ""

  StrCmp $1 "BochsConfigFile" 0 NoOwn ; only do this if we own it
    ReadRegStr $1 HKCR ".bxrc" "backup_val"
    StrCmp $1 "" 0 RestoreBackup ; if backup == "" then delete the whole key
      DeleteRegKey HKCR ".bxrc"
    Goto NoOwn
    RestoreBackup:
      WriteRegStr HKCR ".bxrc" "" $1
      DeleteRegValue HKCR ".bxrc" "backup_val"
  NoOwn:

  DeleteRegKey HKCR "BochsConfigFile"
  DeleteRegKey HKLM "SOFTWARE\${NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

  Delete "${PGDIR}\*.lnk"
  Delete "${PGDIR}\*.pif"
  Delete "${PGDIR}\*.url"
  RMDir "${PGDIR}"

  Delete "${DESKTOP_DLXLINK}"
  Delete "${DESKTOP_DLX_PIF}"

  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.txt"
  Delete "$INSTDIR\*.ico"
  Delete "$INSTDIR\keymaps\*"
  Delete "$INSTDIR\BIOS-bochs-latest"
  Delete "$INSTDIR\VGABIOS-*"
  Delete "$INSTDIR\dlxlinux\*"
  Delete "$INSTDIR\docs\index.html"
  Delete "$INSTDIR\docs\user\*"
  Delete "$INSTDIR\docs\development\*"
  Delete "$INSTDIR\docs\documentation\*"
  Delete "$INSTDIR\docs\images\*"

  RMDIR "$INSTDIR\keymaps"
  RMDIR "$INSTDIR\dlxlinux"
  RMDIR "$INSTDIR\docs\user"
  RMDIR "$INSTDIR\docs\development"
  RMDIR "$INSTDIR\docs\documentation"
  RMDIR "$INSTDIR\docs\images"
  RMDIR "$INSTDIR\docs"
  RMDIR "$INSTDIR"

SectionEnd

;eof
