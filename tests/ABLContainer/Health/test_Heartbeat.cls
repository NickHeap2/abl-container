USING ABLContainer.Health.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Health.test_Heartbeat:

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    Heartbeat:LastHeartbeatTime = ?.
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canWriteAHeartbeat(  ):

    OS-DELETE VALUE(Heartbeat:BeatFileName) NO-ERROR.

    Heartbeat:Beat().

    FILE-INFO:FILENAME = Heartbeat:BeatFileName.
    Assert:IsTrue(FILE-INFO:FULL-PATHNAME <> ?, "Heartbeat file exists").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canWriteAHeartbeatAfterInterval(  ):

    OS-DELETE VALUE(Heartbeat:BeatFileName) NO-ERROR.

    Heartbeat:Beat().

    FILE-INFO:FILENAME = Heartbeat:BeatFileName.
    Assert:IsTrue(FILE-INFO:FULL-PATHNAME <> ?, "Heartbeat file exists").

    OS-DELETE VALUE(Heartbeat:BeatFileName) NO-ERROR.

    Heartbeat:Beat().

    FILE-INFO:FILENAME = Heartbeat:BeatFileName.
    Assert:IsFalse(FILE-INFO:FULL-PATHNAME <> ?, "Heartbeat file exists").

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():

    OS-DELETE VALUE(Heartbeat:BeatFileName) NO-ERROR.

  END METHOD.

END CLASS.