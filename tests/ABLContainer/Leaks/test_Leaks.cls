USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.Performance.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Events.* FROM ASSEMBLY.
USING System.Environment.* FROM ASSEMBLY.
USING System.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Leaks.test_Leaks:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    SESSION:ERROR-STACK-TRACE = TRUE.

    previousPropath = PROPATH.

    Log:ClearData().

/*    TestFormatter:SaveLastEvents = FALSE.*/
/*    TestLogger:CreateLogger(THIS-OBJECT).*/
/*    TestFormatter:ClearLastMessage().    */

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckGetMemoryDoesNotLeak(  ):

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").

    DEFINE VARIABLE initialHandleCount AS INTEGER NO-UNDO.
    initialHandleCount = PerformanceCounts:GetHandles().

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    THIS-OBJECT:GarbageCollect().


    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE finalHandleCount AS INTEGER NO-UNDO.
    finalHandleCount = PerformanceCounts:GetHandles().

    Assert:IsTrue(finalHandleCount <= initialHandleCount, SUBSTITUTE("Final handle count &1 is <= initial handle count &2", finalHandleCount, initialHandleCount) ).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).
/*    Assert:Equals(initialMemoryCount, finalMemoryCount).*/

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogWithoutMemoryLeak(  ):

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    Log:Information("TEST LEAK").

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.
    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogUsingAPropertyArray(  ):
    THIS-OBJECT:GarbageCollect().

    /* set log properties */
    DEFINE VARIABLE propertiesArray AS CLASS System.Array NO-UNDO.
    propertiesArray = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 11).

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

/*    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(TODAY), 0).*/
    propertiesArray:SetValue(NEW OpenEdge.Core.Decimal(123123 / 2), 0).
/*    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(123123), 0).*/
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(123241444124), 1).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(1), 2).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(12), 3).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(123), 4).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(555), 5).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(123233), 6).
/*    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(123233 / 1000), 7).*/
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(1000), 7).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(456565), 8).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(8888), 9).
    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(1000), 10).
/*    propertiesArray:SetValue(NEW OpenEdge.Core.Integer(8888 / 1000), 10).*/

/*    Log:Information(SUBSTITUTE("Processed Id: ~{MessageId~} &1Key: ~{&1Key~} ModifiedDate: ~{ModifiedDate~} Partition: ~{MessagePartition~} (Found in ~{FoundMs~}ms, Lag is ~{ProcessingLag~}ms), built in ~{PayloadDurationMs~}ms (~{PayloadDurationS~}s) with a size of ~{PayloadSize~}bytes, sent in ~{KafkaDurationMs~}ms (~{KafkaDurationS~}s).", "TestEvent"), propertiesArray).*/

