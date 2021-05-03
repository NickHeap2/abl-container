USING ABLContainer.Apm.* FROM PROPATH.
USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.
USING System.Environment.* FROM ASSEMBLY.
USING Elastic.Apm.Api.* FROM ASSEMBLY.
USING System.Collections.Generic.* FROM ASSEMBLY.
USING System.Diagnostics.* FROM ASSEMBLY.
USING System.Console FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Apm.test_Apm:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  DEFINE VARIABLE theTransaction AS Elastic.Apm.Api.ITransaction NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().

    TestLogger:CreateLogger(THIS-OBJECT).
    TestFormatter:ClearLastMessage().

    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVER_URLS", "http://51qsvr-mic-sv01.qa.dhlparcel.co.uk:8200").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SECRET_TOKEN", "123h4vg1k23g4fc1k2h3g4fk1234f23jhg423jh4").

    Agent:Environment = "Development".
    Agent:ServiceName = "ABLContainer".
    Agent:UseCentralConfig = FALSE.
    /*Agent:LogLevel = "Trace".*/
    Agent:FlushInterval = "0s".

  END METHOD.

  @Test.
  METHOD PUBLIC VOID isConfiguredStartsFalse(  ):

    DEFINE VARIABLE isConfigured AS LOGICAL NO-UNDO.

    isConfigured = Elastic.Apm.Agent:IsConfigured.
    Assert:IsFalse(isConfigured).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID agentCanLogToAblContainerAgent(  ):
    /*Agent:LogLevel = "Trace".*/

    Agent:StartTransaction("agentCanLogToAblContainerAgent", "TestMethod").

    Agent:StartSpan("Span1Name", "Span1Type", "Span1SubType", "Span1Action").

    Agent:StartSpan("Span2Name", "Span2Type", "Span2SubType", "Span2Action").

    Agent:EndSpan().

    Agent:EndSpan().

    Agent:EndTransaction().

    PAUSE 3.

  END METHOD.

  @Test.
  METHOD PUBLIC VOID agentCanLogInALoop(  ):
    /*Agent:LogLevel = "Trace".*/

    Agent:StartTransaction("agentCanLogInALoop", "TestMethod").

    OuterMethod().

    Agent:EndTransaction().

    PAUSE 3.

  END METHOD.

  METHOD PUBLIC VOID OuterMethod(  ):
    Agent:StartSpan("OuterMethod", "Method", "", "LoopItems").

    DEFINE VARIABLE loopCount AS INTEGER NO-UNDO.

    DO loopCount = 1 TO 100:

      InnerMethod(loopCount).

    END.

    Agent:EndSpan().
  END.

  METHOD PUBLIC VOID InnerMethod(loopValue AS DECIMAL):
    Agent:StartSpan("InnerMethod", "Method", "", "ProcessItem").

      PAUSE loopValue / 1000.

    Agent:EndSpan().
  END.

  @Test.
  METHOD PUBLIC VOID agentCanLogAnError(  ):
    /*Agent:LogLevel = "Trace".*/

    Agent:StartTransaction("agentCanLogAnError", "TestMethod").

    Agent:StartSpan("ErrorSpanName", "ErrorSpanType", "ErrorSpanSubType", "ErrorSpanAction").

    Agent:CaptureSpanError("There was an error in the thing!", "It was my fault!").

    Agent:EndSpan().

    Agent:EndTransaction().

    PAUSE 3.

  END METHOD.

  @Test.
  METHOD PUBLIC VOID initialise(  ):

  END.

  @Test.
  @ShowDuration.
  METHOD PUBLIC VOID fastestTest(  ):

    DEFINE VARIABLE icount AS INTEGER NO-UNDO.
    DO icount = 1 TO 1000:
    END.

  END.

  @Test.
  @ShowDuration.
  METHOD PUBLIC VOID throwAnError(  ):

    DEFINE VARIABLE icount AS INTEGER NO-UNDO.
    DO icount = 1 TO 1000 ON ERROR UNDO, LEAVE :
/*      Console:WriteLine("icount=" + STRING(icount)).*/
  /*    DEFINE VARIABLE cCallStack AS CHARACTER NO-UNDO.*/
      DEFINE VARIABLE orgStackTrace AS LOGICAL {&API-LOGICAL-FORMAT} NO-UNDO.
      orgStackTrace = SESSION:ERROR-STACK-TRACE.

      SESSION:ERROR-STACK-TRACE = TRUE.
      UNDO, THROW NEW AppError("Throw to get error":U, 0).
      CATCH e AS Progress.Lang.Error:
