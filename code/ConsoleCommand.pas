{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console command object
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConsoleCommand;

interface

uses
  Generics.Collections,
  Console,
  ConsoleColor;

type
{$REGION 'documentation'}
{
  @abstract(Console command object)
  Object to store a console/terminal action to execute
  @member(
    Execute Runs the console/terminal command action
    @param(Console @link(IConsole Console device handler))
  )
}
{$ENDREGION}
  IConsoleCommand = interface
    ['{CB91ED94-B332-4162-B22A-CD9820FB953E}']
    procedure Execute(const Console: IConsole);
  end;

{$REGION 'documentation'}
{
  @abstract(Console command stack object)
  Simple stack object to store commands sequencially
  @member(
    Push Add a new command to the list
    @param(Command @link(IConsoleCommand Command to store))
  )
  @member(
    Pop Get the next command to execute and delete from the list
    @return(@link(IConsoleCommand Next command in lists))
  )
  @member(
    IsEmpty Checks if the stack count > 0
    @return(@true if stack is empty, @false if not)
  )
}
{$ENDREGION}

  IConsoleCommandStack = interface
    ['{3CF47CB2-9A97-4A48-809F-92487C548707}']
    procedure Push(const Command: IConsoleCommand);
    function Pop: IConsoleCommand;
    function IsEmpty: Boolean;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommandStack))
  @member(Push @seealso(IConsoleCommandStack.Push))
  @member(Pop @seealso(IConsoleCommandStack.Pop))
  @member(IsEmpty @seealso(IConsoleCommandStack.IsEmpty))
  @member(Create Object constructor)
  @member(Destroy Object destructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TConsoleCommandStack = class sealed(TInterfacedObject, IConsoleCommandStack)
  strict private
    _List: TThreadList<IConsoleCommand>;
  public
    procedure Push(const Command: IConsoleCommand);
    function Pop: IConsoleCommand;
    function IsEmpty: Boolean;
    constructor Create;
    destructor Destroy; override;
    class function New: IConsoleCommandStack;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to clear screen and restore default style
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TClearCommand = class sealed(TInterfacedObject, IConsoleCommand)
  public
    procedure Execute(const Console: IConsole);
    class function New: IConsoleCommand;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to change the current text/foreground color
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(
    Create Object constructor
    @param(Color @link(TConsoleColor Color to use))
  )
  @member(
    New Create a new @classname as interface
    @param(Color @link(TConsoleColor Color to use))
  )
}
{$ENDREGION}

  TChangeTextColorCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
    _Color: TConsoleColor;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const Color: TConsoleColor);
    class function New(const Color: TConsoleColor): IConsoleCommand;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to change the current background color
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(
    Create Object constructor
    @param(Color @link(TConsoleColor Color to use))
  )
  @member(
    New Create a new @classname as interface
    @param(Color @link(TConsoleColor Color to use))
  )
}
{$ENDREGION}

  TChangeBackColorCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
    _Color: TConsoleColor;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const Color: TConsoleColor);
    class function New(const Color: TConsoleColor): IConsoleCommand;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to change the current cursor position
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(
    Create Object constructor
    @param(X X axis position)
    @param(Y Y axis position)
  )
  @member(
    New Create a new @classname as interface
    @param(X X axis position)
    @param(Y Y axis position)
  )
}
{$ENDREGION}

  TChangeCursorPosCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
    _X, _Y: SmallInt;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const X, Y: SmallInt);
    class function New(const X, Y: SmallInt): IConsoleCommand;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to write text to console/terminal
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(
    Create Object constructor
    @param(Text String to write)
  )
  @member(
    New Create a new @classname as interface
    @param(Text String to write)
  )
}
{$ENDREGION}

  TWriteTextCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
    _Text: String;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const Text: String);
    class function New(const Text: String): IConsoleCommand;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsoleCommand))
  Command to write text to console/terminal with a specific style
  @member(Execute @seealso(IConsoleCommand.Execute))
  @member(
    Create Object constructor
    @param(Text String to write)
    @param(TextColor @link(TConsoleColor text color to use))
    @param(BackColor @link(TConsoleColor Background color to use))
  )
  @member(
    New Create a new @classname as interface
    @param(Text String to write)
    @param(TextColor @link(TConsoleColor text color to use))
    @param(BackColor @link(TConsoleColor Background color to use))
  )
}
{$ENDREGION}

  TWriteStyledTextCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
    _Text: String;
    _TextColor, _BackColor: TConsoleColor;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const Text: String; const TextColor, BackColor: TConsoleColor);
    class function New(const Text: String; const TextColor, BackColor: TConsoleColor): IConsoleCommand;
  end;

