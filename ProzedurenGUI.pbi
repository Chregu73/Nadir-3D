Procedure FadeInWindow(win, time = 1000)
  time = time / 51
  ;Fenster auf Layered setzen
  SetWindowLongPtr_(WindowID(win), #GWL_EXSTYLE, GetWindowLongPtr_(WindowID(win), #GWL_EXSTYLE) | #WS_EX_LAYERED)
  ;Sofort auf 0 (unsichtbar) setzen, bevor das Bild kommt
  SetLayeredWindowAttributes_(WindowID(win), 0, 0, #LWA_ALPHA)
  ;Event-Queue kurz abarbeiten (wichtig, damit Windows das Image zeichnet!)
  While WindowEvent() : Wend
  ;Sanft einblenden
  For alpha = 0 To 255 Step 5
    If alpha = 0
      HideWindow(win, #False)
    EndIf
    SetLayeredWindowAttributes_(WindowID(win), 0, alpha, #LWA_ALPHA)
    UpdateWindow_(WindowID(win)) ; Erzwingt das Neuzeichnen
    Delay(time) 
  Next    
  ;JETZT WICHTIG: Den Layered-Status entfernen
  Protected Style = GetWindowLongPtr_(WindowID(win), #GWL_EXSTYLE)
  SetWindowLongPtr_(WindowID(win), #GWL_EXSTYLE, Style & ~#WS_EX_LAYERED)
  ;Einmaliges Neuzeichnen erzwingen, damit alles sauber aussieht
  RedrawWindow_(WindowID(win), #Null, #Null, #RDW_INVALIDATE | #RDW_UPDATENOW | #RDW_FRAME)
EndProcedure

Procedure PlayNadirScanLong()
  MessageBeep_(#MB_OK)
EndProcedure

Global WindowGCodeHelp
;Hilfe für verschiedene G-Codes anzeigen
Procedure GCodeHelp(EventType)
  If Not IsWindow(WindowGCodeHelp)
    WindowGCodeHelp = OpenWindow(#PB_Any, 100, 100, 980, 600, "G-Codes", #PB_Window_SystemMenu)
    WebViewGadget(0, 0, 0, 980, 600)
    SetGadgetText(0, "file://" + GetCurrentDirectory() + "gcode.html")
    CompilerIf #PB_Compiler_IsMainFile
      Repeat 
        Event = WaitWindowEvent()
      Until Event = #PB_Event_CloseWindow
    CompilerEndIf
  Else
    SetActiveWindow(WindowGCodeHelp)
  EndIf
EndProcedure

Procedure WindowGCodeHelp_Events(Event)
  Select event
    Case #PB_Event_CloseWindow
      CloseWindow(WindowGCodeHelp)
  EndSelect
EndProcedure


Enumeration #PB_Event_FirstCustomValue
  #Event_Nadir_GCode  ;Erhält automatisch den ersten freien Wert (meist 6000+)
  #Event_Nadir_Status ;Falls du später noch mehr eigene Events brauchst
EndEnumeration

Declare.s SendRec2(text.s, timeoutMS.i = 20000)
Global NewList GCodeQueue.s() ;Eine Liste als Puffer
Global WindowGCodeSend
;verschiedene G-Codes senden
Procedure NadirActionCallback(JsonParameters$)
  ;Da wir im JS nur einen Wert senden, ist JsonParameters$ 
  ;einfach ein JSON-String in eckigen Klammern, z.B.: ["G1 X10 Y50 F100"]
  Protected JSON = ParseJSON(#PB_Any, JsonParameters$)
  If JSON
    ;Den fertigen String direkt aus dem ersten Element des JSON-Arrays holen
    ;Protected GCode.s = GetJSONString(GetJSONElement(JSONValue(JSON), 0))
    ;Debug "Sende an Drucker: " + GCode.s
    ; Neuen Befehl hinten an die Liste hängen
    AddElement(GCodeQueue())
    GCodeQueue() = GetJSONString(GetJSONElement(JSONValue(JSON), 0))
    PostEvent(#Event_Nadir_GCode, WindowGCodeSend, 0, 0)
    ;Hier kommt dein Sende-Befehl hin:
    ;RTrim(GCode.s, " ")
    ;SendRec2(GCode.s)
    FreeJSON(JSON)
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure GCodeSend(EventType)
  If Not IsWindow(WindowGCodeSend)
    WindowGCodeSend = OpenWindow(0, 0, 0, 700, 700, "Nadir External UI", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ;Wichtig: WebView2 (Windows) oder WebKit (Mac/Linux)
    ;Download von https://developer.microsoft.com/en-us/microsoft-edge/webview2/
    ;wenn WebViewGadget() abstürzt, fehlt ^
    WebViewGadget(0, 0, 0, 700, 700, #PB_WebView_Debug)
    ;Verbindung herstellen BEVOR wir die Seite laden
    BindWebViewCallback(0, "nadirCmd", @NadirActionCallback())
    ;Die externe Datei laden. Wir nutzen 'file://' gefolgt vom Pfad
    SetGadgetText(0, "file://" + GetCurrentDirectory() + "ui.html")
    ;Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
EndProcedure

Procedure WindowGCodeSend_Events(Event)
  Select event
    Case #PB_Event_CloseWindow
      UnbindWebViewCallback(0, "nadirCmd")
      CloseWindow(WindowGCodeSend)
    Case #Event_Nadir_GCode
      FirstElement(GCodeQueue()) ; Den ältesten Befehl holen
      Protected GCode.s = GCodeQueue()
      ;Entfernt alle Leerzeichen
      GCode.s = Trim(GCode, " ")
      SendRec2(GCode.s)
      DeleteElement(GCodeQueue()) ; Befehl aus der Liste löschen
  EndSelect
EndProcedure


Global WindowManual
;Fenster für Anleitung
Procedure manual(EventType)
  If Not IsWindow(WindowManual)
    WindowManual = OpenWindow(#PB_Any, 100, 100, 980, 600, "Manual", #PB_Window_SystemMenu)
    WebViewGadget(0, 0, 0, 980, 600)
    SetGadgetText(0, "file://" + GetCurrentDirectory() + "manual.html")
    CompilerIf #PB_Compiler_IsMainFile
      Repeat 
        Event = WaitWindowEvent()
      Until Event = #PB_Event_CloseWindow
    CompilerEndIf
  Else
    SetActiveWindow(WindowManual)
  EndIf
EndProcedure

Procedure WindowManual_Events(Event)
  Select event
    Case #PB_Event_CloseWindow
      CloseWindow(WindowManual)
  EndSelect
EndProcedure


;Fenster für manuelle Bedienung
Procedure bedienung(EventType)
  If Not IsWindow(WindowBedienung)
    OpenWindowBedienung()
    ;Fenster immer im Vordergrund, 2.2.2026 Chregu:
    StickyWindow(WindowBedienung, #True) 
  EndIf
EndProcedure

Procedure Ueber(EventType)
  MessageRequester("Über...", ~"Nadir 3D\n2026 by Chregu Müller\nchregu@vtxmail.ch", #PB_MessageRequester_Ok)
EndProcedure

Global NZ$ = #LF$  ;0x0A, 10 dezimal, \n, für MKS TinyBee
;Global NZ$ = #CR$  ;0x0D, 13 dezimal, \r, für TeaCup Firmware


Global ComPort.s = "COM1"
Global ComBaud.l = 115200
Global serialPortOpen.i

Macro lustigeZeichenWeg(string)
  LTrim(LTrim(LTrim(string, "\"), "."), "\")
EndMacro

Procedure comPortOpenClose(Button)
  OpenPreferences("Nadir.ini")
  ComPort.s = ReadPreferenceString("Port", "COM1")
  ClosePreferences()
  If GetToolBarButtonState(0, Button) ;wenn gedrückt
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ComPort.s = "\\\\.\\" + ComPort.s
      CompilerCase #PB_OS_Linux
        ComPort.s = "/dev/" + ComPort.s
      CompilerCase #PB_OS_MacOS
        ;ComPort.s = "/dev/cu.usbserial-xxxxxxxx"
        ;         "/dev/tty.usbserial-xxxxxxxx"
        ComPort.s = "/dev/" + ComPort.s
    CompilerEndSelect
    serialPortOpen.i = OpenSerialPort(0, ComPort.s, ComBaud.l, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 1024, 1024)
    If serialPortOpen.i > 0
      SerialPortTimeouts(0, 300, 300, 300, 10, 100)
      ;StatusBarText(0, 2, LTrim(LTrim(LTrim(ComPort.s, "\"), "."), "\") + " geöffnet")
      StatusBarText(0, 2, lustigeZeichenWeg(ComPort.s) + " geöffnet")
      ;DisableGadget(Combo_5, 1)
      ;DisableGadget(Text_15, 0)
      ;DisableGadget(Button_6, 0)
    Else
      ;StatusBarText(0, 2, ComPort.s + " konnte nicht geöffnet werden")
      StatusBarText(0, 2, lustigeZeichenWeg(ComPort.s) + " konnte nicht geöffnet werden")
      SetToolBarButtonState(0, Button, 0)
    EndIf
  Else ;wenn nicht gedrückt
    If serialPortOpen.i > 0
      CloseSerialPort(0)
      StatusBarText(0, 2, ComPort.s + " geschlossen")
      ;DisableGadget(Combo_5, 0)
      ;DisableGadget(Text_15, 1)
      ;DisableGadget(Button_6, 1)
      serialPortOpen.i = 0
    EndIf
  EndIf
EndProcedure

Procedure testComPorts(ComboGadget)
  anzahl.a = 0      
  rueckGabe.s = ""
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      ;Ports = "\\\\.\\COMn"
      Dmesg = RunProgram("chgport", "/query", GetCurrentDirectory(), #PB_Program_Open|#PB_Program_Read)
      ;evtl. auch: "change port /query"
      ;"chgport" geht nicht unter x86, evtl. "mode" verwenden!
      If Dmesg
        While ProgramRunning(Dmesg)
          If AvailableProgramOutput(Dmesg)
            rueckGabe.s = ReadProgramString(Dmesg)
            ;nur "COMxx" oder "COMx" finden:
            rueckGabe.s = StringField(rueckGabe.s, 1, " ")
            If (Left(rueckGabe.s, 3) = "COM") And (Len(rueckGabe.s) < 6)
              AddGadgetItem(ComboGadget, -1, rueckGabe.s)
              anzahl.a + 1
            EndIf
          EndIf
        Wend
        CloseProgram(Dmesg) ; Schließt die Verbindung zum Programm
      EndIf
    CompilerCase #PB_OS_Linux
      ;Ports = "/dev/tty*"
      Dmesg = RunProgram("ls", "-1 /dev", "", #PB_Program_Open|#PB_Program_Read)
      If Dmesg
        While ProgramRunning(Dmesg)
          If AvailableProgramOutput(Dmesg)
            rueckGabe.s = ReadProgramString(Dmesg)
            ;nur "COMxx" oder "COMx" finden:
            rueckGabe.s = StringField(rueckGabe.s, 1, " ")
            If (Left(rueckGabe.s, 3) = "tty") ;And (Len(rueckGabe.s) < 6)
              AddGadgetItem(ComboGadget, -1, rueckGabe.s)
              anzahl.a + 1
            EndIf
          EndIf
        Wend
        CloseProgram(Dmesg) ; Schließt die Verbindung zum Programm
      EndIf
    CompilerCase #PB_OS_MacOS
      ;Port.s = "/dev/cu.usbserial-xxxxxxxx"
      ;         "/dev/tty.usbserial-xxxxxxxx"
      ;ComboBox ist editierbar!
      Dmesg = RunProgram("ls", "-1 /dev", "", #PB_Program_Open|#PB_Program_Read)
      If Dmesg
        While ProgramRunning(Dmesg)
          If AvailableProgramOutput(Dmesg)
            rueckGabe.s = ReadProgramString(Dmesg)
            ;nur "COMxx" oder "COMx" finden:
            rueckGabe.s = StringField(rueckGabe.s, 1, " ")
            If (Left(rueckGabe.s, 3) = "tty") Or (Left(rueckGabe.s, 2) = "cu")
              AddGadgetItem(ComboGadget, -1, rueckGabe.s)
              anzahl.a + 1
            EndIf
          EndIf
        Wend
        CloseProgram(Dmesg) ; Schließt die Verbindung zum Programm
      EndIf
      anzahl.a = 1
  CompilerEndSelect
  If anzahl = 0
    MessageRequester("W A R N U N G", ~"Es wurde kein COM-Port gefunden\n\nSie können den COM-Port\nmanuell eingeben!", #PB_MessageRequester_Info)
  EndIf
EndProcedure

Procedure SerialSettings(EventType)
  OpenWindowSerial()
  testComPorts(essPo)
  OpenPreferences("Nadir.ini")
  SetGadgetState(essPo, ReadPreferenceInteger("COM", 0))
  ClosePreferences()
  DisableWindow(WindowScanner, #True)
  SetActiveWindow(WindowSerial)
  StickyWindow(WindowSerial, #True)  ; Kurzzeitig "immer oben" einschalten
  ;StickyWindow(WindowSerial, #False) ; Wieder lösen
EndProcedure

Procedure SerSetAbbrechen(EventType)
  DisableWindow(WindowScanner, #False)
  CloseWindow(WindowSerial)
EndProcedure

Procedure SerSetUebernehmen(EventType)
  OpenPreferences("Nadir.ini")
  WritePreferenceInteger("COM", GetGadgetState(essPo))
  WritePreferenceString("Port", GetGadgetText(essPo))
  ClosePreferences()
  DisableWindow(WindowScanner, #False)
  CloseWindow(WindowSerial)
EndProcedure

Procedure Oeffnen(EventType)
  DateiName$ = OpenFileRequester("Surface-Datei wählen", "surface.dat", "Surface (*.dat)", 0)
  If DateiName$ <> ""
    SetGadgetText(DNs, DateiName$)
  EndIf
EndProcedure

;Aendert die Endung nach dem Punkt, robust!
Procedure.s ReplaceEndung(dateinamen$, neueendung$)
  dateinamen$ = ReverseString(dateinamen$)
  dateinamen$ = RemoveString(dateinamen$, StringField(dateinamen$, 1, "."), #PB_String_NoCase, 1, 1)
  dateinamen$ = ReverseString(dateinamen$)
  dateinamen$ + neueendung$
  ProcedureReturn dateinamen$
EndProcedure

Procedure ErzeugeSCAD(EventType)
  OriginalName$ = GetGadgetText(DNs)
  DateiName$ = ReplaceEndung(OriginalName$, "scad")
  If CreateFile(#scad, DateiName$)  ;neue Textdatei erstellen
    WriteStringN(#scad, "//surface.scad")
    WriteStringN(#scad, "")
    WriteStringN(#scad, "x_scale = "+GetGadgetText(SAx)+";")
    WriteStringN(#scad, "y_scale = "+GetGadgetText(SAy)+";")
    WriteStringN(#scad, "z_scale = 1;")
    WriteStringN(#scad, "")
    WriteStringN(#scad, "difference() {")
    Select GetGadgetState(ARFc)
      Case 0 ;Zuerst X-Achse, dann Y-Achse
        WriteStringN(#scad, "  rotate([0,0,0])")
        WriteStringN(#scad, "  mirror([0,0,0])")
      Case 1 ;Zuerst Y-Achse, dann X-Achse
        WriteStringN(#scad, "  rotate([0,0,-90])")
        WriteStringN(#scad, "  mirror([1,0,0])")
    EndSelect
    WriteStringN(#scad, "  scale([x_scale, y_scale, z_scale])")
    WriteStringN(#scad, "  surface(file = "+#DOUBLEQUOTE$+"surface.dat"+
                    #DOUBLEQUOTE$+", center = false);")
    WriteStringN(#scad, "  translate([0,0,-50])")
    WriteStringN(#scad, "  cube([500, 500, 100], center=true);")
    WriteStringN(#scad, "}")
    WriteStringN(#scad, "")
    CloseFile(#scad)
  Else
    StatusBarText(0, 2, "Konnte Datei nicht erstellen!")
  EndIf
EndProcedure

Procedure UpdateSCADTimestamp(DateiName$)
  Protected File, Content$, Pos, NewLine$ = "//Last Update: " + FormatDate("%hh:%ii:%ss", Date())
  ;Wir öffnen die Datei im normalen Schreib/Lese-Modus (nicht Append!)
  If OpenFile(#scad, DateiName$)
    ;1. Die gesamte Datei in einen String einlesen
    ;Wir nutzen Lof(File), um genau zu wissen, wie viel wir lesen müssen.
    FileSeek(#scad, 0)
    Content$ = ReadString(#scad, #PB_File_IgnoreEOL, Lof(#scad))
    ;2. Suchen, ob unser Kommentar schon existiert
    Pos = FindString(Content$, "//Last Update:")
    If Pos > 0
      ;Falls gefunden: Den Pointer genau an den Anfang des alten Kommentars setzen
      ;(PB Strings sind 1-basiert, Dateipointer 0-basiert, daher Pos-1)
      FileSeek(#scad, Pos - 1)
    Else
      ;Falls nicht gefunden: Ans Ende der Datei springen
      FileSeek(#scad, Lof(#scad))
      WriteStringN(#scad, "") ; Eine Leerzeile zur Sicherheit
    EndIf
    ;3. Den neuen Zeitstempel schreiben
    ;Das überschreibt ab dieser Position alles Folgende oder hängt es neu an
    WriteStringN(#scad, NewLine$)
    ;4. WICHTIG: Falls der neue String kürzer wäre als der alte, 
    ;müssten wir den Rest der Datei abschneiden (Truncate).
    ;Da unser Zeitstempel aber immer gleich lang ist, reicht CloseFile.
    TruncateFile(#scad) 
    CloseFile(#scad)
  EndIf
EndProcedure

Procedure EditorAutoScroll(Gadget)
  ;1. Den "Cursor" (Selection) ganz ans Ende setzen (-1)
  SendMessage_(GadgetID(Gadget), #EM_SETSEL, -1, -1)
  ;2. Die Ansicht zum Cursor scrollen
  SendMessage_(GadgetID(Gadget), #EM_SCROLLCARET, 0, 0)
EndProcedure

Procedure.s TimeDateMS()
  Protected st.SYSTEMTIME
  ;Windows API aufrufen, um die Systemzeit inkl. MS zu holen
  GetLocalTime_(@st)
  ;Manuelles Zusammenbauen des Formats: [hh:ii:ss.ms dd.mm.yyyy]
  ProcedureReturn "[" + 
                  RSet(Str(st\wDay), 2, "0") + "." + 
                  RSet(Str(st\wMonth), 2, "0") + "." + 
                  Str(st\wYear) + " " + 
                  RSet(Str(st\wHour), 2, "0") + ":" + 
                  RSet(Str(st\wMinute), 2, "0") + ":" + 
                  RSet(Str(st\wSecond), 2, "0") + "." + 
                  RSet(Str(st\wMilliseconds), 3, "0") + "]"
EndProcedure

Enumeration LogTyp
  #info ;🛈
  #up   ;⯅
  #down ;⯆
EndEnumeration
  
Procedure Loggen(typ, text.s)
  If GetMenuItemState(0, #LogFile)
    text.s = TimeDateMS() + ": " + text.s
    Select typ
      Case #info
        text.s = "🛈 " + text.s
      Case #up
        text.s = "⯅ " + text.s
      Case #down
        text.s = "⯆ " + text.s
    EndSelect
    If IsFile(#log)
      WriteStringN(#log, text.s)
    EndIf
  EndIf
EndProcedure

Macro Unicode(Mem, Type = #PB_Ascii)
  PeekS(Mem, -1, Type)
EndMacro

;wiederholen.c (Character, .c, 0 to +65535) in 10ms
Procedure.s SendRec(text.s, wiederholen.c = 2000)
  Ergebnis.s = ""
  If IsSerialPort(SerialPortHandle.i)
    If WriteSerialPortString(SerialPortHandle.i, text.s + NZ$, #PB_UTF8)
      SetGadgetText(GESs, text.s)
      ClearGadgetItems(EMPFs)
      *Puffer = AllocateMemory(1024)
      While AvailableSerialPortInput(SerialPortHandle.i) Or wiederholen.c
        ;While WindowEvent() : Wend ; Grafische Updates erzwingen
        Delay(10) ;warten bis Daten verarbeitet sind und bestätigt wird
        GeleseneBytes.l = ReadSerialPortData(SerialPortHandle.i, *Puffer, 1024)
        If GeleseneBytes.l
          Ergebnis.s + Unicode(*Puffer, #PB_UTF8)
          SetGadgetText(EMPFs, Ergebnis.s)
          EditorAutoScroll(EMPFs)
        Else
          wiederholen.c - 1
        EndIf
        If FindString(Ergebnis.s, "ok" + NZ$, 1, #PB_String_CaseSensitive)
          wiederholen.c = 0
        EndIf
        Debug wiederholen
      Wend
      FreeMemory(*Puffer)
      ;SetGadgetText(EMPFs, Ergebnis.s)
      ProcedureReturn Ergebnis.s
    Else
      StatusBarText(0, 2, "SerialPortError: " + Str(SerialPortError(SerialPortHandle.i)))
    EndIf
  Else
    StatusBarText(0, 2, "Serielle Schnittstelle nicht verfügbar")
  EndIf
EndProcedure

Procedure.s SendRec2(text.s, timeoutMS.i = 20000)
  Protected Ergebnis.s = ""
  Protected *Puffer = AllocateMemory(1024)
  Protected StartZeit.q = ElapsedMilliseconds()
  
  If IsSerialPort(SerialPortHandle.i)
    If WriteSerialPortString(SerialPortHandle.i, text.s + NZ$, #PB_UTF8)
      SetGadgetText(GESs, text.s)
      Loggen(#up, text.s)
      ; Die Schleife läuft, bis das Timeout erreicht ist
      While (ElapsedMilliseconds() - StartZeit) < timeoutMS
        
        ; 1. Prüfen, ob Daten im Eingangspuffer liegen
        While AvailableSerialPortInput(SerialPortHandle.i) > 0
          GeleseneBytes.l = ReadSerialPortData(SerialPortHandle.i, *Puffer, 1024)
          If GeleseneBytes > 0
            Ergebnis + PeekS(*Puffer, GeleseneBytes, #PB_UTF8)
            
            ; UI Updates innerhalb der Datenverarbeitung
            SetGadgetText(EMPFs, Ergebnis)
            EditorAutoScroll(EMPFs)
            ;Loggen, letztes LF weg:
            text.s = RemoveString(Ergebnis, #LF$, #PB_String_CaseSensitive, Len(Ergebnis))
            ;Zwischen-LFs durch CRLF plus 30 Spaces ersetzen:
            text.s = ReplaceString(text.s, #LF$, #CRLF$ + Space(30))
            Loggen(#down, text.s)
            ; Falls "ok" empfangen wurde, können wir sofort aufhören
            If FindString(Ergebnis, "ok" + NZ$)
              FreeMemory(*Puffer)
              ProcedureReturn Ergebnis
            EndIf
          EndIf
        Wend
        
        ; 2. CPU entlasten und Events verarbeiten
        WindowEvent() 
        Delay(1) ; Wichtig, damit die CPU nicht auf 100% geht
      Wend
    EndIf
  Else
    StatusBarText(0, 2, "COM-Port nicht geöffnet!")
  EndIf
  
  If *Puffer : FreeMemory(*Puffer) : EndIf
  ;Debug Ergebnis
  ProcedureReturn Ergebnis
EndProcedure


; Funktion: Extrahieren des numerischen Werts nach einem exakten Schlüssel
; -------------------------------------------------------------------------
; Input:
;   - InputString.s: Der String, aus dem extrahiert werden soll (z.B. "X:1 Y:2 Z:3.45")
;   - TargetKey.s: Der Schlüssel, der gesucht wird (z.B. "Z:")
;   - IgnoredKey.s: Der Schlüssel, der ignoriert wird (z.B. "Z: ")
; Output:
;   - Der extrahierte String-Wert oder eine leere Zeichenkette bei Fehler/Nicht-Fund.
Procedure.s GetValueAfterKeyEx(InputString.s, TargetKey.s, IgnoredKey.s)
  Protected StartPos.l = 1
  Protected ValueString.s
  Protected ExtractedValue.s
  ; Wir suchen den Zielschlüssel (z.B. "Z:") in einer Schleife
  Repeat
    ; 1. Finde die nächste Position des Zielschlüssels
    StartPos = FindString(InputString, TargetKey, StartPos)
    ; 2. Prüfe, ob der Schlüssel überhaupt noch gefunden wurde
    If StartPos = 0
      ProcedureReturn "" ; Zielschlüssel nicht gefunden
    EndIf
    ; 3. Prüfe, ob es sich um den IGNORIERTEN Schlüssel handelt:
    ;    Wir prüfen, ob das Zeichen nach dem TargetKey ein Leerzeichen ist.
    If Mid(InputString, StartPos, Len(IgnoredKey)) = IgnoredKey
      ; Es ist der unerwünschte Schlüssel ("Z: "). Springe zur nächsten Position.
      StartPos + 1
    Else
      ; !!! TREFFER: Es ist der gesuchte Schlüssel (z.B. "Z:") !!!
      ; 4. Schneide den String ab, um mit dem Wert zu beginnen
      ; (StartPos + Len(TargetKey) ist die Position unmittelbar nach dem Schlüssel)
      ValueString = Mid(InputString, StartPos + Len(TargetKey))
      ; 5. Extrahiere den Wert bis zum nächsten Leerzeichen
      ExtractedValue = StringField(ValueString, 1, " ")
      ProcedureReturn ExtractedValue
    EndIf
  ForEver ; Die Schleife läuft, bis der Schlüssel gefunden oder der String beendet ist.
EndProcedure

Procedure.s GetValueUniversal(InputString.s, TargetKey.s, IgnoredKey.s = "")
  Protected StartPos.l = 1
  Protected Result.s
  Repeat
    ; 1. Suche den Schlüssel
    StartPos = FindString(InputString, TargetKey, StartPos)
    If StartPos = 0 : ProcedureReturn "" : EndIf ; Nicht gefunden
    ; 2. Prüfen, ob dieser Treffer ignoriert werden soll
    If IgnoredKey <> "" And Mid(InputString, StartPos, Len(IgnoredKey)) = IgnoredKey
      StartPos + 1 ; Weitersuchen
    Else
      ; 3. Treffer! Schneide alles nach dem Schlüssel ab
      Result = Mid(InputString, StartPos + Len(TargetKey))
      ; 4. Führende Leerzeichen entfernen (wichtig für "z_probe:  TRIGGERED")
      Result = LTrim(Result)
      ; 5. Nur das erste Wort bis zum nächsten Leerzeichen nehmen
      Result = StringField(Result, 1, " ")
      ProcedureReturn Result
    EndIf
  ForEver
EndProcedure

Procedure.s GetPureValue(InputString.s, Key.s, NoSpaceAllowed.b = #False)
  Protected StartPos.l = 1
  Protected *c.Character ; Pointer für schnelles Zeichen-Scanning
  Protected Result.s = ""
  
  Repeat
    ; 1. Schlüssel suchen
    StartPos = FindString(InputString, Key, StartPos)
    If StartPos = 0 : ProcedureReturn "" : EndIf ; Key nicht gefunden
    
    ; 2. Strikte Prüfung: "Z: 2.30" ignorieren, wenn NoSpaceAllowed = #True
    If NoSpaceAllowed And Mid(InputString, StartPos + Len(Key), 1) = " "
      StartPos + 1
      Continue
    EndIf
    
    ; 3. Wir haben den Startpunkt nach dem Key gefunden
    ; Wir springen im Speicher direkt an die Position nach dem Key
    *c = @InputString + (StartPos + Len(Key) - 1) * SizeOf(Character)
    
    ; 4. Führenden "Müll" überspringen (Leerzeichen, CR, LF, Tabs)
    ; Alle Zeichen <= 32 sind Steuerzeichen oder Leerzeichen
    While *c\c <> 0 And *c\c <= 32
      *c + SizeOf(Character)
    Wend
    
    ; 5. Den eigentlichen Wert einsammeln, bis wieder "Müll" kommt
    While *c\c > 32 
      Result + Chr(*c\c)
      *c + SizeOf(Character)
    Wend
    
    ; Falls wir etwas gefunden haben, geben wir es zurück
    If Result <> ""
      ProcedureReturn Result
    EndIf
    
    ; Falls nach dem Key nur Müll kam, suchen wir weiter (falls der Key mehrmals vorkommt)
    StartPos + 1
  ForEver
EndProcedure


Procedure.s KonvertiereZuZeit(Sekunden.i)
  Protected Stunden.i, Minuten.i, RestSekunden.i
  ;Berechnung der Einheiten
  Stunden = Sekunden / 3600
  Minuten = (Sekunden % 3600) / 60
  RestSekunden = Sekunden % 60
  ;Rückgabe als formatierter String (HH:MM:SS)
  ;RSet fügt bei Bedarf führende Nullen hinzu
  ProcedureReturn RSet(Str(Stunden), 2, "0") + ":" + 
                  RSet(Str(Minuten), 2, "0") + ":" + 
                  RSet(Str(RestSekunden), 2, "0")
EndProcedure


Procedure RemoveShortcuts()
  ;Alternativ:
  ;RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_All)
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad4) ; X-
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad6) ; X+
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad2) ; Y-
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad8) ; Y+
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad3) ; Z-
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad9) ; Z+
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad1) ; Y-, Layout 2
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad7) ; 7 = Home
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Add) ;+ = Schrittweite erhöhen
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Subtract) ;- = Schrittweite erniedrigen
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Divide) ; "/" = Anfang Scan-Area setzen
  RemoveKeyboardShortcut(WindowScanner, #PB_Shortcut_Multiply) ; "*" = Ende Scan-Area setzen
EndProcedure

Procedure AddShortcuts(Layout)
  RemoveShortcuts()
  Select Layout
    Case 1
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad4, #T1) ; X-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad6, #T2) ; X+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad2, #T3) ; Y-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad8, #T4) ; Y+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad3, #T5) ; Z-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad9, #T6) ; Z+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad7, #Homing) ; 7 = Home
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Add,  #SWplus) ; + = Schrittweite erhöhen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Subtract, #SWminus) ; - = Schrittweite erniedrigen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Divide, #SC_ASA_set) ; "/" = Anfang Scan-Area setzen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Multiply, #SC_ESA_set) ; "*" = Ende Scan-Area setzen
    Case 2
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad4, #T1) ; X-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad6, #T2) ; X+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad1, #T3) ; Y-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad9, #T4) ; Y+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad2, #T5) ; Z-
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad8, #T6) ; Z+
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Pad7, #Homing) ; 7 = Home
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Add,  #SWplus) ; + = Schrittweite erhöhen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Subtract, #SWminus) ; - = Schrittweite erniedrigen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Divide, #SC_ASA_set) ; "/" = Anfang Scan-Area setzen
      AddKeyboardShortcut(WindowScanner, #PB_Shortcut_Multiply, #SC_ESA_set) ; "*" = Ende Scan-Area setzen
  EndSelect
EndProcedure

Procedure ShortCutsAus(EventType)
  ShortCuts = #ShortCutsAus
  RemoveShortcuts()
  SetMenuItemState(0, #LNBaus, 1)
  SetMenuItemState(0, #LNB1, 0)
  SetMenuItemState(0, #LNB2, 0)
EndProcedure

Procedure ShortCutsLayout1(EventType)
  ShortCuts = #ShortCutsLayout1
  AddShortcuts(ShortCuts)
  SetMenuItemState(0, #LNBaus, 0)
  SetMenuItemState(0, #LNB1, 1)
  SetMenuItemState(0, #LNB2, 0)
EndProcedure

Procedure ShortCutsLayout2(EventType)
  ShortCuts = #ShortCutsLayout2
  AddShortcuts(ShortCuts)
  SetMenuItemState(0, #LNBaus, 0)
  SetMenuItemState(0, #LNB1, 0)
  SetMenuItemState(0, #LNB2, 1)
EndProcedure

Procedure LogfileMenu(EventType)
  If GetMenuItemState(0, #LogFile)
    SetMenuItemState(0, #LogFile, 0)
    Logfile = 0
  Else
    SetMenuItemState(0, #LogFile, 1)
    Logfile = 1
  EndIf
EndProcedure


Procedure Logfile(EventType)
  If GetMenuItemState(0, #LogFile) = 1
    Logfile = #Aus
    SetMenuItemState(0, #LogFile, 0)
  Else
    Logfile = #Ein
    SetMenuItemState(0, #LogFile, 1)
  EndIf
EndProcedure

Procedure MelodieMenu(EventType)
  If GetMenuItemState(0, #Melodie)
    SetMenuItemState(0, #Melodie, 0)
    Melodie = #Aus
  Else
    SetMenuItemState(0, #Melodie, 1)
    Melodie = #Ein
  EndIf
EndProcedure


;Definition der Funktion aus der Windows-API
Prototype.i MessageBoxTimeout(hWnd.l, lpText.p-unicode, lpCaption.p-unicode, uType.l, wLanguageID.w, dwMilliseconds.l)

Global MessageBoxTimeout.MessageBoxTimeout
If OpenLibrary(0, "user32.dll")
  MessageBoxTimeout = GetFunction(0, "MessageBoxTimeoutW")
EndIf

Procedure QuickInfo(Nachricht.s)
  ;Zeigt ein Fenster für 600ms an
  MessageBoxTimeout(WindowID(WindowScanner), Nachricht.s, "Nadir Info", #MB_ICONINFORMATION | #MB_SETFOREGROUND, 0, 600)
EndProcedure

Procedure StringGadgetVerifizieren(EventGadget, EventType)
  Select EventType
    ;TextGadget hat Fokus verloren
    Case #PB_EventType_LostFocus
      If EventGadget = APx Or EventGadget = APy Or EventGadget = APz Or EventGadget = ASAx Or
         EventGadget = ASAy Or EventGadget = ASAz Or EventGadget = ESAx Or EventGadget = ESAy Or
         EventGadget = ESAz Or EventGadget = GSAx Or EventGadget = GSAy Or EventGadget = GSAz Or
         EventGadget = SAx Or EventGadget = SAy Or EventGadget = SAz Or EventGadget = OSx Or
         EventGadget = OSy Or EventGadget = OSz Or EventGadget = mGx Or EventGadget = mGy Or
         EventGadget = mGz
        SetGadgetText(EventGadget, StrF(ValF(GetGadgetText(EventGadget)), 2))
      EndIf
      ;wenn in Gadget Anfang/Ende Scan-Area
      If EventGadget = ASAx Or EventGadget = ASAy Or EventGadget = ASAz Or EventGadget = ESAx Or
         EventGadget = ESAy Or EventGadget = ESAz Or EventGadget = SAx Or EventGadget = SAy
        anzahlPunkte.f = (((ValF(GetGadgetText(ESAx)) - ValF(GetGadgetText(ASAx))) / ValF(GetGadgetText(SAx))) + 1)
        anzahlPunkte.f * (((ValF(GetGadgetText(ESAy)) - ValF(GetGadgetText(ASAy))) / ValF(GetGadgetText(SAy))) + 1)
        SetGadgetText(ASPs, StrF(anzahlPunkte.f))
        erwarteteZeit.f = (ValF(GetGadgetText(ESAz)) - ValF(GetGadgetText(ASAz))) * anzahlPunkte.f
        ;hier ist die erwartete Zeit = der Scanhöhe als Sekunden, evtl. mit Korrekturfaktor:
        erwarteteZeit.f * 1.5
        SetGadgetText(EZs, KonvertiereZuZeit(erwarteteZeit.f))
        ;Grösse Scan-Area:
        SetGadgetText(GSAx, StrF((ValF(GetGadgetText(ESAx)) - ValF(GetGadgetText(ASAx))), 2))
        SetGadgetText(GSAy, StrF((ValF(GetGadgetText(ESAy)) - ValF(GetGadgetText(ASAy))), 2))
        SetGadgetText(GSAz, StrF((ValF(GetGadgetText(ESAz)) - ValF(GetGadgetText(ASAz))), 2))
      EndIf
      AddShortcuts(ShortCuts)
      Debug "AddShortCuts()"
    ;Fokus erhalten
    Case #PB_EventType_Focus
      Debug "RemoveShortCuts()"
      RemoveShortcuts()
  EndSelect
EndProcedure

;Anfang Scan-Area aus aktueller Position übernehmen
Procedure ASAausAktPos(EventType)
  SetGadgetText(ASAx, GetGadgetText(APx))
  SetGadgetText(ASAy, GetGadgetText(APy))
  SetGadgetText(ASAz, GetGadgetText(APz))
  StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)
  StringGadgetVerifizieren(ASAy, #PB_EventType_LostFocus)
  StringGadgetVerifizieren(ASAz, #PB_EventType_LostFocus)
EndProcedure

;Ende Scan-Area aus aktueller Position übernehmen
Procedure ESAausAktPos(EventType)
  SetGadgetText(ESAx, GetGadgetText(APx))
  SetGadgetText(ESAy, GetGadgetText(APy))
  SetGadgetText(ESAz, GetGadgetText(APz))
  StringGadgetVerifizieren(ESAx, #PB_EventType_LostFocus)
  StringGadgetVerifizieren(ESAy, #PB_EventType_LostFocus)
  StringGadgetVerifizieren(ESAz, #PB_EventType_LostFocus)
EndProcedure


Procedure ConfigLaden()
  OpenPreferences("Nadir.ini")
  ResizeWindow(WindowScanner, ReadPreferenceInteger("Fensterposition X", 100),
               ReadPreferenceInteger("Fensterposition Y", 100), #PB_Ignore, #PB_Ignore)
  SetGadgetText(ASAx, ReadPreferenceString("Anfang Scan-Area X", "30.00"))
  SetGadgetText(ASAy, ReadPreferenceString("Anfang Scan-Area Y", "30.00"))
  SetGadgetText(ASAz, ReadPreferenceString("Anfang Scan-Area Z", "0.00"))
  SetGadgetText(ESAx, ReadPreferenceString("Ende Scan-Area X", "31.00"))
  SetGadgetText(ESAy, ReadPreferenceString("Ende Scan-Area Y", "31.00"))
  SetGadgetText(ESAz, ReadPreferenceString("Ende Scan-Area Z", "1.00"))
  SetGadgetText(SAx, ReadPreferenceString("Scan Auflösung X", "0.10"))
  SetGadgetText(SAy, ReadPreferenceString("Scan Auflösung Y", "0.10"))
  SetGadgetText(SAz, ReadPreferenceString("Scan Auflösung Z", "0.10"))
  SetGadgetText(mGx, ReadPreferenceString("Maximale Geschwindigkeit X", "5.00"))
  SetGadgetText(mGy, ReadPreferenceString("Maximale Geschwindigkeit Y", "5.00"))
  SetGadgetText(mGz, ReadPreferenceString("Maximale Geschwindigkeit Z", "2.50"))
  SetGadgetState(mGs, ReadPreferenceInteger("Maximale Geschwindigkeit senden", #PB_Checkbox_Unchecked))
  SetGadgetState(mBx, ReadPreferenceInteger("Maximale Beschleunigung X", 100))
  SetGadgetState(mBy, ReadPreferenceInteger("Maximale Beschleunigung Y", 100))
  SetGadgetState(mBz, ReadPreferenceInteger("Maximale Beschleunigung Z", 20))
  SetGadgetState(mBs, ReadPreferenceInteger("Maximale Beschleunigung senden", #PB_Checkbox_Unchecked))
  SetGadgetState(SFe, ReadPreferenceInteger("Scanfehler erkennen", #PB_Checkbox_Unchecked))
  SetGadgetState(VAFc, ReadPreferenceInteger("Voransichtsfenster", #PB_Checkbox_Checked))
  SetGadgetState(HvS, ReadPreferenceInteger("Homing vor Scan", #PB_Checkbox_Unchecked))
  SetGadgetState(MaS, ReadPreferenceInteger("Mäander Scan", #PB_Checkbox_Unchecked))
  SetGadgetState(ScVc, ReadPreferenceInteger("Scan-Verfahren", 0))
  SetGadgetState(ARFc, ReadPreferenceInteger("Achsenreihenfolge", 0))
  SetGadgetState(SpVc, ReadPreferenceInteger("Speicher-Verfahren", 0))
  SetGadgetText(DNs, ReadPreferenceString("Dateiname", ""))
  SetGadgetText(Str1Txt, ReadPreferenceString("Individueller String 1", ""))
  SetGadgetText(Str2Txt, ReadPreferenceString("Individueller String 2", ""))
  SetGadgetText(Str3Txt, ReadPreferenceString("Individueller String 3", ""))
  ShortCuts = ReadPreferenceInteger("Layout Nummernblock", #ShortCutsAus)
  Logfile = ReadPreferenceInteger("Logfile schreiben", #Aus)
  Melodie = ReadPreferenceInteger("Melodie bei Scan Ende", #Aus)
  ClosePreferences()
EndProcedure  

Procedure ConfigSpeichern()
  OpenPreferences("Nadir.ini")
  WritePreferenceInteger("Fensterposition X", WindowX(WindowScanner))
  WritePreferenceInteger("Fensterposition Y", WindowY(WindowScanner))
  WritePreferenceString("Anfang Scan-Area X", GetGadgetText(ASAx))
  WritePreferenceString("Anfang Scan-Area Y", GetGadgetText(ASAy))
  WritePreferenceString("Anfang Scan-Area Z", GetGadgetText(ASAz))
  WritePreferenceString("Ende Scan-Area X", GetGadgetText(ESAx))
  WritePreferenceString("Ende Scan-Area Y", GetGadgetText(ESAy))
  WritePreferenceString("Ende Scan-Area Z", GetGadgetText(ESAz))
  WritePreferenceString("Scan Auflösung X", GetGadgetText(SAx))
  WritePreferenceString("Scan Auflösung Y", GetGadgetText(SAy))
  WritePreferenceString("Scan Auflösung Z", GetGadgetText(SAz))
  WritePreferenceString("Maximale Geschwindigkeit X", GetGadgetText(mGx))
  WritePreferenceString("Maximale Geschwindigkeit Y", GetGadgetText(mGy))
  WritePreferenceString("Maximale Geschwindigkeit Z", GetGadgetText(mGz))
  WritePreferenceInteger("Maximale Geschwindigkeit senden", GetGadgetState(mGs))
  WritePreferenceInteger("Maximale Beschleunigung X", GetGadgetState(mBx))
  WritePreferenceInteger("Maximale Beschleunigung Y", GetGadgetState(mBy))
  WritePreferenceInteger("Maximale Beschleunigung Z", GetGadgetState(mBz))
  WritePreferenceInteger("Maximale Beschleunigung senden", GetGadgetState(mBs))
  WritePreferenceInteger("Scanfehler erkennen", GetGadgetState(SFe))
  WritePreferenceInteger("Voransichtsfenster", GetGadgetState(VAFc))
  WritePreferenceInteger("Homing vor Scan", GetGadgetState(HvS))
  WritePreferenceInteger("Mäander Scan", GetGadgetState(MaS))
  WritePreferenceInteger("Scan-Verfahren", GetGadgetState(ScVc))
  WritePreferenceInteger("Achsenreihenfolge", GetGadgetState(ARFc))
  WritePreferenceInteger("Speicher-Verfahren", GetGadgetState(SpVc))
  WritePreferenceString("Dateiname", GetGadgetText(DNs))
  WritePreferenceString("Individueller String 1", GetGadgetText(Str1Txt))
  WritePreferenceString("Individueller String 2", GetGadgetText(Str2Txt))
  WritePreferenceString("Individueller String 3", GetGadgetText(Str3Txt))
  WritePreferenceInteger("Layout Nummernblock", ShortCuts)
  WritePreferenceInteger("Logfile schreiben", Logfile)
  WritePreferenceInteger("Melodie bei Scan Ende", Melodie)
  ClosePreferences()
EndProcedure  

Procedure ScanAufloesung010(EventType)
  SetGadgetText(SAx, "0.10")
  SetGadgetText(SAy, "0.10")
  StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)
EndProcedure

Procedure ScanAufloesung020(EventType)
  SetGadgetText(SAx, "0.20")
  SetGadgetText(SAy, "0.20")
  StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)
EndProcedure

Procedure ScanAufloesung050(EventType)
  SetGadgetText(SAx, "0.50")
  SetGadgetText(SAy, "0.50")
  StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)
EndProcedure

Procedure ScanAufloesung100(EventType)
  SetGadgetText(SAx, "1.00")
  SetGadgetText(SAy, "1.00")
  StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)
EndProcedure


; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 758
; FirstLine = 678
; Folding = -----9---
; EnableXP
; DPIAware