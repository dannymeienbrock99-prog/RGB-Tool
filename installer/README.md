# PRISM Windows-Installer

Die fertige Datei **PRISM-Setup-1.5.1.exe** steht unter [GitHub Releases](https://github.com/dannymeienbrock99-prog/RGB-Tool/releases/tag/v1.5.1). Sie installiert PRISM RGB Studio 1.5.1 für das aktuelle Windows-Benutzerkonto unter `%LOCALAPPDATA%\Programs\PRISM RGB Studio`. Unterstützt wird Windows 10/11 auf x64-PCs mit Intel- oder AMD-Prozessor.

## Mainboard-Vorschau in 1.5.1

Bei einem erkannten MSI-/Micro-Star-Mainboard zeigt die PC-Ansicht das MSI-Design; ASUS/ASUSTeK verwendet das ASUS-Design. Neu in 1.5.1 ist die ASUS-Ansicht als White Build mit weißem Gehäuse, weißen Lüftern, RAM, Grafikkarte, Kühlung und Kabeln. Die MSI-Ansicht bleibt unverändert. Der echte Inventarname steht weiterhin unter dem Symbolbild; das Bild bestätigt kein bestimmtes Modell. Andere, fehlende oder widersprüchliche Mainboarddaten behalten die allgemeine Ansicht. Die Bildwahl wird mit „PC erneut erkennen“ aktualisiert und verändert keine RGB-Kompatibilität. Die Bilddateien liegen in `dist` und werden durch die bestehenden Installer-Regeln mitgeliefert.

Prüfstand 1.5: 68 automatisierte Tests und 19 Vorschauprüfungen mit 11 simulierten Zuständen auf Desktop und Mobil sind bestanden.

Der deutsche Assistent erstellt einen Startmenü-Eintrag, eine Deinstallations-Verknüpfung und auf Wunsch eine Desktop-Verknüpfung. PRISM lässt sich anschließend über Windows-Einstellungen → Apps entfernen. Die Programm- und .NET-Laufzeit sind enthalten. OpenRGB wird nicht benötigt. Tatsächliche LED-Steuerung wird unverändert über Windows LampArray oder das vorhandene Corsair-iCUE bereitgestellt, einschließlich Beleuchtung anderer Hersteller, die iCUE meldet, etwa ASUS. Die optionale Corsair-SDK-Datei lädt jeder Anwender nach Zustimmung zu den Herstellerbedingungen selbst direkt vom offiziellen Download; sie wird in diesem Installer nicht weiterverteilt. Das native Programmfenster benötigt Microsoft Edge WebView2.

Der Installer ist nicht digital signiert. Es wurden keine Windows-Treiber installiert. Echte PC- und RGB-Geräteerkennung wurde getestet, echte LED-Farbübertragung während der Prüfung nicht durchgeführt. Die gemeldete Stream-Deck-Störung konnte nicht direkt reproduziert werden; Stream Deck/Elgato sind jetzt ausdrücklich ausgeschlossen, OpenRGB und fremde Node-Prozesse werden nicht gestartet beziehungsweise beendet.

## Geräte- und Herstellererkennung

PRISM liest die Namen auf dem aktuellen PC aus; es enthält keine Liste vorgegebener Komponentenmodelle. CPU, Mainboard, Arbeitsspeicher, Grafikkarten, Laufwerke und alle von Windows gemeldeten vorhandenen Geräteeinträge werden unabhängig von der RGB-Anbindung gelesen. USB-Busnamen und vorhandene Bildschirm-EDID ergänzen generische Namen. Mehrere Schnittstellen und Softwaregeräte können zu einem physischen Gerät gehören.

Die zusätzliche Herstellerübersicht gruppiert bekannte Marken und tatsächlich gemeldete unbekannte OEM-Hersteller. Nicht zuordenbare Einträge bleiben sichtbar. Die Übersicht zeigt den Anbindungsstatus und die ausdrücklich gemeldeten steuerbaren RGB-Ziele. Eine erkannte Marke oder ein Windows-Gerätename bestätigt keine RGB-Steuerbarkeit.

Razer Chroma wird nur über einen lokalen GET-Statusaufruf geprüft. PRISM eröffnet dafür keine Chroma-Sitzung und sendet keine LED-Farben. Für Lian Li ist kein eigenständiger Adapter enthalten. Kompatible LampArray-Geräte oder von iCUE bereitgestellte Beleuchtung können weiterhin über die bestehenden Schnittstellen gesteuert werden. Passive Lüfter und ARGB-Streifen ohne Gerätekennung werden gegebenenfalls über den Controller zusammengefasst; ihre individuellen Modellnamen kann Windows nicht ermitteln.

## Neue Effekte in 1.4

14 Effekte sind verfügbar. Neu sind Farbwechsel, Komet, Lauflicht, Scanner, Wasserwelle, Feuer, Nordlicht und Farbstreifen. Die acht Szenen enthalten passende Startwerte und Farben; Feineinstellungen wie Schweiflänge und Strahlbreite lassen sich anpassen. Vorschau und LED-Ausgabe teilen dieselbe Effektberechnung. Bestehende Profile bleiben kompatibel; neue Effekte lassen sich ebenfalls speichern, exportieren und importieren.

## Prüfstand 1.4

59 automatisierte Tests sind bestanden, einschließlich der bisherigen Effektausgaben, aller acht neuen Bewegungsmuster, Palette, Richtung, Tempo, Größe, Helligkeitsgrenzen und Vorschauübereinstimmung. Die Oberfläche wurde mit Playwright und Edge bei 1365×1000 und 390×844 geprüft: alle 14 Effekte gegen den echten EffectEngine mit simulierten LED-Geräten anwenden, Regler verändern, alte und neue Profile speichern/laden/exportieren/importieren, acht Szenen auswählen sowie Vorschauanimation und Pause. Es gab keine Browserfehler oder horizontalen Überläufe. Farbübertragung wurde ausschließlich mit simulierten Geräten geprüft.

Der isolierte Installationstest hat den originalen Test-Installer 1.3 erfolgreich auf 1.4 aktualisiert und alle 35 installierten Programmdateien per SHA-256 mit der Bauquelle abgeglichen. Alle 14 Effekte werden vom installierten Dienst bereitgestellt. Oberfläche, Verknüpfungen, reale Windows- und iCUE-Abfragen sowie die Herstellerübersicht mit fünf ausdrücklich bestätigten RGB-Zielnamen funktionieren aus der Installation. Erneute Installation und Deinstallation sind bestanden; selbst hinzugefügte Dateien bleiben erhalten. Die Prüfungen ändern keine realen LED-Farben.

Die Prüfung verwendet dieselbe Installationsquelle mit `TEST_INSTALL`: ausschließlich für diesen Test haben die Verknüpfungen Ziele im Arbeitsordner, die App-ID ist separat und die Windows-App-Registrierung ist ausgeschaltet. Ein eigener Netzwerk-Port verhindert, dass ein bereits laufendes PRISM fälschlich als erfolgreiche Testinstanz erkannt wird.

## Neu bauen

[Inno Setup 6.7.3](https://jrsoftware.org/isdl.php) installieren oder portabel vorbereiten und `ISCC.exe PRISM.iss` in diesem Ordner ausführen. `PRISM.iss`, `PRISM.ico` und der benachbarte Ordner `aura-rgb` bilden die Bauquelle. `ISCC.exe /DTEST_INSTALL PRISM.iss` erzeugt die isolierte Testvariante im Arbeitsordner.
