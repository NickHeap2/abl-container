USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.test_Log:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().
    Log:MinimumLevel = "Information".
    Log:TestMode = TRUE.
    Log:LoggingFormat = "Json".
    Log:LogLevelPrefix = "".
    Log:LogToConsole = FALSE.
    Log:LogToLogManager = TRUE.

/*    TestLogger:CreateLogger(THIS-OBJECT).*/
/*    TestFormatter:ClearLastMessage().    */

    EnvVars:ClearEnvVars().
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetDebugLogLevel(  ):

    Log:MinimumLevel = "Debug".
    Assert:Equals("Debug", Log:MinimumLevel).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetWarningLogLevel(  ):

    Log:MinimumLevel = "Warning".
    Assert:Equals("Warning", Log:MinimumLevel).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetInformationLogLevel(  ):

    Log:MinimumLevel = "Information".
    Assert:Equals("Information", Log:MinimumLevel).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetErrorLogLevel(  ):

    Log:MinimumLevel = "Error".
    Assert:Equals("Error", Log:MinimumLevel).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canHaveDefaultLogLevel(  ):

    Log:MinimumLevel = "Blah".
    Assert:Equals("Information", Log:MinimumLevel).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canFilterLoggingWithLogLevel(  ):

    Log:MinimumLevel = "Error".
    Assert:Equals("Error", Log:MinimumLevel).

    Log:LastLogMessage = "".
    Log:Information("TEST INFORMATION").
    Assert:Equals("", Log:LastLogMessage).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogMessageWithNewlines(  ):

    Log:Information("TEST INFORMATION LINE 1~nTEST INFORMATION LINE 2").
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{'@timestamp': '*', 'level': 'INFO', 'message': 'TEST INFORMATION LINE 1\nTEST INFORMATION LINE 2', 'messageTemplate': '*'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformation(  ):

    Log:Information("TEST INFORMATION").
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{'@timestamp': '*', 'level': 'INFO', 'message': 'TEST INFORMATION', 'messageTemplate': '*'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithParam(  ):

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.String("param1")).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1',* 'Param1': 'param1'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithIntegerParam(  ):

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.Integer(49)).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION 49',* 'Param1': 49~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWith2Params(  ):

    Log:Information("TEST INFORMATION ~{Param1~} -> ~{Param2~}", NEW OpenEdge.Core.String("param1"), NEW OpenEdge.Core.String("param2")).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1 -> param2',* 'Param1': 'param1', 'Param2': 'param2'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWith3Params(  ):

    Log:Information("TEST INFORMATION ~{Param1~} ~{Param2~} ~{Param3~}", NEW OpenEdge.Core.String("param1"), NEW OpenEdge.Core.String("param2"), NEW OpenEdge.Core.String("param3")).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1 param2 param3',* 'Param1': 'param1', 'Param2': 'param2', 'Param3': 'param3'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWith4Params(  ):

    Log:Information("TEST INFORMATION ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~}", NEW OpenEdge.Core.String("param1"), NEW OpenEdge.Core.String("param2"), NEW OpenEdge.Core.String("param3"), NEW OpenEdge.Core.String("param4")).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1 param2 param3 param4',* 'Param1': 'param1', 'Param2': 'param2', 'Param3': 'param3', 'Param4': 'param4'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWith5Params(  ):

    Log:Information("TEST INFORMATION ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~} ~{Param5~}", NEW OpenEdge.Core.String("param1"), NEW OpenEdge.Core.String("param2"), NEW OpenEdge.Core.String("param3"), NEW OpenEdge.Core.String("param4"), NEW OpenEdge.Core.String("param5")).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1 param2 param3 param4 param5',* 'Param1': 'param1', 'Param2': 'param2', 'Param3': 'param3', 'Param4': 'param4', 'Param5': 'param5'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithDateTimeParam(  ):
    DEFINE VARIABLE thisDateTime AS DATETIME NO-UNDO.
    thisDateTime = DATETIME(01, 26, 2021,19, 34, 01, 0009).

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.DateTimeHolder(thisDateTime)).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION 2021-01-26T19:34:01.009',* 'Param1': '2021-01-26T19:34:01.009'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithLogicalValueParam(  ):

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.LogicalValue(TRUE)).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION true',* 'Param1': true~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithUnknownDateTimeParam(  ):
    DEFINE VARIABLE thisDateTime AS DATETIME NO-UNDO.
    thisDateTime = ?.

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.DateTimeHolder(thisDateTime)).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION null',* 'Param1': null~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithUnknownStringParam(  ):
    DEFINE VARIABLE stringValue AS CHARACTER NO-UNDO.
    stringValue = ?.
    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.String(stringValue)).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION null',* 'Param1': null~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithPropArray(  ):

    DEFINE VARIABLE propertyArray AS Progress.Lang.Object EXTENT 4 NO-UNDO.
    propertyArray[1] = NEW OpenEdge.Core.String("param1").
    propertyArray[2] = NEW OpenEdge.Core.String("param2").
    propertyArray[3] = NEW OpenEdge.Core.String("param3").
    propertyArray[4] = NEW OpenEdge.Core.String("param4").

    Log:Information("TEST INFORMATION ~{Param1~}, ~{Param2~}, ~{Param3~}, ~{Param4~}", propertyArray).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1, param2, param3, param4',* 'Param1': 'param1', 'Param2': 'param2', 'Param3': 'param3', 'Param4': 'param4'~}", "Last log message has message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithPushedProperties(  ):
    DEFINE VARIABLE logProperty AS LogProperty NO-UNDO.
  
    logProperty = Log:PushProperty("TestProperty", NEW OpenEdge.Core.String("TestPropertyValue")).
    Assert:NotNull(logProperty).

    Log:Information("TEST INFORMATION ~{Param1~}", NEW OpenEdge.Core.String("param1")).
    logProperty:Dispose().

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION param1',* 'Param1': 'param1', 'TestProperty': 'TestPropertyValue'~}", Log:LastLogMessage).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnException(  ):

    DEFINE VARIABLE errorLogged AS LOGICAL NO-UNDO.

    DO ON ERROR UNDO, LEAVE:
      DEFINE VARIABLE hHandle AS HANDLE NO-UNDO.
      hHandle:ACCEPT-CHANGES().

      CATCH ex AS Progress.Lang.Error :
        Log:Error(ex).
        errorLogged = TRUE.
      END CATCH.
    END.

    Assert:IsTrue(errorLogged).
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'ERROR: Invalid handle.  Not initialized or points to a deleted object. (3135)*'ErrorMessage': 'Invalid handle.  Not initialized or points to a deleted object. (3135)*~}", "Message contains exception").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogJustToConsole(  ):
    Log:LogToConsole = TRUE.
    Log:LogToLogManager = FALSE.

    Log:Information("TEST INFORMATION").

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Log Message contains message").
    Assert:IsTrue(Log:LastConsoleLog MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Console Log contains message").
    Assert:IsEmpty(Log:LastLogManagerLog).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogJustToLogManager(  ):
    Log:LogToConsole = FALSE.
    Log:LogToLogManager = TRUE.

    Log:Information("TEST INFORMATION").

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Log Message contains message").
    Assert:IsEmpty(Log:LastConsoleLog).
    Assert:IsTrue(Log:LastLogManagerLog MATCHES "[*@*+*] P-* T-* * 4GL INFO           ~{*'message': 'TEST INFORMATION'*~}", "Last Log Manager Log contains message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogToNoOutput(  ):
    Log:LogToConsole = FALSE.
    Log:LogToLogManager = FALSE.

    Log:Information("TEST INFORMATION").

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Log Message contains message").
    Assert:IsEmpty(Log:LastConsoleLog).
    Assert:IsEmpty(Log:LastLogManagerLog).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogToBothOutputs(  ):
    Log:LogToConsole = TRUE.
    Log:LogToLogManager = TRUE.

    Log:Information("TEST INFORMATION").

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Log Message contains message").
    Assert:IsTrue(Log:LastConsoleLog MATCHES "~{*'message': 'TEST INFORMATION'*~}", "Last Console Log contains message").
    Assert:IsTrue(Log:LastLogManagerLog MATCHES "[*@*+*] P-* T-* * 4GL INFO           ~{*'message': 'TEST INFORMATION'*~}", "Last Log Manager Log contains message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetALogLevelPrefix(  ):
    Log:LogLevelPrefix = "APP".
    Log:LogToConsole = TRUE.
    Log:LogToLogManager = TRUE.

    Log:Information("TEST INFORMATION").

    Assert:IsTrue(Log:LastLogMessage MATCHES "~{*'level': 'APPINFO', 'message': 'TEST INFORMATION'*~}", "Last Log Message contains message").
    Assert:IsTrue(Log:LastConsoleLog MATCHES "~{*'level': 'APPINFO', 'message': 'TEST INFORMATION'*~}", "Last Console Log contains message").
    Assert:IsTrue(Log:LastLogManagerLog MATCHES "[*@*+*] P-* T-* * 4GL APPINFO        ~{*'message': 'TEST INFORMATION'*~}", "Last Log Manager Log contains message").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogTextFormat(  ):
    Log:LogToConsole = TRUE.
    Log:LoggingFormat = "Text".

    Log:Information("TEST INFORMATION").
    Assert:Equals("TEST INFORMATION", Log:LastConsoleLog).

  END METHOD.
  
  @Test.
  METHOD PUBLIC VOID canLogJsonFormat(  ):
    Log:LogToConsole = TRUE.
    Log:LoggingFormat = "Json".

    Log:Information("TEST INFORMATION").
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{'@timestamp': '*', 'level': 'INFO', 'message': 'TEST INFORMATION', 'messageTemplate': '*'~}", "Last log message has message").

  END METHOD.
  
  @Test.
  METHOD PUBLIC VOID canLogCompactJsonFormat(  ):
    Log:LogToConsole = TRUE.
    Log:LoggingFormat = "CompactJson".

    Log:Information("TEST INFORMATION").
    Assert:IsTrue(Log:LastLogMessage MATCHES "~{'@t': '*', '@l': 'INFO', '@m': 'TEST INFORMATION', '@mt': 'TEST INFORMATION'~}", "Last log message has message").

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    PROPATH = previousPropath.
    Log:MinimumLevel = "Information".
    Log:TestMode = FALSE.

    System.Environment:SetEnvironmentVariable("SWARM_NODE_ID", "").
    System.Environment:SetEnvironmentVariable("SWARM_NODE_HOSTNAME", "").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_ID", "").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_NAME", "").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_LABELS", "").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_ID", "").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_NAME", "").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_SLOT", "").
  END METHOD.

END CLASS.
