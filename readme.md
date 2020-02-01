[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://travis-ci.org/VencejoSoftware/ooConsole.svg?branch=master)](https://travis-ci.org/VencejoSoftware/ooConsole)

# ooConsole - Object pascal console/terminal library
Library to console/terminal access

### Simple parse example
```pascal
var
  Console: IConsole;
begin
  Console := TConsole.New;
  Console.WriteTaggedText('This is a text test of [warning], not [error], styled write text[error].',
    '[', ']',
    procedure(const Text: String; const Tag: String; var TextColor, BackColor: TConsoleColor)
    begin
      if SameText(Tag, 'warning') then
        TextColor := Yellow
      else
        if SameText(Tag, 'error') then
          TextColor := Red
    end);
end;
```

### Documentation
If not exists folder "code-documentation" then run the batch "build_doc". The main entry is ./doc/index.html

### Demo
Before all, run the batch "build_demo" to build proyect. Then go to the folder "demo\build\release\" and run the executable.

## Built With
* [Delphi&reg;](https://www.embarcadero.com/products/rad-studio) - Embarcadero&trade; commercial IDE
* [Lazarus](https://www.lazarus-ide.org/) - The Lazarus project

## Contribute
This are an open-source project, and they need your help to go on growing and improving.
You can even fork the project on GitHub, maintain your own version and send us pull requests periodically to merge your work.

## Authors
* **Alejandro Polti** (Vencejo Software team lead) - *Initial work*