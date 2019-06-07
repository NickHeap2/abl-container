
 /*------------------------------------------------------------------------
    File        : TestFormatter
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Nick Heap
    Created     : Thu May 30 12:49:17 BST 2019
    Notes       :
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Serilog.Events.*.
USING Serilog.Formatting.*.
USING System.IO.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.TestFormatter IMPLEMENTS ITextFormatter:

  DEFINE PUBLIC EVENT OnLog SIGNATURE VOID (logEvent AS LogEvent).

  METHOD PUBLIC VOID Format (logEvent AS LogEvent, textWriter AS TextWriter):
    OnLog:PUBLISH(logEvent).
/*    textWriter:WriteLine("Output").*/
  END METHOD.

END CLASS.