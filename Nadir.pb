;Scannt mit dem 3D-Taster

;interne Variablen:
#x = 0
#y = 1
#z = 2
Global Dim absKrd.f(2) ;Absolut zum Nullpunkt
absKrd.f(#x) = 0
absKrd.f(#y) = 0
absKrd.f(#z) = 0

Global Dim relKrd.f(2) ;Relativ zum Anfang Scan-Area
relKrd.f(#x) = 0
relKrd.f(#y) = 0
relKrd.f(#z) = 0

Enumeration FormMenu
  ;#Laden
  ;#Speichern
  ;#Beenden
  ;#SerielleSchnittstelle
  ;#Hilfe
  ;#GCodes
  ;#Ueber
  #Serial
  #Start
  #Pause
  #Stop
  #Homing
  #Scan
  #Back
  #EsA
  #T1
  #T2
  #T3
  #T4
  #T5
  #T6
  #T7
  #T8
EndEnumeration

XIncludeFile "Nadir.pbf" ;Einbinden der ersten Fenster-Definition
XIncludeFile "Bedienung.pbf"
XIncludeFile "SerialSettings.pbf"
XIncludeFile "Prozeduren.pbi"

OpenWindowScanner() ; Öffnet das erste Fenster. Dieser Prozedurname ist immer 'Open' gefolgt vom Fensternamen.

Macro RechtsBuendig(Gadget) ;Rechtsbündig machen
  SetWindowLong_(GadgetID(Gadget), #GWL_STYLE, GetWindowLong_(GadgetID(Gadget), #GWL_STYLE)&~#ES_LEFT|#ES_RIGHT) ;Rechtsbündig machen
EndMacro

RechtsBuendig(APx) : RechtsBuendig(APy) : RechtsBuendig(APz)
RechtsBuendig(ASAx) : RechtsBuendig(ASAy) : RechtsBuendig(ASAz)
RechtsBuendig(ESAx) : RechtsBuendig(ESAy) : RechtsBuendig(ESAz)
RechtsBuendig(SAx) : RechtsBuendig(SAy) : RechtsBuendig(SAz)
RechtsBuendig(GSAx) : RechtsBuendig(GSAy) : RechtsBuendig(GSAz)
RechtsBuendig(OSx) : RechtsBuendig(OSy) : RechtsBuendig(OSz)
RechtsBuendig(mGx) : RechtsBuendig(mGy) : RechtsBuendig(mGz)
RechtsBuendig(ASPs)
RechtsBuendig(EZs)


Global Ende


; Die Ereignis-Prozedur, wie diese in der Eigenschaft 'Ereignis-Prozedur' jedes Gadgets definiert wurde.
Procedure ToolBarHinzufuegen()
  Img_WindowScanner_S = LoadImage(#PB_Any,"Icons\Gartoon-Team-Gartoon-Misc-Gtk-Connect-Socket.ico")
  Img_WindowScanner_0 = LoadImage(#PB_Any,"Icons\Play.ico")
  Img_WindowScanner_1 = LoadImage(#PB_Any,"Icons\Pause.ico")
  Img_WindowScanner_2 = LoadImage(#PB_Any,"Icons\Stop.ico")
  Img_WindowScanner_3 = LoadImage(#PB_Any,"Icons\Github-Octicons-Goal-16.ico")
  Img_WindowScanner_4 = LoadImage(#PB_Any,"Icons\Pictogrammers-Material-Arrow-Arrow-collapse-down.ico")
  Img_WindowScanner_pY = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Upper-Right.ico")
  Img_WindowScanner_mZ = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Down.ico")
  Img_WindowScanner_mX = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Left.ico")
  Img_WindowScanner_mY = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Lower-Left.ico")
  Img_WindowScanner_pX = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Right.ico")
  Img_WindowScanner_pZ = LoadImage(#PB_Any,"Icons\Custom-Icon-Design-Flat-Cute-Arrows-Arrow-Up.ico")
  Img_WindowScanner_5 = LoadImage(#PB_Any,"Icons\Help.ico")
  Img_WindowScanner_6 = LoadImage(#PB_Any,"Icons\Iconsmind-Outline-Finger-DragFourSides.ico")
  Img_WindowScanner_7 = LoadImage(#PB_Any,"Icons\Pictogrammers-Material-Arrow-Arrow-collapse-up.ico")
  Img_WindowScanner_8 = LoadImage(#PB_Any,"Icons\Pictogrammers-Material-Dip-switch.ico")
  
  CreateToolBar(0, WindowID(WindowScanner), #PB_ToolBar_Large|#PB_ToolBar_Text)
  ToolBarImageButton(#Serial, ImageID(Img_WindowScanner_S), #PB_ToolBar_Toggle, "Serial")
  ToolBarToolTip(0, #Serial, "Serielle Schnittstelle öffnen")
  ToolBarSeparator()
  ToolBarImageButton(#Start, ImageID(Img_WindowScanner_0), #PB_ToolBar_Toggle, "Start")
  ToolBarToolTip(0, #Start, "Scan starten")
  ToolBarImageButton(#Pause,ImageID(Img_WindowScanner_1), #PB_ToolBar_Toggle, "Pause")
  ToolBarToolTip(0, #Pause, "Scan pausieren/fortsetzen")
  ToolBarImageButton(#Stop, ImageID(Img_WindowScanner_2), #PB_ToolBar_Toggle, "Stop")
  ToolBarToolTip(0, #Stop, "Scan stoppen")
  ToolBarSeparator()
  ToolBarImageButton(#Homing,ImageID(Img_WindowScanner_3), #PB_ToolBar_Normal, "Homing")
  ToolBarToolTip(0, #Homing, "Homing")
  ToolBarImageButton(#Scan,ImageID(Img_WindowScanner_4), #PB_ToolBar_Normal, "Scan")
  ToolBarToolTip(0, #Scan, "Aktuellen Punkt scannen")
  ToolBarImageButton(#Back,ImageID(Img_WindowScanner_7), #PB_ToolBar_Normal, "Auf")
  ToolBarToolTip(0, #Back, "Mit Z bis Ende Scan-Area fahren")
  ToolBarImageButton(#EsA,ImageID(Img_WindowScanner_8), #PB_ToolBar_Normal, "Switch")
  ToolBarToolTip(0, #EsA, "Endschalter abfragen")
  ToolBarSeparator()
  ToolBarImageButton(#T1,ImageID(Img_WindowScanner_mX), #PB_ToolBar_Normal, "X-")
  ToolBarToolTip(0, #T1, "X - 0.1mm")
  ToolBarImageButton(#T2,ImageID(Img_WindowScanner_pX), #PB_ToolBar_Normal, "X+")
  ToolBarToolTip(0, #T2, "X + 0.1mm")
  ToolBarImageButton(#T3,ImageID(Img_WindowScanner_mY), #PB_ToolBar_Normal, "Y-")
  ToolBarToolTip(0, #T3, "Y - 0.1mm")
  ToolBarImageButton(#T4,ImageID(Img_WindowScanner_pY), #PB_ToolBar_Normal, "Y+")
  ToolBarToolTip(0, #T4, "Y + 0.1mm")
  ToolBarImageButton(#T5,ImageID(Img_WindowScanner_mZ), #PB_ToolBar_Normal, "Z-")
  ToolBarToolTip(0, #T5, "Z - 0.1mm")
  ToolBarImageButton(#T6,ImageID(Img_WindowScanner_pZ), #PB_ToolBar_Normal, "Z+")
  ToolBarToolTip(0, #T6, "Z + 0.1mm")
  ToolBarSeparator()
  ToolBarImageButton(#T7,ImageID(Img_WindowScanner_5), #PB_ToolBar_Normal, "Hilfe")
  ToolBarToolTip(0, #T7, "Hilfe")
  ToolBarImageButton(#T8,ImageID(Img_WindowScanner_6), #PB_ToolBar_Normal, "Manuell")
  ToolBarToolTip(0, #T8, "Manuell Achsen fahren")
EndProcedure

ToolBarHinzufuegen()
StartDrawing(WindowOutput(WindowScanner))
LineXY(8, 54, 688+8, 54, $848484)
LineXY(8, 55, 688+8, 55, $F5F5F5)
StopDrawing()
AddGadgetItem(ScVc, 0, "Jeden Punkt abtasten mit G40")
AddGadgetItem(ScVc, 1, "Oberfläche abfahren mit M119")
AddGadgetItem(ScVc, 2, "Kombiniert")

AddGadgetItem(ARFc, 0, "Zuerst X-Achse, dann Y-Achse")
AddGadgetItem(ARFc, 1, "Zuerst Y-Achse, dann X-Achse")

AddGadgetItem(SpVc, 0, "Datei geöffnet lassen")
AddGadgetItem(SpVc, 1, "Datei geöffnet lassen mit Flush")
AddGadgetItem(SpVc, 2, "Datei jedesmal öffnen und schliessen")

ConfigLaden()
StringGadgetVerifizieren(ASAx, #PB_EventType_LostFocus)

Procedure Beenden(EventType)
  Ende = #True
EndProcedure


; Die übliche Haupt-Ereignisschleife, die einzige Änderung ist der automatische Aufruf der
; für jedes Fenster generierten Ereignis-Prozedur.
Repeat
  Event = WaitWindowEvent()
  Select EventWindow()
    Case WindowScanner
      If Not WindowScanner_Events(Event) ; Dieser Prozedurname ist immer der Fenstername gefolgt von '_Events'
        Ende = #True
      EndIf
      Select Event
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Serial
              comPortOpenClose(#Serial)
            Case #Start
              Scannen()
            Case #Pause
            Case #Stop
            Case #Homing
              Homing(0)
            Case #Scan
              ScanVonForm(0)
            Case #Back
              Auf(0)
            Case #EsA
              EndschalterAbfragen(0)
            Case #T1 ;X - 0.1mm
              Xm01(0)
            Case #T2 ;X + 0.1mm
              Xp01(0)
            Case #T3 ;Y - 0.1mm
              Ym01(0)
            Case #T4 ;Y + 0.1mm
              Yp01(0)
            Case #T5 ;Z - 0.1mm
              Zm01(0)
            Case #T6 ;Z + 0.1mm
              Zp01(0)
            Case #T7 ;Hilfe
              manual(0)
            Case #T8 ;Manuell Achsen fahren
              bedienung(Event)
          EndSelect
        Case #PB_Event_Gadget
          EventGadget = EventGadget()
          Select EventGadget
            Case APx, APy, APz, ASAx, ASAy, ASAz, ESAx, ESAy, ESAz,
                 GSAx, GSAy, GSAz, SAx, SAy, SAz, OSx, OSy, OSz, mGx, mGy, mGz
              StringGadgetVerifizieren(EventGadget, EventType())
          EndSelect
      EndSelect
    Case WindowGCode
      WindowGCode_Events(Event)
    Case WindowManual
      WindowManual_Events(Event)
    Case WindowBedienung
      If Not WindowBedienung_Events(Event)
        CloseWindow(WindowBedienung)
      EndIf
    Case WindowSerial
      If Not WindowSerial_Events(event) ;Fenster schliessen
        SerSetAbbrechen(0)
      EndIf
  EndSelect
Until Ende = #True ; Beenden, wenn das Hauptfenster geschlossen wird.

If GetToolBarButtonState(0, #Serial)
  comPortOpenClose(#Serial)
EndIf

ConfigSpeichern()
End

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 188
; FirstLine = 171
; Folding = -
; EnableXP
; DPIAware
; UseIcon = Icons\Github-Octicons-Goal-16.ico