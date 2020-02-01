program Demo;

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  CustApp,
  Console,
  ConsoleCOlor;

type

  TDemo = class(TCustomApplication)
  private
    procedure OnTagStyle(const Text: string; var TagValue: string;
      var TextColor, BackColor: TConsoleColor);
  protected
    procedure DoRun; override;
  end;

  procedure TDemo.OnTagStyle(const Text: string; var TagValue: string;
  var TextColor, BackColor: TConsoleColor);
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

  procedure TDemo.DoRun;
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

      WriteTaggedText(
        'This is a text test of [warning], not [error], styled write text[error].' + sLineBreak,
        '[', ']', nil, @OnTagStyle);
    end;
    WriteLn('Press any key to end');
    ReadLn;
    Terminate;
  end;

var
  Application: TDemo;

{$R *.res}

begin
  Application := TDemo.Create(nil);
  Application.Run;
  Application.Free;
end.
