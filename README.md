# NADIR 3D SCANNER

Bedienungsanleitung für Software & Visualisierung

1\. Vorbereitung & Verbindung
-----------------------------

Bevor ein Scan gestartet werden kann, muss die Kommunikation zur Hardware hergestellt werden:

*   Öffnen Sie **Einstellungen** -> serielle Schnittstelle und wählen Sie den korrekten COM-Port aus.
*   Klicken Sie auf Homing. Die Maschine fährt alle Achsen an die Referenzschalter.  
    Wichtig: Ohne Homing ist keine präzise Positionierung möglich.

2\. Den Scan-Bereich definieren
-------------------------------

Sie müssen der Software mitteilen, wo das Objekt liegt. Dies geschieht über zwei Eckpunkte:

Einstellung

Aktion

**Anfang Scan-Area**

Fahren Sie den Kopf zur vorderen linken Ecke des Objekts. Klicken Sie auf Aus aktueller Position übernehmen und danach auf Speichern.

**Ende Scan-Area**

Fahren Sie zur hinteren rechten Ecke. Klicken Sie auf Aus aktueller Position übernehmen und danach auf Speichern.

**Hierher fahren**

Nutzen Sie diese Buttons neben den Koordinaten, um die gespeicherten Eckpunkte zur Kontrolle automatisch anzufahren.

3\. Scan-Parameter einstellen
-----------------------------

Die Detailgenauigkeit und Dauer des Scans werden hier gesteuert:

*   **Scan-Auflösung:** Wählen Sie per Button die Schrittweite (0.10mm bis 1.00mm). Die **Anzahl Scan-Punkte** und die **Erwartete Zeit** aktualisieren sich automatisch.
*   **Mäander Scan:** Aktivieren Sie dieses Häkchen, damit der Scanner im Zick-Zack fährt (spart ca. 30% Zeit).
*   **Homing vor Scan:** Empfohlen, um sicherzustellen, dass die Maschine vor einem langen Lauf perfekt kalibriert ist.
*   **Achsenreihenfolge:** Bestimmt, ob die Maschine erst Zeilen oder erst Spalten abarbeitet.

4\. Live-Visualisierung in OpenSCAD
-----------------------------------

Um das Ergebnis während des Scans in 3D zu sehen, folgen Sie exakt diesem Ablauf:

**Schritt 1:** Klicken Sie im Scanner-Programm auf surface.scad erzeugen.  
**Schritt 2:** Starten Sie das Programm **OpenSCAD** manuell auf Ihrem Rechner.  
**Schritt 3:** Öffnen Sie in OpenSCAD die Datei `surface.scad` aus Ihrem Projektverzeichnis.  
**Schritt 4:** Aktivieren Sie in OpenSCAD im Menü **Design** die Option **Automatic Reload and Preview**.  
**Schritt 5:** Aktivieren Sie im Scanner die Checkbox **OpenSCAD aktualisieren**.

Sobald der Scan läuft, sendet das Programm nach jedem Messpunkt (oder jeder Zeile) ein Signal. OpenSCAD bemerkt dies und baut das 3D-Modell in Echtzeit vor Ihren Augen auf.

5\. Experten-Funktionen & Sicherheit
------------------------------------

Zusätzliche Kontrollen für die Hardware:

*   Z bis Ende Scan-Area fahren: Hebt den Sensor sicher über das Objekt an.
*   Scan (neben der Position): Führt eine einzelne Testmessung durch.
*   Endschalter abfragen: Prüft, ob die Maschine einen Anschlag berührt oder ein Fehler vorliegt.
*   Motoren abschalten: Schaltet den Strom der Motoren ab (z.B. zum Abkühlen oder manuellem Verschieben).
*   max. Geschw. einstellen: Überträgt die eingetragenen Limits an die Motorsteuerung.

6\. Manueller Befehlsversand
----------------------------

Im unteren Bereich finden Sie das **Terminal**. Hier können Sie unter **Individueller String** eigene G-Code Befehle eingeben und mit Senden direkt an die Maschine schicken. Das Feld **Empfangen** zeigt die Antwort der Hardware an.

Nadir 3D Scanner Handbuch • 2026 • Alle Rechte vorbehalten.
