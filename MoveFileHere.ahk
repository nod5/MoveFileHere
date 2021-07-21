#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance force
ListLines, Off
SetWinDelay, -1
SetControlDelay, -1

; MoveFileHere.ahk

; AutoHotkey tool to quickly move newest file from Downloads to the active File Explorer folder in Windows 10.

; Version 2020-12-31  -  Free software GPLv3  -  by Nod5  

; source and documentation at https://github.com/nod5/MoveFileHere

; read settings from ini file
SplitPath, A_ScriptName, , , , vNameNoExt
vIniFile := A_ScriptDir "\" vNameNoExt ".ini"
IniRead, vHotkey      , % vIniFile, Settings, Hotkey      , %A_Space%
IniRead, vSourceFolder, % vIniFile, Settings, SourceFolder, %A_Space%
IniRead, vStartMessage, % vIniFile, Settings, StartMessage, %A_Space%

; default values
if !vHotkey
  vHotkey       := "F7"
if !vSourceFolder
  vSourceFolder := "C:\Users\" A_UserName "\Downloads"
if (vStartMessage != "off")
  vStartMessage := ""

; create hotkey for when Explorer is active
Hotkey, IfWinActive, ahk_class CabinetWClass
Try
{
  Hotkey, %vHotkey%, move_file_here, on
}
catch
{
  ; on error open ini file for editing hotkey and show error popup
  Run % vIniFile
  MsgBox, 5, % vNameNoExt, % "Error: Invalid hotkey: " vHotkey
  IfMsgBox, Retry
  {
    Reload
    Return
  }
  else
    ExitApp
}

