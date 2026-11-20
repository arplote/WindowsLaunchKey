# Shortcuts (AutoHotkey v2)

Windows shortcuts and small tweaks. One script, `WindowsCustomization.ahk`, plus an optional personal file, `Perso.ahk`.

## Install

1. Install [AutoHotkey v2](https://www.autohotkey.com/download/).
2. Put `WindowsCustomization.ahk` and `Perso.example.ahk` in the same folder, then double-click `WindowsCustomization.ahk`. (`WindowsCustomization.ahk` alone is enough to run; `Perso.example.ahk` is only the template for your personal data.)
3. First launch only: the script copies `Perso.example.ahk` to `Perso.ahk` and restarts itself.
4. Press `²` then `?` for the list of all codes (also where you fix broken program paths). Right-click the tray icon (near the clock) for the same list, the giant-cursor toggle, "start with Windows", reload and exit.

## Your personal data: `Perso.ahk`

Everything that is yours (e-mail addresses, phone number, internal websites, files, favourite searches) lives in **`Perso.ahk`**, not in the main script. That file is listed in `.gitignore`, so it is never committed or published.

On a new PC:

1. Get the project (see the main README).
2. Copy `Perso.example.ahk` to `Perso.ahk`. (The script does this for you on first launch.)
3. Edit `Perso.ahk`. It contains two optional sections, each documented in the file:
   - `PersoSnippets()`: text expansion (type `@@` and get your e-mail address).
   - `PersoCodes()`: your own `²` codes, with `AddApp`, `AddTool`, `AddFile`, `AddUrl` and `AddSearch`.
4. Reload the script. Press `²` then `?` to list every available code.

If you delete `Perso.ahk` or either function, the script still runs; you just lose those extras.

## Broken shortcuts: pointing them to your programs

Some codes launch programs that may not be installed on your PC, or are installed elsewhere. If so, a red notification at startup lists them.
Press `²` then `?` (or right-click the tray icon and choose **"Aide et chemins des raccourcis"**) to open the list of all codes. For every program, file or folder launched by a code, you can see and fix its path. For websites and searches (`N/A`), double-click the row to change the link; a search link must contain `{}` where the searched text goes:

- **State**, with a colour per row: `OK` (green), `N/A` (light green: codes with no path to check, such as websites, searches or text insertion), `KO` (red: target not found) and `Ignoré` (grey). Tick "Afficher seulement les raccourcis cassés" to show only the broken ones, or click the *État* column header to sort. The reason is shown under the list. The window does not stay on top unless you tick "Toujours au premier plan".
- **Parcourir… / Dossier… / Saisir…**: pick another program, another folder, or type a path, a full command line, or (for websites and searches) a link.
- **Tester**: launch the selected shortcut to check it (a search is tried with the word "test").
- **Ignorer / Réactiver**: stop reporting a program you do not have on this PC.
- **Rétablir (défaut)**: go back to the path written in the script.

Your choices apply immediately (no reload) and are saved in `Chemins.ini` next to the script. That file is specific to each PC and is never committed, so you can fix a PC once and copy `Chemins.ini` to another one. The browser used to open web links is the one behind `² c`.

## What it does

**Leader key `²`**, then a short code (a notification confirms the action):

- `² c` Chrome, `² x` Firefox, plus codes for Office apps, Teams, tools, sites (`² ?` lists them all).
- Search the **selected text** on Google (`Ctrl+Space`), YouTube (`Ctrl+Shift+Y`), Maps, Images, Wikipedia, translators, synonyms and definitions (`²` then the code).
- `² hh` / `² dd` insert the current time / date. `² ot` pins the active window on top. `² tt` closes a stuck tooltip (or `Win + click` on it).
- `² + arrows` Play/Pause, Next, Previous media, from any app.

**Windows and mouse**

- `AltGr + left click` drag a window from anywhere inside it; add `Right Ctrl` to resize (the corner nearest the cursor moves).
- Shake the mouse to get a giant cursor.
- `Win + click` on a tooltip closes it.

**Audio output switcher**: hold `Home` or `End` to open a popup listing the active sound outputs, then browse and confirm (`Enter`, or wait a moment). Outputs can be set aside from the list.

**Keyboard tweaks**: `PgUp/PgDn` act as `Home/End`, `Insert` acts as `End`, `F1` acts as `F2` (`Shift+F1` is the real F1), `Win + Right Ctrl` acts as the Menu key, `Ctrl+Shift+Space` types a non-breaking space, and `Ctrl+Shift+C` copies formatting in Office apps.

Everything is configurable at the top of the script (colours, delays, browser, tool locations). Comments and messages are in French.

## Running it next to other scripts

The script accepts a `/embedded` argument that hides its own tray icon, for people who launch it from a manager script. You can ignore this: launched directly, it shows its normal icon.
