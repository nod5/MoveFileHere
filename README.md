# MoveFileHere

AutoHotkey tool to quickly move newest file from Downloads to the active File Explorer folder in Windows 10.

Version 2020-12-31  -  Free software GPLv3  -  by Nod5  
  
![MoveFileHere Screenshot](images/MoveFileHere1.png?raw=true)

## Setup
Download [`MoveFileHere.exe`](https://github.com/nod5/MoveFileHere/releases/latest)

## How to use  
- Run `MoveFileHere.exe`
- Open File Explorer and navigate to a folder
- Press `F7`  
   A Tooltip shows `"Move: <filepath>"`
   where `<filepath>` is the newest (most recently modified) file in the Downloads folder.
- To accept press `Enter`, `Space` or `Left Click`  
   To cancel press `Esc` or `F7` or wait 2 seconds  

## Change hotkey and/or source folder  
- Click "Settings" in tray icon menu or edit `MoveFileHere.ini` directly  
- Change to any folder you want to move from.  
- Use AutoHotkey syntax to change the hotkey  
  https://www.autohotkey.com/docs/Hotkeys.htm  
  https://www.autohotkey.com/docs/KeyList.htm  
  Example: to change to `Control + F8` write `Hotkey=^F8`  

## Autostart MoveFileHere when Windows 10 starts
Place a MoveFileHere shortcut in the Windows 10 StartUp folder:
- In File Explorer hold `Alt` and then left click and drag `MoveFileHere.exe` to create the shortcut `MoveFileHere.exe.lnk`
- Press `Win+R` and type `shell:startup` and `Enter` to open the StartUp folder in File Explorer
- Drag the created shortcut into StartUp folder

## Dependency  
`MoveFileHere.exe` works by itself. But if you instead want to run or compile the source `MoveFileHere.ahk` then first install [AutoHotkey](https://www.autohotkey.com/), unicode version.  

## Common questions
**Q** What can I use MoveFileHere for?  
**A** The default use case is to quickly move files from the Downloads folder. Another use case is if you regularly generate files in some other folder (e.g. video processing output) and want a hotkey to  quickly move them.  

**Q** What if a file with the same name already exists?  
**A** MoveFileHere asks if you want to overwrite.  

**Q** Can I have different MoveFileHere hotkeys for different source folders?  
**A** Yes, copy and rename `MoveFileHere.exe` to e.g. `MoveFileHere2.exe` and set a different hotkey and folder for the copy.  

**Q** Can I undo the move with `Ctrl+Z`?  
**A** Not yet.  

**Q** Why was MoveFileHere made?  
**A** Because the sequence Right click, Click "Show in folder", Ctrl+X, Alt+Tab Tab Tab, Ctrl+V is too long.  

## License  
Free Software GPLv3 by https://github.com/nod5/  

## Feedback  
Create a GitHub issue 
