unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, sqlite3conn, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, DBGrids,uSqlite3VTFilesystem;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    aFs: TFSTable;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  aHandle: Pointer;
begin
  SQLite3Connection1.Connected:=True;
  aFs := TFSTable.Create;
  aFS.RegisterToSQLite(SQLite3Connection1.Handle);

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SQLite3Connection1.ExecuteDirect('CREATE VIRTUAL TABLE test USING filesystem');
  SQLQuery1.Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  SQLQuery1.SQL.Text:='select cast(name as varchar(50)),cast(path as varchar),size from test';
  SQLQuery1.Open;
end;

end.

