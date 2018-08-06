# Windows Customization Keyboard Shortcuts

This projects aims to add intuitive actions in Windows, by **turning a useless key (such as CapsLock, NumLock, etc) into a shortcut launcher**.
(NB: this key can still be used, e.g. by typing "Shift + key" instead)


## Main features
**Search based on selected-text**  
From anywhere in Windows, select text and quickly:
- Google it
- Open it's Wikipedia page
- Open it's translation
- Find it on Google Maps
- Search it on YouTube
- Edit the file (if file is selected in the explorer)
- Etc.

**Play/Pause/Next media from anywhere**

**Run software** in two or three keys



## Installing

This project was written for [AutoHotKey](https://autohotkey.com), an open-source custom scripting tool for Windows. You need to install it to run the scripts (a portable version exists).


This project contains two scripts:
- **WindowsCustomization.ahk**. This is the main of the code, it contains the shortcuts and functions.
- **Nofity.ahk**. This is used to display alerts when commands are ran by WindowsCustomization.ahk, in order to make the experience more confortable. It is not mandatory and can be omitted if you want - just make sure to delete the lines that contain the Notify() function in the other script if you don't use

To run the script, just double click them after AutoHotKey has been installed.
To run at startup, put a shortcut to them in your startup folfer.

## How to use

As mentioned above, this script __turns a useless key - such as CapsLock - into a shortcut launcher__. In practice, after pressing CapsLock, you can enter up to 3 keys to do an action. If you want to have the real effect of hte key, press "Shift + changed_key".

In this part will be listed all the shortcuts that I implemented in this script. Shortcuts can be easily added/modified (see dedicated section below).


### Search based on selected-text

**When text is selected***, use the shortcuts below to do the corresponding action on the text.  
When the shortcut is of the form "* > abc", it means that you should **press the launcher key first, and THEN type the shortcut (here abc) to do the corresponding actions**. 

| Shortcut  | Action |
| --- | --- |
| Ctrl + Space | Search it on Google |
| Ctrl + Shift + y | Search it on YouTube |
| * > map  | Search it on Google Map |
| * > im  | Search it on Google Image |
| * > we | Open its Wikipedia English page |
| * > wf | Open its Wikipedia French page |
| * > ef | Show its translation on WordReference English -> French |
| * > fe | Show its translation on WordReference French -> English |
| * > en | Translate it to English in Google Translate |
| * > fr | Translate it to French in Google Translate |
| * > syn | Search for its synonyms (in French) |
| * > def | Search for its definition (in French) |
| * > ed  | Edit the selected file in Sublime Text (see below for details) |

NB: *Regarding file edition, it works if you highlight a file in the explorer, or if the text that is selected is the full path of a local file.*

*It's up to you to modify the websites that are used if you have preferences.*


### Shortcuts not based on selected-text

When the shortcut is of the form "* + a", it means that you should **press the launcher key AND the shortcut (here a) at the same time to do the corresponding actions**. 

| Shortcut  | Action |
| --- | --- |
| * + c | Open Chrome |
| * > c | Open Chrome |
| * > ff | Open FireFox |
| * > ie | Open Internet Explorer (lol) |
| * > ps | Open PowserShell |
| Ctrl + Alt + t | Open bash for Windows |
| * > ol | Open OutLook |
| * > on | Open OneNote |
| * > wo | Open Word |
| * > ex | Open Excel |
| * > pp | Open PowerPoint |
| * > sk | Open Skype |
| * > vb | Open VirtualBox |
| * > st | Open SublimeText |
| * > ws | Open Wireshark |
| * > ot | Set the active window as "Always on top" |
| * + Down_Arrow | Play/Pause the music/video |
| * + Right_Arrow | Next music/video |
| * + Left_Arrow | Previous the music/video |
| * + Page_Up | Increase volume |
| * + Page_Down | Decrease Volume |

*To open bash terminal in your Documents folder, update line 113 of the script accordingly*


### Special shortcuts

Finally, it is possible to "autocomplete" some predefined sentences you are brought to type frequently. Typing the shortcuts below will automatically type the text on the right.

| Shortcut  | Replacing text |
| --- | --- |
| @@ | work.email.address@work.com |
| @] | personal.email.address@gmail.com |
| @sf | Surname FamilyName [replace initials] |
| @00 | +33 (0) 6 10 20 30 40 [your phone number] |
| @br | Best regards, blahblah [to be adapted to your context] |

*NB: The personal email shortcut is adapted to french keyboards - adapt it to your own keyboard (e.g. **@:** for UK keyboards)*


## How to modify/adapt the script

AutoHotKey scripting language is very documented on their [website](https://autohotkey.com/docs/AutoHotkey.htm), but in my opinion it is not very self-explanatory.
I will write a small documentation dedicated to this script later. Meanwhile, the comments in the script should be a good start to make basic modifications.


## Contributing

Please note that the script **Notify.ahk** was entirely written by **gwarble** and found on [AutoHotKey forum](https://autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/) or on his [page](http://www.gwarble.com/ahk/Notify/).
