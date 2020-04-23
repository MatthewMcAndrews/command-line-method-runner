unit uRun;

interface

procedure Run;

implementation

uses
  RTTI, SysUtils;

type
  TValues = array of TValue;

function TryConversion(Str: string; TypeKind: TTypeKind; out Value: TValue): Boolean;
begin
  Result := False;
  case TypeKind of
    tkInteger: begin
      var Int: Integer;
      Result := TryStrToInt(Str, Int);
      Value := Int;
    end;
    tkChar: begin
      Result := (Length(Str) = 1);
      Value := Str[1];
    end;
    tkFloat: begin
      var Ext: Extended;
      Result := TryStrToFloat(Str, Ext);
      Value := Ext;
    end;
    tkUString: begin
      Value := Str;
      Result := True;
    end
  else
    Writeln('Unsupported TTypeKind: ', Ord(TypeKind));
  end;
end;

procedure Run;
begin
  // E.g. <UnitName>.<ClassName>.<MethodName>
  var FullyQualifiedMethodName := ParamStr(1);
  var Names := FullyQualifiedMethodName.Split(['.']);
  // Note that unit names may contain dots.
  if Length(Names) < 3 then
    raise Exception.Create('Fully Qualified Method Name is Required.');

  var UnitName := Names[0];
  var ClassName := Names[1];
  var MethodName := Names[2];

  var Context := TRttiContext.Create;

  var QualifiedTypeName := UnitName +'.'+ ClassName;
  var InstType := Context.FindType(QualifiedTypeName) as TRttiInstanceType;
  if not Assigned(InstType) then begin
    raise Exception.Create('Unknown class: ' + ClassName);
  end;
  if not InstType.IsInstance then begin
    raise Exception.Create(
      'Unsupported Type. ' + ClassName + ' Only Instantiable Types Allowed.');
  end;

  var Method := InstType.GetMethod(MethodName);

  var Arguments: TValues := [];
  for var Parameter in Method.GetParameters do begin
    var Str: string;
    if not FindCmdLineSwitch(Parameter.Name, Str) then begin
      raise Exception.Create(
        'Expected Argument is missing from command line: ' + Parameter.ToString);
    end;

    var Value: TValue;
    // Explicit conversion is necessary to avoid variant conversion issues.
    if not TryConversion(Str, Parameter.ParamType.TypeKind, Value) then begin
      raise Exception.Create('Unable to convert arguement, "' + Str
        + '", to the expected parameter type: ' + Parameter.ToString);
    end;

    Arguments := Arguments + [Value];

  end;

  try
    Method.Invoke(InstType.MetaclassType, Arguments);
  except
    on E: Exception do
      Writeln(E.Message);
  end;

  Context.Free;
end;

end.
