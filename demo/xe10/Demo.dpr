{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{$ENDREGION}
program Demo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  Classes,
  Console in '..\..\code\Console.pas',
  ConsoleColor in '..\..\code\ConsoleColor.pas';

type
  TTestThread = class sealed(TThread)
  strict private
    _ID: Byte;
    _Console: IConsole;
  protected
    procedure Execute; override;
  public
    constructor Create(const ID: Byte; const Console: IConsole); reintroduce;
  end;

{ TTestThread }

procedure TTestThread.Execute;
var
  Color: TConsoleColor;
begin
  inherited;
  Sleep(100);
  for Color := Low(TConsoleColor) to High(TConsoleColor) do
  begin
    _Console.ChangeTextColor(Color);
    _Console.WriteText(Format('%d >> Colored text', [_ID]) + sLineBreak);
    Sleep(250);
  end;
end;

constructor TTestThread.Create(const ID: Byte; const Console: IConsole);
begin
  inherited Create(True);
  _ID := ID;
  _Console := Console;
  FreeOnTerminate := True;
end;

procedure SimpleDemo;
var
  Color: TConsoleColor;
begin
  with TConsole.New do
  begin
    ChangeBackColor(TConsoleColor.Black);
    Clear;
    ChangeTextColor(White);
    WriteText('[');
    ChangeTextColor(Green);
    WriteText('Status');
    ChangeTextColor(White);
    WriteText(']');
    ChangeCursorPos(10, 1);
    ChangeTextColor(White);
    WriteText('<<');
    ChangeBackColor(TConsoleColor.Yellow);
    ChangeTextColor(LightRed);
    WriteText('Error');
    ChangeBackColor(TConsoleColor.Black);
    ChangeTextColor(White);
    WriteText('>>');

    for Color := Low(TConsoleColor) to High(TConsoleColor) do
    begin
      ChangeTextColor(Color);
      WriteText('Colored text' + sLineBreak);
    end;

    WriteTaggedText('This is a text test of [warning], not [error], styled write text[error].', '[', ']',
      procedure(const Text: String; var Tag: String; var TextColor, BackColor: TConsoleColor)
      begin
        if SameText(Tag, 'warning') then
          TextColor := Yellow
        else
          if SameText(Tag, 'error') then
          begin
            TextColor := White;
            BackColor := Red;
          end;
      end);
  end;
end;

procedure ThreadDemo;
var
  Console: IConsole;
  ThreadArray: array of TTestThread;
  i: Byte;
begin
  Console := TConsole.New;
  SetLength(ThreadArray, 50);
  for i := Low(ThreadArray) to High(ThreadArray) do
    ThreadArray[i] := TTestThread.Create(i, Console);
  for i := Low(ThreadArray) to High(ThreadArray) do
    ThreadArray[i].Start;
end;

begin
  try
    SimpleDemo;
    ThreadDemo;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
