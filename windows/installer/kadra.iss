; Kadra installer (Inno Setup 6).
;   iscc /DAppVersion=1.0.0 /DSourceDir=build\windows\x64\runner\Release /DOutputName=kadra-v1.0.0-windows-x64-setup windows\installer\kadra.iss
; Installs per user by default (no administrator rights needed), so the app
; can update itself; "Install for all users" is offered in the first dialog.
; The in-app updater runs it with /SILENT /RELAUNCH=1.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef NumVersion
  #define NumVersion AppVersion
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputName
  #define OutputName "kadra-setup"
#endif

[Setup]
AppId={{6C0D9E2B-4F4A-4C55-9C7B-0F1E6B0A6B3D}
AppName=Kadra
AppVersion={#AppVersion}
AppVerName=Kadra {#AppVersion}
AppPublisher=Kadra
AppPublisherURL=https://github.com/Zaxar1231/ffmpeg-app
AppSupportURL=https://github.com/Zaxar1231/ffmpeg-app/issues
AppUpdatesURL=https://github.com/Zaxar1231/ffmpeg-app/releases
VersionInfoVersion={#NumVersion}
DefaultDirName={autopf}\Kadra
DefaultGroupName=Kadra
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=..\..\dist
OutputBaseFilename={#OutputName}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\kadra.exe
UninstallDisplayName=Kadra
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
ChangesAssociations=yes

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
ru.OpenWith=Добавить Kadra в «Открыть с помощью» для видео и аудио
en.OpenWith=Add Kadra to “Open with” for video and audio files

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "openwith"; Description: "{cm:OpenWith}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; Files moved aside by an in-app update of a portable copy.
Type: files; Name: "{app}\*.kadra-old"

[Icons]
Name: "{autoprograms}\Kadra"; Filename: "{app}\kadra.exe"; AppUserModelID: "Kadra.Kadra"
Name: "{autodesktop}\Kadra"; Filename: "{app}\kadra.exe"; Tasks: desktopicon

[Registry]
; "Open with" entries; the app opens the file on the Home screen.
Root: HKA; Subkey: "Software\Classes\Applications\kadra.exe"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "Kadra"; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\Applications\kadra.exe\shell\open\command"; ValueType: string; ValueData: """{app}\kadra.exe"" ""%1"""; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.mp4\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.mkv\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.mov\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.webm\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.avi\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.m4v\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.ts\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.flv\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.mp3\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.flac\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.wav\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.m4a\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.ogg\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.opus\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.aac\OpenWithList\kadra.exe"; ValueType: none; Flags: uninsdeletekey; Tasks: openwith

[Run]
Filename: "{app}\kadra.exe"; Description: "{cm:LaunchProgram,Kadra}"; Flags: nowait postinstall skipifsilent
; In-app update: start the new version after a silent install.
Filename: "{app}\kadra.exe"; Flags: nowait; Check: Relaunch

[Code]
function Relaunch: Boolean;
begin
  Result := WizardSilent and (ExpandConstant('{param:RELAUNCH|0}') = '1');
end;
