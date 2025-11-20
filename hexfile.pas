unit hexfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, messages, Dialogs, Forms;

type
  THexFile = class(TComponent)
  private
    { Private declarations }
    FFileName:string;
    FFillByte:byte;
    FDatabits:integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure LoadHEX(var DataArray:array of byte);
    procedure SaveHEX(var DataArray:array of byte);
    procedure LoadBIN(var DataArray:array of byte);
    procedure SaveBIN(var DataArray:array of byte);
  published
    { Published declarations }
    property FileName:string read FFileName write FFileName;
    property FillByte: byte read FFillByte write FFillByte;
    property Databits: integer read FDatabits write FDatabits;
  end;


implementation

resourcestring
EDataBufferZero = 'THexFile.Load: Data Buffer can''t have a zero length';
EBufSizeNotDataLength = 'THexFile.Load: Data buffer has a different size than BufferSize';
EErrorInFile = 'There is an error in the file %s :'#13#10+
               '%s at line %s'#13#10+
               'Data was discarded.';
EInvalidData ='There is an error in the file %s :'#13#10+
               '%s at line %s position %s'#13#10+
               'Data was discarded';
EInvRecMark  = '[Invalid Record Marker]';
EInvRecLen   = '[Invalid Record Length]';
EInvStartAdd = '[Invalid Start Address]';
EInvRecType  = '[Invalid Record Type]';
EInvData     = '[Invalid Data]';
EInvCheckSum = '[Invalid Checksum]';
ECapacityExceeded ='The file is too large. Data was discarded.';
EExtLinAddWrong = 'Invalid field for the Extended Linear Address Record at line %s';
EExtSEGAddWrong = 'Invalid field for the Extended Segment Address Record at line %s';
ETooManySavedBytes = 'Too many bytes to save (%s). Max allowed is 10 Mbytes)';

