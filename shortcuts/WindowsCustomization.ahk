#Requires AutoHotkey v2.0
#SingleInstance Force

; Lancé par Main.ahk (/embedded) : pas d'icône propre, son menu est accessible depuis l'icône de Main.
for arg in A_Args
    if arg = "/embedded"
        A_IconHidden := true

; Perso.ahk : données personnelles (emails, sites internes...), jamais publiées sur GitHub.
; Au premier lancement, on le crée à partir du modèle Perso.example.ahk puis on se relance pour l'inclure.
if !FileExist(A_ScriptDir "\Perso.ahk") && FileExist(A_ScriptDir "\Perso.example.ahk") {
    FileCopy A_ScriptDir "\Perso.example.ahk", A_ScriptDir "\Perso.ahk"
    Reload
}
#Include *i Perso.ahk

; =====================================================================================
;  CONFIGURATION
; =====================================================================================

Home      := EnvGet("USERPROFILE")
Tools     := Home "\Documents\Tools"
StartMenu := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
Browser   := "C:\Program Files\Google\Chrome\Application\Chrome.exe"
Sublime   := Tools "\SublimeText\sublime_text.exe"
ImageOnTop := Tools "\ImageOnTop\ImageOnTop.exe"

; Chemins corrigés depuis la fenêtre d'aide ( ² puis ? ) : propres à chaque PC,
; ils priment sur ceux écrits dans ce script (voir la section CHEMINS DES RACCOURCIS).
PathsFile := A_ScriptDir "\Chemins.ini"

; Thème sombre commun aux notifications et au popup de sortie audio (couleurs RVB hexadécimales)
UiColorBg     := "202020"
UiColorText   := "FFFFFF"
UiColorDim    := "A0A0A0"
UiColorBorder := "4A4A4A"
UiFontText    := "Segoe UI Variable Text"
UiFontIcons   := "Segoe Fluent Icons"

; Couleur de fond des notifications : succès / information / avertissement / erreur (texte et icône en blanc)
ColorOk    := "1B7F3B"
ColorInfo  := "2C5F9E"
ColorWarn  := "B85C00"
ColorError := "B42318"

; Bordure qui clignote autour d'une fenêtre qu'on épingle / désépingle
PinColor   := "00D000"
UnpinColor := "FF8C00"

; Redimensionnement : par défaut on tire le coin bas-droit. Si le curseur est dans les 25 % de largeur
; ET 25 % de hauteur d'un autre coin de la fenêtre, c'est ce coin-là qui bouge.
CornerZone    := 0.25
MinWindowSize := 150     ; taille minimale (px) en redimensionnant
ZoneColor     := "3399FF"  ; surbrillance des zones de coin (AltGr + Ctrl droit maintenus)
ZoneOpacity   := 80        ; 0 = invisible, 255 = opaque

; Curseur géant quand on secoue la souris (comme sur Mac)
ShakeCursorEnabled := true
CursorScale   := 4       ; facteur d'agrandissement du curseur
ShakeSwing    := 80      ; distance minimale (px) d'un aller ou d'un retour pour compter comme un mouvement de secousse
ShakeSwings   := 5       ; nombre de changements de direction à enchaîner pour déclencher l'effet
ShakeWindow   := 800     ; ... pendant cette durée (ms)
StopDelay     := 150     ; le curseur redevient normal ce délai (ms) après l'arrêt de la souris
ShrinkDelay   := 400     ; ... ou ce délai (ms) après le dernier mouvement de secousse, si la souris continue de bouger
ShakePollMs   := 15      ; fréquence de lecture de la position de la souris

; Sortie audio : Home / Fin parcourent les sorties actives de Windows (voir la section SORTIE AUDIO)
AudioHoldMs        := 400     ; durée (ms) d'appui sur Home / Fin pour ouvrir le popup (évite les appuis par erreur)
AudioCommitDelayMs := 1200    ; la sortie choisie est appliquée ce délai (ms) après le dernier appui (0 = Entrée uniquement)
AudioDoneDelayMs   := 700     ; le popup reste affiché ce délai (ms) après un changement réussi
AudioSortByName    := true    ; true = ordre alphabétique (stable) ; false = ordre donné par Windows
AudioPopupWidth    := 400
AudioRowHeight     := 46
AudioColorRow      := UiColorBg
AudioColorSelected := "383838"
AudioColorAccent   := "60CDFF"
AudioColorError    := "FF6B6B"
AudioExcludedFile  := A_ScriptDir "\WindowsCustomization_AudioMisesDeCote.txt"   ; sorties mises à part (survit aux redémarrages)

; Modèles d'URL de recherche : {} est remplacé par le texte cherché (encodé)
GoogleSearch := "http://www.google.com/search?hl=en&q={}"

; "Ce texte ressemble à une URL" : nom de domaine, adresse IP ou localhost, avec schéma, port et chemin facultatifs
LooksLikeUrl := "i)^(https?://)?(localhost|(\d{1,3}\.){3}\d{1,3}|[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,4})(:\d{1,5})?([/?#]\S*)?$"
; Sans schéma, une IP ou localhost est ouvert en http:// (comme le fait Chrome)
IsLocalAddress := "i)^(localhost|(\d{1,3}\.){3}\d{1,3})(:\d{1,5})?([/?#]|$)"

; Applications Office où Ctrl+Maj+C = Reproduire la mise en forme
GroupAdd "OfficeApps", "ahk_exe EXCEL.EXE"
GroupAdd "OfficeApps", "ahk_exe POWERPNT.EXE"
GroupAdd "OfficeApps", "ahk_exe WINWORD.EXE"
GroupAdd "OfficeApps", "ahk_exe ONENOTE.EXE"

gToasts := []            ; notifications affichées (voir la section NOTIFICATIONS en bas de fichier)
gToastTags := Map()      ; famille de notification -> dernière notification affichée de cette famille
gAudioPopup   := ""      ; popup de sortie audio affiché et en cours de choix (voir la section SORTIE AUDIO)
gAudioClosing := ""      ; popup de sortie audio validé, en train de se refermer
gAudioExcluded := AudioLoadExcluded()   ; identifiant de sortie -> nom, pour les sorties mises à part (ignorées par Home / Fin)


; =====================================================================================
;  CLAVIER : REMAPPAGES SIMPLES
; =====================================================================================

PgUp::Send "{Home}"
PgDn::Send "{End}"
+PgUp::Send "+{Home}"
+PgDn::Send "+{End}"
Insert::Send "{End}"

$F1::Send "{F2}"
$+F1::Send "{F1}"

LWin & RControl::Send "{AppsKey}"

; Caractères spéciaux
+²::Send "{Raw}²"
² & Enter::Send "⮡"
!+e::Send "∃"
!+o::Send "œ"
!+=::Send "≠"
^+Space::Send "{U+00A0}"      ; espace insécable

#HotIf WinActive("ahk_group OfficeApps")
^+c::Send "!{h}{f}{p}"        ; Reproduire la mise en forme
#HotIf


; =====================================================================================
;  TEXTES À EXPANSION AUTOMATIQUE  (taper l'abréviation suffit, sans touche de fin)
;  Pour de l'insertion dynamique (heure, date...) voir les codes ² hh et ² dd plus bas.
;  Les textes sont définis dans Perso.ahk (fonction PersoSnippets).
; =====================================================================================

Snippets := IsSet(PersoSnippets) ? PersoSnippets() : Map()
for abbreviation, text in Snippets
    Hotstring(":*:" abbreviation, ExpandSnippet.Bind(text))

ExpandSnippet(text, *) {
    Send "{Raw}" text
    Send "{RAlt}"             ; relâche AltGr, resté enfoncé après la frappe de "@"
}


; =====================================================================================
;  TOUCHES MULTIMÉDIA
; =====================================================================================

^!+p::MediaKey("{Media_Play_Pause}", "Play/Pause")
² & Down::MediaKey("{Media_Play_Pause}", "Play/Pause")
² & Right::MediaKey("{Media_Next}", "Suivant")
² & Left::MediaKey("{Media_Prev}", "Précédent")

MediaKey(key, label) {
    Send key
    NotifyInfo("Média", label, 0.5)
}


; =====================================================================================
;  DÉPLACER / REDIMENSIONNER UNE FENÊTRE : AltGr + clic gauche (+ Ctrl droit pour redimensionner)
;  Toucher le bord haut d'un écran maximise la fenêtre sur cet écran ; tant que le clic reste enfoncé,
;  s'éloigner du bord la remet en taille normale et on peut continuer à la déplacer.
; =====================================================================================

RAlt & LButton::DragOrResizeWindow()

DragOrResizeWindow() {
    CoordMode "Mouse", "Screen"
    SetWinDelay 0

    ClearResizeZones()                                  ; le clic fait disparaître les zones affichées
    MouseGetPos &startX, &startY, &hwnd
    WinGetPos &winX, &winY, &winW, &winH, hwnd
    VisibleRect(hwnd, &visX, &visY, &visW, &visH)
    resizing := GetKeyState("RCtrl", "P")
    if WinGetMinMax(hwnd) != 0
        WinRestore hwnd

    ; Coin tiré lors d'un redimensionnement : fractions du curseur dans le contour visible de la fenêtre
    ; (0 = bord gauche/haut). Ce sont les mêmes zones que celles affichées par ShowResizeZones.
    fractionX := (startX - visX) / visW
    fractionY := (startY - visY) / visH
    pullLeft := fractionX < CornerZone
    pullRight := fractionX > 1 - CornerZone
    pullTop := fractionY < CornerZone
    pullBottom := fractionY > 1 - CornerZone
    ; Un coin "spécial" demande les deux axes ; sinon on reste sur le coin bas-droit.
    fromLeft := pullLeft && (pullTop || pullBottom)
    fromTop := pullTop && (pullLeft || pullRight)

    maximizedOn := 0       ; écran sur lequel la fenêtre est maximisée pendant le glissement (0 = non)
    while GetKeyState("LButton", "P") {
        MouseGetPos &x, &y
        if resizing {
            dx := x - startX
            dy := y - startY
            newW := Max(fromLeft ? winW - dx : winW + dx, MinWindowSize)
            newH := Max(fromTop ? winH - dy : winH + dy, MinWindowSize)
            newX := fromLeft ? winX + winW - newW : winX      ; le bord opposé reste fixe, même au minimum
            newY := fromTop ? winY + winH - newH : winY
            WinMove newX, newY, newW, newH, hwnd
            continue
        }
        monitor := MonitorAtTopEdge(x, y)
        if monitor {
            if monitor != maximizedOn {                ; bord haut touché : on maximise, mais le clic reste actif
                MaximizeOnMonitor(hwnd, monitor, winX, winY, winW, winH)
                maximizedOn := monitor
            }
            continue
        }
        if maximizedOn {                               ; on a quitté le bord : la fenêtre redevient normale
            WinRestore hwnd
            maximizedOn := 0
        }
        WinMove x - (startX - winX), y - (startY - winY), , , hwnd
    }
}

; Tant qu'on garde AltGr + Ctrl droit enfoncés (sans cliquer), les 3 zones qui permettent de tirer
; les autres coins s'affichent en surbrillance sur la fenêtre sous le curseur (active ou non).
; Le coin bas-droit, lui, est tout le reste de la fenêtre. Un clic fait disparaître les zones.
RAlt & RCtrl::ShowResizeZones()

ResizeZones := []      ; fenêtres de surbrillance actuellement affichées

ShowResizeZones() {
    CoordMode "Mouse", "Screen"
    shownFor := 0
    try {
        while GetKeyState("RAlt", "P") && GetKeyState("RCtrl", "P") && !GetKeyState("LButton", "P") {
            MouseGetPos , , &hwnd
            if hwnd != shownFor && !IsResizeZone(hwnd) {
                ClearResizeZones()
                shownFor := hwnd
                DrawResizeZones(hwnd)
            }
            Sleep 30
        }
    } finally {
        ClearResizeZones()
    }
}

IsResizeZone(hwnd) {
    for zone in ResizeZones
        if zone.Hwnd = hwnd
            return true
    return false
}

DrawResizeZones(hwnd) {
    if InStr("Shell_TrayWnd Shell_SecondaryTrayWnd Progman WorkerW", WinGetClass(hwnd))
        return                                              ; ni la barre des tâches ni le bureau
    VisibleRect(hwnd, &x, &y, &w, &h)
    zoneW := Round(w * CornerZone)
    zoneH := Round(h * CornerZone)

    ; Les zones ne sont PAS "toujours au premier plan" : on les glisse juste au-dessus de la fenêtre visée dans
    ; l'ordre d'empilement, pour que les fenêtres qui sont devant elle les cachent normalement.
    ; Exception : si la fenêtre visée est elle-même épinglée au premier plan, les zones le sont aussi.
    targetIsTopmost := WinGetExStyle(hwnd) & 0x8
    above := DllCall("GetWindow", "Ptr", hwnd, "UInt", 3, "Ptr")            ; 3 = GW_HWNDPREV : la fenêtre juste devant
    if targetIsTopmost
        insertAfter := above ? above : -1                                   ; -1 = HWND_TOPMOST
    else if above && !(WinGetExStyle(above) & 0x8)
        insertAfter := above
    else
        insertAfter := -2                                                   ; -2 = HWND_NOTOPMOST : sous les fenêtres épinglées

    Critical                                                ; non interruptible : un clic ne peut pas effacer les zones à moitié créées
    for corner in [[x, y], [x + w - zoneW, y], [x, y + h - zoneH]] {      ; haut-gauche, haut-droite, bas-gauche
        zone := Gui("-Caption +ToolWindow +E0x20 +E0x08000000")             ; E0x20 : clics traversants
        zone.BackColor := ZoneColor
        zone.Show("Hide x" corner[1] " y" corner[2] " w" zoneW " h" zoneH)
        WinSetTransparent(ZoneOpacity, zone)
        ; Affichage et placement dans l'empilement en un seul appel (0x53 = sans déplacer, redimensionner ni activer, + afficher).
        ; Un Show() séparé remettrait la fenêtre tout en haut.
        DllCall("SetWindowPos", "Ptr", zone.Hwnd, "Ptr", insertAfter, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x53)
        ResizeZones.Push(zone)
    }
    Critical "Off"
}

; Peut être appelée en même temps par le thread qui affiche les zones et par celui du clic : on prend la liste
; d'un coup (opération indivisible) puis on détruit, sans jamais retirer un élément d'une liste partagée.
ClearResizeZones() {
    global ResizeZones
    Critical
    zones := ResizeZones
    ResizeZones := []
    Critical "Off"
    for zone in zones
        zone.Destroy()
}

; Contour visible d'une fenêtre (sans les bordures invisibles que Windows ajoute autour).
VisibleRect(hwnd, &x, &y, &w, &h) {
    rect := Buffer(16)
    if DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rect, "UInt", 16) = 0 {   ; 9 = contour visible
        x := NumGet(rect, 0, "Int"), y := NumGet(rect, 4, "Int")
        w := NumGet(rect, 8, "Int") - x, h := NumGet(rect, 12, "Int") - y
    } else
        WinGetPos &x, &y, &w, &h, hwnd
}

