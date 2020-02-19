{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console object implemented in Delphi
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}

unit DelphiConsole;

interface

{$IFNDEF FPC}


uses
  Windows, SysUtils,
  ConsoleColor,
  Console;

type

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsole))
  @member(CursorPosition @seealso(IConsole.CursorPosition))
  @member(ChangeCursorPos @seealso(IConsole.ChangeCursorPos))
  @member(ChangeTextColor @seealso(IConsole.ChangeTextColor))
  @member(ChangeBackColor @seealso(IConsole.ChangeBackColor))
  @member(WriteText @seealso(IConsole.WriteText))
  @member(WriteStyledText @seealso(IConsole.WriteStyledText))
  @member(Clear @seealso(IConsole.Clear))
  @member(ResetStyle @seealso(IConsole.ResetStyle))
  @member(
    Create Object constructor
  )
  @member(
    New Create a new @classname as interface
  )
}
{$ENDREGION}
  TDelphiConsole = class sealed(TInterfacedObject, IConsole)
  strict private
    _OutHandle: THandle;
    _DefaultBufferInfo: TConsoleScreenBufferInfo;
  private
    procedure OpenIfNeed;
  public
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
    procedure Clear;
    procedure ResetStyle;
    constructor Create;
    class function New: IConsole;
  end;

function GetConsoleWindow: HWnd; stdcall; external 'kernel32.dll' name 'GetConsoleWindow';
function AttachConsole(ProcessId: DWORD): BOOL; stdcall; external 'kernel32.dll' name 'AttachConsole';

{$ENDIF}

implementation

{$IFNDEF FPC}


function TDelphiConsole.CursorPosition: TPoint;
var
  BufferInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufferInfo);
  Result.X := BufferInfo.dwCursorPosition.X;
  Result.Y := BufferInfo.dwCursorPosition.Y;
end;

procedure TDelphiConsole.ChangeCursorPos(const X, Y: smallint);
var
  NewPos: TCoord;
begin
  NewPos.X := X;
  NewPos.Y := Y;
  SetConsoleCursorPosition(_OutHandle, NewPos);
end;

procedure TDelphiConsole.WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
begin
  ResetStyle;
  if BackColor <> Null then
    ChangeBackColor(BackColor);
  if TextColor <> Null then
    ChangeTextColor(TextColor);
  WriteText(Text);
end;

procedure TDelphiConsole.WriteText(const Text: string);
begin
  Write(Text);
end;

procedure TDelphiConsole.ChangeBackColor(const Color: TConsoleColor);
var
  BufInfo: TConsoleScreenBufferInfo;
  Attributes: byte;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufInfo);
  Attributes := (BufInfo.wAttributes and $0F) or ((Ord(Color) shl 4) and $F0);
  SetConsoleTextAttribute(_OutHandle, Attributes);
end;

procedure TDelphiConsole.ChangeTextColor(const Color: TConsoleColor);
var
  BufInfo: TConsoleScreenBufferInfo;
  Attributes: byte;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufInfo);
  Attributes := (BufInfo.wAttributes and $F0) or (byte(Color) and $0F);
  SetConsoleTextAttribute(_OutHandle, Attributes);
end;

procedure TDelphiConsole.Clear;
var
  coordScreen: TCoord;
  SBI: TConsoleScreenBufferInfo;
  charsWritten: longword;
  ConSize: longword;
begin
  coordScreen.X := 0;
  coordScreen.Y := 0;
  GetConsoleSCreenBufferInfo(_OutHandle, SBI);
  ConSize := SBI.dwSize.X * SBI.dwSize.Y;
  FillConsoleOutputCharacter(_OutHandle, ' ', ConSize, coordScreen, charsWritten);
  FillConsoleOutputAttribute(_OutHandle, SBI.wAttributes, ConSize, coordScreen, charsWritten);
  SetConsoleCursorPosition(_OutHandle, coordScreen);
  ResetStyle;
end;

procedure TDelphiConsole.OpenIfNeed;
  function IsOwnConsoleWindow: Boolean;
  var
    ConsoleHandle: DWORD;
  begin
    GetWindowThreadProcessId(GetConsoleWindow, ConsoleHandle);
    Result := (ConsoleHandle = GetCurrentProcessId);
  end;

const
  ATTACH_PARENT_PROCESS = DWORD(-1);
begin
  if not IsOwnConsoleWindow then
    if not AttachConsole(ATTACH_PARENT_PROCESS) then
      AllocConsole;
end;

procedure TDelphiConsole.ResetStyle;
begin
  SetConsoleTextAttribute(_OutHandle, _DefaultBufferInfo.wAttributes);
end;

constructor TDelphiConsole.Create;
begin
  OpenIfNeed;
  _OutHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleSCreenBufferInfo(_OutHandle, _DefaultBufferInfo);
end;

class function TDelphiConsole.New: IConsole;
begin
  Result := TDelphiConsole.Create;
end;

{$ENDIF}

end.
