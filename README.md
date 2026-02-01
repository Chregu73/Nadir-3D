# NADIR 3D SCANNER

Bedienungsanleitung für Software & Visualisierung

1\. Vorbereitung & Verbindung
-----------------------------

Bevor ein Scan gestartet werden kann, muss die Kommunikation zur Hardware hergestellt werden:

*   Öffnen Sie `Einstellungen` -> serielle Schnittstelle und wählen Sie den korrekten COM-Port aus.
*   Klicken Sie auf `Homing`. Die Maschine fährt alle Achsen an die Referenzschalter.  
    Wichtig: Ohne Homing ist keine präzise Positionierung möglich.

2\. Den Scan-Bereich definieren
-------------------------------

Sie müssen der Software mitteilen, wo das Objekt liegt. Dies geschieht über zwei Eckpunkte:

**Anfang Scan-Area**

Fahren Sie den Kopf zur vorderen linken Ecke des Objekts. Klicken Sie auf `Aus aktueller Position übernehmen` und danach auf `Speichern`.

**Ende Scan-Area**

Fahren Sie zur hinteren rechten Ecke. Klicken Sie auf `Aus aktueller Position übernehmen` und danach auf `Speichern`.

**Hierher fahren**

Nutzen Sie diese Buttons neben den Koordinaten, um die gespeicherten Eckpunkte zur Kontrolle automatisch anzufahren.

3\. Scan-Parameter einstellen
-----------------------------

Die Detailgenauigkeit und Dauer des Scans werden hier gesteuert:

*    Wählen Sie per Button die `Scan-Auflösung` (0.10mm bis 1.00mm) oder tragen Sie die Werte manuell in das Gadget ein. Die `Anzahl Scan-Punkte` und die `Erwartete Zeit` aktualisieren sich automatisch beim verlassen des Gadgets (verliert Fokus).
*    Aktivieren Sie `Mäander Scan`, damit der Scanner im Zick-Zack fährt (spart etwas Zeit).
*   `Homing vor Scan` ist empfohlen, um sicherzustellen, dass die Maschine vor einem langen Lauf perfekt kalibriert ist.
*   `Achsenreihenfolge` bestimmt, ob die Maschine erst Zeilen oder erst Spalten abarbeitet.
*   `Speicher-Verfahren` bestimmt, ob die Datei während des ganzen Scans geöffnet bleibt, nach jeder Zeile ein Flush ausgeführt wird oder jedesmal geöffnet und geschlossen wird.

4\. Live-Visualisierung in OpenSCAD
-----------------------------------

Um das Ergebnis während des Scans in 3D zu sehen, folgen Sie exakt diesem Ablauf:

**Schritt 1:** Klicken Sie im Scanner-Programm auf surface.scad erzeugen.  
**Schritt 2:** Starten Sie das Programm `OpenSCAD` manuell auf Ihrem Rechner.  
**Schritt 3:** Öffnen Sie in OpenSCAD die Datei `surface.scad` aus Ihrem Projektverzeichnis.  
**Schritt 4:** Aktivieren Sie in OpenSCAD im Menü `Design` die Option `Automatic Reload and Preview`.  
**Schritt 5:** Aktivieren Sie im Scanner die Checkbox `OpenSCAD aktualisieren`.

Sobald der Scan läuft, sendet das Programm nach jeder Zeile ein Signal (Aenderung in der Datei). OpenSCAD bemerkt dies und baut das 3D-Modell in Echtzeit vor Ihren Augen auf.

5\. Experten-Funktionen & Sicherheit
------------------------------------

Zusätzliche Kontrollen für die Hardware:

*   `Scan` führt eine einzelne Testmessung durch.
*   `Z bis Ende Scan-Area fahren` oder `Auf` hebt den Sensor sicher über das Objekt an (Z-Wert aus `Ende Scan-Area`).
*   `Endschalter abfragen` oder `Switch` prüft, ob die Maschine einen Anschlag berührt oder ein Fehler vorliegt.
*   `Motoren abschalten` schaltet den Strom der Motoren ab (z.B. zum Abkühlen oder manuellem Verschieben).
*   `max. Geschw. einstellen` bzw. `max. Beschl. einstellen` überträgt die eingetragenen Werte an die Motorsteuerung.

6\. Scannen
----------------------------

*   `Start` startet den Scan-Vorgang
*   `Pause` pausiert den Scan-Vorgang
*   `Stop` beendet den Scan-Vorgang

7\. Manueller Befehlsversand
----------------------------

Im unteren Bereich finden Sie das **Terminal**. Hier können Sie unter `Individueller String` eigene G-Code Befehle eingeben und mit Senden direkt an die Maschine schicken. Das Feld **Empfangen** zeigt die Antwort der Hardware an.

8\. Beenden
----------------------------

Beim Beenden werden alle Einstellungen gespeichert, die serielle Schnittstelle und evtl. geöffnete Dateien geschlossen.

9\. AutoResponser
-----------------

Der AutoResponser simuliert einen MKS TinyBee und antwortet auf die GCodes G40 und M119 detailiert und auf alle Anderen mit "ok".
In der .bat Datei kann die serielle Schnittstelle als Argument mitgegeben werden.
Die Verbindung zu Nadir 3D erfolgt über einen Null-Modem Emulator wie [com0com](https://sourceforge.net/projects/com0com/).

Nadir 3D Scanner Handbuch • 2026
