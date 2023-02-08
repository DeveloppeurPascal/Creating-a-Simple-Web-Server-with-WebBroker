unit WebModuleUnit1;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1RootAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ImagesAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ButtonsAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }

    /// <summary>
    /// Return relative path to DemoSite folder (depending on Windows Delphi default compile folder)
    /// </summary>
    function GetDemoSitePath: string;

    /// <summary>
    /// Write some properties of WebRequest on the console
    /// </summary>
    procedure log(Request: TWebRequest);

    /// <summary>
    /// Filter forbidden characters in filename for security reasons
    /// </summary>
    function FilterFileName(AFileName: string): string;

    procedure AnswerWithFile(AFileName: string; AFileFolder: string;
      Response: TWebResponse; var Handled: Boolean);
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

uses
  System.IOUtils;

procedure TWebModule1.AnswerWithFile(AFileName, AFileFolder: string;
  Response: TWebResponse; var Handled: Boolean);
var
  FileName: string;
  FilePath: string;
  FileExt: string;
begin
  try
    // Check if the filename contains only allowed characters (depending on my choice)
    FileName := FilterFileName(AFileName);

    // No filename ? Ok, returns the default HTML file.
    if FileName.IsEmpty then
      FileName := 'index.html';

    FilePath := tpath.Combine(AFileFolder, FileName);
    if not tfile.Exists(FilePath) then
    begin
      Handled := true;
      Response.ContentType := 'text/plain';
      Response.Content := 'File not found';
      Response.StatusCode := 404;
    end
    else
    begin
      FileExt := tpath.GetExtension(FileName).ToLower;
      // See content-type and MIME depending on file extension at https://en.wikipedia.org/wiki/Media_type
      if (FileExt = '.htm') or (FileExt = '.html') then
      begin
        Response.ContentType := 'text/html';
      end
      else if (FileExt = '.txt') then
      begin
        Response.ContentType := 'text/plain';
      end
      else if (FileExt = '.csv') then
      begin
        Response.ContentType := 'text/csv';
      end
      else if (FileExt = '.json') then
      begin
        Response.ContentType := 'application/json';
      end
      else if (FileExt = '.jpg') or (FileExt = '.jpeg') then
      begin
        Response.ContentType := 'image/jpeg';
      end
      else if (FileExt = '.png') then
      begin
        Response.ContentType := 'image/png';
      end
      else if (FileExt = '.gif') then
      begin
        Response.ContentType := 'image/gif';
      end
      else
      begin
        raise exception.Create('File type not managed by this program.');
      end;
      Handled := true;
      Response.StatusCode := 200;
      Response.ContentStream := tfilestream.Create(FilePath, fmOpenRead);
    end;

  except
    on e: exception do
    begin
      Handled := true;
      Response.ContentType := 'text/plain';
{$IFDEF DEBUG}
      Response.Content := e.Message;
{$ELSE}
      Response.Content := 'Access not allowed';
{$ENDIF}
      // See HTTP status code list at https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
      Response.StatusCode := 403;
    end;
  end;
end;

function TWebModule1.FilterFileName(AFileName: string): string;
var
  i: integer;
  c: char;
begin
  result := '';
  for i := 0 to AFileName.Length - 1 do
  begin
    c := AFileName.Chars[i];
    if CharInSet(c, ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', ',', '.',
      '(', ')', '[', ']', '{', '}', '''', ' ', '·']) then
      result := result + c
    else if CharInSet(c, ['/', '\']) then
      raise exception.Create('Subfolders not allowed.')
    else
      raise exception.Create('Character in filename not allowed.');
  end;
end;

function TWebModule1.GetDemoSitePath: string;
begin
  result := '..\..\..\DemoSite';
end;

procedure TWebModule1.log(Request: TWebRequest);
begin
{$IFDEF DEBUG}
  writeln('url=', Request.URL);
  writeln('host=', Request.Host);
  writeln('scriptname=', Request.scriptname);
  writeln('pathinfo=', Request.pathinfo);
  writeln('query=', Request.Query);
  writeln('queryfields=', Request.QueryFields.Text);
  writeln('----------');
{$ENDIF}
end;

procedure TWebModule1.WebModule1ButtonsAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  log(Request);
  // Response.Content := 'button : ' + Request.pathinfo;
  AnswerWithFile(Request.pathinfo.Substring(Length('/btn/')),
    GetDemoSitePath + '\btn', Response, Handled);
end;

procedure TWebModule1.WebModule1ImagesAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  log(Request);
  // Response.Content := 'image : ' + Request.pathinfo;
  AnswerWithFile(Request.pathinfo.Substring(Length('/img/')),
    GetDemoSitePath + '\img', Response, Handled);
end;

procedure TWebModule1.WebModule1RootAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  log(Request);
  // Response.Content := 'root : ' + Request.pathinfo;
  AnswerWithFile(Request.pathinfo.Substring(Length('/')), GetDemoSitePath,
    Response, Handled);
end;

end.
