USING ABLContainer.Performance.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Core.* FROM ASSEMBLY.
USING Serilog.Events.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.PerformanceLogger IMPLEMENTS ILogEventEnricher :

  METHOD PUBLIC VOID Enrich (logEvent AS CLASS LogEvent, propertyFactory AS CLASS ILogEventPropertyFactory):
    DEFINE VARIABLE cpuProperty AS LogEventProperty NO-UNDO.
    cpuProperty = propertyFactory:CreateProperty("ProcessCPUPercentage", PerformanceCounts:GetCPU(), FALSE).
    logEvent:AddOrUpdateProperty(cpuProperty).

    DEFINE VARIABLE memoryProperty AS LogEventProperty NO-UNDO.
    memoryProperty = propertyFactory:CreateProperty("ProcessMemoryMb", PerformanceCounts:GetMemory(), FALSE).
    logEvent:AddOrUpdateProperty(memoryProperty).

  END METHOD.

END CLASS.