; Indice de l'écran dont le bord supérieur est sous le curseur, 0 sinon.
MonitorAtTopEdge(x, y) {
    loop MonitorGetCount() {
        MonitorGet A_Index, &left, &top, &right
        if y = top && x >= left && x < right
            return A_Index
    }
    return 0
}

; Maximise la fenêtre sur l'écran voulu. Si elle y était déjà au départ, on la remet d'abord
; à sa position initiale pour que "restaurer" la ramène là où elle était.
MaximizeOnMonitor(hwnd, monitor, origX, origY, origW, origH) {
    MonitorGet monitor, &left, &top, &right, &bottom
    centerX := origX + origW // 2
    centerY := origY + origH // 2
    wasOnMonitor := centerX >= left && centerX < right && centerY >= top && centerY < bottom
    if wasOnMonitor
        WinMove origX, origY, , , hwnd
    else
        WinMove left, top, , , hwnd
    WinMaximize hwnd
}


; =====================================================================================
;  RECHERCHE SUR LA SÉLECTION
;  Ctrl+Espace = Google, Ctrl+Maj+Y = YouTube. Sans sélection, il ne se passe rien.
; =====================================================================================

^Space::Guard(() => WithSelection(SearchGoogle, true), "Recherche Google")
^+y::Guard(() => WithSelection(TextActions["y"], true), "Recherche YouTube")

SearchGoogle(text) {
    query := CleanQuery(text)
    if RegExMatch(query, LooksLikeUrl)
        OpenUrl(RegExMatch(query, IsLocalAddress) ? "http://" query : query)
    else
        OpenUrl(StrReplace(GoogleSearch, "{}", UrlEncode(query)))
}

