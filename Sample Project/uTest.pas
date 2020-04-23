unit uTest;

interface

type
  TTest = class
    class procedure Action(Str: string);
  end;

implementation

{ TTest }

class procedure TTest.Action(Str: string);
begin
  Writeln(Str);
end;

initialization
  TTest.Create;

end.
