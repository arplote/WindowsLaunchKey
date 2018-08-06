#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
RegRead, OutputVar, HKEY_CLASSES_ROOT, http\shell\open\command 
StringReplace, OutputVar, OutputVar," 
SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive 
browser=C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe        ; default browser for the script
SetNumLockState, AlwaysOn                                                  ; Keypad numbers are always enabled
#Include Notify.ahk


+²::
  SendRaw, ²
Return

; IF YOU WANT TO USE CapsLock INSTEAD OF POWER TWO, UNCOMMENT THESE THREE LINES (AND COMMENT THE THREE ABOVE)
; AND REPLACE ALL THE OTHER "²" CHARACTERS BY "CapsLock"
; IF YOU WANT TO USE NumLock INSTEAD OF CapsLock, DO THE SAME AS FOR CapsLock AND REPLACE THEM ALL WITH NumLock

;+ & CapsLock::
;  Send, {CapsLock}
;Return


;---------------------- REPLACE TEXT ----------------------

:*:@@::
  SendRaw, work.email.address@work.com
  Send, {RAlt}
Return

:*:@]::
  SendRaw, personal.email.address@gmail.com
  Send, {RAlt}
Return

:*:@sf::
  SendRaw, Surname FamilyName
  Send, {RAlt}
Return

:*:@00::
  SendRaw, +33 (0) 6 10 20 30 40
  Send, {RAlt}
Return

