unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, ComCtrls,
  StdCtrls, ExtCtrls, Menus, Buttons,
  audiodev;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnAbout: TSpeedButton;
    btnMoveTop: TSpeedButton;
    btnMoveUp: TSpeedButton;
    btnMoveDown: TSpeedButton;
    btnForget: TSpeedButton;
    btnMoveBottom: TSpeedButton;
    Label1: TLabel;
    lstDevices: TListView;
    btnShow: TMenuItem;
    btnExit: TMenuItem;
    btnMoveTop2: TMenuItem;
    btnForget2: TMenuItem;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    btnGithub: TMenuItem;
    MenuItem2: TMenuItem;
    btnMoveUp2: TMenuItem;
    btnMoveDown2: TMenuItem;
    btnMoveBottom2: TMenuItem;
    menuApp: TPopupMenu;
    menuDevLst: TPopupMenu;
    btnStartWithWindows: TMenuItem;
    MenuItem4: TMenuItem;
    btnAbout2: TMenuItem;
    btnSave: TMenuItem;
    btnExit2: TMenuItem;
    btnForget3: TMenuItem;
    btnDonationCoder: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    Separator5: TMenuItem;
    Separator6: TMenuItem;
    TrayIcon1: TTrayIcon;
    procedure btnAboutClick(Sender: TObject);
    procedure btnDonationCoderClick(Sender: TObject);
    procedure btnForgetClick(Sender: TObject);
    procedure btnGithubClick(Sender: TObject);
    procedure btnMoveBottomClick(Sender: TObject);
    procedure btnMoveTopClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnStartWithWindowsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure lstDevicesItemChecked(Sender: TObject; Item: TListItem);
    procedure menuDevLstPopup(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
  private
    fDeviceListFile: string;
    fDeviceList: TDeviceList;
    fDeviceNotification: TDeviceNotificationClient;
    fPrevDefault: unicodestring;
    fStartWithWindowsShortcutPath: string;

    function GetStartWithWindows: boolean;
    function GetStartWithWindowsShortcutPath: string;
    procedure LoadFileToListView(const FileName: string);
    procedure PopulateAudioDevices;
    procedure SaveListViewToFile(const FileName: string);
    procedure SetDefaultDevice;
    procedure SaveSettings;
    procedure OnDeviceNotification(Sender: TObject; Device: TDevice);
    procedure SetStartWithWindows(aStart: boolean);
    procedure ShowBallonHint(const aMsg: string; const aFlags: TBalloonFlags);
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  Windows, ShellApi, ShlObj, ComObj, ActiveX,
  uabout;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  fStartWithWindowsShortcutPath := GetStartWithWindowsShortcutPath;
  btnStartWithWindows.Checked := GetStartWithWindows;

  TrayIcon1.Icon := Application.Icon;
  TrayIcon1.Hint := Application.Title;
  TrayIcon1.BalloonTitle := Caption;

  fDeviceListFile := ChangeFileExt(Application.ExeName, '.ini');
  LoadFileToListView(fDeviceListFile);

  PopulateAudioDevices;
  SetDefaultDevice;

  fDeviceNotification := TDeviceNotificationClient.Create;
  fDeviceNotification.OnDeviceAdded := @OnDeviceNotification;
  fDeviceNotification.OnDeviceRemoved := @OnDeviceNotification;
  fDeviceNotification.OnDeviceStateChanged := @OnDeviceNotification;
  fDeviceNotification.OnDefaultDeviceChanged := @OnDeviceNotification;
  fDeviceNotification.Active := True;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  fDeviceNotification.Free;
  fDeviceList.Free;
  SaveSettings;
end;

procedure TfrmMain.FormWindowStateChange(Sender: TObject);
begin
  if WindowState = wsMinimized then
    Hide;
end;

procedure TfrmMain.lstDevicesItemChecked(Sender: TObject; Item: TListItem);
begin
  Item.Checked := not Item.Checked;
end;

procedure TfrmMain.menuDevLstPopup(Sender: TObject);
begin
  if lstDevices.ItemIndex = -1 then
    Abort;
end;

procedure TfrmMain.btnShowClick(Sender: TObject);
begin
  WindowState := wsNormal;
  Show;
end;

procedure TfrmMain.btnMoveUpClick(Sender: TObject);
var
  SelectedIndex: integer;
begin
  SelectedIndex := lstDevices.ItemIndex;

  // Check if an item is selected and not the first item
  if (SelectedIndex > 0) and (SelectedIndex < lstDevices.Items.Count) then
  begin
    lstDevices.Items.Exchange(SelectedIndex, SelectedIndex - 1);
    lstDevices.ItemIndex := SelectedIndex - 1;
  end;

  SetDefaultDevice;
end;

procedure TfrmMain.btnForgetClick(Sender: TObject);
var
  SelectedIndex: integer;
begin
  SelectedIndex := lstDevices.ItemIndex;

  // Check if an item is selected
  if SelectedIndex >= 0 then
  begin
    lstDevices.Items.Delete(SelectedIndex);
    lstDevices.ItemIndex := -1; // Clear the selection
  end;

  SetDefaultDevice;
end;

procedure TfrmMain.btnGithubClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://github.com/hwapx/dcAudioPriorityAdjuster', '', '', SWP_NOACTIVATE);
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  with TfrmAbout.Create(Self) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfrmMain.btnDonationCoderClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://www.donationcoder.com/', '', '', SW_SHOWDEFAULT);
end;

procedure TfrmMain.btnMoveBottomClick(Sender: TObject);
var
  SelectedIndex: integer;
begin
  SelectedIndex := lstDevices.ItemIndex;

  // Check if an item is selected
  if SelectedIndex >= 0 then
    lstDevices.Items.Move(SelectedIndex, lstDevices.Items.Count - 1);

  SetDefaultDevice;
end;

procedure TfrmMain.btnMoveTopClick(Sender: TObject);
var
  SelectedIndex: integer;
begin
  SelectedIndex := lstDevices.ItemIndex;

  // Check if an item is selected
  if SelectedIndex >= 0 then
    lstDevices.Items.Move(SelectedIndex, 0);

  SetDefaultDevice;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnMoveDownClick(Sender: TObject);
var
  SelectedIndex: integer;
begin
  SelectedIndex := lstDevices.ItemIndex;

  // Check if an item is selected and not the last item
  if (SelectedIndex >= 0) and (SelectedIndex < lstDevices.Items.Count - 1) then
  begin
    lstDevices.Items.Exchange(SelectedIndex, SelectedIndex + 1);
    lstDevices.ItemIndex := SelectedIndex + 1;
  end;

  SetDefaultDevice;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  SaveSettings;
end;

procedure TfrmMain.btnStartWithWindowsClick(Sender: TObject);
begin
  SetStartWithWindows(btnStartWithWindows.Checked);
end;

procedure TfrmMain.PopulateAudioDevices;
var
  Empty: boolean;

  procedure AddListItem(ToList: TListView; Device: TDevice); inline;
  const
    CStateName: array[TDeviceState] of string = (
      'Unknown', 'Active', 'Disabled', 'Unplugged');
  var
    Item: TListItem;
    DeviceName: string;
  begin
    DeviceName := UTF8Encode(Device.Name);
    Item := ToList.Items.FindCaption(0, DeviceName, False, True, False, False);
    if not Assigned(Item) then
    begin
      Item := ToList.Items.Add;
      Item.Caption := DeviceName;
    end;

    Item.SubItems.Text := CStateName[Device.State];
    Item.Checked := Device.Default;
    Item.Data := Device;

    if Empty and Item.Checked then
      ToList.Items.Move(Item.Index, 0);
  end;

var
  i: integer;
begin
  Empty := lstDevices.Items.Count = 0;

  if Assigned(fDeviceList) then
    fDeviceList.Free;

  fDeviceList := TDeviceList.Create;

  for i := 0 to fDeviceList.Count - 1 do
  begin
    AddListItem(lstDevices, fDeviceList[i]);

    if fDeviceList[I].Default and (fPrevDefault = '') then
      fPrevDefault := fDeviceList[I].Name;
  end;
end;

procedure TfrmMain.SaveListViewToFile(const FileName: string);
var
  StringList: TStringList;
  i: integer;
begin
  StringList := TStringList.Create;
  try
    // Copy ListView items to StringList
    for i := 0 to lstDevices.Items.Count - 1 do
      StringList.Add(lstDevices.Items[i].Caption);

    // Save StringList to file
    StringList.SaveToFile(FileName);
  finally
    StringList.Free;
  end;
end;

procedure TfrmMain.LoadFileToListView(const FileName: string);
var
  StringList: TStringList;
  i: integer;
begin
  if not FileExists(FileName) then
    exit;

  StringList := TStringList.Create;
  try
    // Load file contents into StringList
    StringList.LoadFromFile(FileName);

    // Clear existing ListView items
    lstDevices.Items.Clear;

    // Add each line from StringList to ListView
    for i := 0 to StringList.Count - 1 do
      lstDevices.Items.Add.Caption := StringList[i];
  finally
    StringList.Free;
  end;
end;

procedure TfrmMain.SetDefaultDevice;
var
  I: integer;
  Dev: TDevice;
begin
  for I := 0 to lstDevices.Items.Count - 1 do
    if lstDevices.Items[I].SubItems[0] = 'Active' then
    begin
      Dev := TDevice(lstDevices.Items[I].Data);

      if Dev.Default then
      begin
        if Dev.Name <> fPrevDefault then
          ShowBallonHint('Windows already changed default audio device to ' + Dev.Name, bfWarning);

        break;
      end;

      try
        Dev.SetDefault;
        fPrevDefault := Dev.Name;

        ShowBallonHint('Default audio device changed to ' + Dev.Name, bfInfo);
      except
        on E: Exception do
          ShowBallonHint('Error changing default device to ' + Dev.Name, bfError);
      end;

      break;
    end;
end;

procedure TfrmMain.SaveSettings;
begin
  SaveListViewToFile(fDeviceListFile);
end;

procedure TfrmMain.OnDeviceNotification(Sender: TObject; Device: TDevice);
begin
  PopulateAudioDevices;
  SetDefaultDevice;
end;

procedure TfrmMain.ShowBallonHint(const aMsg: string; const aFlags: TBalloonFlags);
begin
  TrayIcon1.BalloonFlags := aFlags;
  TrayIcon1.BalloonHint := aMsg;
  TrayIcon1.ShowBalloonHint;
end;

function TfrmMain.GetStartWithWindowsShortcutPath: string;
var
  StartupPath: string;
  ItemIDList: PItemIDList;
begin
  SetLength(StartupPath, MAX_PATH);

  if (SHGetSpecialFolderLocation(0, CSIDL_STARTUP, ItemIDList) <> S_OK) or not
    SHGetPathFromIDList(ItemIdList, PChar(StartupPath)) then
  begin
    Result := '';
    Exit;
  end;

  ILFree(ItemIDList);

  SetLength(StartupPath, StrLen(PChar(StartupPath)));

  Result := StartupPath + '\' + ChangeFileExt(ExtractFileName(Application.ExeName), '.lnk');
end;

function TfrmMain.GetStartWithWindows: boolean;
begin
  Result := FileExists(fStartWithWindowsShortcutPath);
end;

procedure TfrmMain.SetStartWithWindows(aStart: boolean);

  procedure CreateLink;
  var
    ShellLink: IShellLink;
  begin
    ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink;

    ShellLink.SetPath(PChar(Application.ExeName));
    ShellLink.SetArguments('-tray');
    ShellLink.SetWorkingDirectory(PChar(ExtractFilePath(Application.ExeName)));

    (ShellLink as IPersistFile).Save(pwidechar(WideString(fStartWithWindowsShortcutPath)), False);
  end;

begin
  if aStart then
    CreateLink
  else
    DeleteFile(PChar(fStartWithWindowsShortcutPath));
end;

end.
