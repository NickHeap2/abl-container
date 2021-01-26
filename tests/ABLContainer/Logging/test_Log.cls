USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.
/*USING Serilog.Events.* FROM ASSEMBLY.*/
/*USING System.Environment.* FROM ASSEMBLY.*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.test_Log:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().

    TestLogger:CreateLogger(THIS-OBJECT).
    TestFormatter:ClearLastMessage().

    EnvVars:ClearEnvVars().
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformation(  ):

    Log:Information("TEST INFORMATION").
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarningArray(  ):

    DEFINE VARIABLE propertiesArray AS OpenEdge.Core.String EXTENT 2 NO-UNDO.
/*    propertiesArray = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 2).*/
/*    DEFINE VARIABLE propertiesArray AS Array NO-UNDO.*/
/*    propertiesArray = NEW Array(2).*/

    propertiesArray[1] = NEW OpenEdge.Core.String("Param1").
    propertiesArray[2] = NEW OpenEdge.Core.String("Param2").
/*    propertiesArray:Add(NEW OpenEdge.Core.String("Param1")).*/
/*    propertiesArray:Add(NEW OpenEdge.Core.String("Param2")).*/
    
    Log:Warning("Warning ~{Param1~} ~{Param2~}", propertiesArray).
/*    DELETE OBJECT propertiesArray NO-ERROR.*/

    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Warning ~{Param1~} ~{Param2~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param2", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM2~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarningAtArray(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    DEFINE VARIABLE propertiesArray AS Array NO-UNDO.
/*    propertiesArray = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 2).*/
    propertiesArray = NEW Array(2).
    propertiesArray:Add(NEW OpenEdge.Core.String("Param1")).
    propertiesArray:Add(NEW OpenEdge.Core.String("Param2")).
    Log:WarningAt(eventTime, "WarningAt ~{Param1~} ~{Param2~}", propertiesArray).
    DELETE OBJECT propertiesArray NO-ERROR.

    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("WarningAt ~{Param1~} ~{Param2~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param2", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM2~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnError(  ):

    Log:Error("TEST ERROR").
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST ERROR", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfo(  ):

    Log:Debug("TEST DEBUG").
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST DEBUG", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarning(  ):

    Log:Warning("TEST WARNING").
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST WARNING", TestFormatter:LastLogEvent:MessageTemplate:Text).

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
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("ERROR: ~{ErrorMessage~}~n~{ErrorStack~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnExceptionWithoutStackTrace(  ):

    DEFINE VARIABLE errorLogged AS LOGICAL NO-UNDO.

    DO ON ERROR UNDO, LEAVE:
      DEFINE VARIABLE hHandle AS HANDLE NO-UNDO.
      hHandle:ACCEPT-CHANGES().

      CATCH ex AS Progress.Lang.Error :
        SESSION:ERROR-STACK-TRACE = FALSE.
        Log:Error(ex).
        errorLogged = TRUE.
      END CATCH.
    END.

    Assert:IsTrue(errorLogged).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("ERROR: ~{ErrorMessage~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnErrorWithAParam(  ):

    Log:Error("Error ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Error ~{Param1~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnErrorWithTwoParams(  ):

    Log:Error("Error ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Error ~{Param1~} ~{Param2~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param2", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM2~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithAParam(  ):

    Log:Debug("Debug ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Debug ~{Param1~}", TestFormatter:LastLogEvent:MessageTemplate:Text).
    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithTwoParams(  ):

    Log:Debug("Debug ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithThreeParams(  ):

    Log:Debug("Debug ~{Param1~} ~{Param2~} ~{Param3~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithFourParams(  ):

    Log:Debug("Debug ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3"), NEW OpenEdge.Core.String("PARAM4")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithAParam(  ):

    Log:Information("Information ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Information ~{Param1~}", TestFormatter:LastLogEvent:MessageTemplate:Text).
    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithTwoParams(  ):

    Log:Information("Information ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithThreeParams(  ):

    Log:Information("Information ~{Param1~} ~{Param2~} ~{Param3~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithFourParams(  ):

    Log:Information("Information ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3"), NEW OpenEdge.Core.String("PARAM4")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithFiveParams(  ):

    Log:Information("Information ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~} ~{Param5~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3"), NEW OpenEdge.Core.String("PARAM4"), NEW OpenEdge.Core.String("PARAM5")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithSixParams(  ):

    Log:Information("Information ~{Param1~} ~{Param2~} ~{Param3~} ~{Param4~} ~{Param5~} ~{Param6~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3"), NEW OpenEdge.Core.String("PARAM4"), NEW OpenEdge.Core.String("PARAM5"), NEW OpenEdge.Core.String("PARAM6")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAWarningWithAParam(  ):

    Log:Warning("Warning ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("Warning ~{Param1~}", TestFormatter:LastLogEvent:MessageTemplate:Text).
    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAWarningWithTwoParams(  ):

    Log:Warning("Warning ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarningAtWithAParam(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:WarningAt(eventTime, "WarningAt ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarningAtWithTwoParams(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:WarningAt(eventTime, "WarningAt ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWarningAtWithThreeParams(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:WarningAt(eventTime, "WarningAt ~{Param1~} ~{Param2~} ~{Param3~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationAtWithAParam(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    DEFINE VARIABLE lastLogEventEventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:InformationAt(eventTime, "InformationAt ~{Param1~}", NEW OpenEdge.Core.String("PARAM1")).
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").

    lastLogEventEventTime = TestFormatter:LastLogEvent:Timestamp:DateTime.
    Assert:Equals(STRING(eventTime, "99/99/9999 HH:MM:SS.SSS"), STRING(lastLogEventEventTime, "99/99/9999 HH:MM:SS.SSS")).
    Assert:Equals("InformationAt ~{Param1~}", TestFormatter:LastLogEvent:MessageTemplate:Text).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("Param1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"PARAM1~"", logEventPropertyValue:ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationAtWithTwoParams(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:InformationAt(eventTime, "InformationAt ~{Param1~} ~{Param2~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationAtWithThreeParams(  ):
    DEFINE VARIABLE eventTime AS DATETIME NO-UNDO.
    eventTime = ADD-INTERVAL(NOW, -3, "hours").

    Log:InformationAt(eventTime, "InformationAt ~{Param1~} ~{Param2~} ~{Param3~}", NEW OpenEdge.Core.String("PARAM1"), NEW OpenEdge.Core.String("PARAM2"), NEW OpenEdge.Core.String("PARAM3")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckDebugIsEnabled(  ):
    DEFINE VARIABLE isEnabled AS LOGICAL NO-UNDO.
    isEnabled = Log:IsDebugEnabled().
    Assert:IsTrue(isEnabled).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckVerboseIsDisabled(  ):
    DEFINE VARIABLE isEnabled AS LOGICAL NO-UNDO.
    isEnabled = Log:IsVerboseEnabled().
    Assert:IsFalse(isEnabled).

  END METHOD.

  /*TODO*/
  /*
  @Test.
  METHOD PUBLIC VOID canLogMachineNameAndProcessIdProperties(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.context.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    ABLContainer.Configuration.Configuration:Current = configuration.
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.

    Log:Information("TEST INFORMATION").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

    /* check properties */
    Assert:Equals(12, TestFormatter:LastLogEvent:Properties:Count).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("MachineName", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:NotEqual(logEventPropertyValue:ToString(), "~"~"").

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("ProcessId", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:NotEqual(logEventPropertyValue:ToString(), "~"~"").

  END.

  @Test.
  METHOD PUBLIC VOID canLogSwarmProperties(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    System.Environment:SetEnvironmentVariable("SWARM_NODE_ID", "NODE_ID").
    System.Environment:SetEnvironmentVariable("SWARM_NODE_HOSTNAME", "NODE_HOSTNAME").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_ID", "SERVICE_ID").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_NAME", "SERVICE_NAME").
    System.Environment:SetEnvironmentVariable("SWARM_SERVICE_LABELS", "SERVICE_LABELS").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_ID", "TASK_ID").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_NAME", "TASK_NAME").
    System.Environment:SetEnvironmentVariable("SWARM_TASK_SLOT", "TASK_SLOT").

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.context.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    ABLContainer.Configuration.Configuration:Current = configuration.
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.

    Log:Information("TEST INFORMATION").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

    /* check properties */
    Assert:Equals(12, TestFormatter:LastLogEvent:Properties:Count).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmNodeID", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"NODE_ID~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmNodeHostname", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"NODE_HOSTNAME~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmServiceID", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"SERVICE_ID~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmServiceName", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"SERVICE_NAME~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmServiceLabels", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"SERVICE_LABELS~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmTaskID", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TASK_ID~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmTaskSlot", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TASK_SLOT~"", logEventPropertyValue:ToString()).

    success = TestFormatter:LastLogEvent:Properties:TryGetValue("SwarmTaskName", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TASK_NAME~"", logEventPropertyValue:ToString()).

/*    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).*/

/*    DEFINE VARIABLE keyEnumerator AS "System.Collections.Generic.IEnumerator<CHARACTER>" NO-UNDO.*/
/*    keyEnumerator = TestFormatter:LastLogEvent:Properties:Keys:GetEnumerator().                  */
/*    Assert:NotNull(keyEnumerator).                                                               */
/*    DO WHILE keyEnumerator:MoveNext():                                                           */
/*      MESSAGE keyEnumerator:CURRENT.                                                             */
/*    END.                                                                                         */

  END METHOD.
  */

  @Test.
  METHOD PUBLIC VOID canPushProperty(  ):

    DEFINE VARIABLE testProperty AS LogProperty NO-UNDO.

    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST INFORMATION").
    testProperty:Dispose().

    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

    /* check properties */
    Assert:Equals(1, TestFormatter:LastLogEvent:Properties:Count).

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TestValue~"", logEventPropertyValue:ToString()).


    Log:Information("TEST INFORMATION").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION", TestFormatter:LastLogEvent:MessageTemplate:Text).

    /* check properties */
    Assert:Equals(0, TestFormatter:LastLogEvent:Properties:Count).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canPushTwoProperties(  ):

    DEFINE VARIABLE testProperty1 AS LogProperty NO-UNDO.
    DEFINE VARIABLE testProperty2 AS LogProperty NO-UNDO.

    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.
    DEFINE VARIABLE success AS LOGICAL NO-UNDO.

    testProperty1 = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Log:Information("TEST INFORMATION 1").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION 1", TestFormatter:LastLogEvent:MessageTemplate:Text).
    Assert:Equals(1, TestFormatter:LastLogEvent:Properties:Count).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).

    testProperty2 = Log:PushProperty("TestName2", NEW OpenEdge.Core.String("TestValue2")).
    Log:Information("TEST INFORMATION 2").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION 2", TestFormatter:LastLogEvent:MessageTemplate:Text).
    Assert:Equals(2, TestFormatter:LastLogEvent:Properties:Count).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName2", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TestValue2~"", logEventPropertyValue:ToString()).

    testProperty2:Dispose().

    Log:Information("TEST INFORMATION 3").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION 3", TestFormatter:LastLogEvent:MessageTemplate:Text).
    Assert:Equals(1, TestFormatter:LastLogEvent:Properties:Count).
    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).
    Assert:IsTrue(success).
    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).

    testProperty1:Dispose().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canResetProperties(  ):
    DEFINE VARIABLE testProperty1 AS LogProperty NO-UNDO.
    DEFINE VARIABLE testProperty2 AS LogProperty NO-UNDO.

    testProperty1 = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    testProperty2 = Log:PushProperty("TestName2", NEW OpenEdge.Core.String("TestValue2")).

    Log:Information("TEST INFORMATION 1").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION 1", TestFormatter:LastLogEvent:MessageTemplate:Text).
    Assert:Equals(2, TestFormatter:LastLogEvent:Properties:Count).

    Log:ResetContext().

    Log:Information("TEST INFORMATION 2").
    /* check message */
    Assert:NotNull(TestFormatter:LastLogEvent, "LastLogEvent").
    Assert:Equals("TEST INFORMATION 2", TestFormatter:LastLogEvent:MessageTemplate:Text).
    Assert:Equals(0, TestFormatter:LastLogEvent:Properties:Count).

    testProperty2:Dispose().
    testProperty1:Dispose().

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    PROPATH = previousPropath.

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
