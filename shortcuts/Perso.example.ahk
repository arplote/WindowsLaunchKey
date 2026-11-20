; =====================================================================================
;  PERSO.AHK : your personal data (never committed to git: see .gitignore)
;
;  This file is the TEMPLATE. On first launch, WindowsCustomization.ahk copies it to Perso.ahk
;  if that file does not exist yet. Edit Perso.ahk (not this example), then reload the script
;  (tray icon > Reload, or just relaunch it). Delete what you do not need.
;
;  Both functions below are optional: if you remove one, the script simply skips it.
; =====================================================================================


; ---- 1. Text expansion ------------------------------------------------------------
; Type the abbreviation anywhere and it is replaced right away (no end key needed).
; Format:  "abbreviation", "text it expands to"
PersoSnippets() => Map(
    "@@",    "firstname.lastname@example.com",
    "@]",    "my.personal@example.org",
    "@00",   "+33 6 00 00 00 00",
    "@tvb",  "I hope you're doing well",
)


; ---- 2. Personal shortcuts (² then 2-3 letters) -------------------------------------
; Same functions as in the main script. Pick the ones you need:
;
;   AddApp    code, name, program [, folder]      application (Start Menu, alias on the PATH...)
;   AddTool   code, name, program [, folder]      tool with a path or an exe to find
;   AddFile   code, name, path                    open a file or a folder
;   AddUrl    code, name, url                     open a website
;   AddSearch code, name, url_with_{}             search the selected text ({} = the text)
;
; Variables available: Home (your user profile folder), Tools (Home\Documents\Tools), Browser.
; Codes must be unique. Press ² then ? to display the list of every code.
PersoCodes() {
    ; AddUrl "intra", "Company intranet",       "https://intranet.example.com/"
    ; AddUrl "hr",    "HR portal",              "https://hr.example.com/home"
    ; AddFile "doc",  "My reference document",  Home "\Documents\reference.pdf"
    ; AddTool "mytool", "My tool",              Tools "\MyTool\mytool.exe"
    ; AddSearch "wiki", "Internal wiki",        "https://wiki.example.com/search?term={}"
}
