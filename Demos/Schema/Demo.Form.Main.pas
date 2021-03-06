unit Demo.Form.Main;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Rtti, Vcl.StdCtrls, System.DateUtils,
  System.Generics.Collections, System.JSON,

  OpenAPI.Nullables,
  OpenAPI.Schema,
  OpenAPI.Models,
  Neon.Core.Types,
  Neon.Core.Attributes,
  Neon.Core.Persistence,
  Neon.Core.Persistence.JSON;

type
  TPerson = class
  private
    FName: Nullable<string>;
    FAge: Nullable<Integer>;
    FBirthDay: Nullable<TDateTime>;
    FAdult: Boolean;
  public
    function IsNull: Boolean;
    property Name: Nullable<string> read FName write FName;
    property Age: Nullable<Integer> read FAge write FAge;
    property BirthDay: Nullable<TDateTime> read FBirthDay write FBirthDay;
    property Adult: Boolean read FAdult write FAdult;
  end;

type
  TJWTClaims = class
  private
    FMe: TPerson;
    FPippo: Nullable<string>;
    FPeople: TObjectList<TPerson>;
    FYou: TPerson;
    FPluto: string;
  public
    constructor Create; virtual;
    function ShouldInclude(AContext: TNeonIgnoreIfContext): Boolean;

    property Pippo: Nullable<string> read FPippo write FPippo;
    //[NeonInclude(Include.NotEmpty)]
    property Pluto: string read FPluto write FPluto;
    [NeonInclude(Include.CustomFunction)]
    property Me: TPerson read FMe write FMe;
    property You: TPerson read FYou write FYou;

    property People: TObjectList<TPerson> read FPeople write FPeople;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function GetNeonConfiguration: INeonConfiguration;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetNeonConfiguration: INeonConfiguration;
begin
  Result := TNeonConfiguration.Create;
  Result.
    SetPrettyPrint(True).
    GetSerializers.
      RegisterSerializer(TNullableStringSerializer).
      RegisterSerializer(TNullableBooleanSerializer).
      RegisterSerializer(TNullableIntegerSerializer).
      RegisterSerializer(TNullableInt64Serializer).
      RegisterSerializer(TNullableDoubleSerializer).
      RegisterSerializer(TNullableTDateTimeSerializer)
  ;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  LSchema: TOpenAPISchema;
begin
  LSchema := TOpenAPISchema.Create;
  try
    LSchema.Title := 'Titolo';
    LSchema.Type_ := 'object';

    LSchema.Not_ := TOpenAPISchema.Create;
    LSchema.Not_.Title := 'SubSchema';
    LSchema.Type_ := 'string';

    Memo1.Lines.Text := TNeon.ObjectToJSONString(LSchema, GetNeonConfiguration);
  finally
    LSchema.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  LJ: TJWTClaims;
begin
  LJ := TJWTClaims.Create;
  try
    LJ.Pippo := 'MAMAMAMMA';
    Memo1.Lines.Text := TNeon.ObjectToJSONString(LJ, GetNeonConfiguration);
  finally
    LJ.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  LDoc: TOpenAPIDocument;
begin
  LDoc := TOpenAPIDocument.Create;
  Memo1.Lines.Text := TNeon.ObjectToJSONString(LDoc, GetNeonConfiguration);
  LDoc.Free;
end;

constructor TJWTClaims.Create;
begin
  inherited Create;
  FMe := TPerson.Create;
  fme.Age := 50;
  FMe.Adult := False;
end;

function TJWTClaims.ShouldInclude(AContext: TNeonIgnoreIfContext): Boolean;
begin
  Result := False;

  // You can filter by the member name
  if SameText(AContext.MemberName, 'Me') then
  begin
    // And you can filter on additional conditions
    Result := not Me.IsNull;
  end
end;

{ TPerson }

function TPerson.IsNull: Boolean;
begin
  Result := FName.IsNull and FAge.IsNull and FBirthDay.IsNull;
end;

end.
