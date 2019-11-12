USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.Performance.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Performance.test_PerformanceCounts IMPLEMENTS ILogHandler:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  DEFINE PUBLIC PROPERTY LastLogEvent AS LogEvent NO-UNDO
  GET.
  SET.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().
/*    System.Environment:SetEnvironmentVariable(variable, value)*/

    TestLogger:CreateLogger(THIS-OBJECT).
    DELETE OBJECT LastLogEvent NO-ERROR.

  END METHOD.

  METHOD PUBLIC VOID OnLog_Handler (logEvent AS LogEvent):
    LastLogEvent = LogEvent.
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetCPUCount(  ):
    DEFINE VARIABLE cpuCount AS DECIMAL NO-UNDO.
    cpuCount = PerformanceCounts:GetCPU().
    MESSAGE cpuCount.
    Assert:NotZero(cpuCount).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetMemoryCount(  ):
    DEFINE VARIABLE memoryCount AS DECIMAL NO-UNDO.
    memoryCount = PerformanceCounts:GetMemory().
    MESSAGE memoryCount.
    Assert:NotZero(memoryCount).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddPerformanceToLogs(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.performance.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    Log:Information("TEST INFORMATION").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():

    PROPATH = previousPropath.

  END METHOD.

END CLASS.
