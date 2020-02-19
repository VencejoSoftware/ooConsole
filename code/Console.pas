{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console object
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit Console;

interface

uses
  Types,
  ConsoleColor;

type
{$REGION 'documentation'}
{
  @abstract(Console object)
  Object to access to console/terminal properties
  @member(
    CursorPosition Gets the current cursor position
    @return(TPoint with position)
  )
  @member(
    ChangeCursorPos Sets the current cursor position
    @param(X X position)
    @param(Y Y position)
  )
  @member(
    ChangeTextColor Change current text foreground color
    @param(Color Console color)
  )
  @member(
    ChangeBackColor Change current background color
    @param(Color Console color)
  )
  @member(
    WriteText Write text in console
    @param(Text String for console out)
  )
  @member(
    WriteStyledText Write text with custom style
    @param(Text String for console out)
    @param(TextColor Text foreground color)
    @param(BackColor Console back color)
  )
  @member(
    Clear Cleans the console/terminal screen and restore default style
  )
  @member(
    ResetStyle Restore default console/terminal style
  )
}
{$ENDREGION}
  IConsole = interface
    ['{96C214BB-45BD-4DA8-BF47-7D30EAE8E2B9}']
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
    procedure Clear;
    procedure ResetStyle;
  end;

  TConsole = class sealed(TInterfacedObject, IConsole)
  strict private
    _Console: IConsole;
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

implementation

uses
{$IFDEF FPC}
  FpcConsole
{$ELSE}
  DelphiConsole
{$ENDIF};

function TConsole.CursorPosition: TPoint;
begin
  Result := _Console.CursorPosition;
end;

procedure TConsole.ChangeCursorPos(const X, Y: smallint);
begin
  _Console.ChangeCursorPos(X, Y);
end;

procedure TConsole.ChangeTextColor(const Color: TConsoleColor);
begin
  _Console.ChangeTextColor(Color);
end;

procedure TConsole.ChangeBackColor(const Color: TConsoleColor);
begin
  _Console.ChangeBackColor(Color);
end;

procedure TConsole.WriteText(const Text: string);
begin
  _Console.WriteText(Text);
end;

procedure TConsole.WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
begin
  _Console.WriteStyledText(Text, TextColor, BackColor);
end;

procedure TConsole.Clear;
begin
  _Console.Clear;
end;

procedure TConsole.ResetStyle;
begin
  _Console.ResetStyle;
end;

constructor TConsole.Create;
begin
{$IFDEF FPC}
  _Console := TFPCConsole.New;
{$ELSE}
  _Console := TDelphiConsole.New;
{$ENDIF}
end;

class function TConsole.New: IConsole;
begin
  Result := TConsole.Create;
end;

end.
