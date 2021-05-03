USING ABLContainer.Apm.* FROM PROPATH.
/*USING Elastic.Apm.Api.* FROM ASSEMBLY.*/
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Apm.Agent:
/*                                                                                                                                                                             */
/*  DEFINE PRIVATE STATIC VARIABLE TransactionStack AS "Stack<ITransaction>" NO-UNDO.                                                                                          */
/*  DEFINE PUBLIC STATIC PROPERTY CurrentTransaction AS ITransaction NO-UNDO                                                                                                   */
/*  GET.                                                                                                                                                                       */
/*  SET.                                                                                                                                                                       */
/*                                                                                                                                                                             */
/*  DEFINE PRIVATE STATIC VARIABLE SpanStack AS "Stack<ISpan>" NO-UNDO.                                                                                                        */
/*  DEFINE PUBLIC STATIC PROPERTY CurrentSpan AS ISpan NO-UNDO                                                                                                                 */
/*  GET.                                                                                                                                                                       */
/*  SET.                                                                                                                                                                       */
/*                                                                                                                                                                             */
/*  DEFINE PUBLIC STATIC PROPERTY Environment AS CHARACTER NO-UNDO                                                                                                             */
/*  GET.                                                                                                                                                                       */
/*  SET(INPUT environment AS CHARACTER):                                                                                                                                       */
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_ENVIRONMENT", environment).                                                                                       */
/*  END SET.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*  DEFINE PUBLIC STATIC PROPERTY FlushInterval AS CHARACTER NO-UNDO                                                                                                           */
/*  GET.                                                                                                                                                                       */
/*  SET(INPUT flushInterval AS CHARACTER):                                                                                                                                     */
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_FLUSH_INTERVAL", flushInterval). /*default 10s*/                                                                  */
/*  END SET.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*  DEFINE PUBLIC STATIC PROPERTY LogLevel AS CHARACTER NO-UNDO                                                                                                                */
/*  GET.                                                                                                                                                                       */
/*  SET(INPUT logLevel AS CHARACTER):                                                                                                                                          */
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_LOG_LEVEL", logLevel).                                                                                            */
/*  END SET.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*  DEFINE PUBLIC STATIC PROPERTY ServiceName AS CHARACTER NO-UNDO                                                                                                             */
/*  GET.                                                                                                                                                                       */
/*  SET(INPUT serviceName AS CHARACTER):                                                                                                                                       */
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_SERVICE_NAME", serviceName).                                                                                      */
/*  END SET.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*  DEFINE PUBLIC STATIC PROPERTY UseCentralConfig AS LOGICAL NO-UNDO                                                                                                          */
/*  GET.                                                                                                                                                                       */
/*  SET(INPUT useCentralConfig AS LOGICAL):                                                                                                                                    */
/*    System.Environment:SetEnvironmentVariable("ELASTIC_APM_CENTRAL_CONFIG", STRING(useCentralConfig, "True/False")).                                                         */
/*  END SET.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID CaptureSpanError(theMessage AS CHARACTER, culprit AS CHARACTER): /*, frames AS CLASS "System.Diagnostics.StackFrame[]", parentId AS CHARACTER):*/*/
/*    Agent:CurrentSpan:CaptureError(theMessage, culprit, ?, ?).                                                                                                               */
/*  END.                                                                                                                                                                       */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID CaptureSpanException(exception AS System.Exception, culprit AS CHARACTER, isHandled AS LOGICAL, parentId AS CHARACTER):                          */
/*    Agent:CurrentSpan:CaptureException(exception, culprit, isHandled, parentId).                                                                                             */
/*  END.                                                                                                                                                                       */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID EndSpan():                                                                                                                                       */
/*    IF NOT VALID-OBJECT(Agent:CurrentSpan) THEN DO:                                                                                                                          */
/*      RETURN.                                                                                                                                                                */
/*    END.                                                                                                                                                                     */
/*                                                                                                                                                                             */
/*    Agent:CurrentSpan:CustomStackFrames = Agent:GetStackFrames(2).                                                                                                           */
/*    Agent:CurrentSpan:End().                                                                                                                                                 */
/*    IF SpanStack:Count > 0 THEN DO:                                                                                                                                          */
/*      Agent:CurrentSpan = SpanStack:Pop().                                                                                                                                   */
/*    END.                                                                                                                                                                     */
/*    ELSE DO:                                                                                                                                                                 */
/*      Agent:CurrentSpan = ?.                                                                                                                                                 */
/*    END.                                                                                                                                                                     */
/*  END METHOD.                                                                                                                                                                */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID EndTransaction():                                                                                                                                */
/*    IF NOT VALID-OBJECT(Agent:CurrentTransaction) THEN DO:                                                                                                                   */
/*      RETURN.                                                                                                                                                                */
/*    END.                                                                                                                                                                     */
/*                                                                                                                                                                             */
/*    Agent:CurrentTransaction:End().                                                                                                                                          */
/*    IF TransactionStack:Count > 0 THEN DO:                                                                                                                                   */
/*      Agent:CurrentTransaction = TransactionStack:Pop().                                                                                                                     */
/*    END.                                                                                                                                                                     */
/*    ELSE DO:                                                                                                                                                                 */
/*      Agent:CurrentTransaction = ?.                                                                                                                                          */
/*    END.                                                                                                                                                                     */
/*  END METHOD.                                                                                                                                                                */
/*                                                                                                                                                                             */
/*  METHOD PRIVATE STATIC "List<CapturedStackFrame>" GetStackFramesFromError(dropFrames AS INTEGER):                                                                           */
/*    DEFINE VARIABLE cCallStack AS CHARACTER NO-UNDO.                                                                                                                         */
/*    DEFINE VARIABLE orgStackTrace AS LOGICAL {&API-LOGICAL-FORMAT} NO-UNDO.                                                                                                  */
/*    orgStackTrace = SESSION:ERROR-STACK-TRACE.                                                                                                                               */
/*                                                                                                                                                                             */
/*    SESSION:ERROR-STACK-TRACE = TRUE.                                                                                                                                        */
/*    UNDO, THROW NEW AppError("Throw to get error":U, 0).                                                                                                                     */
/*    CATCH e AS Progress.Lang.Error:                                                                                                                                          */
/*      DEFINE VARIABLE capturedStackFrames AS "List<CapturedStackFrame>" NO-UNDO.                                                                                             */
/*      capturedStackFrames = NEW "List<CapturedStackFrame>"().                                                                                                                */
/*                                                                                                                                                                             */
/*      DEFINE VARIABLE level AS INTEGER NO-UNDO.                                                                                                                              */
/*      DEFINE VARIABLE capturedStackFrame AS CapturedStackFrame NO-UNDO.                                                                                                      */
/*                                                                                                                                                                             */
/*      level = 1 + dropFrames.                                                                                                                                                */
/*      _LEVEL:                                                                                                                                                                */
/*      DO WHILE PROGRAM-NAME(level) <> ?:                                                                                                                                     */
/*        capturedStackFrame = NEW CapturedStackFrame().                                                                                                                       */
/*                                                                                                                                                                             */
/*        DEFINE VARIABLE programName AS CHARACTER NO-UNDO.                                                                                                                    */
/*        programName = PROGRAM-NAME(level).                                                                                                                                   */
/*                                                                                                                                                                             */
/*        IF programName MATCHES "*pctinit*" THEN DO:                                                                                                                          */
/*          level = level + 1.                                                                                                                                                 */
/*          NEXT _LEVEL.                                                                                                                                                       */
/*        END.                                                                                                                                                                 */
/*        ELSE IF NUM-ENTRIES(programName, " ") < 2 THEN DO:                                                                                                                   */
/*          capturedStackFrame:Function = "MAIN".                                                                                                                              */
/*          capturedStackFrame:Module = programName.                                                                                                                           */
/*        END.                                                                                                                                                                 */
/*        ELSE DO:                                                                                                                                                             */
/*          capturedStackFrame:Function = ENTRY(1, programName, " ").                                                                                                          */
/*          capturedStackFrame:Module = SUBSTRING(programName, LENGTH(capturedStackFrame:Function) + 1).                                                                       */
/*        END.                                                                                                                                                                 */
/*                                                                                                                                                                             */
/*        /* filename and class */                                                                                                                                             */
/*        IF capturedStackFrame:Module MATCHES "*~~.p"                                                                                                                         */
/*          OR capturedStackFrame:Module MATCHES "*~~.r"                                                                                                                       */
/*        THEN DO:                                                                                                                                                             */
/*          capturedStackFrame:Filename = capturedStackFrame:Module.                                                                                                           */
/*          capturedStackFrame:Module = SUBSTRING(capturedStackFrame:Module, 1, LENGTH(capturedStackFrame:Module) - 2).                                                        */
/*        END.                                                                                                                                                                 */
/*        ELSE DO:                                                                                                                                                             */
/*          capturedStackFrame:Filename = capturedStackFrame:Module + ".cls".                                                                                                  */
/*        END.                                                                                                                                                                 */
/*                                                                                                                                                                             */
/*        capturedStackFrames:Add(capturedStackFrame).                                                                                                                         */
/*        level = level + 1.                                                                                                                                                   */
/*  /*      Console:WriteLine("[" + programName + "] -> [" + capturedStackFrame:Filename + "]").*/                                                                             */
/*      END.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*      RETURN capturedStackFrames.                                                                                                                                            */
/*    END CATCH.                                                                                                                                                               */
/*    FINALLY:                                                                                                                                                                 */
/*      SESSION:ERROR-STACK-TRACE = orgStackTrace.                                                                                                                             */
/*    END FINALLY.                                                                                                                                                             */
/*  END METHOD.                                                                                                                                                                */
/*                                                                                                                                                                             */
/*  METHOD PRIVATE STATIC "List<CapturedStackFrame>" GetStackFrames(dropFrames AS INTEGER):                                                                                    */
/*    DEFINE VARIABLE capturedStackFrames AS "List<CapturedStackFrame>" NO-UNDO.                                                                                               */
/*    capturedStackFrames = NEW "List<CapturedStackFrame>"().                                                                                                                  */
/*                                                                                                                                                                             */
/*    DEFINE VARIABLE level AS INTEGER NO-UNDO.                                                                                                                                */
/*    DEFINE VARIABLE capturedStackFrame AS CapturedStackFrame NO-UNDO.                                                                                                        */
/*                                                                                                                                                                             */
/*    level = 1 + dropFrames.                                                                                                                                                  */
/*    _LEVEL:                                                                                                                                                                  */
/*    DO WHILE PROGRAM-NAME(level) <> ?:                                                                                                                                       */
/*      capturedStackFrame = NEW CapturedStackFrame().                                                                                                                         */
/*                                                                                                                                                                             */
/*      DEFINE VARIABLE programName AS CHARACTER NO-UNDO.                                                                                                                      */
/*      programName = PROGRAM-NAME(level).                                                                                                                                     */
/*                                                                                                                                                                             */
/*      IF programName MATCHES "*pctinit*" THEN DO:                                                                                                                            */
/*        level = level + 1.                                                                                                                                                   */
/*        NEXT _LEVEL.                                                                                                                                                         */
/*      END.                                                                                                                                                                   */
/*      ELSE IF NUM-ENTRIES(programName, " ") < 2 THEN DO:                                                                                                                     */
/*        capturedStackFrame:Function = "MAIN".                                                                                                                                */
/*        capturedStackFrame:Module = programName.                                                                                                                             */
/*      END.                                                                                                                                                                   */
/*      ELSE DO:                                                                                                                                                               */
/*        capturedStackFrame:Function = ENTRY(1, programName, " ").                                                                                                            */
/*        capturedStackFrame:Module = SUBSTRING(programName, LENGTH(capturedStackFrame:Function) + 1).                                                                         */
/*      END.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*      /* filename and class */                                                                                                                                               */
/*      IF capturedStackFrame:Module MATCHES "*~~.p"                                                                                                                           */
/*        OR capturedStackFrame:Module MATCHES "*~~.r"                                                                                                                         */
/*      THEN DO:                                                                                                                                                               */
/*        capturedStackFrame:Filename = capturedStackFrame:Module.                                                                                                             */
/*        capturedStackFrame:Module = SUBSTRING(capturedStackFrame:Module, 1, LENGTH(capturedStackFrame:Module) - 2).                                                          */
/*      END.                                                                                                                                                                   */
/*      ELSE DO:                                                                                                                                                               */
/*        capturedStackFrame:Filename = capturedStackFrame:Module + ".cls".                                                                                                    */
/*      END.                                                                                                                                                                   */
/*                                                                                                                                                                             */
/*      capturedStackFrames:Add(capturedStackFrame).                                                                                                                           */
/*      level = level + 1.                                                                                                                                                     */
/*/*      Console:WriteLine("[" + programName + "] -> [" + capturedStackFrame:Filename + "]").*/                                                                               */
/*    END.                                                                                                                                                                     */
/*                                                                                                                                                                             */
/*    RETURN capturedStackFrames.                                                                                                                                              */
/*  END.                                                                                                                                                                       */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID StartSpan(name AS CHARACTER, type AS CHARACTER, subType AS CHARACTER, action AS CHARACTER):                                                      */
/*    IF NOT VALID-OBJECT(SpanStack) THEN DO:                                                                                                                                  */
/*      SpanStack = NEW "Stack<ISpan>"().                                                                                                                                      */
/*    END.                                                                                                                                                                     */
/*                                                                                                                                                                             */
/*    Agent:SpanStack:Push(Agent:CurrentSpan).                                                                                                                                 */
/*    Agent:CurrentSpan = Agent:CurrentTransaction:StartSpan(name, type, subType, action).                                                                                     */
/*  END METHOD.                                                                                                                                                                */
/*                                                                                                                                                                             */
/*  METHOD PUBLIC STATIC VOID StartTransaction(name AS CHARACTER, type AS CHARACTER):                                                                                          */
/*    IF NOT VALID-OBJECT(TransactionStack) THEN DO:                                                                                                                           */
/*      TransactionStack = NEW "Stack<ITransaction>"().                                                                                                                        */
/*    END.                                                                                                                                                                     */
/*                                                                                                                                                                             */
/*    Agent:TransactionStack:Push(Agent:CurrentTransaction).                                                                                                                   */
/*    Agent:CurrentTransaction = Elastic.Apm.Agent:Tracer:StartTransaction(name, type, ?).                                                                                     */
/*  END METHOD.                                                                                                                                                                */
/*                                                                                                                                                                             */
/*                                                                                                                                                                             */
END CLASS.