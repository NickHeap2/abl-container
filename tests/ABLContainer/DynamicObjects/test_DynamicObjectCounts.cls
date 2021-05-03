USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.DynamicObjects.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.DynamicObjects.test_DynamicObjectCounts:

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
  METHOD PUBLIC VOID canGetDynamicObjectCounts(  ):
    DEFINE VARIABLE dynamicObjectCounts AS DynamicObjectCounts NO-UNDO.
    dynamicObjectCounts = ABLContainer.DynamicObjects.DynamicObjectCounts:GetDynamicObjectCounts().
    Assert:NotNull(dynamicObjectCounts).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddDynamicObjectCountToLogs(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.dynamicobjects.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    Log:Information("TEST INFORMATION").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION",TestFormatter:LastLogEvent:MessageTemplate:Text).

    /* check properties */
    Assert:Equals(8, TestFormatter:LastLogEvent:Properties:Count).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("DatasetCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "DatasetCount").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("DataSourceCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
/*    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "DataSourceCount").*/

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("BufferCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "BufferCount").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcedureCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
/*    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ProcedureCount").*/

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("QueryCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "QueryCount").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ObjectCount", OUTPUT logEventPropertyValue).
    Assert:Equals(TRUE, success).
    Assert:NotZero(INTEGER(logEventPropertyValue:ToString()), "ObjectCount").

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