/*          RETURN.*/
      END CATCH.
      FINALLY:
        SESSION:ERROR-STACK-TRACE = orgStackTrace.
      END FINALLY.
    END.

  END.

  @Test.
  METHOD PUBLIC VOID agentCanLogAnException(  ):
    /*Agent:LogLevel = "Trace".*/

    Agent:StartTransaction("agentCanLogAnException", "TestMethod").

    Agent:StartSpan("ErrorSpanName", "ErrorSpanType", "ErrorSpanSubType", "ErrorSpanAction").

    /*throw an error*/
    DEFINE VARIABLE objectList AS "System.Collections.Generic.List<System.Object>" NO-UNDO.
    objectList:ADD(objectList).

    CATCH er AS Progress.Lang.Error :
      DEFINE VARIABLE exception AS System.Exception NO-UNDO.
      exception = NEW Elastic.Apm.StackTraceException(er:GetMessage(1), er:CallStack).

/*      Console:WriteLine("STACKTRACE:" + exception:StackTrace).*/
/*      Console:WriteLine("CALLSTACK:" + exception:CallStack).  */

      Agent:CaptureSpanException(exception, er:GetMessage(1), TRUE, ?).
    END CATCH.

    FINALLY:

      Agent:EndSpan().

      Agent:EndTransaction().

      PAUSE 3.
    END FINALLY.

  END METHOD.

  @Test.
  METHOD PUBLIC VOID agentCanLogAnErrorException(  ):
    /*Agent:LogLevel = "Trace".*/

    Agent:StartTransaction("agentCanLogAnErrorException", "TestMethod").

    Agent:StartSpan("ErrorSpanName", "ErrorSpanType", "ErrorSpanSubType", "ErrorSpanAction").

    /*throw an error*/
    DEFINE VARIABLE a AS Progress.Lang.Object NO-UNDO.
    a:GetClass().

    Agent:CaptureSpanError("There was an error in the thing!", "It was my fault!").

    Agent:EndSpan().

    Agent:EndTransaction().

    CATCH er AS Progress.Lang.Error :
      /*Console:WriteLine("Error").     */
      /*Console:WriteLine(er:CallStack).*/
      DEFINE VARIABLE exception AS System.Exception NO-UNDO.
      exception = NEW Elastic.Apm.StackTraceException(er:GetMessage(1), er:CallStack).

/*      Console:WriteLine("STACKTRACE:" + exception:StackTrace).*/
/*      Console:WriteLine("CALLSTACK:" + exception:CallStack).*/

      Agent:CaptureSpanException(exception, er:GetMessage(1), TRUE, ?).
    END CATCH.
    FINALLY:
      Agent:EndSpan().
      Agent:EndTransaction().
      PAUSE 3.
    END FINALLY.

  END METHOD.

  @Test.
  METHOD PUBLIC VOID agentCanLogToApmRaw(  ):

    /*https://www.elastic.co/guide/en/apm/agent/dotnet/current/config-core.html*/
    /*core config*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_NAME", "Enricher").
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_NODE_NAME", "localhost").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_VERSION", "1").*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_ENVIRONMENT", "Development").
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_TRANSACTION_SAMPLE_RATE", "1").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_TRANSACTION_MAX_SPANS", "500").*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_CENTRAL_CONFIG", "false").
    /*System.Environment:SetEnvironmentVariable("ELASTIC_APM_SANITIZE_FIELD_NAMES", "").*/
    /*System.Environment:SetEnvironmentVariable("ELASTIC_APM_GLOBAL_LABELS", "key=value,key=value").*/

    /*Reporter*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVER_URLS", "http://localhost:8200").*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVER_URLS", "http://51qsvr-mic-sv01.qa.dhlparcel.co.uk:8200").
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SECRET_TOKEN", "").*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SECRET_TOKEN", "123h4vg1k23g4fc1k2h3g4fk1234f23jhg423jh4").
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_API_KEY", "").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_VERIFY_SERVER_CERT", "").*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_FLUSH_INTERVAL", "0s"). /*default 10s*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_MAX_BATCH_EVENT_COUNT", "10").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_MAX_QUEUE_EVENT_COUNT", "1000").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_METRICS_INTERVAL", "30s").*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_DISABLE_METRICS", "").*/

    /*Supportability*/
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_LOG_LEVEL", "Error").*//*Critical, Error, Warning, Info, Debug, Trace and None*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_LOG_LEVEL", "Error").

    DEFINE VARIABLE isConfigured AS LOGICAL NO-UNDO.

    Assert:NotNull(Elastic.Apm.Agent:Tracer, "Agent:Tracer").

    theTransaction = Elastic.Apm.Agent:Tracer:StartTransaction("agentCanLogToApmTest", "Method", ?).
    Assert:NotNull(theTransaction, "theTransaction").

    THIS-OBJECT:TestMethod("Testing", 1).

    theTransaction:End().

