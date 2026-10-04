; PRISM RGB Studio — Windows x64 installer
; Build with Inno Setup 6.7.3: ISCC.exe PRISM.iss
; /DTEST_INSTALL builds the same payload with workspace-only shortcuts and no registration.
#define AppName "PRISM RGB Studio"
#define AppVersion "1.4.0"
#define PayloadRoot "..\aura-rgb"

[Setup]
#ifdef TEST_INSTALL
#define ShortcutGroup "{app}\QA-Verknuepfungen\Startmenue"
#define ShortcutDesktop "{app}\QA-Verknuepfungen\Desktop"
AppId={{CB74DB74-7296-4F06-9EF9-0784FC1C9F08}
AppName={#AppName} Installationstest
DefaultDirName={src}\PRISM Testinstallation
OutputDir=..\..\work\installer-build
OutputBaseFilename=PRISM-Setup-Test
CreateUninstallRegKey=no
UsePreviousAppDir=no
UsePreviousGroup=no
UsePreviousTasks=no
#else
#define ShortcutGroup "{group}"
#define ShortcutDesktop "{autodesktop}"
AppId={{C3F67CC5-8F37-4CC6-8194-75351476D86B}
AppName={#AppName}
DefaultDirName={localappdata}\Programs\PRISM RGB Studio
OutputDir=..
OutputBaseFilename=PRISM-Setup
CreateUninstallRegKey=yes
#endif
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
DefaultGroupName=PRISM RGB Studio
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible and not arm64
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
DisableProgramGroupPage=yes
DisableWelcomePage=no
DisableDirPage=no
WizardStyle=modern dynamic windows11
WizardSizePercent=110
SetupIconFile=PRISM.ico
UninstallDisplayIcon={app}\PRISM.ico
UninstallDisplayName={#AppName}
Uninstallable=yes
UninstallLogMode=append
CloseApplications=yes
RestartApplications=no
SetupLogging=yes
Compression=lzma2/max
SolidCompression=yes
LZMAUseSeparateProcess=yes
VersionInfoVersion={#AppVersion}
VersionInfoDescription={#AppName} — Installation
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
VersionInfoOriginalFileName=PRISM-Setup.exe
InfoBeforeFile={#PayloadRoot}\INSTALLATION.txt

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "Verknüpfung auf dem &Desktop erstellen"; GroupDescription: "Verknüpfungen:"

[Files]
Source: "{#PayloadRoot}\dist\*"; DestDir: "{app}\dist"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PayloadRoot}\server\*"; DestDir: "{app}\server"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PayloadRoot}\runtime\*"; DestDir: "{app}\runtime"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PayloadRoot}\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PayloadRoot}\native\bin\PRISM-Lighting.exe"; DestDir: "{app}\native\bin"; Flags: ignoreversion
Source: "{#PayloadRoot}\native\bin\WebView2Loader.dll"; DestDir: "{app}\native\bin"; Flags: ignoreversion
Source: "{#PayloadRoot}\native\licenses\*"; DestDir: "{app}\native\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PayloadRoot}\PRISM-starten.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#PayloadRoot}\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#PayloadRoot}\INSTALLATION.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "PRISM.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{#ShortcutGroup}\PRISM RGB Studio"; Filename: "{app}\PRISM-starten.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\PRISM.ico"; Comment: "RGB-Steuerzentrale öffnen"; AppUserModelID: "PRISM.RGBStudio"
Name: "{#ShortcutGroup}\PRISM deinstallieren"; Filename: "{uninstallexe}"; Comment: "PRISM RGB Studio entfernen"
Name: "{#ShortcutDesktop}\PRISM RGB Studio"; Filename: "{app}\PRISM-starten.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\PRISM.ico"; Tasks: desktopicon; Comment: "RGB-Steuerzentrale öffnen"; AppUserModelID: "PRISM.RGBStudio"

[Run]
Filename: "{app}\PRISM-starten.cmd"; WorkingDir: "{app}"; Description: "PRISM RGB Studio jetzt starten"; Flags: postinstall shellexec skipifsilent

; Inno removes only files recorded during installation. No broad directory deletion:
; user-added OpenRGB files and profiles stored in the browser are preserved.