; Copie la sélection et renvoie le texte ("" si rien n'est sélectionné). Le presse-papiers d'origine est restauré.
GetSelection() {
    saved := ClipboardAll()
    A_Clipboard := ""
    BlockInput "On"
    Send "^c"
    BlockInput "Off"
    text := ClipWait(2) ? A_Clipboard : ""
    A_Clipboard := saved
    return text
}

; Appelle action(texte sélectionné). Si rien n'est sélectionné : renvoie false, avec une notification sauf si silent.
WithSelection(action, silent := false) {
    text := GetSelection()
    if text = "" {
        if !silent
            NotifyInfo("Aucune sélection", "Sélectionne du texte puis réessaie", 1.5)
        return false
    }
    action(text)
    return true
}

CleanQuery(text) => Trim(RegExReplace(text, "\R", " "))

UrlEncode(text) {
    size := StrPut(text, "UTF-8")
    bytes := Buffer(size)
    StrPut(text, bytes, "UTF-8")
    encoded := ""
    loop size - 1 {                                   ; -1 : on ignore le NUL final
        byte := NumGet(bytes, A_Index - 1, "UChar")
        char := Chr(byte)
        encoded .= RegExMatch(char, "^[A-Za-z0-9\-._~]$") ? char : "%" Format("{:02X}", byte)
    }
    return encoded
}

OpenUrl(url) => Run('"' Browser '" "' url '"')

; Lance un programme, un fichier ou un dossier. workDir sert à retrouver les programmes
; désignés par leur seul nom (ex. "Excel" dans le menu Démarrer).
RunTarget(target, workDir := "") {
    if FileExist(target)
        target := '"' target '"'
    Run(target, workDir)
}


; =====================================================================================
;  ² puis un code court = lancer une application / un site / une recherche / insérer du texte
;  Ex. : ² puis "ol" ouvre Outlook ; "y" cherche la sélection sur YouTube ; "hh" insère l'heure.
;  ² puis "?" affiche la liste de tous les codes.; =====================================================================================

TypeOrder := ["Application", "Outil", "Fichier / dossier", "Site", "Recherche", "Texte", "Action"]
Verbs := Map("Application", "lancé", "Outil", "lancé", "Fichier / dossier", "ouvert", "Site", "ouvert", "Recherche", "recherche lancée")

Commands    := Map()   ; code -> fonction lancée par ² + code (les recherches utilisent la sélection)
TextActions := Map()   ; code -> fonction(texte) : actions qui ont besoin d'un texte (recherches, ed, op)
CodeInfo    := Map()   ; code -> {type, name, detail}
Checks      := Map()   ; code -> [cible, dossier de travail] : cible lancée par le code ET vérifiée (chemins cassés) ; modifiable
Defaults    := Map()   ; code -> [cible, dossier] tels qu'écrits dans le script (avant Chemins.ini), pour « Rétablir »
Ignored     := Map()   ; code -> true : raccourcis qu'on ne veut plus voir signalés comme cassés (programme absent de ce PC)
Links       := Map()   ; code -> [lien] : adresse d'un site, ou modèle de recherche avec {} ; modifiable comme les chemins
LinkDefaults := Map()  ; code -> lien tel qu'écrit dans le script, pour « Rétablir »
OwnFeedback := Map()   ; codes qui gèrent eux-mêmes leur notification (pas de "lancé" générique)
leaderInput := ""      ; saisie en cours (pour pouvoir l'annuler si on rappuie sur ²)

Register(code, type, name, detail) {
    CodeInfo[code] := {type: type, name: name, detail: detail}
}

; Programmes, fichiers, dossiers
AddProgram(type, code, name, target, workDir := "") {
    Checks[code] := [target, workDir]
    Commands[code] := () => RunTarget(Checks[code][1], Checks[code][2])    ; relu à chaque lancement : un chemin corrigé s'applique tout de suite
    Register(code, type, name, target)
}
AddApp(code, name, target, workDir := "")  => AddProgram("Application", code, name, target, workDir)
AddTool(code, name, target, workDir := "") => AddProgram("Outil", code, name, target, workDir)
AddFile(code, name, target)                => AddProgram("Fichier / dossier", code, name, target)

AddUrl(code, name, url) {
    Links[code] := [url]
    Commands[code] := () => OpenUrl(Links[code][1])                 ; relu à chaque lancement : un lien corrigé s'applique tout de suite
    Register(code, "Site", name, url)
}

; Recherche sur le texte sélectionné
AddSearch(code, name, template) {
    Links[code] := [template]
    TextActions[code] := text => OpenUrl(StrReplace(Links[code][1], "{}", UrlEncode(CleanQuery(text))))
    Commands[code] := () => WithSelection(TextActions[code])
    Register(code, "Recherche", name, template)
}

; Action sur un texte (sélection ou saisie) ; exe = programme à vérifier pour la détection des chemins cassés
AddTextAction(code, name, detail, action, exe := "") {
    TextActions[code] := action
    Commands[code] := () => WithSelection(action)
    if exe != ""
        Checks[code] := [exe, ""]
    Register(code, "Action", name, detail)
}

; Insère du texte dynamique à l'endroit du curseur
AddInsert(code, name, detail, textFn) {
    Commands[code] := () => Send("{Raw}" textFn())
    OwnFeedback[code] := true
    Register(code, "Texte", name, detail)
}

; Action quelconque qui gère elle-même sa notification
AddCustom(code, name, detail, action) {
    Commands[code] := action
    OwnFeedback[code] := true
    Register(code, "Action", name, detail)
}

; --- Applications (bureautique, messagerie) ---
AddApp "ex",  "Excel",                  "Excel", StartMenu
AddApp "wo",  "Word",                   "Word", StartMenu
AddApp "pp",  "PowerPoint",             "PowerPoint", StartMenu
AddApp "on",  "OneNote",                "OneNote", StartMenu
AddApp "ol",  "Outlook",                "Outlook", StartMenu
AddApp "tms", "Teams",                  "ms-teams.exe"                      ; alias du Store, présent dans le PATH

; --- Outils et programmes ---
AddTool "ar",  "Agent Ransack",          Tools "\Agent Ransack\AgentRansack.exe"
AddTool "bs",  "Burp Suite",             "BurpSuite.exe", Home "\AppData\Local\Programs\BurpSuiteCommunity"
AddTool "c",   "Chromium",               "chrome", Tools "\Chromium\chrome-win"
AddTool "hfs", "HFS",                    Tools "\HFS\hfs.exe"
AddTool "mf",  "Firefox",                "firefox.exe"                      ; alias du Store, présent dans le PATH
AddTool "msp", "Paint",                  "mspaint", "C:\WINDOWS\system32\"
AddTool "ocr", "Text-Grab (OCR)",        Tools "\Text-Grab - Local OCR\Text-Grab.exe"
AddTool "ov",  "OpenVPN Connect",        "OpenVPNConnect", "C:\Program Files\OpenVPN Connect\"
AddTool "ps",  "PowerShell",             "powershell", Home
AddTool "st",  "Sublime Text",           Sublime
AddTool "vsc", "Visual Studio Code",     "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
; WindowSpy est un script v2 : on le lance avec l'interpréteur courant, pas avec l'association .ahk (qui pointe vers la v1)
AddTool "ws",  "Window Spy",             '"' A_AhkPath '" "' RegExReplace(A_AhkPath, "[^\\]+$") 'WindowSpy.ahk"'   ; WindowSpy.ahk est dans le dossier de l'interpréteur

; --- Sites web ---
AddUrl "gpt", "ChatGPT",                 "https://chatgpt.com/"
AddUrl "mm",  "Messenger",               "https://www.messenger.com"
AddUrl "owa", "Outlook Web",             "https://outlook.office.com/mail/?actSwt=true"
AddUrl "pg",  "OpenAI Playground",       "https://beta.openai.com/playground"

; --- Recherches ---
AddSearch "y",   "YouTube",              "https://www.youtube.com/results?search_query={}"
AddSearch "im",  "Google Images",        "https://www.google.com/search?q={}&tbm=isch"
AddSearch "map", "Google Maps",          "https://www.google.fr/maps/search/{}"
AddSearch "we",  "Wikipédia EN",         "https://www.wikiwand.com/en/{}"
AddSearch "wf",  "Wikipédia FR",         "https://www.wikiwand.com/fr/{}"
AddSearch "ef",  "Traduction EN > FR (WordReference)", "http://www.wordreference.com/enfr/{}"
AddSearch "fe",  "Traduction FR > EN (WordReference)", "http://www.wordreference.com/fren/{}"
AddSearch "ee",  "Google Traduction > anglais", "https://translate.google.fr/#auto/en/{}"
AddSearch "ff",  "Google Traduction > français", "https://translate.google.fr/#auto/fr/{}"
AddSearch "syn", "Synonymes",            "https://www.synonymo.fr/synonyme/{}"
AddSearch "def", "Définition (Linternaute)", "http://www.linternaute.com/dictionnaire/fr/definition/{}"

; --- Actions sur un texte (sélection ou saisie) ---
AddTextAction "ed", "Éditer un fichier (Sublime)", "Le texte est le chemin du fichier", text => Run('"' Checks["ed"][1] '" "' text '"'), Sublime
AddTextAction "op", "Ouvrir une image (ImageOnTop)", "Le texte est le chemin de l'image", text => Run('"' Checks["op"][1] '" "' text '"'), ImageOnTop

; --- Insertion de texte dynamique ---
AddInsert "hh", "Insérer l'heure", "Heure actuelle, format hh:mm:ss", () => FormatTime(, "HH:mm:ss")
AddInsert "dd", "Insérer la date",  "Date du jour, format jj/mm/aa",   () => FormatTime(, "dd/MM/yy")

; --- Autres actions ---
AddCustom "ot", "Épingler / désépingler la fenêtre", "Fenêtre active toujours au premier plan (bordure verte / orange)", ToggleAlwaysOnTop
AddCustom "tt", "Fermer une tooltip bloquée",        "Puis clic sur la bulle : la ferme et indique l'application d'origine (aussi : Win + clic)", ArmTooltipCloser
AddCustom "?",  "Aide des codes",                   "Affiche cette liste, avec l'état et le chemin des programmes (modifiables)", ToggleHelp

; --- Codes personnels (Perso.ahk) ---
if IsSet(PersoCodes)
    PersoCodes()

; --- Chrome via ² + c, Firefox via ² + x ---
Checks["² c"] := [Browser, ""]
Checks["² x"] := ["firefox.exe", ""]
² & c::Guard(() => Run(Checks["² c"][1]), "Chrome")
² & x::Guard(() => Run(Checks["² x"][1]), "Firefox")

; Tous les codes sont enregistrés : on applique maintenant les chemins corrigés (Chemins.ini)
ApplyPathOverrides()

²:: {
    global leaderInput
    if leaderInput
        leaderInput.Stop()                            ; une nouvelle saisie remplace la précédente
    NotifyInfo("²", "en écoute", 0.3, "leader")

    codes := ""
    for code in Commands
        codes .= (codes = "" ? "" : ",") code

    leaderInput := InputHook("T2 L3 C", "{Enter}.{Esc}{Tab}{NumLock}", codes)
    leaderInput.OnEnd := RunLeaderCommand
    leaderInput.Start()
}

RunLeaderCommand(input) {
    if input.EndReason = "Stopped"                    ; remplacée par une nouvelle saisie : rien à faire
        return
    if input.EndReason != "Match" {                   ; trop long, délai dépassé ou touche de fin
        if input.EndReason = "Max"
            NotifyError("Annulé", "code inconnu : " input.Input, 1.2, "leader")       ; rouge : le code n'existe pas
        else
            NotifyWarn("Annulé", input.EndReason = "Timeout" ? "délai dépassé" : "touche " input.EndKey, 1.2, "leader")   ; orange
        return
    }
    RunCode(input.Match, Commands[input.Match])
}

; Exécute un code (depuis ²) avec gestion d'erreur et notification de succès.
RunCode(code, action) {
    if !Guard(action, "² " code) || OwnFeedback.Has(code)
        return
    info := CodeInfo[code]
    NotifyOk(info.name, Verbs.Get(info.type, "OK"), 1, "leader")
}

; Exécute action(). En cas d'erreur (fichier introuvable...), affiche une notification rouge au lieu d'une
; boîte d'erreur bloquante. Renvoie true si tout s'est bien passé (false si erreur, ou si action() renvoie 0/false).
Guard(action, label := "") {
    try {
        result := action()
    } catch as err {
        detail := err.Extra != "" ? err.Extra : StrSplit(err.Message, "`n")[1]
        if RegExMatch(err.Message, "Action: <(.*?)>", &found)
            detail .= "`n" found[1]
        NotifyError("Erreur" (label != "" ? " : " label : ""), detail)
        return false
    }
    return result != 0
}


; =====================================================================================
;  ÉPINGLER UNE FENÊTRE  (² puis "ot") : bordure verte quand on épingle, orange quand on désépingle
; =====================================================================================

ToggleAlwaysOnTop() {
    hwnd := WinExist("A")
    if !hwnd
        return
    WinSetAlwaysOnTop -1, hwnd
    pinned := WinGetExStyle(hwnd) & 0x8                ; 0x8 = WS_EX_TOPMOST
    title := SubStr(WinGetTitle(hwnd), 1, 45)
    if pinned
        NotifyOk("Épinglée", title, 0.6)
    else
        NotifyInfo("Désépinglée", title, 0.6)
    FlashBorder(hwnd, pinned ? PinColor : UnpinColor)
}

; Cadre coloré qui apparaît brièvement autour d'une fenêtre (4 fines bandes qui laissent passer les clics).
FlashBorder(hwnd, color, milliseconds := 300, thickness := 3) {
    VisibleRect(hwnd, &x, &y, &w, &h)
    bands := [[x, y, w, thickness], [x, y + h - thickness, w, thickness], [x, y, thickness, h], [x + w - thickness, y, thickness, h]]
    frames := []
    for band in bands {
        frame := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20 +E0x08000000")   ; E0x20 : clics traversants
        frame.BackColor := color
        frame.Show("NA x" band[1] " y" band[2] " w" band[3] " h" band[4])
        frames.Push(frame)
    }
    SetTimer(removeFrames, -milliseconds)

    removeFrames(*) {
        for frame in frames
            frame.Destroy()
    }
}


; =====================================================================================
;  CURSEUR GÉANT QUAND ON SECOUE LA SOURIS
;  Un timer lit la position de la souris et compte, sur chaque axe, les allers-retours d'au moins ShakeSwing px.
;  À ShakeSwings changements de direction en ShakeWindow ms, les curseurs système sont remplacés par des copies
;  agrandies ; ils reviennent à la normale peu après la fin de la secousse (et à la fermeture du script).
; =====================================================================================

; Curseurs agrandis : id du curseur système -> forme redessinée en grand (nette), ou "scaled" = curseur d'origine zoomé (un peu flou).
; Flèche, texte (I), main, redimensionnement. Les autres (sablier, croix...) restent à leur taille normale.
; Le I du texte est en "scaled" pour le moment ; remplacer par "ibeam" pour utiliser la version redessinée (déjà codée).
ShakeCursors   := Map(32512, "arrow", 32513, "scaled", 32649, "hand", 32642, "nwse", 32643, "nesw", 32644, "we", 32645, "ns")
gCursorMasters := Map()                                ; id -> curseur dessiné (créé au premier besoin, puis réutilisé)
ShakeItem      := "Curseur géant en secouant la souris"
gCursorBig     := false
gLastShake     := 0
gLastMove      := 0
gMouseX        := 0
gMouseY        := 0
gShakeX        := {dir: 0, anchor: "", swings: []}     ; état du suivi sur chaque axe
gShakeY        := {dir: 0, anchor: "", swings: []}

OnExit(ShakeCursorExit)
RestoreCursors()                                       ; au cas où une session précédente aurait planté avec un curseur géant

ShakeCursorExit(*) {
    RestoreCursors()
}

ApplyShakeCursor() {
    if ShakeCursorEnabled {
        SetTimer ShakeTick, ShakePollMs
    } else {
        SetTimer ShakeTick, 0
        if gCursorBig
            SetBigCursor(false)
    }
}

ToggleShakeCursor(itemName, *) {
    global ShakeCursorEnabled
    ShakeCursorEnabled := !ShakeCursorEnabled
    ApplyShakeCursor()
    A_TrayMenu.ToggleCheck(itemName)
    if ShakeCursorEnabled
        NotifyOk(itemName, "activé")
    else
        NotifyInfo(itemName, "désactivé")
}

ShakeTick() {
    global gLastShake, gLastMove, gMouseX, gMouseY
    CoordMode "Mouse", "Screen"
    MouseGetPos &x, &y
    now := A_TickCount
    if x != gMouseX || y != gMouseY {
        gMouseX := x, gMouseY := y
        gLastMove := now
    }
    swings := Max(TrackSwings(gShakeX, x, now), TrackSwings(gShakeY, y, now))
    if swings >= ShakeSwings {
        gLastShake := Max(LastSwing(gShakeX), LastSwing(gShakeY))   ; tant que ça secoue, le curseur reste grand
        if !gCursorBig
            SetBigCursor(true)
    }
    if gCursorBig && (now - gLastMove > StopDelay || now - gLastShake > ShrinkDelay) {
        SetBigCursor(false)
        gShakeX.swings := [], gShakeY.swings := []     ; sinon la secousse déjà comptée le ferait regrossir aussitôt
    }
}

LastSwing(axis) => axis.swings.Length ? axis.swings[axis.swings.Length] : 0

; Met à jour le suivi d'un axe et renvoie le nombre de changements de direction récents.
TrackSwings(axis, pos, now) {
    if axis.anchor = ""
        axis.anchor := pos
    delta := pos - axis.anchor                         ; écart depuis l'extrémité du mouvement en cours
    if axis.dir = 0 {
        if Abs(delta) >= ShakeSwing {
            axis.dir := delta > 0 ? 1 : -1
            axis.anchor := pos
        }
    } else if delta * axis.dir > 0 {                   ; la souris continue dans le même sens
        axis.anchor := pos
    } else if Abs(delta) >= ShakeSwing {               ; retour assez grand : changement de direction
        axis.dir := -axis.dir
        axis.anchor := pos
        axis.swings.Push(now)
    }
    while axis.swings.Length && now - axis.swings[1] > ShakeWindow
        axis.swings.RemoveAt(1)
    return axis.swings.Length
}

SetBigCursor(big) {
    global gCursorBig
    gCursorBig := big
    if !big {
        RestoreCursors()
        return
    }
    size := DllCall("GetSystemMetrics", "Int", 13) * CursorScale        ; 13 = SM_CXCURSOR (32 px à 100 %)
    for id, kind in ShakeCursors {
        if !gCursorMasters.Has(id)
            gCursorMasters[id] := kind = "scaled" ? ScaledCursor(id, size) : MakeCursor(kind, size)
        ; SetSystemCursor détruit le curseur qu'on lui donne : on lui passe une copie, pour garder l'original
        copy := DllCall("CopyIcon", "Ptr", gCursorMasters[id], "Ptr")
        if copy
            DllCall("SetSystemCursor", "Ptr", copy, "UInt", id)
    }
}

; Curseur système d'origine zoomé à la taille voulue (le point de clic est mis à l'échelle)
ScaledCursor(id, size) {
    normal := DllCall("LoadCursor", "Ptr", 0, "Ptr", id, "Ptr")
    return DllCall("CopyImage", "Ptr", normal, "UInt", 2, "Int", size, "Int", size, "UInt", 0, "Ptr")     ; 2 = IMAGE_CURSOR
}

; Transforme le dessin en vrai curseur Windows (avec son point de clic). Structure ICONINFO en 64 bits.
MakeCursor(kind, size) {
    bitmap := DrawCursor(kind, size, &hotX, &hotY)
    icon := 0
    DllCall("gdiplus\GdipCreateHICONFromBitmap", "Ptr", bitmap, "Ptr*", &icon)
    info := Buffer(32, 0)
    DllCall("GetIconInfo", "Ptr", icon, "Ptr", info)
    NumPut("UInt", 0, info, 0)                         ; fIcon = faux : c'est un curseur
    NumPut("UInt", hotX, info, 4)
    NumPut("UInt", hotY, info, 8)
    cursor := DllCall("CreateIconIndirect", "Ptr", info, "Ptr")
    DllCall("DeleteObject", "Ptr", NumGet(info, 16, "Ptr"))     ; masque et couleur copiés par CreateIconIndirect
    DllCall("DeleteObject", "Ptr", NumGet(info, 24, "Ptr"))
    DllCall("DestroyIcon", "Ptr", icon)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", bitmap)
    return cursor
}

; Démarre GDI+ (une seule fois)
GdipStart() {
    static token := 0
    if token
        return
    input := Buffer(24, 0)
    NumPut("UInt", 1, input)                           ; GdiplusVersion = 1
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", input, "Ptr", 0)
}

; Contour d'un polygone : points = [x1, y1, x2, y2, ...] (unités d'une grille de 32)
PolygonPath(points) {
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    buf := Buffer(points.Length * 4)
    for i, value in points
        NumPut("Float", value, buf, (i - 1) * 4)
    DllCall("gdiplus\GdipAddPathPolygon", "Ptr", path, "Ptr", buf, "Int", points.Length // 2)
    return path
}

; Main au doigt levé (grille de 32) : 1er tracé = silhouette extérieure, 2e = intérieur (avec la séparation des doigts)
HandSvg := "M 13 2 C 11.355469 2 10 3.355469 10 5 L 10 16.8125 L 9.34375 16.125 L 9.09375 15.90625 C 7.941406 14.753906 6.058594 14.753906 4.90625 15.90625 C 3.753906 17.058594 3.753906 18.941406 4.90625 20.09375 L 4.90625 20.125 L 13.09375 28.21875 L 13.15625 28.25 L 13.1875 28.3125 C 14.535156 29.324219 16.253906 30 18.1875 30 L 19.90625 30 C 24.441406 30 28.09375 26.347656 28.09375 21.8125 L 28.09375 14 C 28.09375 12.355469 26.738281 11 25.09375 11 C 24.667969 11 24.273438 11.117188 23.90625 11.28125 C 23.578125 9.980469 22.394531 9 21 9 C 20.234375 9 19.53125 9.300781 19 9.78125 C 18.46875 9.300781 17.765625 9 17 9 C 16.648438 9 16.316406 9.074219 16 9.1875 L 16 5 C 16 3.355469 14.644531 2 13 2 Z"
    . " M 13 4 C 13.554688 4 14 4.445313 14 5 L 14 16 L 16 16 L 16 12 C 16 11.445313 16.445313 11 17 11 C 17.554688 11 18 11.445313 18 12 L 18 16 L 20 16 L 20 12 C 20 11.445313 20.445313 11 21 11 C 21.554688 11 22 11.445313 22 12 L 22 16 L 24.09375 16 L 24.09375 14 C 24.09375 13.445313 24.539063 13 25.09375 13 C 25.648438 13 26.09375 13.445313 26.09375 14 L 26.09375 21.8125 C 26.09375 25.277344 23.371094 28 19.90625 28 L 18.1875 28 C 16.722656 28 15.457031 27.476563 14.40625 26.6875 L 6.3125 18.6875 C 5.867188 18.242188 5.867188 17.757813 6.3125 17.3125 C 6.757813 16.867188 7.242188 16.867188 7.6875 17.3125 L 12 21.625 L 12 5 C 12 4.445313 12.445313 4 13 4 Z"

; Convertit un tracé SVG (commandes M, L, C, Z en coordonnées absolues) en une liste de contours GDI+, un par "M ... Z"
SvgSubpaths(d) {
    paths := []
    path := 0
    x := 0, y := 0
    pos := 1
    while RegExMatch(d, "([MLCZ])([^MLCZ]*)", &command, pos) {
        pos := command.Pos + command.Len
        nums := []
        numberPos := 1
        while RegExMatch(command[2], "-?[\d.]+", &number, numberPos) {
            nums.Push(Float(number[0]))
            numberPos := number.Pos + number.Len
        }
        switch command[1] {
            case "M":
                path := 0
                DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
                paths.Push(path)
                x := nums[1], y := nums[2]
            case "L":
                loop nums.Length // 2 {
                    nx := nums[A_Index * 2 - 1], ny := nums[A_Index * 2]
                    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x, "Float", y, "Float", nx, "Float", ny)
                    x := nx, y := ny
                }
            case "C":
                loop nums.Length // 6 {
                    i := (A_Index - 1) * 6
                    DllCall("gdiplus\GdipAddPathBezier", "Ptr", path, "Float", x, "Float", y, "Float", nums[i + 1], "Float", nums[i + 2]
                        , "Float", nums[i + 3], "Float", nums[i + 4], "Float", nums[i + 5], "Float", nums[i + 6])
                    x := nums[i + 5], y := nums[i + 6]
                }
            case "Z":
                DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
        }
    }
    return paths
}

