USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Health.Heartbeat:
  DEFINE STREAM beatStream.

  DEFINE PUBLIC STATIC PROPERTY IntervalMinutes AS INTEGER INITIAL 2 NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY BeatFileName AS CHARACTER INITIAL "heartbeat.txt" NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY LastHeartbeatTime AS INT64 INITIAL ? NO-UNDO
    GET.
    SET.

  METHOD PUBLIC STATIC VOID Beat():
    DEFINE VARIABLE currentElapsedTime AS INT64 NO-UNDO.

    currentElapsedTime = ETIME.
    /* do we need to write the heartbeat? */
    IF LastHeartbeatTime = ?
      OR currentElapsedTime - lastHeartbeatTime > (IntervalMinutes * 60 * 1000)
    THEN DO:
      LastHeartbeatTime = currentElapsedTime.

      OUTPUT STREAM beatStream TO VALUE(BeatFileName).
      PUT STREAM beatStream UNFORMATTED ISO-DATE(NOW).
      OUTPUT STREAM beatStream CLOSE.
    END.
  END METHOD.

END CLASS.
