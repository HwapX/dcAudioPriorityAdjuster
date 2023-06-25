unit audiodev;

{$mode objfpc}{$H+}

interface

uses Windows, ActiveX, ComObj;

// Start API extracted from MSDN

const
  CLSID_MMDeviceEnumerator: TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  CLSID_IMMEndpoint: TGUID = '{1BE09788-6894-4089-8586-9A2A6C265AC5}';

const
  DEVICE_STATE_ACTIVE = $00000001;
  DEVICE_STATE_DISABLED = $00000002;
  //  DEVICE_STATE_NOTPRESENT = $00000004;
  DEVICE_STATE_UNPLUGGED = $00000008;
//  DEVICE_STATEMASK_ALL    = $0000000F;

{$MINENUMSIZE 4}
type
  EDataFlow = (
    eRender,
    eCapture,
    eAll,
    eDataFlow_enum_count);

  ERole = (
    eConsole,
    eMultimedia,
    eCommunications,
    eRole_enum_count);

  TPropertyKey = record
    fmtid: TGUID;
    pid: DWORD;
  end;

  IMMNotificationClient = interface(IUnknown)
    ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
    function OnDeviceStateChanged(pwstrDeviceId: LPWSTR; dwNewState: DWORD): HRESULT; stdcall;
    function OnDeviceAdded(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
    function OnDeviceRemoved(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
    function OnDefaultDeviceChanged(flow: EDataFlow; role: ERole; pwstrDefaultDeviceId: LPWSTR): HRESULT; stdcall;
    function OnPropertyValueChanged(pwstrDeviceId: LPWSTR; const key: TPropertyKey): HRESULT; stdcall;
  end;

  IPropertyStore = interface(IUnknown)
    function GetCount(out cProps: DWORD): HRESULT; stdcall;
    function GetAt(iProp: DWORD; out key: TPropertyKey): HRESULT; stdcall;
    function GetValue(const key: TPropertyKey; out Value: TPropVariant): HRESULT; stdcall;
    function SetValue(const key: TPropertyKey; const propvar: TPropVariant): HRESULT; stdcall;
    function Commit: HRESULT; stdcall;
  end;

  IMMDevice = interface(IUnknown)
    ['{D666063F-1587-4E43-81F1-B948E807363F}']
    function Activate(const iid: TGUID; dwClsCtx: DWORD; pActivationParams: PPropVariant;
      out EndpointVolume: IUnknown): HRESULT; stdcall;
    function OpenPropertyStore(stgmAccess: DWORD; out Properties: IPropertyStore): HRESULT; stdcall;
    function GetId(out strId: LPWSTR): HRESULT; stdcall;
    function GetState(out State: DWORD): HRESULT; stdcall;
  end;

  IMMDeviceCollection = interface(IUnknown)
    ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
    function GetCount(out cDevices: UINT): HRESULT; stdcall;
    function Item(nDevice: UINT; out Device: IMMDevice): HRESULT; stdcall;
  end;

  IMMDeviceEnumerator = interface(IUnknown)
    ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(dataFlow: EDataFlow; dwStateMask: DWORD;
      out Devices: IMMDeviceCollection): HRESULT; stdcall;
    function GetDefaultAudioEndpoint(EDF: EDataFlow; role: ERole; out EndPoint: IMMDevice): HRESULT; stdcall;
    function GetDevice(pwstrId: LPWSTR; out EndPoint: IMMDevice): HRESULT; stdcall;
    function RegisterEndpointNotificationCallback(const Client: IMMNotificationClient): HRESULT; stdcall;
    function UnregisterEndpointNotificationCallback(const Client: IMMNotificationClient): HRESULT; stdcall;
  end;

  IMMEndpoint = interface(IUnknown)
    ['{1BE09788-6894-4089-8586-9A2A6C265AC5}']
    function GetDataFlow(out dataFlow: EDataFlow): HResult; stdcall;
    function GetEndpointID(out endpointID: LPWSTR): HResult; stdcall;
    function GetDeviceID(out deviceID: LPWSTR): HResult; stdcall;
    function GetDisplayName(out displayName: LPWSTR): HResult; stdcall;
    function SetDisplayName(displayName: LPCWSTR): HResult; stdcall;
    function GetIconPath(out iconPath: LPWSTR): HResult; stdcall;
    function SetIconPath(iconPath: LPCWSTR): HResult; stdcall;
    function GetRuntimeID(out runtimeID: PWCHAR): HResult; stdcall;
  end;

const
  CLSID_IPolicyConfig: TGUID = '{870AF99C-171D-4F9E-AF0D-E63DF40C2BC9}';

type
  IPolicyConfig = interface(IUnknown)
    ['{F8679F50-850A-41CF-9C72-430F290290C8}']

    function SetDefaultEndpoint(wszDeviceId: PCWSTR; eRole: ERole): HRESULT; stdcall;
  end;

const
  CLSID_IPolicyConfigVista: TGUID = '{294935CE-F637-4E7C-A41B-AB255460B862}';
  IID_IPolicyConfigVista: TGUID = '{568b9108-44bf-40b4-9006-86afe5b5a620}';

type
  IPolicyConfigVista = interface(IUnknown)
    ['{568b9108-44bf-40b4-9006-86afe5b5a620}']
    function GetMixFormat(const pszDeviceName: LPCWSTR; out ppFormat: PWAVEFORMATEX): HRESULT; stdcall;
    function GetDeviceFormat(const pszDeviceName: LPCWSTR; nStream: Integer; out ppFormat: PWAVEFORMATEX): HRESULT; stdcall;
    function SetDeviceFormat(const pszDeviceName: LPCWSTR; pEndpointFormat, MixFormat: PWAVEFORMATEX): HRESULT; stdcall;
    function GetProcessingPeriod(const pszDeviceName: LPCWSTR; nStream: Integer; out pnPeriod, pnDRA: Int64): HRESULT; stdcall;
    function SetProcessingPeriod(const pszDeviceName: LPCWSTR; nPeriod: PInt64): HRESULT; stdcall;
    function GetShareMode(const pszDeviceName: LPCWSTR; out pMode: Pointer): HRESULT; stdcall;
    function SetShareMode(const pszDeviceName: LPCWSTR; pMode: Pointer): HRESULT; stdcall;
    function GetPropertyValue(const pszDeviceName: LPCWSTR; const Key: TPROPERTYKEY; out Value: PROPVARIANT): HRESULT; stdcall;
    function SetPropertyValue(const pszDeviceName: LPCWSTR; const Key: TPROPERTYKEY; const Value: PROPVARIANT): HRESULT; stdcall;
    function SetDefaultEndpoint(const wszDeviceId: LPCWSTR; eRole: ERole): HRESULT; stdcall;
    function SetEndpointVisibility(const pszDeviceName: LPCWSTR; nVisibility: Integer): HRESULT; stdcall;
  end;

  // End API

  // Own wrapper

  TDeviceState = (dsUnknown, dsActive, dsDisabled, dsUnplagged);

  { TDevice }

  TDevice = class(TObject)
  private
    fId: unicodestring;
    fName: unicodestring;
    fState: TDeviceState;
    fDefault: boolean;
    fMMDevice: IMMDevice;
  public
    constructor Create(const MMDevice: IMMDevice);
    procedure SetDefault;

    property Id: unicodestring read fId;
    property Name: unicodestring read fName;
    property State: TDeviceState read fState;
    property Default: boolean read fDefault;
  end;

  { TDeviceList }

  TDeviceList = class(TObject)
  private
    fList: array of TDevice;
    function GetCount: integer;
    function GetItem(Index: integer): TDevice;
  public
    constructor Create;
    destructor Destroy; override;
    function FindById(AId: string): TDevice;
    function FindByName(AName: string): TDevice;
    property Count: integer read GetCount;
    property Items[Index: integer]: TDevice read GetItem; default;
  end;

  TDeviceNotificationClientCallback = procedure(Sender: TObject; Device: TDevice) of object;

  { TDeviceNotificationClient }

  TDeviceNotificationClient = class(TInterfacedObject, IMMNotificationClient)
    procedure IMMNotificationClient.OnDefaultDeviceChanged = InternalOnDefaultDeviceChanged;
    procedure IMMNotificationClient.OnDeviceAdded = InternalOnDeviceAdded;
    procedure IMMNotificationClient.OnDeviceRemoved = InternalOnDeviceRemoved;
    procedure IMMNotificationClient.OnDeviceStateChanged = InternalOnDeviceStateChanged;
    procedure IMMNotificationClient.OnPropertyValueChanged = InternalOnPropertyValueChanged;
  private
    fDE: IMMDeviceEnumerator;
    fActive: boolean;
    function InternalOnDefaultDeviceChanged(flow: EDataFlow; role: ERole;
      pwstrDefaultDeviceId: LPWSTR): HRESULT; stdcall;
    function InternalOnDeviceAdded(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
    function InternalOnDeviceRemoved(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
    function InternalOnDeviceStateChanged(pwstrDeviceId: LPWSTR; dwNewState: DWORD): HRESULT; stdcall;
    function InternalOnPropertyValueChanged(pwstrDeviceId: LPWSTR; const key: TPropertyKey): HRESULT; stdcall;

    procedure SetActive(AValue: boolean);
    procedure Callback(AMethod: TDeviceNotificationClientCallback; ADeviceId: LPWSTR);
  public
    OnDeviceAdded: TDeviceNotificationClientCallback;
    OnDeviceRemoved: TDeviceNotificationClientCallback;
    OnDefaultDeviceChanged: TDeviceNotificationClientCallback;
    OnDeviceStateChanged: TDeviceNotificationClientCallback;

    destructor Destroy; override;
    property Active: boolean read fActive write SetActive;
  end;

implementation

{ TDeviceNotificationClient }

function TDeviceNotificationClient.InternalOnDefaultDeviceChanged(flow: EDataFlow; role: ERole;
  pwstrDefaultDeviceId: LPWSTR): HRESULT; stdcall;
begin
  Result := S_OK;

  Callback(OnDefaultDeviceChanged, pwstrDefaultDeviceId);
end;

function TDeviceNotificationClient.InternalOnDeviceAdded(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
begin
  Result := S_OK;

  Callback(OnDeviceAdded, pwstrDeviceId);
end;

function TDeviceNotificationClient.InternalOnDeviceRemoved(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
begin
  Result := S_OK;

  Callback(OnDeviceRemoved, pwstrDeviceId);
end;

function TDeviceNotificationClient.InternalOnDeviceStateChanged(pwstrDeviceId: LPWSTR;
  dwNewState: DWORD): HRESULT; stdcall;
begin
  Result := S_OK;

  Callback(OnDefaultDeviceChanged, pwstrDeviceId);
end;

function TDeviceNotificationClient.InternalOnPropertyValueChanged(pwstrDeviceId: LPWSTR;
  const key: TPropertyKey): HRESULT; stdcall;
begin
  Result := S_OK;
end;

procedure TDeviceNotificationClient.SetActive(AValue: boolean);
begin
  if fActive = AValue then
    Exit;

  if AValue then
  begin
    fDE := CreateComObject(CLSID_MMDeviceEnumerator) as IMMDeviceEnumerator;
    OleCheck(fDE.RegisterEndpointNotificationCallback(Self));
  end
  else
  begin
    OleCheck(fDE.UnregisterEndpointNotificationCallback(Self));
    fDE := nil;
  end;

  fActive := AValue;
end;

procedure TDeviceNotificationClient.Callback(AMethod: TDeviceNotificationClientCallback; ADeviceId: LPWSTR);
var
  Dev: TDevice;
  MMDevice: IMMDevice;
begin
  if not Assigned(AMethod) then
    Exit;

  OleCheck(fde.GetDevice(ADeviceId, MMDevice));
  Dev := TDevice.Create(MMDevice);
  try
    AMethod(Self, Dev);
  finally
    Dev.Free;
  end;
end;

destructor TDeviceNotificationClient.Destroy;
begin
  Active := False;

  inherited;
end;

{ TDeviceList }

constructor TDeviceList.Create;
const
  CValidState = DEVICE_STATE_ACTIVE or DEVICE_STATE_DISABLED or DEVICE_STATE_UNPLUGGED;
var
  DE: IMMDeviceEnumerator;
  DC: IMMDeviceCollection;
  i, Cnt: UINT;
  MMDevice: IMMDevice;
  Device: TDevice;
begin
  inherited Create;

  CoInitialize(nil);

  DE := CreateComObject(CLSID_MMDeviceEnumerator) as IMMDeviceEnumerator;
  OleCheck(DE.EnumAudioEndpoints(eRender, CValidState, DC));
  OleCheck(DC.GetCount(Cnt));
  SetLength(fList, Cnt);
  for i := 0 to Cnt - 1 do
  begin
    OleCheck(DC.Item(i, MMDevice));
    fList[i] := TDevice.Create(MMDevice);
  end;

  if DE.GetDefaultAudioEndpoint(eRender, eConsole, MMDevice) = S_OK then
  begin
    Device := TDevice.Create(MMDevice);
    try
      for i := Low(fList) to High(fList) do
        if fList[i].Id = Device.Id then
        begin
          fList[i].fDefault := True;
          Break;
        end;
    finally
      Device.Free;
    end;
  end;
end;

destructor TDeviceList.Destroy;
var
  i: integer;
begin
  for i := Low(fList) to High(fList) do
    fList[i].Free;

  CoUninitialize;

  inherited;
end;

function TDeviceList.FindById(AId: string): TDevice;
var
  I: integer;
begin
  Result := nil;

  for I := Low(fList) to High(fList) do
    if fList[I].Id = unicodestring(AId) then
      Exit(fList[I]);
end;

function TDeviceList.FindByName(AName: string): TDevice;
var
  I: integer;
begin
  Result := nil;

  for I := Low(fList) to High(fList) do
    if fList[I].Name = unicodestring(AName) then
      Exit(fList[I]);
end;

function TDeviceList.GetCount: integer;
begin
  Result := Length(fList);
end;

function TDeviceList.GetItem(Index: integer): TDevice;
begin
  Result := fList[Index];
end;

function PropVariantClear(var PropVar: TPropVariant): HRESULT; stdcall;
  external 'ole32.dll';

constructor TDevice.Create(const MMDevice: IMMDevice);

  procedure PropVariantInit(out PropVar: TPropVariant); inline;
  begin
    ZeroMemory(@PropVar, SizeOf(PropVar));
  end;

const
  PKEY_Device_FriendlyName: TPropertyKey =
    (fmtid: '{A45C254E-DF1C-4EFD-8020-67D146A850E0}'; pid: 14); // DEVPROP_TYPE_STRING
var
  Props: IPropertyStore;
  VarName: TPropVariant;
  DevState: DWORD;
  AId: pwidechar;
begin
  inherited Create;
  OleCheck(MMDevice.GetState(DevState));
  OleCheck(MMDevice.OpenPropertyStore(STGM_READ, Props));
  OleCheck(MMDevice.GetId(AId));
  fId := AId;
  CoTaskMemFree(AId);
  PropVariantInit(VarName);
  OleCheck(Props.GetValue(PKEY_Device_FriendlyName, VarName));
  fName := VarName.pwszVal;
  case DevState of
  DEVICE_STATE_ACTIVE:
    fState := dsActive;
  DEVICE_STATE_DISABLED:
    fState := dsDisabled;
  DEVICE_STATE_UNPLUGGED:
    fState := dsUnplagged;
  else
    fState := dsUnknown;
  end;
  PropVariantClear(VarName);
  Props := nil;
  fMMDevice := MMDevice;
end;

procedure TDevice.SetDefault;
var
  PolicyConfig: IPolicyConfigVista;
  AId: pwidechar;
begin      
  OleCheck(fMMDevice.GetId(AId));
  PolicyConfig := CreateComObject(CLSID_IPolicyConfigVista) as IPolicyConfigVista;
  OleCheck(PolicyConfig.SetDefaultEndpoint(PWideChar(fId), eConsole));
  CoTaskMemFree(AId);
end;


end.
