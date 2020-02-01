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
{$IFDEF FPC}
  Crt,
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}
  SysUtils, Types, StrUtils,
  ConsoleColor;

type

{$REGION 'documentation'}
{
  @abstract(Callback executed when a tag is founded for custom styles)
  @param(Text String to send to console)
  @param(Tag Tag value founded)
  @param(TextColor Foreground text color to customize)
  @param(BackColor Background text color to customize)
}
{$ENDREGION}

{$IFDEF FPC}
  TOnApplyConsoleTextTagStyle = procedure(const Text: String; var Tag: String;
    var TextColor, BackColor: TConsoleColor);
  TOnApplyConsoleTextTagStyleOfObject = procedure(const Text: String; var Tag: String;
    var TextColor, BackColor: TConsoleColor) of object;
{$ELSE}
  TOnApplyConsoleTextTagStyle = reference to procedure(const Text: String; var Tag: String;
    var TextColor, BackColor: TConsoleColor);
{$ENDIF}

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
    WriteTaggedText Write text in console, parsing tags for colorising tag-text
    @param(Text String for console out)
    @param(StartTag String with starting tag delimiter)
    @param(EndTag String with finishing tag delimiter)
    @param(OnStyle Callback to execute when tag is founded to set custom style)
    @param(OnStyleOfObject Tricky for free pascal debt with anonymous functions)
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
}
{$ENDREGION}

  IConsole = interface
    ['{96C214BB-45BD-4DA8-BF47-7D30EAE8E2B9}']
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteTaggedText(const Text, StartTag, EndTag: String; const OnStyle: TOnApplyConsoleTextTagStyle
{$IFDEF FPC}; const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF} );
    procedure WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
    procedure Clear;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConsole))
  @member(CursorPosition @seealso(IConsole.CursorPosition))
  @member(ChangeCursorPos @seealso(IConsole.ChangeCursorPos))
  @member(ChangeTextColor @seealso(IConsole.ChangeTextColor))
  @member(ChangeBackColor @seealso(IConsole.ChangeBackColor))
  @member(WriteText @seealso(IConsole.WriteText))
  @member(WriteTaggedText @seealso(IConsole.WriteTaggedText))
  @member(WriteStyledText @seealso(IConsole.WriteStyledText))
  @member(Clear @seealso(IConsole.Clear))
  @member(
    FindTag Find tag based in a start position and tag delimiters
    @param(Text String to use when parsing)
    @param(StartTag String with starting tag delimiter)
    @param(EndTag String with finishing tag delimiter)
    @param(Offset Parse start position)
  )
  @member(
    ExtractTags Builds a list of tags
    @param(Text String to use when parsing)
    @param(StartTag String with starting tag delimiter)
    @param(EndTag String with finishing tag delimiter)
    @return(Array of founded tags)
  )
  @member(
    Create Object constructor
  )
  @member(
    New Create a new @classname as interface
  )
}
{$ENDREGION}
{ TConsole }

  TConsole = class sealed(TInterfacedObject, IConsole)
  strict private
  type
    TTextTag = record
      StartPos, EndPos: NativeInt;
      Founded: Boolean;
      Content: String;
    end;

    TTextTagArray = array of TTextTag;
  strict private
{$IFNDEF FPC}
    _OutHandle: THandle;
    _DefaultBufferInfo: TConsoleScreenBufferInfo;
{$ENDIF}
  private
    function FindTag(const Text, StartTag, EndTag: String; const Offset: NativeInt): TTextTag;
    function ExtractTags(const Text, StartTag, EndTag: String): TTextTagArray;
    procedure OpenIfNeed;
  public
    function CursorPosition: TPoint;
    procedure ChangeCursorPos(const X, Y: smallint);
    procedure ChangeTextColor(const Color: TConsoleColor);
    procedure ChangeBackColor(const Color: TConsoleColor);
    procedure WriteText(const Text: string);
    procedure WriteTaggedText(const Text, StartTag, EndTag: String; const OnStyle: TOnApplyConsoleTextTagStyle
{$IFDEF FPC}; const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF});
    procedure WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
    procedure Clear;
    constructor Create;
    class function New: IConsole;
  end;

{$IFNDEF FPC}


function GetConsoleWindow: HWnd; stdcall; external 'kernel32.dll' name 'GetConsoleWindow';
function AttachConsole(ProcessId: DWORD): BOOL; stdcall; external 'kernel32.dll' name 'AttachConsole';
{$ENDIF}

implementation

function TConsole.FindTag(const Text, StartTag, EndTag: String; const Offset: NativeInt): TTextTag;
begin
  Result.StartPos := PosEx(StartTag, Text, Offset);
  Result.EndPos := PosEx(EndTag, Text, Succ(Result.StartPos));
  Result.Founded := (Result.StartPos > 0) and (Result.EndPos > 0);
  if Result.Founded then
    Result.Content := Copy(Text, Result.StartPos + Length(StartTag), Result.EndPos - Result.StartPos - Length(EndTag));
end;

function TConsole.ExtractTags(const Text, StartTag, EndTag: String): TTextTagArray;
var
  TextTag: TTextTag;
  Offset: NativeInt;
begin
  Offset := 1;
  SetLength(Result, 0);
  repeat
    TextTag := FindTag(Text, StartTag, EndTag, Offset);
    if TextTag.Founded then
    begin
      SetLength(Result, Succ(Length(Result)));
      Result[High(Result)] := TextTag;
      Offset := Succ(TextTag.EndPos);
    end;
  until not TextTag.Founded;
