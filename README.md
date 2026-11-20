# WindowsLaunchKey

Keyboard shortcuts and small quality-of-life tweaks for Windows, written with [AutoHotkey](https://www.autohotkey.com).
Press a "leader" key, type two or three letters, and launch an app, open a site, or search the text you have selected.

This repository contains two generations of the project:

| | Folder | AutoHotkey | Status |
| --- | --- | --- | --- |
| **Shortcuts (current)** | [`shortcuts/`](shortcuts/) | **v2** | Maintained |
| Legacy | [`legacy-v1/`](legacy-v1/) | v1.1 | Kept for reference, no longer developed |

## Install the current version (AutoHotkey v2)

Ideal for a machine you only use for a few days: nothing to compile, nothing written outside the folder you put the files in.

1. Install [AutoHotkey v2](https://www.autohotkey.com/download/) (a portable version also works).
2. Download the files, in one of two ways:
   - **[`WindowsLaunchKey-Shortcuts.zip`](https://github.com/arplote/WindowsLaunchKey/releases/latest/download/WindowsLaunchKey-Shortcuts.zip)**, then unzip it anywhere; or
   - **the files one by one** (no unzip tool needed), saved in the same folder:
     [`WindowsCustomization.ahk`](https://github.com/arplote/WindowsLaunchKey/releases/latest/download/WindowsCustomization.ahk) (the script, the only required file) and
     [`Perso.example.ahk`](https://github.com/arplote/WindowsLaunchKey/releases/latest/download/Perso.example.ahk) (optional template for your personal data).
3. Double-click `WindowsCustomization.ahk`.
4. On first launch the script creates `Perso.ahk` from the template, if `Perso.example.ahk` is next to it. Open `Perso.ahk` to add your own e-mail addresses, websites and apps (details in [`shortcuts/README.md`](shortcuts/README.md)).

You can also clone this repository or use *Code > Download ZIP* and take the `shortcuts/` folder.

> **Heads-up:** the leader key is `²`, which sits above Tab on French (AZERTY) keyboards, and the interface messages are in French. Both are easy to change at the top of the script.

## Legacy version (AutoHotkey v1)

The original script, using CapsLock as the leader key, is in [`legacy-v1/`](legacy-v1/) with its own README. It needs AutoHotkey v1.1.

## License

[MIT](LICENSE)
