unit DW.VCL.Container;

interface

uses Classes, System.SysUtils, Forms, VCL.ExtCtrls, Controls, System.RTLConsts, DWTypes,
DWElementTag, DW.VCL.Common, DW.VCL.ScriptEvents, DW.VCL.ScriptParams, DW.VCL.Interfaces;

type

  // TDWContainer is the Base for DW Containers:
  // DWForms, DWFrames, DWContainers(like a Regions), DWInputGroups, all containers.
  TDWContainer = class(TCustomControl, IDWControl)
  private
    FOnAsyncLoad: TDWAsyncProcedure;
    FOnAsyncUnLoad: TDWAsyncProcedure;
    FRenderInvisibleControls: Boolean;
    FAsyncRefreshControl: Boolean;
    FOnHTMLtag: TDWOnHtmlTagProcedure;
    FStyle: TStringList;
    FZIndex: Integer;
    FScript: TStringList;
    FCss: string;
    FScriptInsideTag: boolean;
    FScriptEvents: TDWScriptEvents;
    FScriptParams: TDWScriptParams;
    procedure OnScriptChange(ASender : TObject);
    procedure SetOnAsyncLoad(const Value: TDWAsyncProcedure);
    procedure SetOnAsyncUnLoad(const Value: TDWAsyncProcedure);
    procedure SetRenderInvisibleControls(const Value: Boolean);
    procedure SetOnHTMLtag(const Value: TDWOnHtmlTagProcedure);
    procedure SetStyle(const Value: TStringList);
    procedure SetZIndex(const Value: Integer);
    function IsScriptEventsStored: Boolean; virtual;
    procedure SetCss(const Value: string);

    procedure SetScriptEvents(const Value: TDWScriptEvents);
    procedure SetScriptInsideTag(const Value: boolean);
    function GetScriptParams: TDWScriptParams;
    procedure SetScriptParams(const Value: TDWScriptParams);
    procedure OnStyleChange(ASender : TObject);
    function GetScriptInsideTag: boolean;
    function GetScript: TStringList;
    procedure SetScript(const Value: TStringList);virtual;
  protected
    FMainID: string;
    FRendered: boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetParent(AParent: TWinControl); override;
    // Render HTML "style" tag property
    function RenderStyle: string; virtual;
    // used to render "class" attribute  on Async Calls in descendant class
    procedure InternalRenderCss(var ACss: string); virtual;
    procedure InternalRenderScript(const AHTMLName: string; AScript: TStringList);virtual;
    procedure RenderScripts; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetCssString: string;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    // Force a full refresh of the container and all Child Controls during an Async call.
    // Usually there is no need to use this method, only if some property changed during async calls is not reflected.
    procedure AsyncRefreshControl; virtual;
    // Cancel AsyncRefreshControl
    // Usually there is no need to use this method. It is for internal use.
    procedure ResetAsyncRefreshControl; virtual;
    // Remove a control from html flow. You should execute this when destroying a control durinc async calls before Freeing @br
    // If you are destroying a region is enought to execute this in that region, you don't need to execute it in each child control.
    procedure AsyncRemoveControl;
    // Render control on full form load or on FRendered = false
    // Return one TDWElementTag with element HTML
    function RenderHTML: TDWElementTag; virtual;
    // Render control on form Async Calls
    // Return one TDWElementXHTMLTag with element XHTML
    function RenderAsync: TDWElementXHTMLTag; virtual;
    // Render AsyncEvents(ClallBacks)
    function RenderAsyncEvents: string; virtual;
    // Render Cursor Style and add to "style" tag property
    function RenderCursorStyle: string; virtual;
    // Render Control Inline Style
    procedure InternalRenderStyle(AStyle: TStringList); virtual;
    //render child components
    procedure RenderComponents(aTagParent:TDWElementTag); virtual;
    function RenderCSSClass: string; virtual;
    // Get Form where Component it is
    // Need Type Cast to TDWCustomForm
    function Form: TDWContainer;
    // Return the first Parent Container
    function ParentContainer: TDWContainer;
    // Return name of element in HTML.
    // If RootParent is an TDWCustomForm, HTMLName is same as Name,
    // else if RootParent is an TDWFrame, HTMLName is FrameName_ComponentName
    // this is necessary because one frame can be placed into one Form,
    // and this can cause duplicate names in same HTML Page
    function HTMLName: string;
    // Return the root container of a component.
    // if component is in one TDWCustomForm, this return a Form,
    // else if component is in one TDWCustomFrame, this return a Frame
    // for compatibility the object returned is an TDWContainer,
    // but this never return containers, like a Panels, etc
    // the returned element to be casted usin some like this:
    // @preformatted(
    // if ReturnedObject.InheritsFrom(TDWCustomForm) then //its one Form
    // TDWCustomForm(ReturnedObject)."your code here"
    // else if ReturnedObject.InheritsFrom(TDWCustomFrame) then  //its one Frame
    // TDWCustomFrame(ReturnedObject)."your code here")
    function RootParent: TDWContainer;

  published
    // property "class" of HTML Element, used for CSS styles
    property Css: string read FCss write SetCss;
    // JavaScripts to be executted on browser when especified event occurs
    property ScriptEvents: TDWScriptEvents read FScriptEvents write SetScriptEvents stored IsScriptEventsStored;
    // Specifies user javascript code that will be rendered and executed with this object. @br
    // You can define ScriptParams inside the script. ScriptParams are specified in scripts as: {%param%}. @br
    // With property ScriptInsideTag you can define if the script will be rendered inside or outside the script.
    property Script: TStringList read GetScript write SetScript;
    property ScriptParams: TDWScriptParams read GetScriptParams write SetScriptParams;
        // Specifies if the script will be rendered inside the control tag or not. @br
    // If true the script will be rendered inside the tag. @br
    // If false a new div will be created to surround the control and the script will be rendered in this div, outside the control tag. @br
    // this is necessary script can't be placed inside the tag, for example in input controls.
    property ScriptInsideTag: boolean read GetScriptInsideTag write SetScriptInsideTag default True;
    property RenderInvisibleControls: Boolean read FRenderInvisibleControls
      write SetRenderInvisibleControls default True;
    // List of inline styles in pairs name: value
    property Style: TStringList read FStyle write SetStyle;
    // The z-index property specifies the stack order of an element.
    // An element with greater stack order is always in front of an element with a lower stack order.
    // Note: z-index only works on positioned elements (position:absolute, position:relative, or position:fixed).
    // see: http://www.w3schools.com/csSref/pr_pos_z-index.asp
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
    property OnAsyncLoad: TDWAsyncProcedure read FOnAsyncLoad write SetOnAsyncLoad;
    property OnAsyncUnLoad: TDWAsyncProcedure read FOnAsyncUnLoad write SetOnAsyncUnLoad;
    // Occurs after HTMLTag is created
    property OnHTMLtag: TDWOnHtmlTagProcedure read FOnHTMLtag write SetOnHTMLtag;
  end;

  //base for all Modules Containers(Forms, Frames, etc)
  TDWModuleContainer = class(TDWContainer)
    public
      constructor Create(AOwner: TComponent); override;
  end;


  // Helper to access private Field  FTabList in TWinControl,
  // is used in TDWControl Class
  TWinControlHelper = class helper for TWinControl
  public
    function GetTabList: TList;
  end;

