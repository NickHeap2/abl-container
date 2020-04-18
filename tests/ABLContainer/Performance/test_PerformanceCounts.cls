USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.Performance.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Performance.test_PerformanceCounts:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().

    TestLogger:CreateLogger(THIS-OBJECT).
    TestFormatter:ClearLastMessage().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetCPUCount(  ):
    DEFINE VARIABLE cpuCount AS DECIMAL NO-UNDO.
    cpuCount = PerformanceCounts:GetCPU().
    Assert:NotZero(cpuCount).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetMemoryCount(  ):
    DEFINE VARIABLE memoryCount AS DECIMAL NO-UNDO.
    memoryCount = PerformanceCounts:GetMemory().
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

    /* check properties */
    Assert:Equals(6, TestFormatter:LastLogEvent:Properties:Count).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcessCPUPercentage", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ProcessCPUPercentage").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcessHandleCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ProcessHandleCount").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcessMemoryMb", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ProcessMemoryMb").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcessMemoryBytes", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ProcessMemoryBytes").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Application", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotEmpty(logEventPropertyValue:ToString(), "Application").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Environment", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotEmpty(logEventPropertyValue:ToString(), "Environment").

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():

    PROPATH = previousPropath.

  END METHOD.

END CLASS.