; Rectangle à coins arrondis
RoundRectPath(x, y, w, h, r) {
    path := 0
    d := r * 2
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    for corner in [[x, y, 180], [x + w - d, y, 270], [x + w - d, y + h - d, 0], [x, y + h - d, 90]]
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", corner[1], "Float", corner[2], "Float", d, "Float", d, "Float", corner[3], "Float", 90)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    return path
}

; Dessine un curseur net de size x size px (grille de 32 unités). Renvoie le bitmap GDI+ et le point de clic en pixels.
; kind : "arrow", "ibeam", "hand", "we" (gauche-droite), "ns" (haut-bas), "nwse", "nesw"
DrawCursor(kind, size, &hotX, &hotY) {
    GdipStart()
    bitmap := 0, g := 0, pen := 0, fill := 0, detail := 0, brush := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", size, "Int", size, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bitmap)   ; 32 bits ARGB
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap, "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)           ; anticrénelage
    unit := size / 32
    DllCall("gdiplus\GdipScaleWorldTransform", "Ptr", g, "Float", unit, "Float", unit, "Int", 0)

    solids := []                                       ; formes pleines peintes en dernier : [contour, couleur]
    lines := []                                        ; détails intérieurs : [x1, y1, x2, y2, couleur]
    outline := 2.6                                     ; épaisseur du trait noir (la moitié intérieure est recouverte par le blanc)
    join := 2                                          ; jointure des angles du contour : 2 = arrondie, 0 = vive
    hot := [16, 16]
    angle := 0
    switch kind {
        case "arrow":
            ; Pointe fine (40°) et coins vifs (jointure en onglet) ; le point de clic est tout au bout du contour noir :
            ; sommet - épaisseur du trait / sin(demi-angle) le long de la bissectrice
            shapes := [PolygonPath([2.6, 4, 2.6, 23.8, 6.9, 19.8, 10.2, 27.2, 13.9, 25.6, 10.9, 18.75, 15.05, 18.75])]
            join := 0
            hot := [1.3, 0.45]
        case "ibeam":
            shapes := [RoundRectPath(10, 4, 12, 3, 1), RoundRectPath(14.4, 5, 3.2, 22, 1), RoundRectPath(10, 25, 12, 3, 1)]
        case "hand":                                   ; main au doigt levé : tracé SVG (extérieur noir, intérieur blanc)
            shapes := []
            for contour in SvgSubpaths(HandSvg)
                solids.Push([contour, solids.Length ? 0xFFFFFFFF : 0xFF000000])
            hot := [13, 2]
        default:                                       ; flèche à deux têtes, tournée selon l'orientation
            shapes := [PolygonPath([3, 16, 9.5, 9.5, 9.5, 13.5, 22.5, 13.5, 22.5, 9.5, 29, 16, 22.5, 22.5, 22.5, 18.5, 9.5, 18.5, 9.5, 22.5])]
            angle := Map("we", 0, "nwse", 45, "ns", 90, "nesw", -45)[kind]
    }
    if angle {                                         ; rotation autour du centre (16, 16)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", 16, "Float", 16, "Int", 0)
        DllCall("gdiplus\GdipRotateWorldTransform", "Ptr", g, "Float", angle, "Int", 0)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", -16, "Float", -16, "Int", 0)
    }

    DllCall("gdiplus\GdipCreatePen1", "UInt", 0xFF000000, "Float", outline, "Int", 0, "Ptr*", &pen)
    DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", join)
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0xFFFFFFFF, "Ptr*", &fill)
    for path in shapes                                 ; d'abord tous les contours épais, puis tous les remplissages blancs :
        DllCall("gdiplus\GdipDrawPath", "Ptr", g, "Ptr", pen, "Ptr", path)    ; seul le tour de l'ensemble reste noir
    for path in shapes
        DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", fill, "Ptr", path)
    for line in lines {
        DllCall("gdiplus\GdipCreatePen1", "UInt", line[5], "Float", 0.9, "Int", 0, "Ptr*", &detail)
        DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", detail, "Float", line[1], "Float", line[2], "Float", line[3], "Float", line[4])
        DllCall("gdiplus\GdipDeletePen", "Ptr", detail)
    }
    for solid in solids {
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", solid[2], "Ptr*", &brush)
        DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", solid[1])
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
        DllCall("gdiplus\GdipDeletePath", "Ptr", solid[1])
    }

    for path in shapes
        DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", fill)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    hotX := Round(hot[1] * unit)
    hotY := Round(hot[2] * unit)
    return bitmap
}

; Recharge les curseurs de l'utilisateur depuis le registre (SPI_SETCURSORS)
RestoreCursors() {
    DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
}


; =====================================================================================
;  AIDE (² puis "?") : LISTE DES CODES, ÉTAT ET CHEMINS DES PROGRAMMES
; =====================================================================================

HelpGui := ""

