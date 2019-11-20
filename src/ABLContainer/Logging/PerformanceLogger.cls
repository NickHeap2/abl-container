USING ABLContainer.Performance.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Core.* FROM ASSEMBLY.
USING Serilog.Events.* FROM ASSEMBLY.
USING System.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.PerformanceLogger IMPLEMENTS ILogEventEnricher :

  METHOD PUBLIC VOID Enrich (logEvent AS CLASS LogEvent, propertyFactory AS CLASS ILogEventPropertyFactory):
    DEFINE VARIABLE cpuPercentage AS DECIMAL NO-UNDO.
    cpuPercentage = PerformanceCounts:GetCPU().

    DEFINE VARIABLE cpuProperty AS LogEventProperty NO-UNDO.
    cpuProperty = propertyFactory:CreateProperty("ProcessCPUPercentage", cpuPercentage, FALSE).
    logEvent:AddOrUpdateProperty(cpuProperty).

    DEFINE VARIABLE memoryBytes AS DECIMAL NO-UNDO.
    memoryBytes = PerformanceCounts:GetMemory().

    DEFINE VARIABLE memoryMbProperty AS LogEventProperty NO-UNDO.
    memoryMbProperty = propertyFactory:CreateProperty("ProcessMemoryMb", Math:Round(memoryBytes / 1024 / 1024, 2), FALSE).
    logEvent:AddOrUpdateProperty(memoryMbProperty).

    DEFINE VARIABLE memoryBytesProperty AS LogEventProperty NO-UNDO.
    memoryBytesProperty = propertyFactory:CreateProperty("ProcessMemoryBytes", memoryBytes, FALSE).
    logEvent:AddOrUpdateProperty(memoryBytesProperty).

  END METHOD.

END CLASS.
