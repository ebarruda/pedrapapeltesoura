program PedraPapelTesoura;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LResources
  { add your units here }, PedraPapelTesoura_Unit1;

{$IFDEF WINDOWS}{$R PedraPapelTesoura.rc}{$ENDIF}

begin
  {$I PedraPapelTesoura.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

