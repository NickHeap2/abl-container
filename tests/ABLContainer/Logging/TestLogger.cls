USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.* FROM ASSEMBLY.
USING Serilog.Events.* FROM ASSEMBLY.
USING Serilog.Core.* FROM ASSEMBLY.
USING Serilog.Configuration.* FROM ASSEMBLY.
USING Serilog.Formatting.* FROM ASSEMBLY.
USING Serilog.LoggerConfiguration FROM ASSEMBLY.
USING Serilog.Sinks.Console.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.



CLASS ABLContainer.Logging.TestLogger:

/*  METHOD STATIC VOID CreateLogger(obj AS ILogHandler):                                                                                            */
/*    DEFINE VARIABLE loggerConfiguration AS LoggerConfiguration NO-UNDO.                                                                           */
/*    loggerConfiguration = NEW LoggerConfiguration().                                                                                              */
/*    loggerConfiguration:MinimumLevel:Debug().                                                                                                     */
/*    loggerConfiguration:Enrich:FromLogContext().                                                                                                  */
/*                                                                                                                                                  */
/*    DEFINE VARIABLE loggerSinkConfiguration AS LoggerSinkConfiguration NO-UNDO.                                                                   */
/*    loggerSinkConfiguration = loggerConfiguration:WriteTo.                                                                                        */
/*                                                                                                                                                  */
/*    DEFINE VARIABLE textFormatter AS TestFormatter NO-UNDO.                                                                                       */
/*/*    textFormatter = NEW ABLContainer.Logging.TestFormatter().*/                                                                                 */
/*    textFormatter = ABLContainer.Logging.TestFormatter:GetFormatter().                                                                            */
/*                                                                                                                                                  */
/*    IF VALID-OBJECT(obj) THEN DO:                                                                                                                 */
/*      textFormatter:OnLog:Subscribe(obj:OnLog_Handler) NO-ERROR.                                                                                  */
/*      IF ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                                                                                                   */
/*        MESSAGE ERROR-STATUS:GET-MESSAGE(1).                                                                                                      */
/*      END.                                                                                                                                        */
/*    END.                                                                                                                                          */
/*    ELSE DO:                                                                                                                                      */
/*      MESSAGE "Log Handler object is not valid!".                                                                                                 */
/*    END.                                                                                                                                          */
/*                                                                                                                                                  */
/*    DEFINE VARIABLE logEventSink AS Serilog.Core.ILogEventSink NO-UNDO.                                                                           */
/*    loggerConfiguration = Serilog.ConsoleLoggerConfigurationExtensions:Console(loggerSinkConfiguration, textFormatter, LogEventLevel:Debug, ?, ?).*/
/*                                                                                                                                                  */
/*    Serilog.Log:Logger = loggerConfiguration:CreateLogger().                                                                                      */
/*                                                                                                                                                  */
/*  END.                                                                                                                                            */


  METHOD STATIC VOID CreateLogger(obj AS Progress.Lang.Object):
    DEFINE VARIABLE loggerConfiguration AS LoggerConfiguration NO-UNDO.
    loggerConfiguration = NEW LoggerConfiguration().
    loggerConfiguration:MinimumLevel:Debug().
    loggerConfiguration:Enrich:FromLogContext().

    DEFINE VARIABLE loggerSinkConfiguration AS LoggerSinkConfiguration NO-UNDO.
    loggerSinkConfiguration = loggerConfiguration:WriteTo.

    DEFINE VARIABLE testFormatter AS TestFormatter NO-UNDO.
    testFormatter = ABLContainer.Logging.TestFormatter:GetFormatter().

    DEFINE VARIABLE logEventSink AS Serilog.Core.ILogEventSink NO-UNDO.
    loggerConfiguration = Serilog.ConsoleLoggerConfigurationExtensions:Console(loggerSinkConfiguration, testFormatter, LogEventLevel:Debug, ?, ?).

    Serilog.Log:Logger = loggerConfiguration:CreateLogger().

  END.

END CLASS.