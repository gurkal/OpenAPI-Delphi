unit Demo.Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Rtti, Vcl.StdCtrls,

  Neon.Core.Types,
  Neon.Core.Persistence,
  Neon.Core.Persistence.JSON,
  OpenAPI.Models,
  OpenAPI.Serializer,
  OpenAPI.Schema;


type
  TfrmMain = class(TForm)
    memoDocument: TMemo;
    btnAddInfo: TButton;
    btnDocumentGenerate: TButton;
    btnAddServers: TButton;
    btnAddPaths: TButton;
    btnAddModels: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAddInfoClick(Sender: TObject);
    procedure btnAddServersClick(Sender: TObject);
    procedure btnDocumentGenerateClick(Sender: TObject);
    procedure btnAddPathsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddModelsClick(Sender: TObject);
  private
    FDocument: TOpenAPIDocument;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FDocument := TOpenAPIDocument.Create;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FDocument.Free;
end;

procedure TfrmMain.btnAddInfoClick(Sender: TObject);
begin
  FDocument.OpenAPI := '3.0.2';
  FDocument.Info.Title := 'OpenAPI Demo';
  FDocument.Info.Description := 'OpenAPI Demo Description';
  FDocument.Info.Contact.Name := 'Paolo Rossi';
  FDocument.Info.Contact.URL := 'https://github.com/paolo-rossi';
  FDocument.Info.License.Name := 'Apache-2.0';
  FDocument.Info.License.URL := 'http://www.apache.org/licenses/';
end;

procedure TfrmMain.btnAddServersClick(Sender: TObject);
begin
  FDocument.Servers.Add(TOpenAPIServer.Create('https://api.mycompany.com/rest/app/', 'Production Server'));
  FDocument.Servers.Add(TOpenAPIServer.Create('https://beta.mycompany.com/rest/app/', 'Beta Server API v2'));
  FDocument.Servers.Add(TOpenAPIServer.Create('https://test.mycompany.com/rest/app/', 'Testing Server'));
end;

procedure TfrmMain.btnDocumentGenerateClick(Sender: TObject);
begin
  memoDocument.Lines.Text := TNeon.ObjectToJSONString(FDocument, TOpenAPISerializer.GetNeonConfig);
end;

procedure TfrmMain.btnAddModelsClick(Sender: TObject);
var
  LCOmponents: TOpenAPIComponents;
  CustomerSchemaRef,CustomerSchema: TOpenAPISchema;
begin
  CustomerSchemaRef:=TOpenAPISchema.Create;
  CustomerSchemaRef.Type_:='object';

  CustomerSchema:=TOpenAPISchema.Create;
  CustomerSchema.Type_:='integer';
  CustomerSchemaRef.Properties.Add('id',CustomerSchema);

  CustomerSchema:=TOpenAPISchema.Create;
  CustomerSchema.Type_:='string';
  CustomerSchemaRef.Properties.Add('name',CustomerSchema);


  FDocument.Components.Schemas.Add('customer',CustomerSchemaRef);
end;

procedure TfrmMain.btnAddPathsClick(Sender: TObject);
var
  LPath: TOpenAPIPathItem;
  LParameter: TOpenAPIParameter;
  LResponse: TOpenAPIResponse;
  LResponseContent: TOpenApiMediaType;
  LRequestBody: TOpenApiMediaType;
begin
  LPath := TOpenAPIPathItem.Create;
  LPath.Description := 'Customers resource';

  LPath.Get.Summary := 'Get all customers';
  LPath.Get.OperationId := 'CustomerList';

  LParameter := TOpenAPIParameter.Create;
  LPath.Get.Parameters.Add(LParameter);
  LParameter.Name := 'id';
  LParameter.In_ := 'query';
  LParameter.Description := 'Customer ID';
  LParameter.Schema.Type_ := 'string';
  LParameter.Schema.Enum.ValueFrom<TArray<string>>(['enum1', 'enum2']);
  LParameter.Style:=TParameterStyle.Form;


  LParameter := TOpenAPIParameter.Create;
  LPath.Get.Parameters.Add(LParameter);
  LParameter.Name := 'country';
  LParameter.In_ := 'query';
  LParameter.Description := 'Country Code';
  LParameter.Schema.Type_ := 'string';
  LParameter.Schema.Enum.ValueFrom<TArray<string>>(['it', 'en', 'de', 'ch', 'fr']);
  LParameter.Style:=TParameterStyle.Form;

  LResponse:=TOpenAPIResponse.Create;
  LResponse.Description:='OK';
  LResponseContent:=TOpenApiMediaType.Create;
  LResponseContent.Schema.Type_:='array';

  LResponseContent.Schema.Items:=TOpenAPISchema.Create;
  LResponseContent.Schema.Items.Ref:='#/components/schemas/customer';
  LResponse.Content.Add('application/json',LResponseContent);

  LPath.Get.Responses.Add('200',LResponse);

  LPath.Post.Summary := 'Save Customer';
  LPath.Post.OperationId := 'SaveCustomer';
  LPath.Post.RequestBody:=TOpenAPIRequestBody.Create;
  LRequestBody:=TOpenApiMediaType.Create;
  LRequestBody.Schema.Type_:='object';
  LRequestBody.Schema.Items:=TOpenAPISchema.Create;
  LRequestBody.Schema.Items.Ref:='#/components/schemas/customer';
  LPath.Post.RequestBody.Content.Add('customer',LRequestBody);

  LResponse:=TOpenAPIResponse.Create;
  LResponse.Description:='OK';
  LPath.Post.Responses.Add('200',LResponse);

  FDocument.Paths.Add('/customers', LPath);
end;

initialization
  ReportMemoryLeaksOnShutdown:=True;

end.
