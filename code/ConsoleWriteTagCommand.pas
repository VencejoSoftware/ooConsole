{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console write tag command object
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConsoleWriteTagCommand;

interface

uses
  SysUtils, StrUtils,
  Console,
  ConsoleColor,
  ConsoleCommand;

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
  @abstract(Implementation of @link(IConsoleCommand))
  Command to change the current text/foreground color
  @member(Execute @seealso(IConsoleCommand.Execute))
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
    @param(Text String for console out)
    @param(StartTag String with starting tag delimiter)
    @param(EndTag String with finishing tag delimiter)
    @param(OnStyle Callback to execute when tag is founded to set custom style)
    @param(OnStyleOfObject Tricky for free pascal debt with anonymous functions)  )
  @member(
    New Create a new @classname as interface
    @param(Text String for console out)
    @param(StartTag String with starting tag delimiter)
    @param(EndTag String with finishing tag delimiter)
    @param(OnStyle Callback to execute when tag is founded to set custom style)
    @param(OnStyleOfObject Tricky for free pascal debt with anonymous functions)  )
}
{$ENDREGION}

  TWriteTagCommand = class sealed(TInterfacedObject, IConsoleCommand)
  strict private
  type
    TTextTag = record
      StartPos, EndPos: NativeInt;
      Founded: Boolean;
      Content: String;
    end;

    TTextTagArray = array of TTextTag;
  strict private
    _Text, _StartTag, _EndTag: String;
    _OnStyle: TOnApplyConsoleTextTagStyle;
{$IFDEF FPC}
    _OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject;
{$ENDIF}
  private
    function ExtractTags(const Text, StartTag, EndTag: String): TTextTagArray;
    function FindTag(const Text, StartTag, EndTag: String; const Offset: NativeInt): TTextTag;
  public
    procedure Execute(const Console: IConsole);
    constructor Create(const Text, StartTag, EndTag: String;
      const OnStyle: TOnApplyConsoleTextTagStyle
{$IFDEF FPC}; const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF} );
    class function New(const Text, StartTag, EndTag: String;
      const OnStyle: TOnApplyConsoleTextTagStyle
{$IFDEF FPC}; const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF} ): IConsoleCommand;
  end;

implementation

function TWriteTagCommand.FindTag(const Text, StartTag, EndTag: String; const Offset: NativeInt): TTextTag;
begin
  Result.StartPos := PosEx(StartTag, Text, Offset);
  Result.EndPos := PosEx(EndTag, Text, Succ(Result.StartPos));
  Result.Founded := (Result.StartPos > 0) and (Result.EndPos > 0);
  if Result.Founded then
    Result.Content := Copy(Text, Result.StartPos + Length(StartTag), Result.EndPos - Result.StartPos - Length(EndTag));
end;

function TWriteTagCommand.ExtractTags(const Text, StartTag, EndTag: String): TTextTagArray;
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

procedure TWriteTagCommand.Execute(const Console: IConsole);
var
  TextTag: TTextTag;
  TextColor, BackColor: TConsoleColor;
  LastUnStyledPos: NativeInt;
  Tag: String;
begin
  LastUnStyledPos := 1;
  for TextTag in ExtractTags(_Text, _StartTag, _EndTag) do
  begin
    Console.WriteStyledText(Copy(_Text, LastUnStyledPos, TextTag.StartPos + Length(_StartTag) - LastUnStyledPos),
      Null, Null);
    LastUnStyledPos := TextTag.EndPos;
    Tag := TextTag.Content;
    TextColor := Null;
    BackColor := Null;
    if Assigned(_OnStyle) then
      _OnStyle(_Text, Tag, TextColor, BackColor)
{$IFDEF FPC}
    else
      _OnStyleOfObject(_Text, Tag, TextColor, BackColor)
{$ENDIF};
    Console.WriteStyledText(Tag, TextColor, BackColor);
  end;
  Console.WriteStyledText(Copy(_Text, LastUnStyledPos), Null, Null);
end;

constructor TWriteTagCommand.Create(const Text, StartTag, EndTag: String;
  const OnStyle: TOnApplyConsoleTextTagStyle{$IFDEF FPC};
  const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF});
begin
  _Text := Text;
  _StartTag := StartTag;
  _EndTag := EndTag;
  _OnStyle := OnStyle;
{$IFDEF FPC}
  _OnStyleOfObject := OnStyleOfObject;
{$ENDIF}
end;

class function TWriteTagCommand.New(const Text, StartTag, EndTag: String;
  const OnStyle: TOnApplyConsoleTextTagStyle
{$IFDEF FPC}; const OnStyleOfObject: TOnApplyConsoleTextTagStyleOfObject{$ENDIF}): IConsoleCommand;
begin
  Result := TWriteTagCommand.Create(Text, StartTag, EndTag, OnStyle{$IFDEF FPC}, OnStyleOfObject{$ENDIF});
end;

end.