:*:@br::
  SendRaw, `nBest regards,`n`nSurname FamilyName
  Send, {RAlt}
Return


;---------------------- MEDIA KEYS ----------------------
; Better used with an extension such as keysocket (https://github.com/borismus/keysocket)
; that enables Windows Media Keys in most music/video websites in the browser

² & Down::
{
   Send {Media_Play_Pause}
   Notify("AutoHotKey","Play/Pause",0.2,"GC_=6ACFFA")
   Return
}

² & Right::
{
   Send {Media_Next}
   Notify("AutoHotKey","Next",0.2,"GC_=6ACFFA")
   Return
}

² & Left::
{
   Send {Media_Prev}
   Notify("AutoHotKey","Previous",0.2,"GC_=6ACFFA")
   Return
}

² & PgUp:: Send {Volume_Up 1}
² & PgDn:: Send {Volume_Down 1}


;---------------------- BASIC SHORTCUTS ----------------------

^Space::                            ; Search in Google
{ 
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, googleSearch 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   return 
}

^+y::                               ; Search on YouTube
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, youtubeSearch 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   return 
}

^!t::                              ; Open bash terminal for Windows
{
   Run, C:\Windows\System32\bash.exe -c 'cd /mnt/c/Users/YOUR_NAME/Documents/; exec bash'
   return
}


;---------------------- SPECIAL KEY SHORTCUTS ----------------------

² & c::                              ; Open Chrome
{
   Run, chrome, C:\Program Files (x86)\Google\Chrome\Application\
   return
}

²::                                             ; Start the listener after the special key
Notify("AutoHotKey","Listening",0.2)            ; A short notification (0.2 sec) shows that the script is listening
Input, UserInput, T2 L3 C, {enter}.{esc}{tab},ps,ol,on,wo,ex,pp,sk,vb,c,ff,ie,st,ws,ot,ed,y,map,we,wf,ef,fe,en,fr,syn,def,im
; T2 = timeout after 2 seconds
; L3 = max length is 3 characters
; enter is the validation key
; escape and tab are the cancel keys
; all the following strings are the strings to match

if (ErrorLevel = "Max")
{
    Notify("AutoHotKey","Stopping",0.2,"GC_=Red")
    return
}
if (ErrorLevel = "Timeout")
{
    Notify("AutoHotKey","Stopping",0.2,"GC_=Red")
    return
}
if (ErrorLevel = "NewInput")
    return
if InStr(ErrorLevel, "EndKey:")
{
    Notify("AutoHotKey","Stopping",0.2,"GC_=Red")
    return
}
; Otherwise, a match was found.



;---------------------- GENERAL SHORTCUTS ----------------------


if (UserInput = "ps")
{
   Run, powershell, C:\Windows\System32\WindowsPowerShell\v1.0
   Notify("AutoHotKey","PowerShell",0.2,"GC_=Green")
}

if (UserInput = "ol")
{
   Run, Outlook, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
   Notify("AutoHotKey","Outlook",0.2,"GC_=Green")
}

if (UserInput = "on")
{
   Run, OneNote 2016, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
   Notify("AutoHotKey","OneNote",0.2,"GC_=Green")
}

if (UserInput = "wo")
{
   Run, Word, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
   Notify("AutoHotKey","Word",0.2,"GC_=Green")
}

if (UserInput = "ex")
{
   Run, Excel, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
   Notify("AutoHotKey","Excel",0.2,"GC_=Green")
}

if (UserInput = "pp")
{
   Run, PowerPoint, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
   Notify("AutoHotKey","PowerPoint",0.2,"GC_=Green")
}

if (UserInput = "sk")
{
   Run, Skype for Business, C:\ProgramData\Microsoft\Windows\Start Menu\Programs
   Notify("AutoHotKey","Skype",0.2,"GC_=Green")
}

if (UserInput = "vb")
{
   Run, Oracle VM VirtualBox, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox
   Notify("AutoHotKey","VirtualBox",0.2,"GC_=Green")
}

if (UserInput = "c")
{
   Run, chrome, C:\Program Files (x86)\Google\Chrome\Application\
   Notify("AutoHotKey","Chrome",0.2,"GC_=Green")
}

if (UserInput = "ff")
{
   Run, firefox, C:\Program Files\Mozilla Firefox
   Notify("AutoHotKey","FireFox",0.2,"GC_=Green")
}

if (UserInput = "ie")
{
   Run, iexplore, C:\Program Files\internet explorer
   Notify("AutoHotKey","Internet Explorer",0.2,"GC_=Green")
}

if (UserInput = "st")
{
   Run, C:\Program Files\Sublime Text 3\sublime_text.exe
   Notify("AutoHotKey","Sublime Text",0.2,"GC_=Green")
}

if (UserInput = "ws")
{
   Run, Wireshark, C:\Program Files\Wireshark\
   Notify("AutoHotKey","Wireshark",0.2,"GC_=Green")
}

if (UserInput = "ot")
{
   Winset, Alwaysontop, , A
   Notify("AutoHotKey","Alwaysontop",0.2,"GC_=Green")
}


;---------------------- SHORTCUTS BASED ON SELECTED TEXT ----------------------

if (UserInput = "ed")                                       ; edit selected file
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      Run, C:\Program Files\Sublime Text 3\sublime_text.exe "%clipboard%
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Edit",0.2,"GC_=Green")
   return
}

if (UserInput = "y")                                       ; search on YouTube
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, youtubeSearch 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","YouTube",0.2,"GC_=Green")
   return 
}

if (UserInput = "map")                                     ; search on Google Maps
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, googleMapsSearch 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","OK",0.2,"GC_=Green")
   return 
}

if (UserInput = "we")                                       ; open Wikipedia English page
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, wikipediaEnglish 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Wiki en",0.2,"GC_=Green")
   return 
}

if (UserInput = "wf")                                       ; open Wikipedia French page
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, wikipediaFrench
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Wiki fr",0.2,"GC_=Green")
   return 
}

if (UserInput = "ef")                                    ; open WordReference translation English -> French
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, englishToFrenchTranslate 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","en to fr",0.2,"GC_=Green")
   return 
}

if (UserInput = "fe")                                    ; open WordReference translation French -> English
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, frenchToEnglishTranslate 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","fr to en",0.2,"GC_=Green")
   return 
}

if (UserInput = "en")                                       ; Translate to English in Google Translate
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, toEnglishTranslate 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","To english",0.2,"GC_=Green")
   return 
}

if (UserInput = "fr")                                       ; Translate to French in Google Translate
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, toFrenchTranslate 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","To french",0.2,"GC_=Green")
   return 
}

if (UserInput = "syn")                                         ; Search for synonyms (French website)
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, synonyme 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Synonyme",0.2,"GC_=Green")
   return 
}

if (UserInput = "def")                                         ; Search for definition (French website)
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, definition 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Definition",0.2,"GC_=Green")
   return 
}

if (UserInput = "im")                                           ; Search on Google Image
{
   BlockInput, on 
   prevClipboard = %ClipboardAll% 
   clipboard = 
   Send, ^c 
   BlockInput, off 
   ClipWait, 2 
   if ErrorLevel = 0 
   { 
      searchQuery=%clipboard% 
      GoSub, googleImage 
   } 
   clipboard = %prevClipboard% 
   VarSetCapacity(prevClipboard, 0)
   Notify("AutoHotKey","Google Image",0.2,"GC_=Green")
   return 
}

return


;---------------------- FUNCTIONS DEFINITION ----------------------

googleSearch: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 

   If ( RegExMatch(searchQuery, "^(https?://|www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))        ; this regex checks wether it's a URL or a word to be searched on google
      Run, %browser% %searchQuery%
   else 
      {
      StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
      StringReplace, searchQuery, searchQuery, `+, `%2B, All 
      StringReplace, searchQuery, searchQuery, `&, `%26, All 
      Run, %browser% http://www.google.com/search?hl=en&q=%searchQuery%
      }
return

googleImage: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://www.google.com/search?q=%searchQuery%&tbm=isch
return

youtubeSearch: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://www.youtube.com/results?search_query=%searchQuery%
return

wikipediaEnglish: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   }
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://www.wikiwand.com/en/%searchQuery%
return

wikipediaFrench: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   }
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://www.wikiwand.com/fr/%searchQuery%
return

englishToFrenchTranslate: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   }
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% http://www.wordreference.com/enfr/%searchQuery%
return

frenchToEnglishTranslate: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% http://www.wordreference.com/fren/%searchQuery%
return

toEnglishTranslate: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://translate.google.fr/#auto/en/%searchQuery%
return

toFrenchTranslate: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://translate.google.fr/#auto/fr/%searchQuery%
return

synonyme: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% http://www.linternaute.com/dictionnaire/fr/synonyme/%searchQuery%
return

definition: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% http://www.linternaute.com/dictionnaire/fr/definition/%searchQuery%
return

googleMapsSearch: 
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
   Loop 
   { 
      noExtraSpaces=1 
      StringLeft, leftMost, searchQuery, 1 
      IfInString, leftMost, %A_Space% 
      { 
         StringTrimLeft, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      StringRight, rightMost, searchQuery, 1 
      IfInString, rightMost, %A_Space% 
      { 
         StringTrimRight, searchQuery, searchQuery, 1 
         noExtraSpaces=0 
      } 
      If (noExtraSpaces=1) 
         break 
   } 
   StringReplace, searchQuery, searchQuery, %A_Space%, `%20, All 
   StringReplace, searchQuery, searchQuery, `+, `%2B, All 
   StringReplace, searchQuery, searchQuery, `&, `%26, All 
   Run, %browser% https://www.google.fr/maps/search/%searchQuery%
return
