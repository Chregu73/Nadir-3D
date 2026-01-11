;Auto-Responser

Global SerialPortHandle.i, Ergebnis.s

ComPort.s = ProgramParameter(0)
;ComPort.s = "COM5"
ComBaud.l = 115200

Global NZ$ = #LF$  ;0x0A, 10 dezimal, \n, für MKS TinyBee
;Global NZ$ = #CR$  ;0x0D, 13 dezimal, \r, für TeaCup Firmware

OpenConsole()

SerialPortHandle.i = OpenSerialPort(#PB_Any, ComPort.s, ComBaud.l, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 1024, 1024)
;If SerialPortHandle.i
If IsSerialPort(SerialPortHandle.i)
  ;SetSerialPortStatus(SerialPortHandle.i, #PB_SerialPort_DTR, 0)  ;geht nicht mit MKS
  ;SetSerialPortStatus(SerialPortHandle.i, #PB_SerialPort_RTS, 1)  ;geht nicht mit MKS
  SerialPortTimeouts(SerialPortHandle.i, 300, 300, 300, 10, 100)
  PrintN("Serielle Schnittstelle geöffnet")
Else
  PrintN("Kann serielle Schnittstelle nicht öffnen")
EndIf

Macro Unicode(Mem, Type = #PB_Ascii)
  PeekS(Mem, -1, Type)
EndMacro

PrintN("ESC zum Abbrechen")
Repeat
  KeyPressed$ = Inkey()
  If AvailableSerialPortInput(SerialPortHandle.i)
    *Puffer = AllocateMemory(128)
    Delay(10) ;warten bis Daten verarbeitet sind und bestätigt wird
    ReadSerialPortData(SerialPortHandle.i, *Puffer, 128)
    Ergebnis.s = Unicode(*Puffer, #PB_UTF8)
    FreeMemory(*Puffer)
    Ergebnis.s = Trim(Ergebnis.s, NZ$)
    ConsoleColor(2, 0)
    PrintN(Ergebnis.s)
    ConsoleColor(4, 0)
    If FindString(Ergebnis.s, "G30", 1, #PB_String_CaseSensitive)
      WriteSerialPortString(SerialPortHandle.i, "Ok" + NZ$, #PB_UTF8)
      PrintN("Ok")
      WriteSerialPortString(SerialPortHandle.i, "Bed X: 40.00 Y: 30.00 Z: 4.80" + NZ$, #PB_UTF8)
      PrintN("Bed X: 40.00 Y: 30.00 Z: 4.80")
      zufallshoehe.f = Random(500, 0) / 100
      string.s = StrF(zufallshoehe.f, 2)
      string.s ="X:40.00 Y:30.00 Z:" + string.s + " E:0.00 Count X:3200 Y:2400 Z:1921"
      WriteSerialPortString(SerialPortHandle.i, string.s + NZ$, #PB_UTF8)
      PrintN(string.s)
      WriteSerialPortString(SerialPortHandle.i, "ok" + NZ$, #PB_UTF8)
      PrintN("ok")
    ElseIf FindString(Ergebnis.s, "G28", 1, #PB_String_CaseSensitive)
      WriteSerialPortString(SerialPortHandle.i, "Ok" + NZ$, #PB_UTF8)
      PrintN("Ok")
      Delay(1000)
      WriteSerialPortString(SerialPortHandle.i, "busy: processing" + NZ$, #PB_UTF8)
      PrintN("busy: processing")
      Delay(1000)
      WriteSerialPortString(SerialPortHandle.i, "ok" + NZ$, #PB_UTF8)
      PrintN("ok")
    ElseIf FindString(Ergebnis.s, "M119", 1, #PB_String_CaseSensitive)
      WriteSerialPortString(SerialPortHandle.i, "Ok" + NZ$, #PB_UTF8)
      PrintN("Ok")
      WriteSerialPortString(SerialPortHandle.i, "Reporting endstop status" + NZ$, #PB_UTF8)
      PrintN("Reporting endstop status")
      WriteSerialPortString(SerialPortHandle.i, "x_min: open" + NZ$, #PB_UTF8)
      PrintN("x_min: open")
      WriteSerialPortString(SerialPortHandle.i, "y_min: open" + NZ$, #PB_UTF8)
      PrintN("y_min: open")
      WriteSerialPortString(SerialPortHandle.i, "z_min: open" + NZ$, #PB_UTF8)
      PrintN("z_min: open")
      WriteSerialPortString(SerialPortHandle.i, "z_probe: TRIGGERED" + NZ$, #PB_UTF8)
      PrintN("z_probe: TRIGGERED")
      WriteSerialPortString(SerialPortHandle.i, "ok" + NZ$, #PB_UTF8)
      PrintN("ok")
    Else
      WriteSerialPortString(SerialPortHandle.i, "ok" + NZ$, #PB_UTF8)
      PrintN("ok")
    EndIf
  Else
    Delay(20)   ;Wir verwenden nicht die gesamte CPU-Zeit, da wir uns auf einem Multitaskting-OS befinden
  EndIf
Until KeyPressed$ = Chr(27) ;Warten, bis ESC gedrückt wird

If IsSerialPort(SerialPortHandle.i)
  CloseSerialPort(SerialPortHandle.i)
EndIf

End

; IDE Options = PureBasic 6.21 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 4
; FirstLine = 1
; Folding = -
; EnableXP
; DPIAware
; Executable = AutoResponser.exe