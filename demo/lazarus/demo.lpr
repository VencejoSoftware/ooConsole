{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{$ENDREGION}
program demo;

{$APPTYPE CONSOLE}

{$define UseCThreads}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  SysUtils,
  Console in '..\..\code\Console.pas',
  ConsoleColor in '..\..\code\ConsoleColor.pas',
  ConsoleCommand in '..\..\code\ConsoleCommand.pas',
  ConsoleWriteTagCommand in '..\..\code\ConsoleWriteTagCommand.pas',
  DelphiConsole in '..\..\code\DelphiConsole.pas',
  FpcConsole in '..\..\code\FpcConsole.pas',
  StackedConsole in '..\..\code\StackedConsole.pas',
  DemoCode in '..\code\DemoCode.pas';

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
