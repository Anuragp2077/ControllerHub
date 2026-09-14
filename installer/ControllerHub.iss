#define MyAppName "ControllerHub"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "ControllerHub"
#define MyAppExeName "ControllerHub.exe"

#define ProjectRoot ".."
#define PublishDir "..\ControllerHub.App\bin\Release\net10.0-windows\win-x64\publish"
#define ViGEmInstaller "payload\ViGEmBus_1.22.0_x64_x86_arm64.exe"

[Setup]

AppId={{8E8E0A40-7C0B-4E5F-9F3A-CONTROLLERHUB-V1}}

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\ControllerHub
DefaultGroupName=ControllerHub

OutputDir=..\releases\v1.0.0
OutputBaseFilename=ControllerHub-Setup-v1.0.0

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

PrivilegesRequired=admin

Compression=lzma
SolidCompression=yes

WizardStyle=modern

SetupIconFile=..\ControllerHub.App\controllerhub.ico

UninstallDisplayIcon={app}\ControllerHub.exe

DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]

Source: "{#PublishDir}\ControllerHub.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion

Source: "{#ViGEmInstaller}"; \
    DestDir: "{tmp}"; \
    Flags: deleteafterinstall

[Icons]

Name: "{group}\ControllerHub"; \
    Filename: "{app}\ControllerHub.exe"; \
    IconFilename: "{app}\ControllerHub.exe"

Name: "{autodesktop}\ControllerHub"; \
    Filename: "{app}\ControllerHub.exe"; \
    IconFilename: "{app}\ControllerHub.exe"

[Run]

Filename: "{tmp}\ViGEmBus_1.22.0_x64_x86_arm64.exe"; \
    Parameters: "/exenoui /qn /norestart"; \
    StatusMsg: "Installing ViGEmBus virtual controller driver..."; \
    Flags: waituntilterminated

Filename: "{app}\ControllerHub.exe"; \
    Description: "Launch ControllerHub"; \
    Flags: nowait postinstall skipifsilent