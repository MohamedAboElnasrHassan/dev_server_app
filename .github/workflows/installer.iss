#define MyAppName "{#AppName}"
#define MyAppVersion "{#AppVersion}"
#define MyAppExeName "{#AppExeName}"
#define SourceDir "{#SourceDir}"
#define OutputDir "{#OutputDir}"

[Setup]
AppId={{com.mohamedaboelnasrhassan.devserver}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=MohamedAboElnasrHassan
AppPublisherURL=https://github.com/MohamedAboElnasrHassan/dev_server
AppSupportURL=https://github.com/MohamedAboElnasrHassan/dev_server
AppUpdatesURL=https://github.com/MohamedAboElnasrHassan/dev_server
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir={#OutputDir}
OutputBaseFilename=dev_server-v{#MyAppVersion}-setup
SetupIconFile=assets\images\logo.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode
Name: "autostart"; Description: "Start automatically when Windows starts"; GroupDescription: "Auto-start options:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Visual C++ Runtime files
Source: "C:\Windows\System32\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion onlyifdoesntexist
Source: "C:\Windows\System32\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion onlyifdoesntexist
Source: "C:\Windows\System32\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion onlyifdoesntexist

; Flutter and plugin DLL files - ensure these are included
Source: "{#SourceDir}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\connectivity_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

// Check for VC++ Redistributable
function VCRedistInstalled: Boolean;
var
  ResultCode: Integer;
begin
  // Try to run a command that uses the VC++ runtime
  if Exec(ExpandConstant('{sys}\cmd.exe'), '/c echo VC++ Redistributable check', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Result := (ResultCode = 0)
  else
    Result := False;
end;

// Install VC++ Redistributable if needed
procedure InstallVCRedist;
var
  ResultCode: Integer;
  TempFile: String;
begin
  TempFile := ExpandConstant('{tmp}\vc_redist.x64.exe');

  // Download VC++ Redistributable
  if not FileExists(TempFile) then
  begin
    if not DownloadTemporaryFile('https://aka.ms/vs/17/release/vc_redist.x64.exe', 'vc_redist.x64.exe', '', nil) then
    begin
      MsgBox('Failed to download VC++ Redistributable. The application may not work correctly.', mbError, MB_OK);
      Exit;
    end;
  end;

  // Install VC++ Redistributable
  if Exec(TempFile, '/passive /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode <> 0 then
      MsgBox('VC++ Redistributable installation failed with code: ' + IntToStr(ResultCode), mbError, MB_OK);
  end
  else
    MsgBox('Failed to run VC++ Redistributable installer.', mbError, MB_OK);
end;

// Check for VC++ Redistributable during setup
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if not VCRedistInstalled then
    begin
      if MsgBox('Microsoft Visual C++ Redistributable is required for this application. Would you like to install it now?', mbConfirmation, MB_YESNO) = IDYES then
        InstallVCRedist;
    end;
  end;
end;
