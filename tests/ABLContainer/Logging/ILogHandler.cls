USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.

INTERFACE ABLContainer.Logging.ILogHandler:

  METHOD VOID OnLog_Handler (logEvent AS LogEvent).

END INTERFACE.