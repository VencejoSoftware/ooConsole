{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console object implemented in freepascal
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FpcConsole;

{$apptype console}

interface

{$IFDEF FPC}

uses
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
  SysUtils, Types,
  Crt,
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

  { TFPCConsole }

  TFPCConsole = class sealed(TInterfacedObject, IConsole)
  private
    procedure OpenIfNeed;
  public
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteStyledText(const Text: string;
      const TextColor, BackColor: TConsoleColor);
    procedure Clear;
    procedure ResetStyle;
    constructor Create;
    class function New: IConsole;
  end;

{$IFDEF WINDOWS}
function AttachConsole(ProcessId: DWORD): BOOL; stdcall;
  external 'kernel32.dll' Name 'AttachConsole';
{$ENDIF}
{$ENDIF}

implementation

{$IFDEF FPC}


function TFPCConsole.CursorPosition: TPoint;
begin
  Result.X := WhereX;
  Result.X := WhereY;
end;

procedure TFPCConsole.ChangeCursorPos(const X, Y: smallint);
begin
  GotoXY(Succ(X), Succ(Y));
end;

procedure TFPCConsole.ChangeTextColor(const Color: TConsoleColor);
begin
  TextColor(byte(Color));
end;

procedure TFPCConsole.ChangeBackColor(const Color: TConsoleColor);
begin
  TextBackground(byte(Color));
end;

procedure TFPCConsole.WriteText(const Text: string);
begin
  Write(stderr, Text);
end;

procedure TFPCConsole.WriteStyledText(const Text: string;
  const TextColor, BackColor: TConsoleColor);
begin
  NormVideo;
  if BackColor <> Null then
    ChangeBackColor(BackColor);
  if TextColor <> Null then
    ChangeTextColor(TextColor);
  WriteText(Text);
end;

procedure TFPCConsole.ResetStyle;
begin
  AssignCrt(stderr);
  Rewrite(stderr);
end;

procedure TFPCConsole.Clear;
begin
  ResetStyle;
  Clrscr;
end;

procedure TFPCConsole.OpenIfNeed;
begin
{$IFDEF WINDOWS}
  AllocConsole;
{$ENDIF}
  SysInitStdIO;
end;

constructor TFPCConsole.Create;
begin
  OpenIfNeed;
  ResetStyle;
end;

class function TFPCConsole.New: IConsole;
begin
  Result := TFPCConsole.Create;
end;

{$ENDIF}

end.
