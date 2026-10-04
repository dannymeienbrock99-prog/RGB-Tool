# PRISM für Windows bauen

Für die Nutzung brauchst du keinen Quellcode-Build. Verwende den Installer oder die portable ZIP-Datei unter [Releases](https://github.com/dannymeienbrock99-prog/RGB-Tool/releases).

## Vollständiger Build

Voraussetzungen: Windows x64, PowerShell 7, Node.js 24.19.0 mit npm und .NET SDK 8. Internetzugriff ist für die offiziellen Abhängigkeiten erforderlich.

Im Stammverzeichnis des Repositorys:

```powershell
./scripts/build-windows.ps1
```

Das Skript prüft die Versionen, lädt feste Microsoft-SDK- und Inno-Setup-Versionen mit SHA256-Prüfung, installiert die npm-Abhängigkeiten aus dem Lockfile, führt die automatisierten Tests aus und baut Oberfläche und native Windows-Komponente. Danach erstellt es den deutschen Installer und eine portable ZIP-Version mit Node- und .NET-Laufzeit.

Die Ergebnisse liegen in `artifacts/`: `PRISM-Setup-1.5.exe`, `PRISM-RGB-Windows.zip` und `SHA256SUMS.txt`. Build-Abhängigkeiten liegen im ignorierten Verzeichnis `.build/`. Das Skript installiert PRISM nicht und verändert keine RGB-Farben.

Die optionale Corsair-SDK-DLL wird nicht gebündelt. PRISM lädt sie bei der Einrichtung nach Zustimmung zur Herstellerlizenz separat herunter.

## Oberfläche entwickeln

Im Ordner `aura-rgb`:

```powershell
npm ci
npm test
npm run build
```

Für die Entwicklung in zwei Terminals `npm start` und `npm run dev` ausführen. Die Vite-Oberfläche leitet lokale API-Aufrufe an den PRISM-Dienst weiter. Native RGB-Steuerung setzt die gebaute Windows-Komponente voraus; Tests verwenden simulierte Geräte.

## GitHub-Veröffentlichung

Der Workflow `.github/workflows/windows-release.yml` startet bei Änderungen am Programm, Installer oder Build auf `main`, sowie manuell über GitHub Actions. Er führt den Windows-Build aus und veröffentlicht dessen Downloads als Release `v<Version>` erst nach erfolgreichem Build. Nur der Veröffentlichungsjob erhält Schreibrechte für Repository-Inhalte.

Bestehende veröffentlichte Versionen werden nicht mit einem anderen Commit überschrieben. Für eine neue Veröffentlichung die Version in `aura-rgb/package.json`, `aura-rgb/server/version.mjs` und `installer/PRISM.iss` gemeinsam erhöhen und die Anleitungen aktualisieren.
