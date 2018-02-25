{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit sqlitefilesystemtable;

{$warn 5023 off : no warning about unused units}
interface

uses
  uSqlite3VTFilesystem, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('sqlitefilesystemtable', @Register);
end.
