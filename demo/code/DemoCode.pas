unit DemoCode;

interface

uses
  Classes, SysUtils,
  Console, StackedConsole,
  ConsoleWriteTagCommand,
  ConsoleColor;

procedure ThreadDemo;
procedure SimpleDemo;

implementation

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

procedure OnTagStyle(const Text: string; var TagValue: string;
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

procedure ThreadDemo;
var
  Console: IStackedConsole;
  ThreadArray: array of TTestThread;
  i: Byte;
begin
  Console := TStackedConsole.New;
  SetLength(ThreadArray, 50);
  for i := Low(ThreadArray) to High(ThreadArray) do
    ThreadArray[i] := TTestThread.Create(i, Console);
  for i := Low(ThreadArray) to High(ThreadArray) do
    ThreadArray[i].Start;
  Console.WriteStyledText('Press any key to finish!', LightRed, Null);
  Console.RunCommand(
    TWriteTagCommand.New(
    'This is a text test of [warning], not [error], styled write text[error].', '[', ']',
{$IFDEF FPC}
    OnTagStyle, nil
{$ELSE}
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
    end
{$ENDIF}));
end;

procedure SimpleDemo;
var
  Console: IConsole;
  Color: TConsoleColor;
begin
  Console := TConsole.New;
  Console.ChangeBackColor(TConsoleColor.Black);
  Console.Clear;
  Console.ChangeTextColor(White);
  Console.WriteText('[');
  Console.ChangeTextColor(Green);
  Console.WriteText('Status');
  Console.ChangeTextColor(White);
  Console.WriteText(']');
  Console.ChangeCursorPos(10, 1);
  Console.ChangeTextColor(White);
  Console.WriteText('<<');
  Console.ChangeBackColor(TConsoleColor.Yellow);
  Console.ChangeTextColor(LightRed);
  Console.WriteText('Error');
  Console.ChangeBackColor(TConsoleColor.Black);
  Console.ChangeTextColor(White);
  Console.WriteText('>>');
  for Color := Low(TConsoleColor) to High(TConsoleColor) do
  begin
    Console.ChangeTextColor(Color);
    Console.WriteText('Colored text' + sLineBreak);
  end;
  TWriteTagCommand.New(
    'This is a text test of [warning], not [error], styled write text[error].', '[', ']',
{$IFDEF FPC}
    OnTagStyle, nil
{$ELSE}
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
    end
{$ENDIF}).Execute(Console);
end;

end.
