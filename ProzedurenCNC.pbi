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

Procedure.f ScanG30(x.f, y.f, z.f)
  move(x.f, y.f, z.f)
  wert.f = Scan(0)
  ;wert.f hat nun den gescannten Wert
  If GetGadgetState(SFe) And (wert.f >= z.f) ;wenn "Scanfehler erkennen" aktiviert
    move(x.f, y.f, -1) ;tief runterfahren um den Kontaktfehler zu beheben
    ;Debug "Scanfehler detektiert:"
    ;Debug wert.f
    wert.f = Scan(0) ;nochmals scannen
  EndIf
  move(x.f, y.f, z.f)
  ProcedureReturn wert.f
EndProcedure

;z.f ist die Höhe der Scan Area, also oben!
Procedure.f ScanM119(x.f, y.f, z.f)
  Protected al.f = ValF(GetGadgetText(SAz)) ;Auflösung Z
  ;nur mit X und Y zu den Zielkoordinaten fahren ohne Z:
  move(x.f, y.f, relKrd.f(#z))
  While EndschalterAbfragen(EventType)
    If relKrd.f(#z) > z.f
      Break
    EndIf
    ;jetzt +1mm, bei ebeneren Objekten kleiner, geht dann schneller!
    ;bei grossen Höhenunterschieden gehen grössere Zahlen schneller!
    ;relKrd.f(#z) + 1
    ;ausprobieren mit plus Auflösung Z
    relKrd.f(#z) + al.f
    move(x.f, y.f, relKrd.f(#z))
  Wend
  While Not EndschalterAbfragen(EventType)
    If relKrd.f(#z) < 0
      Break
    EndIf
    relKrd.f(#z) - al.f ;minus Auflösung Z
    move(x.f, y.f, relKrd.f(#z))
  Wend
  ProcedureReturn relKrd.f(#z)
EndProcedure

Procedure.f ScanKombiniert(x.f, y.f, z.f)
  Protected al.f = ValF(GetGadgetText(SAz)) ;Auflösung Z
  ;nur mit X und Y zu den Zielkoordinaten fahren ohne Z:
  move(x.f, y.f, relKrd.f(#z))
  While EndschalterAbfragen(EventType)
    If relKrd.f(#z) > z.f
      Break
    EndIf
    ;jetzt +1mm, bei ebeneren Objekten kleiner, geht dann schneller!
    ;bei grossen Höhenunterschieden gehen grössere Zahlen schneller!
    relKrd.f(#z) + 1
    move(x.f, y.f, relKrd.f(#z))
  Wend  
  wert.f = Scan(0)
  ProcedureReturn wert.f
EndProcedure

;-Dateiformat .dat für OpenSCAD:
;Das Format für textbasierte Höhenkarten ist eine Zahlenmatrix, welche die
;Höhenwerte für spezifische Punkte darstellt. Die Zeilen werden in Richtung
;der Y-Achse abgebildet, die Spalten in Richtung der X-Achse, wobei zwischen
;benachbarten Zeilen und Spalten jeweils ein Schritt von einer Einheit erfolgt.
;Die Zahlen müssen durch Leerzeichen oder Tabulatoren getrennt werden.
;Leerzeilen sowie Zeilen, die mit einem #-Zeichen beginnen, werden ignoriert.

Procedure Scannen()
  If GetToolBarButtonState(0, #Start)
    If serialPortOpen.i
      If CreateFile(0, GetGadgetText(DNs)) ;neue Textdatei erstellen
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
        absKrd.f(#z) = ValF(GetGadgetText(ASAz))
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
        ;Sekunden speichern für Restdauerberechnung:
        Protected startSekunden.f = ElapsedMilliseconds()/1000
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
                ScanData.f(CurrentInner.i) = ScanG30(x.f, y.f, SAHz.f)
              Case 1 ;Oberfläche abfahren mit M119
                ScanData.f(CurrentInner.i) = ScanM119(x.f, y.f, SAHz.f)
              Case 2 ;Kombiniert
                ScanData.f(CurrentInner.i) = ScanKombiniert(x.f, y.f, SAHz.f)
            EndSelect
            ;ProgressBar aktualisieren:
            Fortschritt.i + 1
            StatusBarProgress(0, 1, Fortschritt.i, #PB_StatusBar_Raised,
                              0, Val(GetGadgetText(ASPs)))
            StatusBarText(0, 2, "Scanne Punkt " + Str(Fortschritt.i) + "/" + GetGadgetText(ASPs))
            ;Restdaueranzeige aktualisieren:
            ;ASPs = Anzahl Scan-Punkte
            Protected abgelaufeneSekunden.f = ElapsedMilliseconds()/1000 - startSekunden.f
            Protected verbleibendeSekunden.f = (abgelaufeneSekunden.f / Fortschritt.i) * (Val(GetGadgetText(ASPs)) - Fortschritt.i)
            ;Debug verbleibendeSekunden
            SetGadgetText(EZs, KonvertiereZuZeit(verbleibendeSekunden.f))
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
        SetGadgetText(APy, StrF(absKrd.f(#y), 2))
        SetGadgetText(APz, StrF(absKrd.f(#z), 2))
      Else
        StatusBarText(0, 2, "Konnte Datei nicht erstellen!")
      EndIf
    Else
      SetToolBarButtonState(0, #Start, #False)
      StatusBarText(0, 2, "COM-Port nicht geöffnet!")
    EndIf
  EndIf
EndProcedure

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 436
; FirstLine = 397
; Folding = -------
; EnableXP
; DPIAware