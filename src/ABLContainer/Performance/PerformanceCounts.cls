
 /*------------------------------------------------------------------------
    File        : PerformanceCounts
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Nick Heap
    Created     : Tue Nov 12 10:31:11 GMT 2019
    Notes       :
  ----------------------------------------------------------------------*/

USING ABLContainer.Performance.* FROM PROPATH.
USING Progress.Lang.*.
USING System.Diagnostics.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Performance.PerformanceCounts:

  DEFINE PRIVATE PROPERTY ProcessorCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PRIVATE PROPERTY CpuPerformanceCounter AS PerformanceCounter NO-UNDO
  GET.
  SET.

  DEFINE PRIVATE PROPERTY MemoryPerformanceCounter AS PerformanceCounter NO-UNDO
  GET.
  SET.

  DEFINE STATIC VARIABLE performanceCountsInstance AS PerformanceCounts NO-UNDO.

  CONSTRUCTOR PUBLIC PerformanceCounts (  ):
    SUPER ().

    THIS-OBJECT:ProcessorCount = System.Environment:ProcessorCount.
    IF THIS-OBJECT:ProcessorCount < 1 THEN DO:
      THIS-OBJECT:ProcessorCount = 1.
    END.

    DEFINE VARIABLE currentProcess AS Process NO-UNDO.
    currentProcess = Process:GetCurrentProcess().

    DEFINE VARIABLE performanceCounterCategory AS PerformanceCounterCategory NO-UNDO.
    performanceCounterCategory = NEW PerformanceCounterCategory("Process").

    DEFINE VARIABLE instanceNames AS CHARACTER EXTENT NO-UNDO.
    instanceNames = performanceCounterCategory:GetInstanceNames().

    DEFINE VARIABLE thisInstanceName AS CHARACTER NO-UNDO.
    DEFINE VARIABLE instance AS INTEGER NO-UNDO.
    DEFINE VARIABLE instanceName AS CHARACTER NO-UNDO.

    _GET_INSTANCE_NAME:
    DO instance = 1 TO EXTENT(instanceNames):
      instanceName = instanceNames[instance].
      IF instanceName BEGINS currentProcess:ProcessName THEN DO ON ERROR UNDO, LEAVE:
        DEFINE VARIABLE processId AS INTEGER NO-UNDO.
        DEFINE VARIABLE performanceCounter AS PerformanceCounter NO-UNDO.
        performanceCounter = NEW PerformanceCounter("Process", "ID Process", instanceName, TRUE).
        IF currentProcess:id = performanceCounter:RawValue THEN DO:
          thisInstanceName = instanceName.
        END.

        FINALLY:
          IF VALID-OBJECT(performanceCounter) THEN DO:
            performanceCounter:Dispose() NO-ERROR.
            DELETE OBJECT performanceCounter NO-ERROR.
          END.
        END FINALLY.
      END.
    END.

    IF thisInstanceName <> "" THEN DO:
      THIS-OBJECT:CpuPerformanceCounter = NEW PerformanceCounter("Process", "% Processor Time", thisInstanceName, TRUE).
      IF VALID-OBJECT(THIS-OBJECT:CpuPerformanceCounter) THEN DO:
        THIS-OBJECT:CpuPerformanceCounter:NextValue().
      END.

      THIS-OBJECT:MemoryPerformanceCounter = NEW PerformanceCounter("Process", "Private Bytes", thisInstanceName, TRUE).
      IF VALID-OBJECT(THIS-OBJECT:MemoryPerformanceCounter) THEN DO:
        THIS-OBJECT:MemoryPerformanceCounter:NextValue().
      END.
      /* sleep 500 to enable first stats to be accurate */
      System.Threading.Thread:Sleep(500).

    END.

  END CONSTRUCTOR.

  METHOD PUBLIC STATIC DECIMAL GetCPU(  ):

    IF NOT VALID-OBJECT(performanceCountsInstance) THEN DO:
      performanceCountsInstance = NEW PerformanceCounts().
    END.

    RETURN System.Math:Round(performanceCountsInstance:CpuPerformanceCounter:NextValue() / performanceCountsInstance:ProcessorCount, 2).

  END METHOD.

  METHOD PUBLIC STATIC DECIMAL GetMemory(  ):

    IF NOT VALID-OBJECT(performanceCountsInstance) THEN DO:
      performanceCountsInstance = NEW PerformanceCounts().
    END.

    RETURN System.Math:Round(performanceCountsInstance:MemoryPerformanceCounter:NextValue() / 1024 / 1024, 2).

  END METHOD.

	DESTRUCTOR PUBLIC PerformanceCounts ( ):

	 IF VALID-OBJECT(THIS-OBJECT:CpuPerformanceCounter) THEN DO:
	   THIS-OBJECT:CpuPerformanceCounter:Dispose() NO-ERROR.
	   DELETE OBJECT THIS-OBJECT:CpuPerformanceCounter NO-ERROR.
	 END.
   IF VALID-OBJECT(THIS-OBJECT:MemoryPerformanceCounter) THEN DO:
     THIS-OBJECT:MemoryPerformanceCounter:Dispose() NO-ERROR.
     DELETE OBJECT THIS-OBJECT:MemoryPerformanceCounter NO-ERROR.
   END.

	END DESTRUCTOR.

END CLASS.