implementation

uses DWUtils, DW.VCL.CustomForm, DW.VCL.Frame;

{ TDWContainer }

procedure TDWContainer.AsyncRefreshControl;
begin
  FAsyncRefreshControl := True;
  Invalidate;
end;

procedure TDWContainer.AsyncRemoveControl;
begin
  TDWBSCommon.AsyncRemoveControl(FMainID);
  FAsyncRefreshControl := False;
  FRendered := False;
end;

constructor TDWContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAsyncRefreshControl    := False;
  RenderInvisibleControls := True;
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents, csSetCaption, csDoubleClicks,
    csParentBackground, csPannable, csGestures];
 (*f (ClassType <> TFrame) and not(csDesignInstance in ComponentState) then
    begin
      if not InitInheritedComponent(Self, TDWContainer) then
        raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
    end
  else
    begin
      Width  := 320;
      Height := 240;
    end;  *)

  FRendered := False;
  //FReleased := False;
  //FCustomAsyncEvents := nil;
  //FCustomRestEvents := nil;
  FCss := '';
  FMainID := '';
  FScript := TStringList.Create;
  FScript.OnChange := OnScriptChange;
  FScriptInsideTag := True;
  FScriptParams := TDWScriptParams.Create;
  FScriptParams.OnChange := OnScriptChange;
  FScriptEvents:= TDWScriptEvents.Create(Self);
  FStyle := TStringList.Create;
  FStyle.OnChange := OnStyleChange;
  FStyle.NameValueSeparator := ':';
  //default parent
  if (Parent = nil)
  and (AOwner <> nil)
  and (AOwner is TWinControl) then
   Parent:= TWinControl(Aowner);
  //default Name
  if name = '' then
    name := DWGetUniqueComponentName(Owner, Copy(ClassName,2,MaxInt));
