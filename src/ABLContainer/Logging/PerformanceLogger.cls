USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.Performance.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.PerformanceLogger IMPLEMENTS ILogEnricher:

  METHOD PUBLIC VOID GetProperties(  ):
    /* cpu */
    DEFINE VARIABLE cpuPercentage AS DECIMAL NO-UNDO.
    cpuPercentage = PerformanceCounts:GetCPU().
    
    Log:PushProperty("ProcessCPUPercentage", NEW OpenEdge.Core.Decimal(cpuPercentage)).

    /* handle count */
    DEFINE VARIABLE handleCount AS DECIMAL NO-UNDO.
    handleCount = PerformanceCounts:GetHandles().

    Log:PushProperty("ProcessHandleCount", NEW OpenEdge.Core.Decimal(handleCount)).

    /* memory */
    DEFINE VARIABLE memoryBytes AS DECIMAL NO-UNDO.
    memoryBytes = PerformanceCounts:GetMemory().

    Log:PushProperty("ProcessMemoryMb", NEW OpenEdge.Core.Decimal(ROUND(memoryBytes / 1024 / 1024, 2))).

    Log:PushProperty("ProcessMemoryBytes", NEW OpenEdge.Core.Decimal(memoryBytes)).

  END METHOD.

END CLASS.