/*    CATCH er AS Progress.Lang.Error :            */
/*      System.Console:WriteLine(er:GetMessage(1)).*/
/*      System.Console:WriteLine(er:CallStack).    */
/*      Assert:IsEmpty(er:GetMessage(1)).          */
/*    END.                                         */

    /*wait for writes to finish*/
    PAUSE 3.

  END METHOD.

  METHOD PUBLIC CHARACTER TestMethod (inputChar AS CHARACTER, inputInt AS INTEGER):
    Assert:NotNull(theTransaction, "theTransaction").

    DEFINE VARIABLE span AS Elastic.Apm.Api.ISpan NO-UNDO.
    span = theTransaction:StartSpan("test_Apm", "Method", "agentCanLogToApm", "StartSpan").
    Assert:NotNull(span, "span").

    DEFINE VARIABLE capturedStackFrames AS "List<CapturedStackFrame>" NO-UNDO.
    capturedStackFrames = NEW "List<CapturedStackFrame>"().
    Assert:NotNull(capturedStackFrames, "capturedStackFrames").

    DEFINE VARIABLE level AS INTEGER NO-UNDO INITIAL 1.
    DEFINE VARIABLE capturedStackFrame AS CapturedStackFrame NO-UNDO.
    _LEVEL:
    DO WHILE PROGRAM-NAME(level) <> ?:
      capturedStackFrame = NEW CapturedStackFrame().
      Assert:NotNull(capturedStackFrame, "capturedStackFrames").

      DEFINE VARIABLE programName AS CHARACTER NO-UNDO.
      programName = PROGRAM-NAME(level).

      IF programName MATCHES "*pctinit*" THEN DO:
        level = level + 1.
        NEXT _LEVEL.
      END.
      ELSE IF NUM-ENTRIES(programName, " ") < 2 THEN DO:
        capturedStackFrame:Function = "MAIN".
        capturedStackFrame:Module = programName.
      END.
      ELSE DO:
        capturedStackFrame:Function = ENTRY(1, programName, " ").
        capturedStackFrame:Module = SUBSTRING(programName, LENGTH(capturedStackFrame:Function) + 1).
      END.

      /* filename and class */
      IF capturedStackFrame:Module MATCHES "*~~.p"
        OR capturedStackFrame:Module MATCHES "*~~.r"
      THEN DO:
        capturedStackFrame:Filename = capturedStackFrame:Module.
        capturedStackFrame:Module = SUBSTRING(capturedStackFrame:Module, 1, LENGTH(capturedStackFrame:Module) - 2).
      END.
      ELSE DO:
        capturedStackFrame:Filename = capturedStackFrame:Module + ".cls".
      END.
      Assert:NotTrue(capturedStackFrame:Filename MATCHES "*~~.p~~.cls" ).

      capturedStackFrames:Add(capturedStackFrame).
/*      Console:WriteLine("[" + programName + "] -> [" + capturedStackFrame:Filename + "]").*/
      level = level + 1.
    END.

    span:CustomStackFrames = capturedStackFrames.

    span:Labels:Add("inputChar", inputChar).
    span:Labels:Add("inputInt", STRING(inputInt)).


    DEFINE VARIABLE theResult AS CHARACTER NO-UNDO.
    theResult = inputChar + "-" + STRING(inputInt).

    span:Labels:Add("theResult", theResult).
    span:End().
  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    PROPATH = previousPropath.

    /*core config*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_NAME", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_NODE_NAME", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_VERSION", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_ENVIRONMENT", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_TRANSACTION_SAMPLE_RATE", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_TRANSACTION_MAX_SPANS", "").

    /*Reporter*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVER_URLS", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SECRET_TOKEN", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_API_KEY", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_VERIFY_SERVER_CERT", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_FLUSH_INTERVAL", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_MAX_BATCH_EVENT_COUNT", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_MAX_QUEUE_EVENT_COUNT", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_METRICS_INTERVAL", "").
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_DISABLE_METRICS", "").

    /*Supportability*/
    System.Environment:SetEnvironmentVariable("ELASTIC_APM_LOG_LEVEL", "").

  END METHOD.

END CLASS.