end;

procedure TDWContainer.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Parent = nil then
    Params.WndParent := Application.Handle;
end;

destructor TDWContainer.Destroy;
begin
  FScriptEvents.Free;
  inherited;
end;

function TDWContainer.Form: TDWContainer;
begin
  Result := TDWContainer(DWFindParentForm(Self));
end;

[UIPermission(SecurityAction.LinkDemand, Window = UIPermissionWindow.AllWindows)]
procedure TDWContainer.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
      begin
        OwnedComponent := Components[I];
        if not OwnedComponent.HasParent then
          Proc(OwnedComponent);
      end;
end;

function TDWContainer.GetCssString: string;
begin
   Result := RenderCSSClass;
end;

function TDWContainer.GetScript: TStringList;
begin
  Result:= FScript;
end;

function TDWContainer.GetScriptInsideTag: boolean;
begin
  Result:= FScriptInsideTag;
end;

function TDWContainer.GetScriptParams: TDWScriptParams;
begin
  Result := FScriptParams;
end;

function TDWContainer.HTMLName: string;
var
  LRootParent: TDWContainer;
begin
  LRootParent := RootParent;
  //
  if LRootParent.InheritsFrom(TDWCustomForm) then
    HTMLName := Name
  else
    HTMLName := LRootParent.Name + '_' + Name;
end;

procedure TDWContainer.InternalRenderCss(var ACss: string);
begin
  raise Exception.Create('Implement InternalRenderCss in Descendant Class: ' + ClassName);
end;

procedure TDWContainer.InternalRenderScript(const AHTMLName: string;
  AScript: TStringList);
begin
  raise Exception.Create('Implement InternalRenderScript in Descendant Class: ' + ClassName);
end;

procedure TDWContainer.InternalRenderStyle(AStyle: TStringList);
begin
  raise Exception.Create('Implement InternalRenderStyle in Descendant Class: ' + ClassName);
end;

function TDWContainer.IsScriptEventsStored: Boolean;
begin
  Result := ScriptEvents.Count > 0;
end;

procedure TDWContainer.OnScriptChange(ASender: TObject);
begin
  AsyncRefreshControl;
end;

procedure TDWContainer.OnStyleChange(ASender: TObject);
begin
  Invalidate;
end;

procedure TDWContainer.SetCss(const Value: string);
begin
  if FCss <> value then
    begin
      FCss := Value;
      Invalidate;
    end;
end;

procedure TDWContainer.SetOnAsyncLoad(const Value: TDWAsyncProcedure);
begin
  FOnAsyncLoad := Value;
end;

procedure TDWContainer.SetOnAsyncUnLoad(const Value: TDWAsyncProcedure);
begin
  FOnAsyncUnLoad := Value;
end;

procedure TDWContainer.SetOnHTMLtag(const Value: TDWOnHtmlTagProcedure);
begin
  FOnHTMLtag := Value;
end;

