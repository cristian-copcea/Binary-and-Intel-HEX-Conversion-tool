unit editor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, KHexEditor;

type

  { THexEditor }

  THexEditor = class(TForm)
    KHexEditor1: TKHexEditor;
    StatusBar1: TStatusBar;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure KHexEditor1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  HexEditor: THexEditor;

implementation
uses main;
{$R *.lfm}

{ THexEditor }

procedure THexEditor.KHexEditor1Change(Sender: TObject);
begin
 StatusBar1.Panels[0].Text:='Size: '+IntToStr(KHexEditor1.Data.Size)+' bytes';
 if KHexEditor1.Modified then
    StatusBar1.Panels[1].Text:='Modified data'
 else
   StatusBar1.Panels[1].Text:='Original data';
  main.datasize:=KHexEditor1.Data.Size;
end;

procedure THexEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 if HexEditor.KHexEditor1.Modified then
    MessageDlg('Warning','Data was modified using the Hex Editor.'+#13+#10'You might wish to save modified data after exiting the editor.',mtWarning,[mbOK],0);
    main.CopyData:=true;
end;

end.

