{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Console color definitions
  @created(22/01/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConsoleColor;

{$IFDEF FPC}
{$ModeSwitch advancedrecords}
{$ModeSwitch typehelpers}
{$ENDIF}

interface

uses
  SysUtils;

type
{$REGION 'documentation'}
{
  Enum for valid console colors
  @value Black Black color
  @value Blue Blue color
  @value Green Green color
  @value Cyan Cyan color
  @value Red Red color
  @value Magenta Magenta color
  @value Brown Brown color
  @value LightGray Lighted gray color
  @value DarkGray Darked gray color
  @value LightBlue Lighted blue color
  @value LightGreen Lighted green color
  @value LightCyan Lighted cyan color
  @value LightRed Lighted red color
  @value LightMagenta Lighted magenta color
  @value Yellow Yellow color
  @value White White color
}
{$ENDREGION}
  TConsoleColor = (Null = - 1, Black = 0, Blue = 1, Green = 2, Cyan = 3, Red = 4, Magenta = 5, Brown = 6, LightGray = 7,
    DarkGray = 8, LightBlue = 9, LightGreen = 10, LightCyan = 11, LightRed = 12, LightMagenta = 13, Yellow = 14,
    White = 15);

{$REGION 'documentation'}
{
  @abstract(Severity helper for cast data types)
  @member(ToString Cast color enum to string)
  @member(
    FromString Tries to get enum value from string. Raise error if not match
    @param(Text String to convert)
  )
}
{$ENDREGION}

  TConsoleColorHelper = record helper for TConsoleColor
  strict private
  const
    COLOR_TEXT: array [TConsoleColor] of string = ('Black', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Brown',
      'LightGray', 'DarkGray', 'LightBlue', 'LightGreen', 'LightCyan', 'LightRed', 'LightMagenta', 'Yellow',
      'White', 'Null');
  public
    function ToString: string;
    procedure FromString(const Text: string);
  end;

implementation

procedure TConsoleColorHelper.FromString(const Text: string);
var
  Item: TConsoleColor;
begin
  for Item := Low(TConsoleColor) to High(TConsoleColor) do
    if SameText(Text, COLOR_TEXT[Item]) then
    begin
      Self := Item;
      Exit;
    end;
  raise Exception.Create(Format('Invalid color: "%s"', [Text]));
end;

function TConsoleColorHelper.ToString: string;
begin
  Result := COLOR_TEXT[Self];
end;

end.
