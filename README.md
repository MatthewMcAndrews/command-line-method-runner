# command-line-method-runner
An easy way to expose class methods to the command line. 

This code enables declared methods on a class to be called via the command line provided that
  * the CLMR.bpl package is added to the project via Project > Options > Packages > Runtime Packages
    * Ensure that "Link with runtime packages" is set to True
    * Add CLMR.bpl to "Runtime packages"
  * the uRun.pas unit is included in the project
  * the unit containing the class is included in the project
  * the class is declared in the interface section of a unit
  * the class is referenced in the project (otherwise it is excluded by the linker)
  * the method parameters are of supported types (Currently: Integer, Char, String, Float)

The command line must follow this format: `<AppName> <UnitName>.<ClassName>.<MethodName> -<Param1> <Value1> -<Param2> <Value2> ...`

The command itself is case-sensitive: the unit, class, and method names must match the case of their declaration.

When the uRun.Run() procedure is called, it parses the command line, and if the corresponding method exists, then it runs the method passing in the arguments from the command line. If the specified method does not exist, or the argument value types differ from the method parameter types, then an exception is raise instead.
