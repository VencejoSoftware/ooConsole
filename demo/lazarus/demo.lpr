{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{$ENDREGION}
program Demo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Console in '..\..\code\Console.pas',
  ConsoleColor in '..\..\code\ConsoleColor.pas';

procedure OnTagStyle(const Text: string; var TagValue: string;
var
  TextColor, BackColor: TConsoleColor);
begin
  if SameText(TagValue, 'warning') then
    TextColor := Yellow
  else
  if SameText(TagValue, 'error') then
  begin
    BackColor := Red;
    TextColor := White;
  end;
end;

var
  Color: TConsoleColor;

begin
  try
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

      WriteTaggedText('This is a text test of [warning], not [error], styled write text[error].' + sLineBreak,
        '[', ']', @OnTagStyle, nil);
    end;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