end;


{$IFDEF FPC}

function TConsole.CursorPosition: TPoint;
begin
  Result.X := WhereX;
  Result.X := WhereY;
end;

procedure TConsole.ChangeCursorPos(const X, Y: smallint);
begin
  GotoXY(Succ(X), Succ(Y));
end;

procedure TConsole.ChangeTextColor(const Color: TConsoleColor);
begin
  TextColor(byte(Color));
end;

procedure TConsole.ChangeBackColor(const Color: TConsoleColor);
begin
  TextBackground(byte(Color));
end;

procedure TConsole.WriteText(const Text: string);
begin
  Write(stderr, Text);
end;

procedure TConsole.WriteTaggedText(const Text, StartTag, EndTag: String;
  const OnStyle: TOnApplyConsoleTextTagStyle;
  const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject);
var
  TextTag: TTextTag;
  TextColor, BackColor: TConsoleColor;
  LastUnStyledPos: NativeInt;
  Tag: String;
begin
  LastUnStyledPos := 1;
  for TextTag in ExtractTags(Text, StartTag, EndTag) do
  begin
    WriteStyledText(Copy(Text, LastUnStyledPos, TextTag.StartPos + Length(StartTag) - LastUnStyledPos), Null,
      Null);
    LastUnStyledPos := TextTag.EndPos;
    Tag := TextTag.Content;
    TextColor := Null;
    BackColor := Null;
    if Assigned(OnStyle) then
      OnStyle(Text, Tag, TextColor, BackColor)
    else
      OnStyleOfObject(Text, Tag, TextColor, BackColor);
    WriteStyledText(Tag, TextColor, BackColor);
  end;
  WriteStyledText(Copy(Text, LastUnStyledPos), Null, Null);
end;

procedure TConsole.WriteStyledText(const Text: String; const TextColor,
  BackColor: TConsoleColor);
begin
  NormVideo;
  if BackColor <> Null then
    ChangeBackColor(BackColor);
  if TextColor <> Null then
    ChangeTextColor(TextColor);
  WriteText(Text);
end;

procedure TConsole.Clear;
begin
  Clrscr;
end;

procedure TConsole.OpenIfNeed;
begin
{$IFDEF WINDOWS}
  AllocConsole;
{$ENDIF}
  SysInitStdIO;
end;

constructor TConsole.Create;
begin
  OpenIfNeed;
  AssignCrt(stderr);
  Rewrite(stderr);
end;

{$ELSE}


function TConsole.CursorPosition: TPoint;
var
  BufferInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufferInfo);
  Result.X := BufferInfo.dwCursorPosition.X;
  Result.Y := BufferInfo.dwCursorPosition.Y;
end;

procedure TConsole.ChangeCursorPos(const X, Y: smallint);
var
  NewPos: TCoord;
begin
  NewPos.X := X;
  NewPos.Y := Y;
  SetConsoleCursorPosition(_OutHandle, NewPos);
end;

procedure TConsole.WriteStyledText(const Text: String; const TextColor, BackColor: TConsoleColor);
begin
  SetConsoleTextAttribute(_OutHandle, _DefaultBufferInfo.wAttributes);
  if BackColor <> Null then
    ChangeBackColor(BackColor);
  if TextColor <> Null then
    ChangeTextColor(TextColor);
  WriteText(Text);
end;

procedure TConsole.WriteTaggedText(const Text, StartTag, EndTag: String; const OnStyle: TOnApplyConsoleTextTagStyle);
var
  TextTag: TTextTag;
  TextColor, BackColor: TConsoleColor;
  LastUnStyledPos: NativeInt;
  Tag: String;
begin
  LastUnStyledPos := 1;
  for TextTag in ExtractTags(Text, StartTag, EndTag) do
  begin
    WriteStyledText(Copy(Text, LastUnStyledPos, TextTag.StartPos + Length(StartTag) - LastUnStyledPos), Null, Null);
    LastUnStyledPos := TextTag.EndPos;
    Tag := TextTag.Content;
    TextColor := Null;
    BackColor := Null;
    OnStyle(Text, Tag, TextColor, BackColor);
    WriteStyledText(Tag, TextColor, BackColor);
  end;
  WriteStyledText(Copy(Text, LastUnStyledPos), Null, Null);
end;

procedure TConsole.WriteText(const Text: string);
begin
  Write(Text);
end;

procedure TConsole.ChangeBackColor(const Color: TConsoleColor);
var
  BufInfo: TConsoleScreenBufferInfo;
  Attributes: byte;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufInfo);
  Attributes := (BufInfo.wAttributes and $0F) or ((Ord(Color) shl 4) and $F0);
  SetConsoleTextAttribute(_OutHandle, Attributes);
end;

procedure TConsole.ChangeTextColor(const Color: TConsoleColor);
var
  BufInfo: TConsoleScreenBufferInfo;
  Attributes: byte;
begin
  GetConsoleSCreenBufferInfo(_OutHandle, BufInfo);
  Attributes := (BufInfo.wAttributes and $F0) or (byte(Color) and $0F);
  SetConsoleTextAttribute(_OutHandle, Attributes);
end;

procedure TConsole.Clear;
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
end;

procedure TConsole.OpenIfNeed;
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

constructor TConsole.Create;
begin
  OpenIfNeed;
  _OutHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleSCreenBufferInfo(_OutHandle, _DefaultBufferInfo);
end;

{$ENDIF}


class function TConsole.New: IConsole;
begin
  Result := TConsole.Create;
end;

end.
