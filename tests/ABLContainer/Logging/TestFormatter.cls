USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.
USING Serilog.Formatting.* FROM ASSEMBLY.
USING System.IO.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.TestFormatter IMPLEMENTS ITextFormatter:

  DEFINE STATIC VARIABLE TestFormatterInstance AS TestFormatter NO-UNDO.
  DEFINE PUBLIC STATIC VARIABLE LastLogEvent AS LogEvent NO-UNDO.
  DEFINE PUBLIC EVENT OnLog SIGNATURE VOID (logEvent AS LogEvent).

  METHOD PUBLIC VOID Format (logEvent AS LogEvent, textWriter AS TextWriter):
    OnLog:PUBLISH(logEvent).
/*    textWriter:WriteLine("Output").*/
  END METHOD.

  METHOD STATIC PUBLIC VOID ClearLastMessage():
    DELETE OBJECT LastLogEvent NO-ERROR.
  END METHOD.

  METHOD STATIC PUBLIC TestFormatter GetFormatter():
    IF NOT VALID-OBJECT(TestFormatter:TestFormatterInstance) THEN DO:
      TestFormatter:TestFormatterInstance = NEW TestFormatter().
      TestFormatter:TestFormatterInstance:OnLog:SUBSCRIBE(TestFormatter:TestFormatterInstance:OnLog_Handler).
    END.
    RETURN TestFormatterInstance.
  END METHOD.

  METHOD PUBLIC VOID OnLog_Handler (logEvent AS LogEvent):
    LastLogEvent = LogEvent.
  END METHOD.

END CLASS.