; trim any trailing backslash in folder path
vSourceFolder := RTrim(vSourceFolder, "\")

; verify source folder exists
if !InStr(FileExist(vSourceFolder), "D")
{
  Run % vIniFile
  MsgBox, 5, % vNameNoExt, % "Not found: `n" vSourceFolder
  IfMsgBox, Retry
  {
    Reload
    Return
  }
  else
    ExitApp
}

; write settings
IniWrite, % vHotkey      , % vIniFile, Settings, Hotkey
IniWrite, % vSourceFolder, % vIniFile, Settings, SourceFolder

; tray menu
Menu, Tray, Icon, C:\Windows\System32\imageres.dll, 283
Menu, Tray, NoStandard
Menu, Tray, Add, About, menu_about
Menu, Tray, Default, About
Menu, Tray, Add, Settings, menu_settings
Menu, Tray, Add, Exit, menu_exit

vMessage =
(
In File Explorer press [%vHotkey%] to move the latest file from [%vSourceFolder%] to the active folder.

Edit [%vNameNoExt%.ini] to change hotkey and source folder.

https://github.com/nod5/MoveFileHere
)

; show message on first run only
if (vStartMessage != "off")
{
  IniWrite, % "off", % vIniFile, Settings, StartMessage
  MsgBox,, % vNameNoExt, % vMessage
}
return

menu_about:
  MsgBox,, % vNameNoExt, % vMessage
Return

menu_settings:
  Run % vIniFile
  sleep 100
  MsgBox, 1. Edit settings`n2. Save and close file`n3. Click OK
  Reload
Return

menu_exit:
  ExitApp
Return

move_file_here:
  if vLock
    goto cancel_move
  ; lock hotkey until this file move finishes
  vLock := 1

  ; clear tooltip, timers and variables from previous run
  ToolTip
  SetTimer, tooltip_off, off
  SetTimer, cancel_move, off
  vDate := vFile := ""

  ; get latest (most recently modified) file in source folder
  Loop, Files, %vSourceFolder%\*.*
  {
    loopfile := A_LoopFileFullPath
    if (A_LoopFileTimeModified > vDate)
    {
      vDate := A_LoopFileTimeModified
      vFile := A_LoopFileFullPath
    }
  }

  ; cancel if no file to move
  if !vFile
  {
    Tooltip,  `n   No file to move    `n  `n  
    ToggleHotkeys("off")
    SetTimer, tooltip_off, 2000
    return
  }

  ; show tooltip with file path 
  ToolTip,  `n   Move:`n   %vFile%   `n  `n  

  ; enable hotkeys: confirm move (Space, Enter, Left Click), cancel move (Esc)
  ; function: enable/disable hotkeys for while confirm/cancel tooltip shows
  ToggleHotkeys("on")
  ; time out action after 2s
  SetTimer, cancel_move, 2000
return



; move file to current folder in active Explorer window
hotkey_enter:
hotkey_lbutton:
hotkey_space:
  ; File Explorer must be active
  If !WinActive("ahk_class CabinetWClass")
    return
  ; get current folder path
  vFolder := ActiveExplorerPath()
  ; trim any trailing backslash (in case active folder is a root drive e.g. C:\ )
  vFolder := RTrim(vFolder, "\")

  If !FileExist(vFolder) or (vFolder = vSourceFolder)
  {
    Tooltip,  `n   Error: cannot move to %vSourceFolder%    `n  `n  
    ToggleHotkeys("off")
    SetTimer, tooltip_off, -2000
    return
  }

  ; disable timeout timer and confirm/cancel hotkeys
  SetTimer, cancel_move, Off
  ToggleHotkeys("off")

  ; prompt for confirmation if overwrite
  SplitPath, vFile, vFilename
  if FileExist(vFolder "\" vFilename)
  {
    MsgBox,1,Overwrite?, % folder "\" vFilename "`n`nFile already exists. Overwrite?"
    IfMsgBox, Cancel
      goto cancel_move
  }

  ; move file
  FileMove, % vFile , % vFolder, 1
  Tooltip % "  `n   ** " (ErrorLevel ? "Move Error!" : "Moved" ) " **   `n  "
  SetTimer, tooltip_off, -1500
  ; select moved file in active Explorer window
  SelectNamedFileExplorer(vFilename)
  ; all finished, so remove lock on hotkey
  vLock := ""
return
 
hotkey_esc: 
cancel_move:
  ToggleHotkeys("off")
  SetTimer, cancel_move, off
tooltip_off:
  ToolTip
  vLock := ""
return


; function: enable/disable hotkeys for the confirm/cancel tooltip
ToggleHotkeys(vState := "on")
{
  Hotkey, IfWinActive, ahk_class CabinetWClass
  Hotkey, Space   , hotkey_space    , % vState
  Hotkey, Enter   , hotkey_enter    , % vState
  Hotkey, Lbutton , hotkey_lbutton  , % vState
  Hotkey, Esc     , hotkey_esc      , % vState
}


; function: get active window File Explorer folder path
; ref https://docs.microsoft.com/en-us/windows/win32/shell/folderitem-path
ActiveExplorerPath()
{
  vHwnd := WinActive("ahk_class CabinetWClass")
  if (vHwnd)
    for window in ComObjCreate("Shell.Application").Windows
    {
      vWindowHwnd := ""
      try vWindowHwnd := window.HWND
      if (vWindowHwnd = vHwnd)
      {
        path := window.Document.Folder.Self.Path
        ; if start with "::" (for example Control Panel window) then return nothing
        return SubStr(path, 1, 2) = "::" ? "" : path
      }
    }
}


; function: SelectNamedFileExplorer(filename, [hwnd])
; select a single filename in File Explorer window using ComObj and Folder.ParseName
; acts on HWND Explorer window or (default) active Explorer window
; much faster than for-loop over each FolderItem if folder has many files
; https://docs.microsoft.com/en-us/windows/desktop/shell/folder
; https://docs.microsoft.com/en-us/windows/desktop/shell/folder-parsename
SelectNamedFileExplorer(vFilename, vHwnd := "")
{
  ; HWND from parameter or (default) active Explorer
  vHwnd := vHwnd ? vHwnd : WinExist("A")
  if !vHwnd
    return

  ; must be Explorer
  WinGetClass, vClass, % "ahk_id " vHwnd
  if (vClass != "CabinetWClass")
    return

  for window in ComObjCreate("Shell.Application").Windows
  {
    vWindowHwnd := ""
    try vWindowHwnd := window.HWND
    if (vWindowHwnd != vHwnd)
      continue

    sfv   := window.Document
    ; https://docs.microsoft.com/en-us/windows/desktop/shell/folder
    ; https://docs.microsoft.com/en-us/windows/desktop/shell/folderitems
    item := sfv.Folder.ParseName(vFilename)
    ; select item (1), deselect all other (4), ensure item in view (8), focus item (16)
    ; ref https://docs.microsoft.com/en-us/windows/desktop/shell/shellfolderview-selectitem
    ; use try to avoid exception if file already deleted/renamed
    try sfv.SelectItem(item, 1+4+8+16)
    sfv := item := ""
    break
  }
  window := ""
  return
}