[UIPermission(SecurityAction.LinkDemand, Window = UIPermissionWindow.AllWindows)]
procedure TDWContainer.SetParent(AParent: TWinControl);
var
  LRecreate: Boolean;
begin
  LRecreate := HandleAllocated;
  if LRecreate then
    UpdateRecreatingFlag(True);
  try
    if (Parent = nil) and LRecreate then
      DestroyHandle;
    inherited;
  finally
    if LRecreate then
      UpdateRecreatingFlag(False);
  end;
end;

procedure TDWContainer.SetRenderInvisibleControls(const Value: Boolean);
begin
  if FRenderInvisibleControls <> Value then
    begin
      FRenderInvisibleControls := Value;
      AsyncRefreshControl;
    end;
end;

procedure TDWContainer.SetScript(const Value: TStringList);
begin
  FScript.Assign(Value);
end;

procedure TDWContainer.SetScriptEvents(const Value: TDWScriptEvents);
begin
  FSCriptEvents.Assign(Value);
end;

procedure TDWContainer.SetScriptInsideTag(const Value: boolean);
begin
  FScriptInsideTag := Value;
end;

procedure TDWContainer.SetScriptParams(const Value: TDWScriptParams);
begin
  FScriptParams.Assign(Value);
end;

procedure TDWContainer.SetStyle(const Value: TStringList);
begin
  FStyle.Assign(Value);
end;

procedure TDWContainer.SetZIndex(const Value: Integer);
begin
  FZIndex := Value;
end;

function TDWContainer.ParentContainer: TDWContainer;
begin
  Result := GetParentContainer(Self);
end;

function TDWContainer.RenderAsync: TDWElementXHTMLTag;
begin
  raise Exception.Create('Implement RenderAsync in Descendant Class: ' + ClassName);
end;

function TDWContainer.RenderAsyncEvents: string;
begin
  raise Exception.Create('Implement RenderAsyncEvents in Descendant Class: ' + ClassName);
end;

procedure TDWContainer.RenderComponents(aTagParent:TDWElementTag);
begin
  TDWRegionCommon.RenderComponents(Self, aTagParent);
end;

function TDWContainer.RenderCSSClass: string;
begin
   raise Exception.Create('Implement RenderCSSClass in Descendant Class: ' + ClassName);
end;

function TDWContainer.RenderCursorStyle: string;
begin
  { TODO 1 -oDELCIO -cIMPLEMENT : Render Container Cursor Style }
end;

function TDWContainer.RenderHTML: TDWElementTag;
begin
  raise Exception.Create('Implement RenderHTML in Descendant Class: ' + ClassName);
end;


procedure TDWContainer.RenderScripts;
begin
  raise Exception.Create('Implement RenderScripts in Descendant Class: ' + ClassName);
end;

function TDWContainer.RenderStyle: string;
begin
  raise Exception.Create('Implement RenderStyle in Descendant Class: ' + ClassName);
end;

procedure TDWContainer.ResetAsyncRefreshControl;
begin
  FAsyncRefreshControl := False;
end;

function TDWContainer.RootParent: TDWContainer;
//var
 // CompTest: TControl;
//  LForm: TDWCustomForm;
begin
  Result := nil;
  { TODO 1 -oDELCIO -cIMPLEMENT :  Find RootParent for Frame }
  (* CompTest := self;
    while Assigned(CompTest) and (not(CompTest is TDWCustomFrame)) do
    CompTest := CompTest.Parent; *)
  if Result = nil then
    Result := TDWContainer(Form);
end;

{ TWinControlHelper }

function TWinControlHelper.GetTabList: TList;
begin
  Result := Self.FTabList;
end;

{ TDWModuleContainer }

constructor TDWModuleContainer.Create(AOwner: TComponent);
begin
  inherited;
  if (ClassType <> TFrame) and not(csDesignInstance in ComponentState) then
    begin
      if not InitInheritedComponent(Self, TFrame) then
        raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
    end
  else
    begin
      Width  := 320;
      Height := 240;
    end;
end;

end.
