Global WindowGCode

Procedure gcodes(EventType)
  If Not IsWindow(WindowGCode)
    WindowGCode = OpenWindow(#PB_Any, 100, 100, 980, 600, "G-Codes", #PB_Window_SystemMenu)
    WebViewGadget(0, 0, 0, 980, 600)
    SetGadgetText(0, "file://" + GetCurrentDirectory() + "gcode.html")
    CompilerIf #PB_Compiler_IsMainFile
      Repeat 
        Event = WaitWindowEvent()
      Until Event = #PB_Event_CloseWindow
    CompilerEndIf
  Else
    SetActiveWindow(WindowGCode)
  EndIf
EndProcedure

Procedure WindowGCode_Events(Event)
  Select event
    Case #PB_Event_CloseWindow
      CloseWindow(WindowGCode)
  EndSelect
EndProcedure

Global WindowManual

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

Procedure bedienung(EventType)
  If Not IsWindow(WindowBedienung)
    OpenWindowBedienung()
  EndIf
EndProcedure

Procedure Ueber(EventType)
  MessageRequester("Über...", ~"Nadir 3D\n2026 by Chregu Müller\nchregu@vtxmail.ch", #PB_MessageRequester_Ok)
EndProcedure

Global NZ$ = #LF$  ;0x0A, 10 dezimal, \n, für MKS TinyBee
;Global NZ$ = #CR$  ;0x0D, 13 dezimal, \r, für TeaCup Firmware

#move_quick = "G0"
#move = "G1"
#pause_ms = "G4 P"
#set_units_To_millimeters = "G21"
#home_all_axes = "G28"
#single_z_probe = "G30"
#use_absolute_coordinates = "G90"
#use_relative_coordinates = "G91"
#set_position = "G92"
#disable_motors = "M84"
#set_bed_temperature = "M140 S"
#get_firmware_version = "M115"
#get_current_position = "M114"
#get_endstop_status = "M119" ;Get Endstop Status
#schnell = 1000   ;in [mm/min.] entspricht 16.6 [mm/s]
#langsam = 500

Global ComPort.s = "COM1"
Global ComBaud.l = 115200
Global serialPortOpen.i

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
      StatusBarText(0, 2, LTrim(LTrim(LTrim(ComPort.s, "\"), "."), "\") + " geöffnet")
      ;DisableGadget(Combo_5, 1)
      ;DisableGadget(Text_15, 0)
      ;DisableGadget(Button_6, 0)
    Else
      StatusBarText(0, 2, ComPort.s + " konnte nicht geöffnet werden")
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
  If CreateFile(0, DateiName$)  ;neue Textdatei erstellen
    WriteStringN(0, "//surface.scad")
    WriteStringN(0, "")
    WriteStringN(0, "x_scale = "+GetGadgetText(SAx)+";")
    WriteStringN(0, "y_scale = "+GetGadgetText(SAy)+";")
    WriteStringN(0, "z_scale = 1;")
    WriteStringN(0, "")
    WriteStringN(0, "mirror([1,0,0])")
    WriteStringN(0, "scale([x_scale, y_scale, z_scale])")
    WriteStringN(0, "surface(file = "+#DOUBLEQUOTE$+"surface.dat"+
                    #DOUBLEQUOTE$+", center = false);")
    WriteStringN(0, "")
    CloseFile(0)
  Else
    StatusBarText(0, 2, "Konnte Datei nicht erstellen!")
  EndIf
EndProcedure

Macro Unicode(Mem, Type = #PB_Ascii)
  PeekS(Mem, -1, Type)
EndMacro

Procedure EditorAutoScroll(Gadget)
  ; 1. Den "Cursor" (Selection) ganz ans Ende setzen (-1)
  SendMessage_(GadgetID(Gadget), #EM_SETSEL, -1, -1)
  ; 2. Die Ansicht zum Cursor scrollen
  SendMessage_(GadgetID(Gadget), #EM_SCROLLCARET, 0, 0)
EndProcedure

;wiederholen.c (Character, .c, 0 to +65535) in 10ms
Procedure.s SendRec(text.s, wiederholen.c = 2000)
  Ergebnis.s = ""
  If IsSerialPort(SerialPortHandle.i)
    If WriteSerialPortString(SerialPortHandle.i, text.s + NZ$, #PB_UTF8)
      SetGadgetText(GESs, text.s)
      ClearGadgetItems(EMPFs)
      *Puffer = AllocateMemory(1024)
      While AvailableSerialPortInput(SerialPortHandle.i) Or wiederholen.c
        While WindowEvent() : Wend ; Grafische Updates erzwingen
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

Procedure set_bed_temperature(temperatur.l)
  PrintN(SendRec2(#set_bed_temperature + Str(temperatur.l)))
EndProcedure

;beim Fahren zum Anfang Scan-Area kann man normal nach absoluten Koordinaten fahren
;beim Scannen wird von Anfang Scan-Area auf Null gesetzt und von dort absolut gefahren
;nach dem Scannen zumAnfang Scan-Area gefahren und die Koordinaten wieder aktualisiert
Procedure move(x.f, y.f, z.f, f.f=#schnell)
  SendRec2(#move +
           " X" + StrF(x.f, 2) +
           " Y" + StrF(y.f, 2) +
           " Z" + StrF(z.f, 2) +
           " F" + StrF(f.f, 2))
  SetGadgetText(APx, StrF(x.f, 2))
  SetGadgetText(APy, StrF(y.f, 2))
  SetGadgetText(APz, StrF(z.f, 2))
EndProcedure

Procedure moveRel(x.f, y.f, z.f)
  absKrd.f(#x) + x.f
  absKrd.f(#y) + y.f
  absKrd.f(#z) + z.f
  move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))
EndProcedure

Procedure Xp01(EventType) : moveRel( 0.1, 0, 0) : EndProcedure ;X  +0.1mm
Procedure Xp1(EventType)  : moveRel(   1, 0, 0) : EndProcedure ;X  +1mm
Procedure Xp10(EventType) : moveRel(  10, 0, 0) : EndProcedure ;X +10mm
Procedure Xm01(EventType) : moveRel(-0.1, 0, 0) : EndProcedure ;X  -0.1mm
Procedure Xm1(EventType)  : moveRel(  -1, 0, 0) : EndProcedure ;X  -1mm
Procedure Xm10(EventType) : moveRel( -10, 0, 0) : EndProcedure ;X -10mm

Procedure Yp01(EventType) : moveRel(0, 0.1,  0) : EndProcedure ;Y  +0.1mm
Procedure Yp1(EventType)  : moveRel(0,   1,  0) : EndProcedure ;Y  +1mm
Procedure Yp10(EventType) : moveRel(0,  10,  0) : EndProcedure ;Y +10mm
Procedure Ym01(EventType) : moveRel(0,-0.1,  0) : EndProcedure ;Y  -0.1mm
Procedure Ym1(EventType)  : moveRel(0,  -1,  0) : EndProcedure ;Y  -1mm
Procedure Ym10(EventType) : moveRel(0, -10,  0) : EndProcedure ;Y -10mm
                                      
Procedure Zp01(EventType) : moveRel(0,  0, 0.1) : EndProcedure ;Z  +0.1mm
Procedure Zp1(EventType)  : moveRel(0,  0,   1) : EndProcedure ;Z  +1mm
Procedure Zp10(EventType) : moveRel(0,  0,  10) : EndProcedure ;Z +10mm
Procedure Zm01(EventType) : moveRel(0,  0,-0.1) : EndProcedure ;Z  -0.1mm
Procedure Zm1(EventType)  : moveRel(0,  0,  -1) : EndProcedure ;Z  -1mm
Procedure Zm10(EventType) : moveRel(0,  0, -10) : EndProcedure ;Z -10mm

Procedure FahrenNachAktuellePosition(EventType)
  absKrd.f(#x) = ValF(GetGadgetText(APx))
  absKrd.f(#y) = ValF(GetGadgetText(APy))
  absKrd.f(#z) = ValF(GetGadgetText(APz))
  move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))
  ;so gehts nicht, absKrd wird nicht aktualisiert:
  ;move(ValF(GetGadgetText(APx)), ValF(GetGadgetText(APy)), ValF(GetGadgetText(APz)))
EndProcedure

Procedure FahrenNachAnfangScanArea(EventType)
  absKrd.f(#x) = ValF(GetGadgetText(ASAx))
  absKrd.f(#y) = ValF(GetGadgetText(ASAy))
  absKrd.f(#z) = ValF(GetGadgetText(ASAz))
  move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))
EndProcedure

Procedure FahrenNachEndeScanArea(EventType)
  absKrd.f(#x) = ValF(GetGadgetText(ESAx))
  absKrd.f(#y) = ValF(GetGadgetText(ESAy))
  absKrd.f(#z) = ValF(GetGadgetText(ESAz))
  move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))
EndProcedure

Procedure MotorenAbschalten(EventType)
  SendRec2(#disable_motors)
EndProcedure

Procedure individuellerString1Senden(EventType)
  SendRec2(GetGadgetText(Str1Txt))
EndProcedure
Procedure individuellerString2Senden(EventType)
  SendRec2(GetGadgetText(Str2Txt))
EndProcedure
Procedure individuellerString3Senden(EventType)
  SendRec2(GetGadgetText(Str3Txt))
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


Procedure maxGeschwEinstellen(EventType)
  SendRec2("M203 X" + GetGadgetText(mGx) + " Y" +
           GetGadgetText(mGy) + " Z" +
           GetGadgetText(mGz) + " E25.00") ;Maximale Geschwindigkeit [mm/s]
EndProcedure

Procedure maxBeschlEinstellen(EventType)
  SendRec2("M201 X" + GetGadgetText(mBx) + " Y" +
           GetGadgetText(mBy) + " Z" +
           GetGadgetText(mBz) + " E1000") ;Maximale Geschwindigkeit [mm/s]
EndProcedure

Procedure Druckerinitialisieren()
  ;SendRec2(#get_firmware_version)  ;kommt viel zu viel Text zurück!
  SendRec2(#set_units_To_millimeters)
  SendRec2(#use_absolute_coordinates)
  ;SendRec2("G92 X0 Y0 Z0")   ;setze den Nullpunkt hier
  
  ;SendRec2("M92 X2145.00 Y2145.00 Z2210.00 E96.00")   ;Schritte pro [mm]
  ;SendRec2("M203 X5.00 Y5.00 Z2.50 E25.00")       ;Maximale Geschwindigkeit [mm/s]
  maxGeschwEinstellen(0)
  ;SendRec2("M201 X100.00 Y100.00 Z20.00 E1000.00");Maximale Beschleunigung [mm/s^2]
  maxBeschlEinstellen(0)
EndProcedure

Procedure Homing(EventType)
  SendRec2(#home_all_axes, 20000)
  ;noch alle Koordinaten auf 0 setzen:
  absKrd.f(#x) = 0
  absKrd.f(#y) = 0
  absKrd.f(#z) = 0
  relKrd.f(#x) = 0
  relKrd.f(#y) = 0
  relKrd.f(#z) = 0
  SetGadgetText(APx, "0.00")
  SetGadgetText(APy, "0.00")
  SetGadgetText(APz, "0.00")
EndProcedure

Procedure.f Scan(EventType)
  Ergebnis.s = SendRec2(#single_z_probe, 20000)
  Ergebnis.s = GetValueAfterKeyEx(Ergebnis.s, "Z:", "Z: ")
  ProcedureReturn ValF(Ergebnis.s)
EndProcedure

Procedure ScanVonForm(EventType)
  Scan(0)
EndProcedure

Procedure Auf(EventType)
  SendRec2(#move + " Z" + GetGadgetText(ESAz))
EndProcedure

Procedure.s KonvertiereZuZeit(Sekunden.i)
  Protected Stunden.i, Minuten.i, RestSekunden.i
  ; Berechnung der Einheiten
  Stunden = Sekunden / 3600
  Minuten = (Sekunden % 3600) / 60
  RestSekunden = Sekunden % 60
  ; Rückgabe als formatierter String (HH:MM:SS)
  ; RSet fügt bei Bedarf führende Nullen hinzu
  ProcedureReturn RSet(Str(Stunden), 2, "0") + ":" + 
                  RSet(Str(Minuten), 2, "0") + ":" + 
                  RSet(Str(RestSekunden), 2, "0")
EndProcedure

Procedure StringGadgetVerifizieren(EventGadget, EventType)
  ;TextGadget hat Fokus verloren
  If EventType = #PB_EventType_LostFocus
    If IsNAN(ValF(GetGadgetText(EventGadget)))
      Debug "Keine Zahl"
    Else
      SetGadgetText(EventGadget, StrF(ValF(GetGadgetText(EventGadget)), 2))
    EndIf
    ;wenn in Gadget Anfang/Ende Scan-Area
    If EventGadget = ASAx Or ASAy Or ASAz Or ESAx Or ESAy Or ESAz Or SAx Or SAy
      anzahlPunkte.f = (((ValF(GetGadgetText(ESAx)) - ValF(GetGadgetText(ASAx))) / ValF(GetGadgetText(SAx))) + 1)
      anzahlPunkte.f * (((ValF(GetGadgetText(ESAy)) - ValF(GetGadgetText(ASAy))) / ValF(GetGadgetText(SAy))) + 1)
      SetGadgetText(ASPs, StrF(anzahlPunkte.f))
      erwarteteZeit.f = (ValF(GetGadgetText(ESAz)) - ValF(GetGadgetText(ASAz))) * anzahlPunkte.f
      ;hier ist die erwartete Zeit = der Scanhöhe als Sekunden, evtl. mit Korrekturfaktor:
      erwarteteZeit.f * 1
      SetGadgetText(EZs, KonvertiereZuZeit(erwarteteZeit.f))
    EndIf
  EndIf
EndProcedure

Procedure EndschalterAbfragen(EventType)
  Ergebnis.s = SendRec2(#get_endstop_status)
  ;Bekomme zurück:
  ;Reporting endstop status
  ;x_min: open
  ;y_min: open
  ;z_min: open
  ;z_probe: TRIGGERED
  ;ok
  ;Ergebnis.s = GetValueAfterKeyEx(Ergebnis.s, "z_probe: ", "z_probe:")
  ;Ergebnis.s = GetValueUniversal(Ergebnis.s, "z_probe:")
  Ergebnis.s = GetPureValue(Ergebnis.s, "z_probe: ")
  ;TRIGGERED oder TRUE ist: Hat Kontakt mit Oberfläche!
  If Ergebnis.s = "TRIGGERED"
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure ConfigLaden()
  OpenPreferences("Nadir.ini")
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
  ClosePreferences()
EndProcedure  

Procedure ConfigSpeichern()
  OpenPreferences("Nadir.ini")
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

Procedure.f ScanG40(x.f, y.f, z.f)
  move(x.f, y.f, z.f)
  wert.f = Scan(0)
  move(x.f, y.f, z.f)
  ProcedureReturn wert.f
EndProcedure

;z.f ist die Höhe der Scan Area, also oben!
Procedure.f ScanM119(x.i, y.i, z.f)
  Protected al.f = ValF(GetGadgetText(SAz)) ;Auflösung Z
  ;nur mit X und Y zu den Zielkoordinaten fahren ohne Z:
  move(x.i, y.i, relKrd.f(#z))
  While EndschalterAbfragen(EventType)
    If relKrd.f(#z) > z.f
      Break
    EndIf
    ;jetzt +1mm, bei ebeneren Objekten kleiner, geht dann schneller!
    ;bei grossen Höhenunterschieden gehen grössere Zahlen schneller!
    relKrd.f(#z) + 1
    move(x.i, y.i, relKrd.f(#z))
  Wend
  While Not EndschalterAbfragen(EventType)
    If relKrd.f(#z) < 0
      Break
    EndIf
    relKrd.f(#z) - al.f ;- Auflösung Z
    move(x.i, y.i, relKrd.f(#z))
  Wend
  ProcedureReturn relKrd.f(#z)
EndProcedure

Procedure.f ScanKombiniert(x.i, y.i, z.f)
  Protected al.f = ValF(GetGadgetText(SAz)) ;Auflösung Z
  ;nur mit X und Y zu den Zielkoordinaten fahren ohne Z:
  move(x.i, y.i, relKrd.f(#z))
  While EndschalterAbfragen(EventType)
    If relKrd.f(#z) > z.f
      Break
    EndIf
    ;jetzt +1mm, bei ebeneren Objekten kleiner, geht dann schneller!
    ;bei grossen Höhenunterschieden gehen grössere Zahlen schneller!
    relKrd.f(#z) + 1
    move(x.i, y.i, relKrd.f(#z))
  Wend  
  wert.f = Scan(0)
  ProcedureReturn wert.f
EndProcedure

Procedure Scannen()
  If GetToolBarButtonState(0, #Start)
    If serialPortOpen.i
      If CreateFile(0, GetGadgetText(DNs))  ;neue Textdatei erstellen
        WriteStringN(0, "#surface.dat")
        WriteStringN(0, "#Aufloesung X-Achse: "+GetGadgetText(SAx)+"mm")
        WriteStringN(0, "#Aufloesung Y-Achse: "+GetGadgetText(SAy)+"mm")
        ;Vorbereiten
        StatusBarText(0, 2, "Scan gestartet!")
        If GetGadgetState(HvS) ;Homing vor Scan
          Homing(0)
        EndIf
        If GetGadgetState(mGs) ;max. Geschw. senden
          maxGeschwEinstellen(0)
        EndIf
        If GetGadgetState(mBs) ;max. Beschl. senden
          maxBeschlEinstellen(0)
        EndIf
        ;zum Scan-Anfang fahren
        ;zuerst mit Z ganz rauf
        absKrd.f(#z) = ValF(GetGadgetText(ESAz))
        move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))

        ;dann mit X und Y zum Anfang Scan-Area
        absKrd.f(#x) = ValF(GetGadgetText(ASAx))
        absKrd.f(#y) = ValF(GetGadgetText(ASAy))
        move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))

        ;und mit Z auch noch zum Anfang Scan-Area
        absKrd.f(#z) = ValF(GetGadgetText(ESAz))
        move(absKrd.f(#x), absKrd.f(#y), absKrd.f(#z))
        
        ;Koordinaten auf Null setzen:
        SendRec2(#set_position + " X0 Y0 Z0")
        ;die absoluten Koordinaten sind nun in absKrd.f() gespeichert
        ;von nun an für das Scanen relativ zu Anfang Scan-Area
        
        ;Scan Schleife
        ;Koordinaten für Schlaufe berechnen
        anzahlPunkteX.i = Round(((ValF(GetGadgetText(ESAx)) - ValF(GetGadgetText(ASAx))) / ValF(GetGadgetText(SAx))), #PB_Round_Nearest)
        anzahlPunkteY.i = Round(((ValF(GetGadgetText(ESAy)) - ValF(GetGadgetText(ASAy))) / ValF(GetGadgetText(SAy))), #PB_Round_Nearest)
        If GetGadgetState(SpVc) = 1 ;Datei geöffnet lassen mit Flush
          FlushFileBuffers(0)
        EndIf
        Protected MaxX.i = anzahlPunkteX.i, MaxY.i = anzahlPunkteY.i
        Protected OrderXY.b, MeanderScan.b
        OrderXY.b = GetGadgetState(ARFc) ;Zuerst Y-Achse, dann X-Achse
        MeanderScan.b = GetGadgetState(MaS) ;Mäander Scan
        Protected i.i, j.i, OuterMax.i, InnerMax.i
        Protected CurrentX.i, CurrentY.i
        Protected CurrentInner.i
        ;ProgressBar:
        Protected Fortschritt.i = 0
        StatusBarProgress(0, 1, Fortschritt.i, #PB_StatusBar_Raised, 0, Val(GetGadgetText(ASPs)))
        ;Entscheidung welche Achse erst später:
        Dim ScanData.f(anzahlPunkteX.i + anzahlPunkteY.i)
        ;oberer Z ab relativ Anfang Scan-Area (Scan-Area Höhe):
        Protected SAHz.f = (ValF(GetGadgetText(ESAz)) - ValF(GetGadgetText(ASAz)))
        relKrd.f(#z) = SAHz.f ;der rel. Koordinaten den Startwert für oben geben
        WriteStringN(0, "#Maximale Hoehe: "+StrF(SAHz.f, 2)+"mm")
        ;Bestimme, welche Achse die "äußere" (langsame) und welche die "innere" (schnelle) ist
        If OrderXY.b
          OuterMax = MaxX.i : InnerMax = MaxY.i
        Else
          OuterMax = MaxY.i : InnerMax = MaxX.i
        EndIf
        For i.i = 0 To OuterMax.i
          For j.i = 0 To InnerMax.i
            ;Prüfen auf Stop/Pause
            ;1. GUI am Leben erhalten
            ;Verarbeitet Klicks auf Pause/Stop während der Scan läuft
            While WindowEvent() : Wend 
            ;2. STOP Prüfung
            If GetToolBarButtonState(0, #Stop)
              SetToolBarButtonState(0, #Stop, #False)
              SetToolBarButtonState(0, #Start, #False)
              Break 2 ; Verlässt beide Schleifen (i und j) sofort
            EndIf
            ;3. PAUSE Prüfung
            While GetToolBarButtonState(0, #Pause)
              ;Warte hier, solange Pause aktiv ist
              While WindowEvent() : Wend
              Delay(20) ; CPU entlasten
              ;Falls während Pause Stop gedrückt wird
              If GetToolBarButtonState(0, #Stop)
                SetToolBarButtonState(0, #Stop, #False)
                SetToolBarButtonState(0, #Pause, #False)
                SetToolBarButtonState(0, #Start, #False)
                ;aus der While und den zwei For raus!
                Break 3
              EndIf
            Wend
            ;Scanen vorbereiten
            If MeanderScan.b And (i % 2 = 1) ; Wenn ungerade Zeile
              CurrentInner.i = InnerMax.i - j.i  ; Rückwärts laufen
            Else
              CurrentInner.i = j.i             ; Vorwärts laufen
            EndIf
            ; Das "Mapping": Wir weisen die Schleifenzähler den echten Koordinaten zu
            If OrderXY.b
              CurrentX.i = i.i : CurrentY.i = CurrentInner.i
            Else
              CurrentX.i = CurrentInner.i : CurrentY.i = i.i
            EndIf
            x.f = CurrentX.i * ValF(GetGadgetText(SAx))
            y.f = CurrentY.i * ValF(GetGadgetText(SAy))
            Select GetGadgetState(ScVc) ;Scan-Verfahren
              Case 0 ;Jeden Punkt abtasten mit G40
                ScanData.f(CurrentInner.i) = ScanG40(x.f, y.f, SAHz.f)
              Case 1 ;Oberfläche abfahren mit M119
                ScanData.f(CurrentInner.i) = ScanM119(x.f, y.f, SAHz.f)
              Case 2 ;Kombiniert
                ScanData.f(CurrentInner.i) = ScanKombiniert(x.f, y.f, SAHz.f)
            EndSelect
            ;ProgressBar aktualisieren:
            Fortschritt.i + 1
            StatusBarProgress(0, 1, Fortschritt.i, #PB_StatusBar_Raised,
                              0, Val(GetGadgetText(ASPs)))
          Next j.i
          ;hier Daten speichern ausserhalb der inneren Schleife:
          If Not IsFile(0)
            ;an bestehende Textdatei anfügen
            OpenFile(0, GetGadgetText(DNs), #PB_File_Append)
          EndIf
          For k.i = 0 To InnerMax.i
            If Not k.i = InnerMax.i
              WriteString(0, StrF(ScanData.f(k.i), 2) + " ")
            Else
              WriteStringN(0, StrF(ScanData.f(k.i), 2))
            EndIf
          Next k.i
          ;Datei geöffnet lassen mit Flush:
          If GetGadgetState(SpVc) = 1
            FlushFileBuffers(0)
          EndIf
          ;Datei jedesmal schliessen:
          If GetGadgetState(SpVc) = 2
            CloseFile(0)
          EndIf
          ;OpenSCAD Fenster aktualisieren:
          ;funktioniert nur mit SpVc = 2 (Datei jedesmal schliessen)
          If GetGadgetState(VAFc)
            OriginalName$ = GetGadgetText(DNs)
            DateiName$ = ReplaceEndung(OriginalName$, "scad")
            If OpenFile(1, DateiName$, #PB_File_Append)
              ;Wir schreiben optional einen kleinen Kommentar ans Ende, 
              ;um sicherzugehen, dass Windows die Änderung registriert.
              WriteStringN(1, "//Last Update: " + FormatDate("%hh:%ii:%ss", Date()))
              CloseFile(1)
              EndIf
          EndIf
          ;wenn "Oberfläche abfahren mit M119" oder "Kombiniert" UND NICHT "Mäander-Scan":
          If GetGadgetState(ScVc) > 0 And Not MeanderScan.b
            ;auf obere Höhe fahren damit beim Zurückfahren nicht touchiert wird:
            move(x.f, y.f, SAHz.f)
          EndIf
        Next i.i
        
        ;Ende
        SetToolBarButtonState(0, #Start, #False)
        StatusBarText(0, 2, "Scan beendet!")
        If IsFile(0)
          CloseFile(0)
        EndIf
        ;auf die Scan-Area Höhe fahren
        move(x.f, y.f, SAHz.f)
        ;mit X und Y auf 0
        move(0, 0, SAHz.f)
        ;und runter an den Anfang Scan-Area:
        move(0, 0, 0)
        ;wieder absolute Koordinaten:
        SendRec2(#set_position +
                 " X" + StrF(absKrd.f(#x), 2) +
                 " Y" + StrF(absKrd.f(#y), 2) +
                 " Z" + StrF(absKrd.f(#z), 2))
        SetGadgetText(APx, StrF(absKrd.f(#x), 2))
        SetGadgetText(APy, StrF(absKrd.f(#x), 2))
        SetGadgetText(APz, StrF(absKrd.f(#x), 2))
      Else
        StatusBarText(0, 2, "Konnte Datei nicht erstellen!")
      EndIf
    Else
      SetToolBarButtonState(0, #Start, #False)
      StatusBarText(0, 2, "COM-Port nicht geöffnet!")
    EndIf
  EndIf
EndProcedure

CompilerIf #PB_Compiler_IsMainFile
  gcodes(0)
  End
CompilerEndIf
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 28
; FirstLine = 12
; Folding = --v-----6----
; EnableXP
; DPIAware