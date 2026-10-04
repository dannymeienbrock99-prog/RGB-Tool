# PRISM RGB Studio

RGB-Steuerzentrale für Windows 10/11 x64 (Intel/AMD), Version **1.5.1**.

PRISM erkennt die von Windows gemeldeten PC-Komponenten und Gerätenamen des jeweiligen PCs. Die Oberfläche bietet **14 RGB-Effekte**, acht Szenen, bis zu acht Farben, Helligkeit, Geschwindigkeit, Richtung und passende Feineinstellungen. Profile lassen sich speichern und importieren/exportieren.

## Herunterladen

Die fertige Windows-Version findest du unter **[Releases](https://github.com/dannymeienbrock99-prog/RGB-Tool/releases)**:

- [PRISM-Setup-1.5.1.exe](https://github.com/dannymeienbrock99-prog/RGB-Tool/releases/download/v1.5.1/PRISM-Setup-1.5.1.exe): deutscher Installer, Installation für dein Benutzerkonto ohne Administratorrechte.
- `PRISM-RGB-Windows.zip`: portable Version; vollständig entpacken und `PRISM-starten.cmd` öffnen.
- `SHA256SUMS.txt`: Prüfsummen der Downloads.

Eine alte PRISM-Version vor der Installation vollständig beenden. Das Setup ist nicht digital signiert.

## Geräte und RGB

Neu in 1.5: Die PC-Vorschau verwendet bei einem erkannten MSI-/Micro-Star-Mainboard das MSI-Design, bei ASUS/ASUSTeK das ASUS-Design. Andere Hersteller behalten die allgemeine Ansicht. Die Bildwahl liest ausschließlich Mainboarddaten und aktualisiert sich mit „PC erneut erkennen“. Unter dem Hersteller-Symbolbild steht der tatsächlich gemeldete Mainboardname; das Foto bestätigt kein bestimmtes Modell.

Neu in 1.5.1: Die ASUS-Vorschau zeigt einen White Build mit weißem Gehäuse, weißen Lüftern, RAM, Grafikkarte, Kühlung und Kabeln. Die MSI-Vorschau bleibt unverändert. Automatische Herstellerwahl und echter Mainboardname bleiben erhalten.

Die PC-Erkennung zeigt unter anderem CPU, Mainboard, RAM, Grafikkarten, Laufwerke und von Windows gemeldete USB-Geräte. Modellnamen werden aus den vorhandenen Schnittstellen gelesen, nicht für einen bestimmten PC vorgegeben.

Die tatsächliche LED-Steuerung funktioniert über **Windows LampArray** und optional das offizielle **Corsair-iCUE-SDK**. iCUE muss für die Corsair-Anbindung installiert sein und laufen. Die Hersteller-DLL wird erst nach Zustimmung zur Corsair-Lizenz direkt von Corsair geladen; sie ist nicht im Download enthalten. Windows-LampArray-Geräte benötigen das native PRISM-Fenster im Vordergrund und Microsoft Edge WebView2.

Ein erkannter Gerätename bedeutet nicht automatisch, dass dessen RGB steuerbar ist. Eine universelle Unterstützung aller Modelle ist nicht vorhanden. Lian Li hat derzeit keine eigene Anbindung. Passive Lüfter und LED-Streifen erscheinen über ihren Controller, sofern dieser eine unterstützte Schnittstelle bereitstellt.

Stream Deck und Elgato-Geräte sind von der Lichtsteuerung ausgeschlossen. PRISM benötigt und startet OpenRGB nicht. Die Razer-Statusanzeige liest nur den lokalen Status und steuert keine Razer-LEDs.

## Effekte

Statisch · Regenbogen · Atmen · Welle · Farbverlauf · Funkeln · Farbwechsel · Komet · Lauflicht · Scanner · Wasserwelle · Feuer · Nordlicht · Farbstreifen.

Die Vorschau verwendet dieselbe Effektberechnung wie die LED-Ausgabe. Erst **Auf Geräte anwenden** überträgt die gewählten Farben.

## Quellcode und Anleitung

- [Bedienungsanleitung](aura-rgb/README.md)
- [Windows-Komponente und Schnittstellen](aura-rgb/native/README.md)
- [Installer](installer/README.md)
- [Vollständiger Windows-Build](BUILDING.md)
- React-Oberfläche: `aura-rgb/src`
- Lokaler Dienst und Hardwareerkennung: `aura-rgb/server`
- Automatisierte Tests mit simulierten Geräten: `aura-rgb/tests`

Im Ordner `aura-rgb`:

```sh
npm ci
npm test
npm run dev
npm run build
```

Der Quellcode-Download enthält keine fertigen Windows-Laufzeiten. Verwende zum direkten Start den Installer oder die portable Version. Mit `scripts/build-windows.ps1` werden die nötigen Laufzeiten vorbereitet und beide Windows-Pakete gebaut. Die vollständigen Voraussetzungen stehen in [BUILDING.md](BUILDING.md).

## Prüfung und Lizenzen

Prüfstand 1.5: 68 automatisierte Tests sind bestanden. Die Mainboard-Vorschau wurde auf Desktop und Mobil mit 11 simulierten Zuständen und 19 Prüfungen getestet, einschließlich Bildwechsel bei Aktualisierung, fehlender Bilder und neutraler Auswahl bei unbekannten Herstellern. Der Installer wurde in der vorherigen Version isoliert installiert/aktualisiert; seine Dateiregeln enthalten auch die neuen Vorschaubilder. Effektübertragung wurde mit simulierten RGB-Geräten getestet; daraus folgt keine Bestätigung der LED-Funktion für jedes Hardwaremodell.

Lizenztexte mitgelieferter Komponenten liegen in `aura-rgb/licenses`, `aura-rgb/runtime` und `aura-rgb/native/licenses`. Für den PRISM-eigenen Quellcode wird hier keine zusätzliche Lizenz erteilt.
