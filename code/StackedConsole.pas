unit StackedConsole;

interface

uses
  Classes, Types,
  SyncObjs,
  Console,
  ConsoleColor,
  ConsoleCommand;

type
  TRunCommandThread = class sealed(TThread)
  strict private
    _OnEvent: TThreadMethod;
  protected
    procedure Execute; override;
  public
    constructor Create(const OnEvent: TThreadMethod); reintroduce;
  end;

  IStackedConsole = interface(IConsole)
    ['{1E49B715-A9A9-4126-B15F-82CE1F2173A5}']
    procedure RunCommand(const Command: IConsoleCommand);
  end;

  TStackedConsole = class sealed(TInterfacedObject, IStackedConsole)
  strict private
    _Stack: IConsoleCommandStack;
    _Console: IConsole;
    _CriticalSection: SyncObjs.TCriticalSection;
    _RunThread: TRunCommandThread;
    _WaitToFinish: Boolean;
  private
    procedure RunNextCommand;
  public
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
    procedure Clear;
    procedure ResetStyle;
    procedure RunCommand(const Command: IConsoleCommand);
    constructor Create(const WaitToFinish: Boolean);
    destructor Destroy; override;
    class function New(const WaitToFinish: Boolean = True): IStackedConsole;
  end;

implementation

{ TRunCommandThread }

procedure TRunCommandThread.Execute;
begin
  inherited;
  while not Terminated do
    _OnEvent;
end;

constructor TRunCommandThread.Create(const OnEvent: TThreadMethod);
begin
  inherited Create(True);
  _OnEvent := OnEvent;
  FreeOnTerminate := True;
end;

{ TStackedConsole }

function TStackedConsole.CursorPosition: TPoint;
begin
  _CriticalSection.Enter;
  try
    Result := _Console.CursorPosition;
  finally
    _CriticalSection.Leave;
  end;
end;

procedure TStackedConsole.ChangeCursorPos(const X, Y: smallint);
begin
  RunCommand(TChangeCursorPosCommand.New(X, Y));
end;

procedure TStackedConsole.ChangeTextColor(const Color: TConsoleColor);
begin
  RunCommand(TChangeTextColorCommand.New(Color));
end;

procedure TStackedConsole.ChangeBackColor(const Color: TConsoleColor);
begin
  RunCommand(TChangeBackColorCommand.New(Color));
end;

procedure TStackedConsole.WriteText(const Text: string);
begin
  RunCommand(TWriteTextCommand.New(Text));
end;

procedure TStackedConsole.WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
begin
  RunCommand(TWriteStyledTextCommand.New(Text, TextColor, BackColor));
end;

procedure TStackedConsole.Clear;
begin
  RunCommand(TClearCommand.New);
end;

procedure TStackedConsole.ResetStyle;
begin
  _CriticalSection.Enter;
  try
    _Console.ResetStyle;
  finally
    _CriticalSection.Leave;
  end;
end;

procedure TStackedConsole.RunNextCommand;
var
  Command: IConsoleCommand;
begin
  Command := _Stack.Pop;
  if Assigned(Command) then
  begin
    _CriticalSection.Enter;
    try
      Command.Execute(_Console);
    finally
      _CriticalSection.Leave;
    end;
  end;
end;

procedure TStackedConsole.RunCommand(const Command: IConsoleCommand);
begin
  _Stack.Push(Command);
end;

constructor TStackedConsole.Create(const WaitToFinish: Boolean);
begin
  _WaitToFinish := WaitToFinish;
  _CriticalSection := SyncObjs.TCriticalSection.Create;
  _Console := TConsole.New;
  _Stack := TConsoleCommandStack.New;
  _RunThread := TRunCommandThread.Create(RunNextCommand);
  _RunThread.Start;
end;

destructor TStackedConsole.Destroy;
begin
  if _WaitToFinish then
    while not _Stack.IsEmpty do
        ;
  _RunThread.Terminate;
  while not _RunThread.Terminated do
      ;
  _CriticalSection.Enter;
  _CriticalSection.Leave;
  _CriticalSection.Free;
  inherited;
end;

class function TStackedConsole.New(const WaitToFinish: Boolean): IStackedConsole;
begin
  Result := TStackedConsole.Create(WaitToFinish);
end;

end.
