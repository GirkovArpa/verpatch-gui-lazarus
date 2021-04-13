unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, Controls, Dialogs, Menus, StdCtrls,
  LCLType, FileInfo, WinPeImageReader, Process, StrUtils, Unit2, UITypes;

const
  BUF_SIZE = 2048; // Buffer size for reading the output in chunks


type

  { TForm1 }

  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItemFile: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemUsage: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure MenuItemFileClick(Sender: TObject);
    procedure MenuItemUsageClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemOpenClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItemFileClick(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  pic: TPicture;
begin
  pic := TPicture.Create;

  pic.LoadFromResourceName(HINSTANCE, 'LAZ_OPEN');
  MenuItemOpen.bitmap.assign(pic.bitmap);
  pic.LoadFromResourceName(HINSTANCE, 'LAZ_SAVE');
  MenuItemSave.bitmap.assign(pic.bitmap);
  pic.LoadFromResourceName(HINSTANCE, 'BTN_HELP');
  MenuItemUsage.bitmap.assign(pic.bitmap);
  pic.LoadFromResourceName(HINSTANCE, 'BTN_INFO');
  MenuItemAbout.bitmap.assign(pic.bitmap);

  pic.Free;
end;

procedure TForm1.MenuItemUsageClick(Sender: TObject);
var
  message: PChar;
begin
  message := 'Verpatch.exe must be in this folder, or in your PATH environment variable.';
  Application.MessageBox(message, 'Usage', MB_ICONQUESTION);
end;

procedure TForm1.MenuItemAboutClick(Sender: TObject);
var
  message: string;
  FileVersionInfo: TFileVersionInfo;
  Version: String;
begin
  FileVersionInfo := TFileVersionInfo.Create(nil);
  FileVersionInfo.ReadFileInfo;
  Version := FileVersionInfo.VersionStrings.Values['FileVersion'];
  message := 'Verpatch GUI Lazarus v' + Version + ' © 2021 GirkovArpa';
  Application.MessageBox(PChar(message), 'About', MB_ICONINFORMATION);
  FileVersionInfo.Free;
end;

procedure TForm1.MenuItemOpenClick(Sender: TObject);
var
   FileVersionInfo: TFileVersionInfo;
   VS: TStrings;
begin
  if OpenDialog1.Execute then
    begin
      if fileExists(OpenDialog1.Filename) then
        begin
             Edit1.text := OpenDialog1.filename;
             FileVersionInfo := TFileVersionInfo.Create(nil);
             FileVersionInfo.FileName := OpenDialog1.filename;
             FileVersionInfo.ReadFileInfo;
             VS := FileVersionInfo.VersionStrings;
             Edit2.text := VS.Values['FileDescription'];
             Edit3.text := VS.Values['FileVersion'];
             Edit4.text := VS.Values['ProductName'];
             Edit5.text := VS.Values['ProductVersion'];
             Edit6.text := VS.Values['LegalCopyright'];
             Edit7.text := VS.Values['PrivateBuild'];
             Edit8.text := VS.Values['CompanyName'];
             Edit9.text := VS.Values['OriginalFilename'];
             FileVersionInfo.Free;
        end;
    end
end;

procedure TForm1.MenuItemSaveClick(Sender: TObject);
var
   process: Tprocess;
   OutputStream : TStream;
   BytesRead    : longint;
   Buffer       : array[1..BUF_SIZE] of byte;
begin
  if SaveDialog1.Execute then
    begin
      process  := TProcess.Create(nil);
      process.Options     := [poUsePipes, poStderrToOutPut];
      process.Executable  := 'verpatch.exe';
      process.parameters.add('/va');
      process.parameters.add(SaveDialog1.Filename);
      process.parameters.add(PadRight(Edit3.text, 1));
      process.parameters.add('/s');
      process.parameters.add('OriginalFilename');
      process.parameters.add(PadRight(Edit9.text, 1));
      process.parameters.add('/s');
      process.parameters.add('desc');
      process.parameters.add(PadRight(Edit2.text, 1));
      process.parameters.add('/s');
      process.parameters.add('pb');
      process.parameters.add(PadRight(Edit7.text, 1));
      process.parameters.add('/s');
      process.parameters.add('company');
      process.parameters.add(PadRight(Edit8.text, 1));
      process.parameters.add('/s');
      process.parameters.add('(c)');
      process.parameters.add(PadRight(Edit6.text, 1));
      process.parameters.add('/s');
      process.parameters.add('product');
      process.parameters.add(PadRight(Edit4.text, 1));
      process.parameters.add('/pv');
      process.parameters.add(PadRight(Edit5.text, 1));
      process.execute;

      OutputStream := TMemoryStream.Create;

      repeat
        BytesRead := process.Output.Read(Buffer, BUF_SIZE);
        OutputStream.Write(Buffer, BytesRead)
      until BytesRead = 0;

      process.Free;
    end;

  with TStringList.Create do
  begin
    OutputStream.Position := 0;
    LoadFromStream(OutputStream);
    if (Length(Text) > 0) then
      begin
      Application.MessageBox(PChar(Text), 'Error', MB_ICONERROR);
      end
    else
    begin
        Application.MessageBox('Save complete!', 'Success!', MB_OK);
    end;
    Free
  end;

  OutputStream.Free;
end;

end.

