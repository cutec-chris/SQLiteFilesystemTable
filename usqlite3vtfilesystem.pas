unit uSqlite3VTFilesystem;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, uSqlite3Helper, sqlite3dyn, usqlite3virtualTable, LCLProc;

type

  { TFSCursor }

  TFSCursor = class(TSQLiteVirtualTableCursor)
  private
    FTab: TSQLite3VTab;
    FSearchRecs : array of TSearchRec;
    FEof: Boolean;
    FPath : string;
    FGoUp : Boolean;
  public
    constructor Create(vTab : TSQLite3VTab);
    destructor Destroy; override;
    function SearchPath(aPath : string) : Boolean;
    function Search(Prepared : TSQLVirtualTablePrepared) : Boolean;
    function Column(Index : Integer;var Res : TSQLVar) : Boolean;
    function Next : Boolean;
    function Eof : Boolean;
  end;

  TFSCursorClass = class of TFSCursor;

  { TFSTable }

  TFSTable = class(TSQLiteVirtualTable)
  public
    function Prepare(Prepared: TSQLVirtualTablePrepared): Boolean; override;
    function GetName: string; override;
    function CursorClass: TSQLiteVirtualTableCursorClass; override;
  end;

implementation

var
  fModule: TSQLite3Module;

{ TFSTable }

function TFSTable.Prepare(Prepared: TSQLVirtualTablePrepared): Boolean;
begin

end;

function TFSTable.GetName: string;
begin
  Result := 'filesystem';
end;

function TFSTable.CursorClass: TSQLiteVirtualTableCursorClass;
begin
  Result := TFSCursor;
end;

{ TFSCursor }

constructor TFSCursor.Create(vTab: TSQLite3VTab);
begin
  FTab := vTab;
  FGoUp:=False;
end;

destructor TFSCursor.Destroy;
begin
  while length(FSearchRecs)>0 do
    begin
      FindClose(FSearchRecs[length(FSearchRecs)-1]);
      SetLength(FSearchRecs,length(FSearchRecs)-1);
    end;
  inherited Destroy;
end;

function TFSCursor.SearchPath(aPath: string): Boolean;
var
  FSr: TRawByteSearchRec;
begin
  FPath:=aPath;
  FEof := FindFirst(StringReplace(FPath,'/',DirectorySeparator,[rfReplaceAll]) +'*', {faAnyFile and }faDirectory,FSr) <> 0;
  setlength(FSearchRecs,length(FSearchRecs)+1);
  FSearchRecs[Length(FSearchRecs)-1] := Fsr;
  if (not FEof) and (FSR.Name='.') then Result := Next;
end;

function TFSCursor.Search(Prepared: TSQLVirtualTablePrepared): Boolean;
begin
  Result := True;
  {$ifdef Windows}
  FPath:='c:';
  {$else}
  FPath:='/';
  {$endif}
  SearchPath(FPath);
end;

function TFSCursor.Column(Index: Integer; var Res: TSQLVar): Boolean;
begin
  Res.VType:=ftNull;
  case Index of
  //-1:Res := Fsr.Time;
  0:begin
      Res.VType:=ftUTF8;
      Res.VText:= PUTF8Char(FSearchRecs[length(FSearchRecs)-1].Name);//name
    end;
  1:begin
      Res.VType:=ftUTF8;
      Res.VText:=PUTF8Char(FPath);//path
    end;
  2:begin
      Res.VType:=ftInt64;
      if FSearchRecs[length(FSearchRecs)-1].Attr and faDirectory = faDirectory then
        Res.VInt64:= 1
      else
        Res.VInt64:= 0; //isdir
    end;
  3:begin
      Res.VType:=ftInt64;
      Res.VInt64 := FSearchRecs[length(FSearchRecs)-1].Size;//size
    end;
  4:begin
      Res.VType:=ftInt64;
      Res.VInt64:=FSearchRecs[length(FSearchRecs)-1].Time; //mtime
    end;
  //ctime
  //atime
  end;
  Result := True;
end;

function TFSCursor.Next: Boolean;
label retry;
begin
  Result := True;
retry:
  if (FSearchRecs[length(FSearchRecs)-1].Attr and faDirectory = faDirectory) and( not ((FSearchRecs[length(FSearchRecs)-1].Name='.') or (FSearchRecs[length(FSearchRecs)-1].Name='..')))  then
    SearchPath(IncludeTrailingBackslash(IncludeTrailingBackslash(FPath)+FSearchRecs[length(FSearchRecs)-1].Name));
  if FEof and (length(FSearchRecs)>0) then
    begin
      if pos('/',FPath)>0 then
        begin
          FPath := copy(FPath,0,LastDelimiter('/',FPath)-1);
          FPath := copy(FPath,0,LastDelimiter('/',FPath));
        end;
      FindClose(FSearchRecs[length(FSearchRecs)-1]);
      SetLength(FSearchRecs,length(FSearchRecs)-1);
      if length(FSearchRecs)=0 then
        begin
          FEof:=True;
          exit;
        end;
      feof := FindNext(FSearchRecs[length(FSearchRecs)-1]) <> 0;
    end
  else
    feof := FindNext(FSearchRecs[length(FSearchRecs)-1]) <> 0;
  if (not FEof) and ((FSearchRecs[length(FSearchRecs)-1].Name='.') or (FSearchRecs[length(FSearchRecs)-1].Name='..')) then goto retry;
  if FEof and (length(FSearchRecs)>0) then
    goto retry;
  if length(FSearchRecs)>0 then
    debugln(IncludeTrailingBackslash(FPath)+FSearchRecs[length(FSearchRecs)-1].Name)
end;

function TFSCursor.Eof: Boolean;
begin
  result := FEof;
end;


const
  Structure = 'create table fs ('+
  'name  text,'+
  'path  text,'+
  'isdir int,'+
  'size  int,'+
  'mtime int,'+
  'ctime int,'+
  'atime int'+
  ')';

end.