implementation

{ TClearCommand }

procedure TClearCommand.Execute(const Console: IConsole);
begin
  Console.Clear;
end;

class function TClearCommand.New: IConsoleCommand;
begin
  Result := TClearCommand.Create;
end;

{ TChangeTextColorCommand }

procedure TChangeTextColorCommand.Execute(const Console: IConsole);
begin
  Console.ChangeTextColor(_Color);
end;

constructor TChangeTextColorCommand.Create(const Color: TConsoleColor);
begin
  _Color := Color;
end;

class function TChangeTextColorCommand.New(const Color: TConsoleColor): IConsoleCommand;
begin
  Result := TChangeTextColorCommand.Create(Color);
end;

{ TChangeBackColorCommand }

procedure TChangeBackColorCommand.Execute(const Console: IConsole);
begin
  Console.ChangeBackColor(_Color);
end;

constructor TChangeBackColorCommand.Create(const Color: TConsoleColor);
begin
  _Color := Color;
end;

class function TChangeBackColorCommand.New(const Color: TConsoleColor): IConsoleCommand;
begin
  Result := TChangeBackColorCommand.Create(Color);
end;

{ TChangeCursorPosCommand }

procedure TChangeCursorPosCommand.Execute(const Console: IConsole);
begin
  Console.ChangeCursorPos(_X, _Y);
end;

constructor TChangeCursorPosCommand.Create(const X, Y: SmallInt);
begin
  _X := X;
  _Y := Y;
end;

class function TChangeCursorPosCommand.New(const X, Y: SmallInt): IConsoleCommand;
begin
  Result := TChangeCursorPosCommand.Create(X, Y);
end;

{ TWriteTextCommand }

procedure TWriteTextCommand.Execute(const Console: IConsole);
begin
  Console.WriteText(_Text);
end;

constructor TWriteTextCommand.Create(const Text: String);
begin
  _Text := Text;
end;

class function TWriteTextCommand.New(const Text: String): IConsoleCommand;
begin
  Result := TWriteTextCommand.Create(Text);
end;

{ TWriteStyledTextCommand }

procedure TWriteStyledTextCommand.Execute(const Console: IConsole);
begin
  Console.ResetStyle;
  if _BackColor <> Null then
    Console.ChangeBackColor(_BackColor);
  if _TextColor <> Null then
    Console.ChangeTextColor(_TextColor);
  Console.WriteText(_Text);
end;

constructor TWriteStyledTextCommand.Create(const Text: String; const TextColor, BackColor: TConsoleColor);
begin
  _Text := Text;
  _TextColor := TextColor;
  _BackColor := BackColor;
end;

class function TWriteStyledTextCommand.New(const Text: String; const TextColor, BackColor: TConsoleColor)
  : IConsoleCommand;
begin
  Result := TWriteStyledTextCommand.Create(Text, TextColor, BackColor);
end;

{ TConsoleCommandStack }

procedure TConsoleCommandStack.Push(const Command: IConsoleCommand);
var
  List: TList<IConsoleCommand>;
begin
  List := _List.LockList;
  try
    List.Add(Command);
  finally
    _List.UnlockList;
  end;
end;

function TConsoleCommandStack.Pop: IConsoleCommand;
var
  List: TList<IConsoleCommand>;
begin
  Result := nil;
  List := _List.LockList;
  try
    if List.Count > 0 then
    begin
      Result := List.First;
      List.Delete(0);
    end;
  finally
    _List.UnlockList;
  end;
end;

function TConsoleCommandStack.IsEmpty: Boolean;
var
  List: TList<IConsoleCommand>;
begin
  List := _List.LockList;
  try
    Result := List.Count < 1;
  finally
    _List.UnlockList;
  end;
end;

constructor TConsoleCommandStack.Create;
begin
  _List := TThreadList<IConsoleCommand>.Create;
end;

destructor TConsoleCommandStack.Destroy;
begin
  _List.Free;
  inherited;
end;

class function TConsoleCommandStack.New: IConsoleCommandStack;
begin
  Result := TConsoleCommandStack.Create;
end;

end.
