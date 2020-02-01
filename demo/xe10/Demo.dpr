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
  Console in '..\..\code\Console.pas',
  ConsoleColor in '..\..\code\ConsoleColor.pas';

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

      WriteTaggedText('This is a text test of [warning], not [error], styled write text[error].',
        '[', ']',
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
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
