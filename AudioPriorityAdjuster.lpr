program AudioPriorityAdjuster;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  ShellApi, StrUtils,
  Forms, umain, audiodev, uAbout
  { you can add units after this };

{$R *.res}

function IsUserAnAdmin(): Boolean; external shell32;

var
  StartHidden: Boolean;
begin
  StartHidden:= Application.HasOption('hidden');
  if not IsUserAnAdmin() then
  begin
    ShellExecuteA(0, 'runas', PChar(Application.ExeName), PChar(IfThen(StartHidden, '-hidden', '')), nil, cmdshow);
    Exit;
  end;

  RequireDerivedFormResource:=True;
  Application.Title:='Audio Priority Adjuster';
  Application.ShowMainForm:= not StartHidden;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