; Codes triés par type (dans l'ordre de TypeOrder) puis par code
SortedCodes() {
    lines := ""
    for code, info in CodeInfo {
        index := 99
        for i, type in TypeOrder
            if type = info.type
                index := i
        lines .= Format("{:02}|{}`n", index, code)
    }
    codes := []
    for line in StrSplit(Sort(RTrim(lines, "`n")), "`n")
        codes.Push(StrSplit(line, "|", , 2)[2])
    return codes
}

; Ouvre la fenêtre d'aide (voir ShowHelp, section CHEMINS DES RACCOURCIS) ; la ferme si elle est déjà ouverte
ToggleHelp() {
    if HelpGui
        CloseHelp()
    else
        ShowHelp()
}

CloseHelp(*) {
    global HelpGui
    HelpGui.Destroy()
    HelpGui := ""
}

; Liste des [code, nom, problème] dont la cible est introuvable
FindBrokenTargets() {
    broken := []
    for code, check in Checks {
        if Ignored.Has(code)
            continue
        problem := CheckTarget(check[1], check[2])
        if problem != ""
            broken.Push([code, CodeInfo.Has(code) ? CodeInfo[code].name : code, problem])
    }
    return broken
}

; Renvoie "" si la cible semble lancable, sinon la description du problème.
CheckTarget(target, workDir) {
    if workDir != "" && !DirExist(workDir)
        return "Dossier introuvable : " workDir
    path := target
    if SubStr(path, 1, 1) = '"' && RegExMatch(path, '^"([^"]+)"', &quoted)     ; ligne de commande : on teste le programme
        path := quoted[1]
    if FileExist(path)
        return ""
    if InStr(path, "\")
        return "Fichier introuvable : " path
    ; Simple nom de programme : dossier de travail, PATH (alias du Store compris), ou "App Paths" de Windows
    if workDir != "" {
        for extension in ["", ".exe", ".lnk", ".bat", ".cmd"]
            if FileExist(RTrim(workDir, "\") "\" path extension)
                return ""
    }
    found := Buffer(520)
    if DllCall("SearchPathW", "Ptr", 0, "Str", path, "Str", ".exe", "UInt", 260, "Ptr", found, "Ptr", 0, "UInt") > 0
        return ""
    for root in ["HKLM", "HKCU"] {
        try {
            RegRead root "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" path ".exe"
            return ""
        }
    }
    return "Introuvable : " path (workDir != "" ? "  (dans " workDir ")" : "")
}


; =====================================================================================
;  CHEMINS DES RACCOURCIS : voir l'état de chaque programme / fichier / dossier lancé par un code, et le corriger
;  Les corrections sont écrites dans Chemins.ini (à côté du script, propre à ce PC). Elles priment sur les chemins
;  du script et s'appliquent tout de suite, sans recharger.
; =====================================================================================

ExtraNames := Map("² c", "Chrome (² + c)", "² x", "Firefox (² + x)")   ; raccourcis qui ne sont pas des codes de la liste ² ?

; Les valeurs sont écrites entre < > : IniRead retirerait sinon les guillemets qui entourent toute la valeur.
; Chemins.ini est créé en Unicode (UTF-16) pour garder tels quels les accents et le « ² ».
PathIniRead(section, key) {
    value := IniRead(PathsFile, section, key, "")
    return (SubStr(value, 1, 1) = "<" && SubStr(value, -1) = ">") ? SubStr(value, 2, -1) : value
}

PathIniWrite(section, key, value) {
    if !FileExist(PathsFile)
        FileAppend "[Chemins]`n[Ignores]`n", PathsFile, "UTF-16"
    IniWrite "<" value ">", PathsFile, section, key
}

PathIniDelete(section, key) {
    try IniDelete PathsFile, section, key
}

; Appelée une fois, quand tous les codes sont enregistrés
ApplyPathOverrides() {
    global Browser
    for code, check in Checks
        Defaults[code] := [check[1], check[2]]
    for code, check in Checks {
        value := PathIniRead("Chemins", code)
        if value != "" {
            check[1] := value
            check[2] := ""             ; le dossier de travail ne sert qu'à retrouver un programme désigné par son seul nom
        }
        if PathIniRead("Ignores", code) = "1"
            Ignored[code] := true
    }
    Browser := Checks["² c"][1]        ; tous les liens web passent par ce navigateur
    for code, link in Links {          ; adresses des sites et modèles de recherche
        LinkDefaults[code] := link[1]
        value := PathIniRead("Liens", code)
        if value != "" {
            link[1] := value
            CodeInfo[code].detail := value
        }
    }
}

SetLink(code, value) {
    Links[code][1] := value
    CodeInfo[code].detail := value
    PathIniWrite("Liens", code, value)
}

ResetLink(code) {
    Links[code][1] := LinkDefaults[code]
    CodeInfo[code].detail := LinkDefaults[code]
    PathIniDelete("Liens", code)
}

SetTarget(code, target) {
    global Browser
    Checks[code][1] := target
    Checks[code][2] := ""
    PathIniWrite("Chemins", code, target)
    if code = "² c"
        Browser := target
}

ResetTarget(code) {
    global Browser
    Checks[code][1] := Defaults[code][1]
    Checks[code][2] := Defaults[code][2]
    PathIniDelete("Chemins", code)
    if code = "² c"
        Browser := Checks[code][1]
}

ToggleIgnored(code) {
    if Ignored.Has(code) {
        Ignored.Delete(code)
        PathIniDelete("Ignores", code)
    } else {
        Ignored[code] := true
        PathIniWrite("Ignores", code, "1")
    }
}

; Chemin ou lien différent de celui du script ? (les liens sont comparés en respectant la casse)
IsModified(code) {
    if Defaults.Has(code)
        return Checks[code][1] != Defaults[code][1] || Checks[code][2] != Defaults[code][2]
    return LinkDefaults.Has(code) && Links[code][1] !== LinkDefaults[code]
}

; Lignes de la fenêtre : tous les codes de la liste ² ? (par type puis par code). Ceux qui lancent un programme, un fichier
; ou un dossier ont en plus un état OK / KO / Ignoré et un chemin modifiable.
PathRows(onlyBroken := false) {
    codes := SortedCodes()
    for code in Checks
        if !CodeInfo.Has(code)
            codes.Push(code)
    rows := []
    for code in codes {
        info := CodeInfo.Has(code) ? CodeInfo[code] : {type: "Application", name: ExtraNames.Get(code, code), detail: ""}
        hasPath := Checks.Has(code)
        hasLink := Links.Has(code)
        problem := "", state := "", path := hasLink ? Links[code][1] : info.detail
        if hasPath {
            check := Checks[code]
            path := check[1]
            problem := CheckTarget(check[1], check[2])
            state := Ignored.Has(code) ? "Ignoré" : (problem = "" ? "OK" : "KO")
        }
        if onlyBroken && state != "KO"
            continue
        rows.Push({code: code, state: state, type: info.type, name: info.name, path: path, problem: problem, hasPath: hasPath, hasLink: hasLink, modified: IsModified(code)})
    }
    return rows
}

; Fenêtre d'aide ( ² puis ? ) : liste de tous les codes, avec l'état et le chemin des programmes, que l'on peut corriger.
ShowHelp(onlyBroken := false) {
    global HelpGui, HelpList, HelpOnlyBroken, HelpProblem, HelpRows, HelpButtons
    HelpGui := Gui("+ToolWindow +OwnDialogs", "Raccourcis ²")      ; pas au premier plan par défaut (case à cocher ci-dessous) ; OwnDialogs : sélecteurs de fichier au-dessus
    HelpGui.SetFont("s10")
    HelpOnlyBroken := HelpGui.Add("Checkbox", "w420 Checked" onlyBroken, "Afficher seulement les raccourcis cassés")   ; largeur fixe : le libellé reçoit un compteur
    HelpOnlyBroken.OnEvent("Click", (*) => RefreshPaths())
    HelpGui.Add("Checkbox", "x+20 yp w260", "Toujours au premier plan").OnEvent("Click", (box, *) => HelpGui.Opt((box.Value ? "+" : "-") "AlwaysOnTop"))
    HelpList := HelpGui.Add("ListView", "xm r26 w1000 -Multi", ["État", "Code", "Type", "Nom", "Détail / chemin", "Modifié"])
    HelpList.OnNotify(-12, HelpListDraw)                                              ; NM_CUSTOMDRAW : couleur de fond des lignes selon l'état
    HelpList.OnEvent("DoubleClick", (*) => PathBrowse())
    HelpList.OnEvent("ItemSelect", (*) => ShowPathProblem())
    HelpList.OnEvent("ColClick", (list, column) => list.ModifyCol(column, "Sort"))      ; clic sur un titre : tri (ex. État)
    HelpProblem := HelpGui.Add("Text", "w1000 h40", "")
    HelpButtons := []
    HelpButtons.Push(HelpGui.Add("Button", "Section w120", "Parcourir…"))
    HelpButtons.Push(HelpGui.Add("Button", "ys w120", "Dossier…"))
    HelpButtons.Push(HelpGui.Add("Button", "ys w120", "Saisir…"))
    HelpButtons.Push(HelpGui.Add("Button", "ys w100", "Tester"))
    HelpButtons.Push(HelpGui.Add("Button", "ys w150", "Ignorer / Réactiver"))
    HelpButtons.Push(HelpGui.Add("Button", "ys w150", "Rétablir (défaut)"))
    HelpButtons[1].OnEvent("Click", (*) => PathBrowse())
    HelpButtons[2].OnEvent("Click", (*) => PathBrowse(true))
    HelpButtons[3].OnEvent("Click", (*) => PathInput())
    HelpButtons[4].OnEvent("Click", (*) => PathTest())
    HelpButtons[5].OnEvent("Click", (*) => PathToggleIgnored())
    HelpButtons[6].OnEvent("Click", (*) => PathReset())
    HelpGui.Add("Button", "ys w100 Default", "Fermer").OnEvent("Click", CloseHelp)
    HelpGui.Add("Text", "xs", "Aussi : ² + c (Chrome), ² + x (Firefox), ² + flèches (média), ² + Entrée (⮡).   Échap pour fermer.")
    HelpGui.Add("Text", , "Double-clic : changer le chemin d'un programme, ou le lien d'un site ou d'une recherche. Les corrections sont propres à ce PC (Chemins.ini).")
    HelpGui.OnEvent("Close", CloseHelp)
    HelpGui.OnEvent("Escape", CloseHelp)
    RefreshPaths()
    HelpGui.Show()
}

; Couleur de fond des lignes selon la colonne État (COLORREF : 0xBBGGRR) : vert = OK, vert plus clair = N/A, rouge clair = KO, gris = ignoré
StateColors := Map("OK", 0xCEEFC6, "N/A", 0xECF7E8, "KO", 0xCEC7FF, "Ignoré", 0xE6E6E6)

; Dessin personnalisé de la liste : un ListView n'a pas de couleur de ligne native. Les décalages dépendent de la taille
; des pointeurs (structure NMLVCUSTOMDRAW).
HelpListDraw(list, lParam) {
    stage := NumGet(lParam, 3 * A_PtrSize, "UInt")
    if stage = 0x1                                       ; CDDS_PREPAINT : demander une notification pour chaque ligne
        return 0x20                                      ; CDRF_NOTIFYITEMDRAW
    if stage = 0x10001 {                                 ; CDDS_ITEMPREPAINT : avant le dessin d'une ligne
        row := NumGet(lParam, 5 * A_PtrSize + 16, "UPtr") + 1
        state := list.GetText(row, 1)
        if StateColors.Has(state) {
            NumPut("UInt", StateColors[state], lParam, 8 * A_PtrSize + 20)      ; clrTextBk
            return 0x2                                   ; CDRF_NEWFONT : applique les couleurs
        }
    }
    return 0
}

; Remplit la liste ; reselectCode : ligne à garder sélectionnée
RefreshPaths(reselectCode := "") {
    global HelpRows
    if reselectCode = ""
        reselectCode := SelectedPathCode()
    HelpRows := PathRows(HelpOnlyBroken.Value)
    HelpOnlyBroken.Text := "Afficher seulement les raccourcis cassés (" FindBrokenTargets().Length ")"
    HelpList.Opt("-Redraw")
    HelpList.Delete()
    for row in HelpRows {
        index := HelpList.Add("", row.hasPath ? row.state : "N/A", row.code, row.type, row.name, row.path, row.modified ? "oui" : "")   ; N/A : pas de chemin à vérifier (site, recherche...)
        if row.code = reselectCode
            HelpList.Modify(index, "Select Focus Vis")
    }
    HelpList.ModifyCol(1, 55)
    HelpList.ModifyCol(2, 50)
    HelpList.ModifyCol(3, 125)
    HelpList.ModifyCol(4, 200)
    HelpList.ModifyCol(5, 485)
    HelpList.ModifyCol(6, 60)
    HelpList.Opt("+Redraw")
    SetTimer(RepaintHelpList, -40)
    ShowPathProblem()
}

; Les couleurs passent par la notification de dessin (HelpListDraw), ignorée quand la fenêtre s'ouvre depuis ² (le code est lancé
; par un évènement InputHook, dans un thread encore non interruptible) : les lignes restaient blanches jusqu'au premier
; défilement. On demande donc un second dessin, dès que ce thread est terminé.
RepaintHelpList() {
    if HelpGui
        HelpList.Redraw()
}

SelectedPathCode() {
    row := HelpList.GetNext()
    return row ? HelpList.GetText(row, 2) : ""
}

; Sous la liste : le problème de la ligne sélectionnée. Boutons (Parcourir, Dossier, Saisir, Tester, Ignorer, Rétablir) :
; tous actifs pour un chemin ; Saisir, Tester et Rétablir pour un lien (site, recherche) ; aucun pour les autres codes.
ShowPathProblem() {
    code := SelectedPathCode()
    text := ""
    enabled := [false, false, false, false, false, false]
    for row in HelpRows {
        if row.code = code {
            if row.hasPath
                enabled := [true, true, true, true, true, true]
            else if row.hasLink
                enabled := [false, false, true, true, false, true]
            text := row.state = "KO" ? row.problem : (row.state = "Ignoré" ? "Ignoré : ne sera plus signalé comme cassé." : "")
            break
        }
    }
    HelpProblem.Text := text
    for index, button in HelpButtons
        button.Enabled := enabled[index]
}

; Dossier de départ des sélecteurs : celui du chemin actuel, ou le premier dossier parent qui existe
PathStartDir(target) {
    path := RegExMatch(target, '^"([^"]+)"', &quoted) ? quoted[1] : target
    while path != "" && !DirExist(path) {
        parent := RegExReplace(path, "\\?[^\\]*$")
        if parent = path
            break
        path := parent
    }
    return DirExist(path) ? path : A_ProgramFiles
}

; Choisit un autre fichier (ou dossier) pour le code sélectionné. Appelée aussi par le double-clic sur une ligne :
; pour un site ou une recherche, on modifie alors le lien ; pour les autres codes, il n'y a rien à modifier.
PathBrowse(folder := false) {
    code := SelectedPathCode()
    if code = "" {
        NotifyInfo("Chemins", "Sélectionne d'abord une ligne", 1.5)
        return
    }
    if !Checks.Has(code) {
        if Links.Has(code)
            PathInput()
        else
            NotifyInfo("Chemins", "Rien à modifier pour ce code", 1.5)
        return
    }
    name := CodeInfo.Has(code) ? CodeInfo[code].name : ExtraNames.Get(code, code)
    start := PathStartDir(Checks[code][1])
    chosen := folder ? DirSelect("*" start, 3, "Dossier pour « " name " »") : FileSelect(1, start, "Programme ou fichier pour « " name " »", "Tous les fichiers (*.*)")
    if chosen = ""
        return
    SetTarget(code, chosen)
    RefreshPaths(code)
}

; Saisie libre : chemin complet ou ligne de commande avec arguments (programmes) ; adresse (sites, recherches)
PathInput() {
    code := SelectedPathCode()
    if code = "" {
        NotifyInfo("Chemins", "Sélectionne d'abord une ligne", 1.5)
        return
    }
    name := CodeInfo.Has(code) ? CodeInfo[code].name : ExtraNames.Get(code, code)
    if Checks.Has(code) {
        answer := InputBox("Chemin complet, ou ligne de commande avec ses arguments :", "Chemin de « " name " »", "w760 h150", Checks[code][1])
        if answer.Result != "OK" || Trim(answer.Value) = ""
            return
        SetTarget(code, Trim(answer.Value))
    } else if Links.Has(code) {
        isSearch := CodeInfo[code].type = "Recherche"
        prompt := isSearch ? "Adresse de la recherche, avec {} à l'endroit du texte cherché :" : "Adresse du site :"
        answer := InputBox(prompt, "Lien de « " name " »", "w760 h150", Links[code][1])
        value := Trim(answer.Value)
        if answer.Result != "OK" || value = ""
            return
        if isSearch && !InStr(value, "{}") {
            NotifyWarn("Lien refusé", "Une recherche doit contenir {} à l'endroit du texte cherché", 4)
            return
        }
        SetLink(code, value)
    } else {
        NotifyInfo("Chemins", "Rien à modifier pour ce code", 1.5)
        return
    }
    RefreshPaths(code)
}

; Lance le raccourci sélectionné ; pour une recherche, avec le mot « test »
PathTest() {
    code := SelectedPathCode()
    if code = "" {
        NotifyInfo("Chemins", "Sélectionne d'abord une ligne", 1.5)
        return
    }
    try {
        if Checks.Has(code)
            RunTarget(Checks[code][1], Checks[code][2])
        else if Links.Has(code)
            OpenUrl(StrReplace(Links[code][1], "{}", "test"))
        else
            NotifyInfo("Chemins", "Rien à tester pour ce code", 1.5)
    } catch as err {
        NotifyError("Lancement impossible", err.Message, 5)
    }
}

PathToggleIgnored() {
    code := SelectedPathCode()
    if code = "" || !Checks.Has(code)
        return
    ToggleIgnored(code)
    RefreshPaths(code)
}

PathReset() {
    code := SelectedPathCode()
    if code = "" || !(Checks.Has(code) || Links.Has(code))
        return
    if !IsModified(code) {
        NotifyInfo("Chemins", Checks.Has(code) ? "Déjà le chemin par défaut" : "Déjà le lien par défaut", 1.5)
        return
    }
    if Checks.Has(code)
        ResetTarget(code)
    else
        ResetLink(code)
    RefreshPaths(code)
}


; =====================================================================================
;  MENU DE LA ZONE DE NOTIFICATION (icône AutoHotkey près de l'horloge)
; =====================================================================================

StartupShortcut := A_Startup "\" RegExReplace(A_ScriptName, "\.ahk$") ".lnk"
StartupItem := "Lancer au démarrage de Windows"

SetupTrayMenu() {
    tray := A_TrayMenu
    tray.Insert("1&")                                                  ; séparateur
    tray.Insert("1&", StartupItem, ToggleStartup)
    tray.Insert("1&", ShakeItem, ToggleShakeCursor)
    if ShakeCursorEnabled
        tray.Check(ShakeItem)
    tray.Insert("1&", "Aide et chemins des raccourcis (² ?)", (*) => ToggleHelp())
    if FileExist(StartupShortcut)
        tray.Check(StartupItem)
    A_IconTip := "AutoHotKey - Raccourcis Windows"
}

ToggleStartup(itemName, *) {
    if FileExist(StartupShortcut) {
        FileDelete StartupShortcut
        A_TrayMenu.Uncheck(itemName)
        NotifyInfo("Démarrage Windows", "désactivé")
    } else {
        FileCreateShortcut A_AhkPath, StartupShortcut, A_ScriptDir, '"' A_ScriptFullPath '"', "Raccourcis Windows AutoHotkey"
        A_TrayMenu.Check(itemName)
        NotifyOk("Démarrage Windows", "activé")
    }
}


; =====================================================================================
;  SORTIE AUDIO : Home / Fin parcourent les sorties actives de Windows (celles de Ctrl+Win+V)
;  Un appui LONG (AudioHoldMs) sur Home ou Fin ouvre le popup, sélection sur la sortie actuelle (rien ne change).
;  Ensuite chaque appui court avance d'une sortie, sans délai : Home = précédente, Fin = suivante (les flèches haut /
;  bas font la même chose quand le popup est ouvert). La sortie choisie est appliquée quand on arrête d'appuyer
;  (ou tout de suite avec Entrée ; Échap annule ; un clic sur une ligne valide).
;  Le petit œil à droite de chaque ligne met une sortie « à part » : elle passe dans une liste séparée en bas du popup
;  et Home / Fin ne la parcourent plus (un clic sur sa ligne l'applique quand même ; re-cliquer l'œil la remet dans la
;  liste). Ce choix est enregistré dans AudioExcludedFile. Tant que la souris, déplacée depuis le dernier appui,
;  est sur le popup, la validation automatique attend.
;  Un appui court quand le popup est fermé ne fait rien. Ctrl+Home, Maj+Fin, etc. gardent leur rôle habituel, et les
;  Send "{Home}" / "{End}" de PgUp, PgDn et Insert ne déclenchent pas ces raccourcis (les touches envoyées par
;  AutoHotkey sont ignorées par ses propres raccourcis).
; =====================================================================================

$Home::AudioKey(-1, "Home")
$End::AudioKey(1, "End")

#HotIf gAudioPopup
Enter::AudioCommit()
NumpadEnter::AudioCommit()
Escape::AudioCancel()
Up::AudioArrow(-1)
Down::AudioArrow(1)
#HotIf

; Popup fermé : il faut maintenir la touche AudioHoldMs pour l'ouvrir (sur la sortie actuelle). Popup ouvert : chaque
; appui avance tout de suite.
; On attend le relâchement de la touche (une étape par appui, pas de répétition automatique) avant d'armer la validation.
AudioKey(delta, key) {
    if !gAudioPopup && KeyWait(key, "T" (AudioHoldMs / 1000))     ; relâchée avant le délai : simple appui, ignoré
        return
    AudioStep(delta)
    KeyWait(key)
    AudioArm()
}

; Flèches haut / bas, popup ouvert : même effet que Home / Fin (la répétition automatique de la touche fait défiler).
AudioArrow(delta) {
    AudioStep(delta)
    AudioArm()
}

; Programme la validation automatique après le dernier appui.
AudioArm() {
    if gAudioPopup && AudioCommitDelayMs > 0
        SetTimer(AudioAutoCommit, -AudioCommitDelayMs)
}

; Validation automatique, repoussée tant que l'utilisateur se sert de la souris sur le popup (œil à cliquer).
AudioAutoCommit(*) {
    if gAudioPopup && gAudioPopup.MouseBusy()
        SetTimer(AudioAutoCommit, -300)
    else
        AudioCommit()
}

AudioStep(delta) {
    global gAudioPopup, gAudioClosing
    if !gAudioPopup {
        try {
            devices := AudioListOutputs()
            currentId := AudioDefaultId()
        } catch as err {
            AudioTip("Sorties audio illisibles : " err.Message)
            return
        }
        if !devices.Length {
            AudioTip("Aucune sortie audio active")
            return
        }
        if gAudioClosing {
            gAudioClosing.Destroy()
            gAudioClosing := ""
        }
        gAudioPopup := AudioPopup(devices, currentId)
        gAudioPopup.Open()                        ; ouverture : on montre la sortie actuelle, sans avancer
        return
    }
    SetTimer(AudioAutoCommit, 0)                  ; pas de validation automatique pendant que la touche est maintenue
    gAudioPopup.Move(delta)
}

AudioCommit(*) {
    global gAudioPopup, gAudioClosing
    SetTimer(AudioAutoCommit, 0)
    popup := gAudioPopup
    if !popup
        return
    gAudioPopup := ""
    keepSeconds := popup.Apply()
    if !keepSeconds {
        popup.Destroy()
        return
    }
    gAudioClosing := popup
    SetTimer(AudioCloseIfStillClosing.Bind(popup), -Round(keepSeconds * 1000))
}

AudioCloseIfStillClosing(popup) {
    global gAudioClosing
    if gAudioClosing = popup {
        popup.Destroy()
        gAudioClosing := ""
    }
}

AudioCancel(*) {
    global gAudioPopup
    SetTimer(AudioAutoCommit, 0)
    if gAudioPopup {
        gAudioPopup.Destroy()
        gAudioPopup := ""
    }
}

AudioTip(text) {
    ToolTip(text, , , 19)
    SetTimer(() => ToolTip(, , , 19), -1800)
}

; Popup : fenêtre sombre sans bordure, coins arrondis de Windows 11, icônes Segoe Fluent.
class AudioPopup {
    __New(devices, currentId) {
        this.devices := devices
        this.currentId := currentId
        this.shown := false
        this.clicked := false                                ; validation par un clic sur une ligne
        this.x := ""                                       ; position à l'écran, fixée à la première apparition
        this.mouseAt := [0, 0]
        this.Build()
        this.selected := 0
        for i, row in this.rows
            if row.device.id = currentId
                this.selected := i
    }

    Build() {
        pad := 8
        top := pad + 30                                      ; sous le titre
        this.gui := g := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x08000000")   ; E0x08000000 : ne vole pas le focus
        g.BackColor := UiColorBg
        g.MarginX := pad
        g.MarginY := pad

        g.SetFont("s9 c" UiColorDim, UiFontText)
        this.header := g.Add("Text", Format("x{} y{} w{} h24 +0x200", pad + 12, pad, AudioPopupWidth - 12), "Sortie audio")

        ; Sorties parcourues par Home / Fin d'abord, puis celles mises à part (liste séparée en bas)
        ordered := []
        for device in this.devices
            if !gAudioExcluded.Has(device.id)
                ordered.Push(device)
        this.enabledCount := ordered.Length
        for device in this.devices
            if gAudioExcluded.Has(device.id)
                ordered.Push(device)

        this.rows := []
        y := top
        for i, device in ordered {
            if i = this.enabledCount + 1 {
                g.SetFont("s8 c" UiColorDim, UiFontText)
                g.Add("Text", Format("x{} y{} w{} h20 +0x200", pad + 12, y + 20, AudioPopupWidth - 12), "Mises à part (ignorées par Home / Fin)")
                y += 44                                  ; espace en plus pour bien séparer les deux listes
            }
            aside := i > this.enabledCount
            textColor := aside ? UiColorDim : UiColorText
            row := {index: i, device: device}
            ; Une ligne = 5 zones côte à côte (barre d'accent, icône, nom, coche, œil) qui changent de fond ensemble.
            row.bar := g.Add("Text", Format("x{} y{} w4 h{} +0x100 Background{}", pad, y, AudioRowHeight, AudioColorRow))
            g.SetFont("s15 c" textColor, UiFontIcons)
            row.icon := g.Add("Text", Format("x{} y{} w44 h{} +0x200 +0x100 Center Background{}", pad + 4, y, AudioRowHeight, AudioColorRow), AudioGlyphFor(device.form))
            g.SetFont("s11 c" textColor, UiFontText)
            row.name := g.Add("Text", Format("x{} y{} w{} h{} +0x200 +0x4000 +0x100 Background{}", pad + 48, y, AudioPopupWidth - 140, AudioRowHeight, AudioColorRow), device.name)
            g.SetFont("s12 c" AudioColorAccent, UiFontIcons)
            row.mark := g.Add("Text", Format("x{} y{} w44 h{} +0x200 +0x100 Center Background{}", pad + AudioPopupWidth - 92, y, AudioRowHeight, AudioColorRow), device.id = this.currentId ? Chr(0xE73E) : "")
            g.SetFont("s12 c" UiColorDim, UiFontIcons)
            row.eye := g.Add("Text", Format("x{} y{} w44 h{} +0x200 +0x100 Center Background{}", pad + AudioPopupWidth - 44, y, AudioRowHeight, AudioColorRow), Chr(aside ? 0xED1A : 0xE7B3))   ; œil barré / ouvert
            for control in [row.bar, row.icon, row.name, row.mark]
                control.OnEvent("Click", this.Pick.Bind(this, i))
            row.eye.OnEvent("Click", this.ToggleAside.Bind(this, i))
            this.rows.Push(row)
            y += AudioRowHeight + 2
        }

        y += 4
        g.SetFont("s8 c" UiColorDim, UiFontText)
        g.Add("Text", Format("x{} y{} w{} h36", pad + 12, y, AudioPopupWidth - 12), "Home / ↑   Fin / ↓   ·   Entrée valider   ·   Échap annuler`nClic sur l'œil : mettre la sortie à part / la remettre")

        this.width := AudioPopupWidth + 2 * pad
        this.height := y + 36 + pad
        RoundFrame(g, this.width, this.height)
    }

    ; Première apparition : la sélection est sur la sortie actuelle (même si elle est à part).
    Open() {
        MouseGetPos(&mx, &my)
        this.mouseAt := [mx, my]
        if this.selected
            this.Paint(this.selected, true)
        this.Show()
    }

    ; Home / Fin ne parcourent que les sorties qui ne sont pas à part.
    Move(delta) {
        MouseGetPos(&mx, &my)
        this.mouseAt := [mx, my]
        n := this.enabledCount
        if !n
            return
        old := this.selected
        if !old || old > n
            new := delta > 0 ? 1 : n
        else
            new := Mod(old - 1 + delta + n, n) + 1
        this.selected := new
        if old
            this.Paint(old, false)
        this.Paint(new, true)
    }

    ; La souris a bougé depuis le dernier appui de touche et se trouve sur le popup : on la laisse faire.
    MouseBusy() {
        MouseGetPos(&mx, &my, &window)
        return this.shown && window = this.gui.Hwnd && (mx != this.mouseAt[1] || my != this.mouseAt[2])
    }

    ; Œil cliqué : la sortie passe dans la liste à part (ou en revient), choix enregistré sur disque.
    ToggleAside(i, *) {
        global gAudioPopup
        if gAudioPopup != this
            return
        device := this.rows[i].device
        if gAudioExcluded.Has(device.id)
            gAudioExcluded.Delete(device.id)
        else
            gAudioExcluded[device.id] := device.name
        AudioSaveExcluded()
        SetTimer(AudioAutoCommit, 0)
        SetTimer(this.Rebuild.Bind(this), -1)                ; hors de l'événement du clic : on détruit la fenêtre cliquée
    }

    ; Redessine le popup après un changement de liste, au même endroit. La sélection en attente est gardée
    ; sauf si la sortie vient d'être mise à part.
    Rebuild() {
        global gAudioPopup
        if gAudioPopup != this
            return
        selectedId := this.selected ? this.rows[this.selected].device.id : ""
        this.gui.Destroy()
        this.Build()
        this.selected := 0
        for i, row in this.rows
            if i <= this.enabledCount && row.device.id = selectedId
                this.selected := i
        if this.selected
            this.Paint(this.selected, true)
        MouseGetPos(&mx, &my)
        this.mouseAt := [mx - 1, my]                         ; la souris compte comme « en train de servir » jusqu'à ce qu'elle quitte le popup
        this.Show()
        AudioArm()
    }

    Paint(i, selected) {
        row := this.rows[i]
        background := selected ? AudioColorSelected : AudioColorRow
        for control in [row.icon, row.name, row.mark, row.eye] {
            control.Opt("+Background" background)
            control.Redraw()
        }
        row.bar.Opt("+Background" (selected ? AudioColorAccent : background))
        row.bar.Redraw()
    }

    Show() {
        if this.x = "" {
            MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
            this.x := left + (right - left - this.width) // 2
            this.y := top + (bottom - top - this.height) // 3
        }
        this.gui.Show(Format("NA x{} y{} w{} h{}", this.x, this.y, this.width, this.height))
        this.shown := true
    }

    Pick(i, *) {
        global gAudioPopup
        if gAudioPopup != this
            return
        if this.selected
            this.Paint(this.selected, false)
        this.selected := i
        this.Paint(i, true)
        this.clicked := true
        AudioCommit()
    }

    ; Applique la sortie sélectionnée. Renvoie le nombre de secondes pendant lesquelles garder le popup
    ; affiché (0 = le fermer tout de suite). Un clic sur la sortie déjà active laisse aussi voir la sélection un instant.
    Apply() {
        if !this.selected
            return 0
        device := this.rows[this.selected].device
        if device.id = this.currentId {
            if !this.clicked
                return 0
            this.header.Text := "Sortie audio inchangée"
            return AudioDoneDelayMs / 1000
        }
        try {
            AudioSetDefault(device.id)
        } catch as err {
            this.header.SetFont("c" AudioColorError)
            this.header.Text := "Changement impossible : " err.Message
            return 3
        }
        for i, row in this.rows
            row.mark.Text := i = this.selected ? Chr(0xE73E) : ""
        this.header.Text := "Sortie audio changée"
        return AudioDoneDelayMs / 1000
    }

    Destroy() {
        this.gui.Destroy()
    }
}

; Sorties mises à part, enregistrées une par ligne « identifiant <tabulation> nom » (le nom sert juste à s'y retrouver
; en ouvrant le fichier). Une sortie débranchée y reste : elle sera encore à part quand on la rebranche.
AudioLoadExcluded() {
    excluded := Map()
    try {
        for line in StrSplit(FileRead(AudioExcludedFile, "UTF-8"), "`n", "`r") {
            parts := StrSplit(line, "`t", , 2)
            if parts[1] != ""
                excluded[parts[1]] := parts.Length > 1 ? parts[2] : ""
        }
    }
    return excluded
}

AudioSaveExcluded() {
    text := ""
    for id, name in gAudioExcluded
        text .= id "`t" name "`n"
    try {
        file := FileOpen(AudioExcludedFile, "w", "UTF-8-RAW")
        file.Write(text)
        file.Close()
    } catch as err
        AudioTip("Enregistrement impossible : " err.Message)
}

; Icône Segoe Fluent selon le type de sortie (PKEY_AudioEndpoint_FormFactor).
AudioGlyphFor(formFactor) {
    switch formFactor {
        case 3, 5: return Chr(0xE7F6)     ; casque / micro-casque
        case 9:    return Chr(0xE7F4)     ; écran (HDMI, DisplayPort)
        default:   return Chr(0xE767)     ; haut-parleur
    }
}

; --- API Core Audio de Windows via COM (code technique, rien à modifier ici) ---

; Sorties actives (branchées et activées), triées par nom si AudioSortByName. Chaque élément : {id, name, form}.
AudioListOutputs() {
    enumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")   ; IMMDeviceEnumerator
    ComCall(3, enumerator, "UInt", 0, "UInt", 1, "Ptr*", &collection := 0)      ; EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE)
    ComCall(3, collection, "UInt*", &count := 0)                                 ; IMMDeviceCollection::GetCount
    devices := []
    loop count {
        ComCall(4, collection, "UInt", A_Index - 1, "Ptr*", &device := 0)       ; IMMDeviceCollection::Item
        ComCall(4, device, "UInt", 0, "Ptr*", &store := 0)                       ; IMMDevice::OpenPropertyStore(STGM_READ)
        name := AudioProperty(store, "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", 14)   ; PKEY_Device_FriendlyName
        form := AudioProperty(store, "{1DA5D803-D492-4EDD-8C23-E0C0FFEE7F0E}", 0)    ; PKEY_AudioEndpoint_FormFactor
        devices.Push({id: AudioDeviceId(device), name: name, form: form})
        ObjRelease(store)
        ObjRelease(device)
    }
    ObjRelease(collection)
    if AudioSortByName
        loop devices.Length - 1 {                                                ; tri par insertion (quelques éléments)
            i := A_Index + 1
            current := devices[i]
            j := i - 1
            while j >= 1 && StrCompare(devices[j].name, current.name, "Locale") > 0 {
                devices[j + 1] := devices[j]
                j--
            }
            devices[j + 1] := current
        }
    return devices
}

; Identifiant de la sortie par défaut actuelle ("" si aucune).
AudioDefaultId() {
    try {
        enumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
        ComCall(4, enumerator, "UInt", 0, "UInt", 0, "Ptr*", &device := 0)      ; GetDefaultAudioEndpoint(eRender, eConsole)
        id := AudioDeviceId(device)
        ObjRelease(device)
        return id
    } catch
        return ""
}

AudioDeviceId(device) {
    ComCall(5, device, "Ptr*", &buffer := 0)                                     ; IMMDevice::GetId
    id := StrGet(buffer, "UTF-16")
    DllCall("ole32\CoTaskMemFree", "Ptr", buffer)
    return id
}

; Lit une propriété d'un périphérique : texte (VT_LPWSTR) ou entier (VT_UI4), "" si absente.
AudioProperty(store, guid, pid) {
    key := Buffer(20)                                                            ; PROPERTYKEY : GUID + numéro
    DllCall("ole32\CLSIDFromString", "Str", guid, "Ptr", key)
    NumPut("UInt", pid, key, 16)
    value := Buffer(24, 0)                                                       ; PROPVARIANT
    try
        ComCall(5, store, "Ptr", key, "Ptr", value)                              ; IPropertyStore::GetValue
    catch
        return ""
    vt := NumGet(value, 0, "UShort")
    result := vt = 31 ? StrGet(NumGet(value, 8, "Ptr"), "UTF-16") : vt = 19 ? NumGet(value, 8, "UInt") : ""
    DllCall("ole32\PropVariantClear", "Ptr", value)
    return result
}

; Définit la sortie par défaut pour les trois rôles de Windows (console, multimédia, communications), comme le
; sélecteur de Windows. Pas d'API publique pour ça : on passe par IPolicyConfig (non documentée mais stable
; depuis Vista, utilisée par tous les outils de bascule audio).
AudioSetDefault(id) {
    policy := ComObject("{870AF99C-171D-4F9E-AF0D-E63DF40C2BC9}", "{F8679F50-850A-41CF-9C72-430F290290C8}")   ; CPolicyConfigClient / IPolicyConfig
    for role in [0, 1, 2]
        ComCall(13, policy, "WStr", id, "UInt", role)                            ; SetDefaultEndpoint
}


; =====================================================================================
;  FERMER UNE TOOLTIP BLOQUÉE  (² puis "tt", puis clic sur la bulle ; ou directement Win + clic sur la bulle)
;  Les tooltips Windows laissent passer la souris : on cherche, parmi toutes les bulles visibles, celle qui se
;  trouve sous le curseur. La notification indique de quelle application elle vient.
;  Après ² + tt, le mode reste armé (Échap pour annuler, ou 10 s sans clic) tant qu'aucune bulle n'a été fermée.
; =====================================================================================

TooltipCloseTimeoutMs := 10000
gTooltipArmed := false

#LButton::Guard(() => CloseTooltipUnderCursor() || NotifyWarn("Aucune tooltip ici", "Win + clic directement sur la bulle", 2, "tooltip"), "Fermer la tooltip")

#HotIf gTooltipArmed
LButton::Guard(TooltipArmedClick, "Fermer la tooltip")
Escape::DisarmTooltipCloser()
#HotIf

ArmTooltipCloser() {
    global gTooltipArmed := true
    SetTimer(DisarmTooltipCloser, -TooltipCloseTimeoutMs)
    NotifyInfo("Fermer une tooltip", "Clique sur la bulle (Échap pour annuler)", TooltipCloseTimeoutMs / 1000, "tooltip")
}

DisarmTooltipCloser() {
    global gTooltipArmed := false
    SetTimer(DisarmTooltipCloser, 0)
    NotifyInfo("Fermer une tooltip", "Annulé", 1, "tooltip")
}

TooltipArmedClick() {
    if CloseTooltipUnderCursor() {
        global gTooltipArmed := false
        SetTimer(DisarmTooltipCloser, 0)
    } else {
        NotifyWarn("Aucune tooltip ici", "Clique directement sur la bulle (Échap pour annuler)", 2, "tooltip")
    }
}

; Toutes les fenêtres de type tooltip : celles de Windows classique (tooltips_class32) et celles d'Office
; (MicrosoftWindowsTooltip, c'est la classe de la bulle "Close" bloquée de Word).
TooltipWindows() {
    list := []
    for cls in ["tooltips_class32", "MicrosoftWindowsTooltip"]
        for hwnd in WinGetList("ahk_class " cls)
            list.Push(hwnd)
    return list
}

; Ferme la tooltip sous le curseur. Renvoie false s'il n'y en a pas.
CloseTooltipUnderCursor() {
    static TTM_POP := 0x41C                            ; message officiel pour faire disparaître une tooltip
    CoordMode "Mouse", "Screen"
    MouseGetPos &mx, &my
    margin := 6
    for hwnd in TooltipWindows() {
        if !DllCall("IsWindowVisible", "Ptr", hwnd)
            continue
        WinGetPos &x, &y, &w, &h, hwnd
        if mx < x - margin || mx > x + w + margin || my < y - margin || my > y + h + margin
            continue
        try text := Trim(WinGetText(hwnd), " `t`r`n")
        catch
            text := ""
        try app := WinGetProcessName(hwnd)
        catch
            app := "application inconnue"
        PostMessage TTM_POP, 0, 0, , hwnd
        WinHide hwnd
        NotifyOk("Tooltip fermée", app (text != "" ? "`n« " SubStr(text, 1, 60) " »" : ""), 2, "tooltip")
        return true
    }
    return false
}


; =====================================================================================
;  DÉMARRAGE
; =====================================================================================

SetupTrayMenu()
ApplyShakeCursor()
NotifyOk("AutoHotKey", "démarré")
brokenAtStart := FindBrokenTargets()
if brokenAtStart.Length {
    names := ""
    for item in brokenAtStart
        names .= (names = "" ? "" : ", ") item[1]
    NotifyError(brokenAtStart.Length " raccourci(s) cassé(s)", names "`n² puis ? : la liste des raccourcis permet de les corriger", 8)
}


; =====================================================================================
;  NOTIFICATIONS  (code technique, rien à modifier ici)
;  Quatre types : NotifyOk (vert), NotifyInfo (bleu), NotifyWarn (orange), NotifyError (rouge, reste plus longtemps).
;  Petites cartes colorées à coins arrondis, empilées en bas à droite de l'écran principal, avec fondu ; un clic les ferme.
;  tag (facultatif) : famille de notification. Une nouvelle notification remplace la précédente de même famille
;  au lieu de s'empiler (ex. les appuis répétés sur ²).
; =====================================================================================

NotifyOk(title, message := "", seconds := 1, tag := "")     => Notify(title, message, seconds, ColorOk, 0xE73E, tag)
NotifyInfo(title, message := "", seconds := 1, tag := "")   => Notify(title, message, seconds, ColorInfo, 0xE946, tag)
NotifyWarn(title, message := "", seconds := 3, tag := "")   => Notify(title, message, seconds, ColorWarn, 0xE7BA, tag)
NotifyError(title, message := "", seconds := 7, tag := "")  => Notify(title, message, seconds, ColorError, 0xE711, tag)

; seconds : durée d'affichage (0 = reste jusqu'au clic).
; color   : couleur de fond, hexadécimal RVB ("2C5F9E") ; par défaut ColorInfo.
; glyph   : code de l'icône dans la police Segoe Fluent Icons (0xE946 = information).
Notify(title, message := "", seconds := 30, color := "", glyph := 0xE946, tag := "") {
    if color = ""
        color := ColorInfo
    if tag != "" && gToastTags.Has(tag)
        ToastCloseNow(gToastTags[tag])                                      ; remplace la notification précédente de la famille
    toast := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x08000000")          ; E0x08000000 : ne vole pas le focus
    toast.BackColor := color
    toast.MarginX := 14
    toast.MarginY := 10

    toast.SetFont("s14 c" UiColorText, UiFontIcons)
    icon := toast.Add("Text", "x14 y8 w24 h24 Center BackgroundTrans +0x100", Chr(glyph))
    toast.SetFont("s10 w600 c" UiColorText, UiFontText)
    titleText := toast.Add("Text", "x48 y10 BackgroundTrans +0x100", title)  ; 0x100 : rend le texte cliquable
    controls := [icon, titleText]
    if message != "" {
        toast.SetFont("s10 norm c" UiColorText, UiFontText)
        wrap := StrLen(message) > 50 ? " w380" : ""                         ; messages longs : retour à la ligne
        controls.Push(toast.Add("Text", "x48 y+2 BackgroundTrans +0x100" wrap, message))
    }
    for control in controls
        control.OnEvent("Click", dismiss)

    toast.Show("Hide")                                                      ; calcule la taille sans afficher
    toast.GetPos(, , &width, &height)
    RoundFrame(toast, width, height, color)

    DetectHiddenWindows true                                                ; la fenêtre est encore cachée à ce stade
    WinSetTransparent(0, toast)                                             ; apparition en fondu
    gToasts.Push(toast)
    if tag != ""
        gToastTags[tag] := toast
    Reflow()
    toast.Show("NA")                                                        ; NA : sans activer la fenêtre
    ToastFade(toast, 0, 255, 6)
    if seconds > 0
        SetTimer(dismiss, -Round(seconds * 1000))

    dismiss(*) {
        index := ToastIndex(toast)
        if !index                                                           ; déjà fermée (clic puis timer)
            return
        gToasts.RemoveAt(index)
        Reflow()
        ToastFade(toast, 255, 0, 5, () => ToastCloseNow(toast))             ; disparition en fondu
    }
}

; Ferme tout de suite une notification (sans fondu), qu'elle soit affichée ou déjà en train de disparaître.
ToastCloseNow(toast) {
    index := ToastIndex(toast)
    if index
        gToasts.RemoveAt(index)
    for tag, tagged in gToastTags
        if tagged = toast {
            gToastTags.Delete(tag)
            break
        }
    try toast.Destroy()
}

; Fondu de l'opacité de `from` à `to` (0-255) en `steps` étapes, puis appelle `done` s'il est fourni.
ToastFade(toast, from, to, steps, done := "") {
    step := 0
    SetTimer(tick, 15)

    tick() {
        step++
        value := Round(from + (to - from) * step / steps)
        try
            WinSetTransparent(value >= 255 ? "Off" : value, toast)
        catch {                                                             ; fenêtre déjà fermée
            SetTimer(tick, 0)
            return
        }
        if step >= steps {
            SetTimer(tick, 0)
            if done
                done()
        }
    }
}

; Coins arrondis et liseré fin (Windows 11), de la couleur `border` (UiColorBorder par défaut).
; Avant Windows 11, coins arrondis par une région de découpe.
RoundFrame(window, width, height, border := "") {
    rgb := Integer("0x" (border = "" ? UiColorBorder : border))
    bgr := ((rgb & 0xFF) << 16) | (rgb & 0xFF00) | (rgb >> 16)
    try {
        if DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", window.Hwnd, "Int", 33, "Int*", 2, "Int", 4) = 0 {   ; 33 : coins arrondis
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", window.Hwnd, "Int", 34, "Int*", bgr, "Int", 4)      ; 34 : couleur du liseré
            return
        }
    }
    DetectHiddenWindows true                                                ; la fenêtre est encore cachée à ce stade
    WinSetRegion("0-0 w" width " h" height " R12-12", window)
}

ToastIndex(toast) {
    for index, candidate in gToasts
        if candidate = toast
            return index
    return 0
}

; Réempile les notifications depuis le bas de la zone de travail.
Reflow() {
    MonitorGetWorkArea(MonitorGetPrimary(), , , &right, &bottom)
    y := bottom - 12
    for toast in gToasts {
        toast.GetPos(, , &width, &height)
        y -= height
        toast.Move(right - width - 12, y)
        y -= 8
    }
}
