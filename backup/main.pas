unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, KHexEditor, hexfile,editor;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LoadHEXBTN: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    LoadOpt: TRadioGroup;
    SaveOpt: TRadioGroup;
    SaveHEXBTN: TButton;
    LoadBinBTN: TButton;
    SaveBinBTN: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Label4DblClick(Sender: TObject);
    procedure LoadHexFile(Sender: TObject);
    procedure LoadBinFile(Sender: TObject);
    procedure SaveHexFile(Sender: TObject);
    procedure SaveBinFile(Sender: TObject);
    procedure LoadHEXBTNClick(Sender: TObject);
    procedure SaveBinBTNClick(Sender: TObject);
    procedure SaveHEXBTNClick(Sender: TObject);
    procedure LoadBinBTNClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    Silent: boolean;
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Myhexfile:THexfile;
  data: array of byte;
  stream: TMemoryStream;
  datasize:integer;
  CopyData:boolean;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.LoadHexFile(Sender: TObject);
begin
   try
    Cursor:=crHourGlass;
    Label4.Cursor:=crHourGlass;
    Myhexfile.FileName:=OpenDialog1.FileName;
    Label4.Caption:=OpenDialog1.FileName;
    SetLength(data,10485761);
    Myhexfile.LoadHEX(data);
    datasize:=Myhexfile.Databits+1;
    Label1.Caption:=IntToStr(datasize);
    SetLength(data,Myhexfile.Databits+1);
    editor.HexEditor.KHexEditor1.Clear;
   finally
    Cursor:=crDefault;
    Label4.Cursor:=crDefault;
    Label5.Cursor:=crDefault;
   end;
end;

procedure TForm1.LoadBinFile(Sender: TObject);
begin
   try
    Cursor:=crHourGlass;
    Label4.Cursor:=crHourGlass;
    Myhexfile.FileName:=OpenDialog1.FileName;
    Label4.Caption:=OpenDialog1.FileName;
    SetLength(data,10485761);
    Myhexfile.LoadBIN(data);
    datasize:=Myhexfile.Databits+1;
    Label1.Caption:=IntToStr(datasize);
    SetLength(data,Myhexfile.Databits+1);
    editor.HexEditor.KHexEditor1.Clear;
   finally
    Cursor:=crDefault;
    Label4.Cursor:=crDefault;
    Label5.Cursor:=crDefault;
   end;
end;
procedure TForm1.SaveHexFile(Sender: TObject);
begin
   try
    Cursor:=crHourGlass;
    Label5.Cursor:=crHourGlass;
    Myhexfile.FileName:=SaveDialog1.FileName;
    Label5.Caption:=SaveDialog1.FileName;
    Myhexfile.SaveHEX(data);
    editor.HexEditor.KHexEditor1.Clear;
   finally
    Cursor:=crDefault;
    Label5.Cursor:=crDefault;
    Label5.Cursor:=crDefault;
   end;
end;
procedure TForm1.SaveBinFile(Sender: TObject);
begin
   try
    Cursor:=crHourGlass;
    Label5.Cursor:=crHourGlass;
    Panel5.Cursor:=crHourGlass;
    Myhexfile.FileName:=SaveDialog1.FileName;
    Label5.Caption:=SaveDialog1.FileName;
    Myhexfile.SaveBIN(data);
    editor.HexEditor.KHexEditor1.Clear;
   finally
    Cursor:=crDefault;
    Label5.Cursor:=crDefault;
    Panel5.Cursor:=crDefault;
   end;

end;


procedure TForm1.LoadHEXBTNClick(Sender: TObject);
begin
  if OpenDialog1.Execute then LoadHexFile(self); LoadOpt.ItemIndex:=0;
end;
procedure TForm1.LoadBinBTNClick(Sender: TObject);
begin
  if OpenDialog1.Execute then LoadBinFile(self); LoadOpt.ItemIndex:=1;
end;
procedure TForm1.SaveHEXBTNClick(Sender: TObject);
begin
  if SaveDialog1.Execute then SaveHexFile(self); SaveOpt.ItemIndex:=0;
end;
procedure TForm1.SaveBinBTNClick(Sender: TObject);
begin
  if SaveDialog1.Execute then SaveBinFile(self); SaveOpt.ItemIndex:=1;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Myhexfile:=THexfile.Create(self);
  Myhexfile.FillByte:=$FF;
  Silent:=false;
  stream:=TmemoryStream.Create;
  CopyData:=false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if OpenDialog1.FileName='' then
      Label1.Caption:=' no file opened'
  else
      Label1.Caption:=IntToStr(length(data))+ ' bytes';
  if CopyData then
  begin
     CopyData:=False;
     //aici copiem in array datele din stream
//     stream.SetSize(length(data));
//     stream.Position:=0;
//     stream.WriteBuffer(data[0],length(data));
//     stream.Position:=0;
     stream.SetSize(editor.HexEditor.KHexEditor1.Data.Size);
     stream.Position:=0;
     editor.HexEditor.KHexEditor1.SaveToStream(stream);
     SetLength(data,editor.HexEditor.KHexEditor1.Data.Size);
     stream.Position:=0;
     stream.ReadBuffer(data[0],length(data));
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Label5.Cursor:=crHourGlass;
 Panel5.Cursor:=crHourGlass;
 try
  if (OpenDialog1.FileName<>'') and (SaveDialog1.FileName<>'') then
  begin
     case LoadOpt.ItemIndex of
          0: begin Label9.Caption:='Status: Loading Hex file'; LoadHexFile(self); end;
          1: begin Label9.Caption:='Status: Loading Hex file'; LoadBinFile(self); end;
     end;
     case SaveOpt.ItemIndex of
          0: begin Label9.Caption:='Status: Saving Hex file'; SaveHexFile(self); end;
          1: begin Label9.Caption:='Status: Saving Hex file'; SaveBinFile(self); end;
     end;
     Label9.Caption:='Status: All operations done.';
  end
  else
      MessageDlg('Error','First load and save files manually, then press the "SilentOp" button to redo the series of operations silently',mtError,[mbOK],0);
 finally
  Label5.Cursor:=crHourGlass;
  Panel5.Cursor:=crHourGlass;
 end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if HexEditor.KHexEditor1.Modified then
  begin
     if MessageDlg('Warning','Data was modified using the Hex Editor.'+#13+#10'You might wish to save modified data first.'+#13+#10'Do you wish to close the application and loose all modifications?',mtWarning,[mbYes, mbNo],0)=mrNo then
        CloseAction:=caNone;
  end
  else
  begin
    Myhexfile.Free;
    stream.Free;
    CloseAction:=caFree;
  end;
end;

procedure TForm1.Label4DblClick(Sender: TObject);
begin
    HexEditor.show;
  if not HexEditor.KHexEditor1.Modified then
  begin
       stream.SetSize(length(data));
       stream.Position:=0;
       stream.WriteBuffer(data[0],length(data));
       stream.Position:=0;
       HexEditor.KHexEditor1.LoadFromStream(stream);
  end;
end;








end.