procedure THexFile.LoadHEX(var DataArray:array of byte);
var
FName,Line,a:string;
FIn:TextFile;
StartAdd,RecLength,RecType,i,j,LineNum,CurAdd:Integer;
Check,CheckSum:Integer;
Offset:integer;
begin
  FName:=FFileName;
  try
          AssignFile(FIn,FName);
          Reset(FIn);
          LineNum:=0;
         for i:=0 to High(DataArray) do DataArray[i]:=FFillByte;
         Offset:=0; //defined by the record type, first zero
          while not eof(FIn) do
          begin
           inc(LineNum);
           Readln(FIn,Line);
           if Line[1]<>':' then
           begin
            for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
            raise Exception.CreateFmt(EErrorInFile,[FName,EInvRecMark,IntToStr(LineNum)]);
            Exit;
           end;
           try
            RecLength:=StrToInt('$'+copy(Line,2,2));
           except
            On EConvertError do
            begin
             for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
             raise Exception.CreateFmt(EErrorInFile,[FName,EInvRecLen,IntToStr(LineNum)]);
             Exit;
            end;
           end;

           try
            StartAdd:=StrToInt('$'+copy(Line,4,4));
           except
            On EConvertError do
            begin
             for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
             raise Exception.CreateFmt(EErrorInFile,[FName,EInvStartAdd,IntToStr(LineNum)]);
             Exit;
            end;
           end;

           try
            RecType:=StrToInt(copy(Line,8,2));     //record type
           except
            On EConvertError do
            begin
             for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
             raise Exception.CreateFmt(EErrorInFile,[FName,EInvRecType,IntToStr(LineNum)]);
             Exit;
            end;
           end;

           if not RecType in [0..2,4] then   //only these record types are allowed
           begin
            for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
            raise Exception.CreateFmt(EErrorInFile,[FName,EInvRecType,IntToStr(LineNum)]);
            Exit;
           end;

           if RecType=0 then //Normal Data
           begin
            for i:=1 to RecLength do
            begin
             CurAdd:=StartAdd+i+Offset-1;
             if CurAdd>High(DataArray) then
             begin
              for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
              raise Exception.CreateFmt(ECapacityExceeded,[FName,IntToStr(High(DataArray))]);
              Exit;
             end;
             try
              DataArray[CurAdd]:=StrToInt('$'+copy(Line,10+(i-1)*2,2));
              except
              on EConvertError do
              begin
               for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
               raise Exception.CreateFmt(EInvalidData,[FName,EInvData,IntToStr(LineNum),IntToStr(10+(i-1)*2)]);
               Exit;
              end;
             end;
            end;
            a:='$'+copy(Line,length(Line)-1,2);
            CheckSum:=StrToInt(a);
            Check:=RecLength;
            for j:=1 to RecLength+3 do
            begin
             a:='$'+copy(Line,2+j*2,2);
             Check:=Check+StrToInt(a);
            end;
            Check:=256-(Check-(Check div 256)*256);
            if Check=256 then Check:=0;
            if Check<>CheckSum then
            begin
             for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
             raise Exception.CreateFmt(EErrorInFile,[FName,EInvCheckSum,IntToStr(LineNum)]);
             Exit;
            end;
           end
           else
           if RecType=2 then //Extended segment address
           begin
              if StartAdd<>0 then
              begin
               for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
               raise Exception.CreateFmt(EExtSEGAddWrong,[LineNum]);
               Exit;
              end;
              try
               Offset:=StrToInt('$'+copy(Line,10,4)+'0');
               except
               on EConvertError do
               begin
                for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
                raise Exception.CreateFmt(EInvalidData,[FName,EInvData,IntToStr(LineNum),IntToStr(10+(i-1)*2)]);
                Exit;
               end;
              end;
              a:='$'+copy(Line,length(Line)-1,2);
              CheckSum:=StrToInt(a);
              Check:=RecLength;
              for j:=1 to RecLength+3 do
              begin
               a:='$'+copy(Line,2+j*2,2);
               Check:=Check+StrToInt(a);
              end;
              Check:=256-(Check-(Check div 256)*256);
              if Check=256 then Check:=0;
              if Check<>CheckSum then
              begin
               for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
               raise Exception.CreateFmt(EErrorInFile,[FName,EInvCheckSum,IntToStr(LineNum)]);
               Exit;
              end;
           end
           else
           if RecType=4 then //Extended linear address
           begin
              if StartAdd<>0 then
              begin
               for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
               raise Exception.CreateFmt(EExtLinAddWrong,[LineNum]);
               Exit;
              end;
              try
               Offset:=StrToInt('$'+copy(Line,10,4)+'0000');
               except
               on EConvertError do
               begin
                for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
                raise Exception.CreateFmt(EInvalidData,[FName,EInvData,IntToStr(LineNum),IntToStr(10+(i-1)*2)]);
                Exit;
               end;
              end;
              a:='$'+copy(Line,length(Line)-1,2);
              CheckSum:=StrToInt(a);
              Check:=RecLength;
              for j:=1 to RecLength+3 do
              begin
               a:='$'+copy(Line,2+j*2,2);
               Check:=Check+StrToInt(a);
              end;
              Check:=256-(Check-(Check div 256)*256);
              if Check=256 then Check:=0;
              if Check<>CheckSum then
              begin
               for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
               raise Exception.CreateFmt(EErrorInFile,[FName,EInvCheckSum,IntToStr(LineNum)]);
               Exit;
              end;
           end
           else
           if RecType=1 then //End Of File
           begin
            a:='$'+copy(Line,length(Line)-1,2);
            CheckSum:=StrToInt(a);
            Check:=RecLength;
            for j:=1 to RecLength+3 do
            begin
             a:='$'+copy(Line,2+j*2,2);
             Check:=Check+StrToInt(a);
            end;
            Check:=256-(Check-(Check div 256)*256);
            if Check=256 then Check:=0;
            if Check<>CheckSum then
            begin
             for j:=0 to High(DataArray) do DataArray[j]:=FFillByte;
             raise Exception.CreateFmt(EErrorInFile,[FName,EInvCheckSum,IntToStr(LineNum)]);
             Exit;
            end;
           end;
          end;
  finally
         CloseFile(FIn);
         FDatabits:=CurAdd;
  end;
end;