/*    DEFINE VARIABLE obj AS System.Object NO-UNDO.*/
/*    obj = propertiesArray:GetValue(0).           */
/*    DELETE OBJECT obj NO-ERROR.                  */

    DELETE OBJECT propertiesArray.

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.
    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canPushPropertyWithoutMemoryLeak(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK").
    testProperty:Dispose().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.

    THIS-OBJECT:GarbageCollect().

    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    testProperty = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Log:Information("TEST LEAK 1").
    testProperty:Dispose().
/*    DELETE OBJECT testProperty.*/
/*    testProperty = ?.          */

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canPushPropertyAndLogLotsWithoutMemoryLeak(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE logLoops AS INTEGER NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK").
    testProperty:Dispose().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.


    THIS-OBJECT:GarbageCollect().

    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    testProperty = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).


    DO logLoops = 1 TO 1000:
      Log:Information("TEST LEAK 1").
    END.

    testProperty:Dispose().
/*    DELETE OBJECT testProperty.*/
/*    testProperty = ?.          */

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canPushPropertiesWithoutMemoryLeak(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK").
    testProperty:Dispose().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.

    THIS-OBJECT:GarbageCollect().

    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    testProperty = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Log:Information("TEST LEAK 1").
    testProperty:Dispose().
    DELETE OBJECT testProperty.
    testProperty = ?.

/*    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.                 */
/*    DEFINE VARIABLE success AS LOGICAL NO-UNDO.                                                            */
/*    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).*/
/*                                                                                                           */
/*    Assert:Equals(TRUE, success).                                                                          */
/*    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).                                     */

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName2", NEW OpenEdge.Core.String("TestValue2")).
    Log:Information("TEST LEAK 2").
    testProperty:Dispose().
    DELETE OBJECT testProperty.
    testProperty = ?.

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName3", NEW OpenEdge.Core.String("TestValue3")).
    Log:Information("TEST LEAK 3").
    testProperty:Dispose().
    DELETE OBJECT testProperty.
    testProperty = ?.

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName4", NEW OpenEdge.Core.String("TestValue4")).
    Log:Information("TEST LEAK 4").
    testProperty:Dispose().
    DELETE OBJECT testProperty.
    testProperty = ?.

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName5", NEW OpenEdge.Core.String("TestValue5")).
    Log:Information("TEST LEAK 5").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName6", NEW OpenEdge.Core.String("TestValue6")).
    Log:Information("TEST LEAK 6").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName7", NEW OpenEdge.Core.String("TestValue7")).
    Log:Information("TEST LEAK 7").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName8", NEW OpenEdge.Core.String("TestValue8")).
    Log:Information("TEST LEAK 8").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).
    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

    testProperty = Log:PushProperty("TestName9", NEW OpenEdge.Core.String("TestValue9")).
    Log:Information("TEST LEAK 9").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canPushNestedPropertiesWithoutMemoryLeak(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty1 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty2 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty3 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty4 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty5 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty6 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty7 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty8 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty9 AS System.IDisposable NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK ~{TestName~}").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    testProperty1 = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Log:Information("TEST LEAK 1").
    testProperty2 = Log:PushProperty("TestName2", NEW OpenEdge.Core.String("TestValue2")).
    Log:Information("TEST LEAK 2").
    testProperty3 = Log:PushProperty("TestName3", NEW OpenEdge.Core.String("TestValue3")).
    Log:Information("TEST LEAK 3").
    testProperty4 = Log:PushProperty("TestName4", NEW OpenEdge.Core.String("TestValue4")).
    Log:Information("TEST LEAK 4").
    testProperty5 = Log:PushProperty("TestName5", NEW OpenEdge.Core.String("TestValue5")).
    Log:Information("TEST LEAK 5").
    testProperty6 = Log:PushProperty("TestName6", NEW OpenEdge.Core.String("TestValue6")).
    Log:Information("TEST LEAK 6").
    testProperty7 = Log:PushProperty("TestName7", NEW OpenEdge.Core.String("TestValue7")).
    Log:Information("TEST LEAK 7").
    testProperty8 = Log:PushProperty("TestName8", NEW OpenEdge.Core.String("TestValue8")).
    Log:Information("TEST LEAK 8").
    testProperty9 = Log:PushProperty("TestName9", NEW OpenEdge.Core.String("TestValue9")).
    Log:Information("TEST LEAK 9").

    testProperty9:Dispose().
    DELETE OBJECT testProperty9.
    testProperty8:Dispose().
    DELETE OBJECT testProperty8.
    testProperty7:Dispose().
    DELETE OBJECT testProperty7.
    testProperty6:Dispose().
    DELETE OBJECT testProperty6.
    testProperty5:Dispose().
    DELETE OBJECT testProperty5.
    testProperty4:Dispose().
    DELETE OBJECT testProperty4.
    testProperty3:Dispose().
    DELETE OBJECT testProperty3.
    testProperty2:Dispose().
    DELETE OBJECT testProperty2.
    testProperty1:Dispose().
    DELETE OBJECT testProperty1.

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.
    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canRemoveProperty(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty1 AS System.IDisposable NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK ~{TestName~}").
    testProperty:Dispose().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.

    THIS-OBJECT:GarbageCollect().

    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).

    testProperty1 = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Assert:IsTrue(VALID-OBJECT(testProperty1)).

    Log:Information("TEST LEAK 1").

/*    DEFINE VARIABLE logEventPropertyValue AS Serilog.Events.LogEventPropertyValue NO-UNDO.                 */
/*    DEFINE VARIABLE success AS LOGICAL NO-UNDO.                                                            */
/*    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).*/
/*    Assert:IsTrue(success).                                                                                */
/*    Assert:Equals("~"TestValue1~"", logEventPropertyValue:ToString()).                                     */

    testProperty1:Dispose().
    testProperty1 = ?.
    Assert:IsFalse(VALID-OBJECT(testProperty1)).

    Log:Information("TEST LEAK 1 WITHOUT VALUE").

/*    success = TestFormatter:LastLogEvent:Properties:TryGetValue("TestName1", OUTPUT logEventPropertyValue).*/
/*    Assert:IsFalse(success).                                                                               */

    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.


  @Test.
  METHOD PUBLIC VOID canClearDownDisposables(  ):
    DEFINE VARIABLE testProperty AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty1 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty2 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty3 AS System.IDisposable NO-UNDO.
    DEFINE VARIABLE testProperty4 AS System.IDisposable NO-UNDO.

    /* initial calls to setup base memory footprint */
    Log:Information("TEST LEAK").
    testProperty = Log:PushProperty("TestName", NEW OpenEdge.Core.String("TestValue")).
    Log:Information("TEST LEAK ~{TestName~}").
    testProperty:Dispose().

    THIS-OBJECT:GarbageCollect().

    DEFINE VARIABLE initialMemoryCount AS DECIMAL NO-UNDO.
    initialMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(initialMemoryCount).



    testProperty1 = Log:PushProperty("TestName1", NEW OpenEdge.Core.String("TestValue1")).
    Assert:IsTrue(VALID-OBJECT(testProperty1)).
    Log:Information("TEST LEAK 1").
    testProperty1:Dispose().
    testProperty1 = ?.
    Assert:IsFalse(VALID-OBJECT(testProperty1)).

    testProperty2 = Log:PushProperty("TestName2", NEW OpenEdge.Core.String("TestValue2")).
    Assert:IsTrue(VALID-OBJECT(testProperty2)).
    Log:Information("TEST LEAK 2").
    testProperty2:Dispose().
    testProperty2 = ?.
    Assert:IsFalse(VALID-OBJECT(testProperty2)).

    testProperty3 = Log:PushProperty("TestName3", NEW OpenEdge.Core.String("TestValue3")).
    Assert:IsTrue(VALID-OBJECT(testProperty3)).
    Log:Information("TEST LEAK 3").
    testProperty3:Dispose().
    testProperty3 = ?.
    Assert:IsFalse(VALID-OBJECT(testProperty3)).

    testProperty4 = Log:PushProperty("TestName4", NEW OpenEdge.Core.String("TestValue4")).
    Assert:IsTrue(VALID-OBJECT(testProperty4)).
    Log:Information("TEST LEAK 4").
    testProperty4:Dispose().
    testProperty4 = ?.
    Assert:IsFalse(VALID-OBJECT(testProperty4)).



    DEFINE VARIABLE finalMemoryCount AS DECIMAL NO-UNDO.

    THIS-OBJECT:GarbageCollect().

    finalMemoryCount = PerformanceCounts:GetMemory().
    Assert:NotZero(finalMemoryCount).

    Assert:IsTrue(finalMemoryCount <= initialMemoryCount, SUBSTITUTE("Final memory &1 is <= initial memory &2", finalMemoryCount, initialMemoryCount) ).

  END METHOD.



  METHOD PUBLIC VOID GarbageCollect( ):
    GC:Collect().
    GC:WaitForPendingFinalizers().
    GC:Collect().
  END.



END CLASS.