procedure THexFile.SaveHEX(var DataArray:array of byte);
var
FName,Line,a:string;
FOut:TextFile;
i,j:Integer;
CheckSum:Integer;
Offset:integer;
kk,lk:integer;
begin
 if Length(DataArray)>StrToInt64('$A00000') then
        Raise Exception.CreateFmt(ETooManySavedBytes,[IntToHex(Length(DataArray),8)]);

  FName:=FFileName;
  try
        AssignFile(FOut,FName);
        Rewrite(FOut);
        Offset:=0;

        for i:=0 to High(DataArray) div 16-1 do
        begin
         //do we need to write an Extended Linear Address Record?
         if ((i div $1000)>0) and
             (Offset<>(i div $1000)) then
         begin
               Offset:=i div $1000;
               Line:=':02000004'+IntToHex(Offset,4);
               CheckSum:=0;
               for j:=1 to 6 do
               begin
                a:='$'+copy(Line,j*2,2);
                CheckSum:=CheckSum+StrToInt(a);
               end;
               CheckSum:=256-(CheckSum-(CheckSum div 256)*256);
               if CheckSum=256 then CheckSum:=0;
               Line:=Line+IntToHex(CheckSum,2);
               Writeln(FOut,Line);
         end;

         Line:=':'+IntToHex(16,2)+IntToHex(i*16-Offset*$10000,4)+'00';
         for j:=0 to 15 do Line:=Line+IntToHex(DataArray[i*16+j],2);
         CheckSum:=16;
         for j:=1 to 19 do
         begin
          a:='$'+copy(Line,2+j*2,2);
          CheckSum:=CheckSum+StrToInt(a);
         end;
         CheckSum:=256-(CheckSum-(CheckSum div 256)*256);
         if CheckSum=256 then CheckSum:=0;
         Line:=Line+IntToHex(CheckSum,2);
         Writeln(FOut,Line);
        end;

        if (i=0) then i:=-1;
        kk:=High(DataArray) div 16*16;
        lk:=High(DataArray) ;
        Line:=':'+IntToHex(lk-kk+1,2)+IntToHex((i+1)*16-Offset*$10000,4)+'00';
        for j:=0 to (lk-kk) do
             Line:=Line+IntToHex(DataArray[kk+j],2);
        CheckSum:=0;
        for j:=0 to lk-kk+4 do
        begin
          a:='$'+copy(Line,2+j*2,2);
          CheckSum:=CheckSum+StrToInt(a);
        end;
        CheckSum:=256-(CheckSum-(CheckSum div 256)*256);
        if CheckSum=256 then CheckSum:=0;
        Line:=Line+IntToHex(CheckSum,2);
        Writeln(FOut,Line);

        Line:=':00000001FF';
        Writeln(FOut,Line);
  finally
          CloseFile(FOut);
  end;
end;

procedure THexFile.SaveBIN(var DataArray:array of byte);
var
FName:string;
FOut:File of byte;
i:Integer;
begin
 if Length(DataArray)>StrToInt64('$A00000') then
        Raise Exception.CreateFmt(ETooManySavedBytes,[IntToHex(Length(DataArray),8)]);

  FName:=FileName;
  try
        AssignFile(FOut,FName);
        Rewrite(FOut);
        for i:=0 to High(DataArray) do
        begin
         Write(FOut,DataArray[i]);
        end;
  finally
          CloseFile(FOut);
  end;
end;

procedure THexFile.LoadBIN(var DataArray:array of byte);
var
FName:string;
FIn:File of byte;
b:byte;
i,Offset:integer;
begin

  FName:=FileName;
  try
        AssignFile(FIn,FName);
        Reset(FIn);
        if FileSize(FIn)>High(DataArray) then
           raise exception.CreateFmt(ECapacityExceeded,[]);
        for i:=0 to High(DataArray) do DataArray[i]:=FillByte;
        Offset:=0;
        while not EOF(FIn) do
        begin
         Read(FIn,b);
         DataArray[Offset]:=b;
         inc(Offset);
         Application.ProcessMessages;
        end;
        FDatabits:=Offset-1;
  finally
          CloseFile(FIn);
  end;
end;



end.

