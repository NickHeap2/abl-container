/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

SESSION:ERROR-STACK-TRACE=YES.

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */

RUN ClearPropath.
DEFINE VARIABLE propathEnvVar AS CHARACTER NO-UNDO.
DEFINE VARIABLE environmentEnvVar AS CHARACTER NO-UNDO.

propathEnvVar = OS-GETENV("BOOTSTRAP_PROPATH").
IF propathEnvVar = ""
  OR propathEnvVar = ?
THEN DO:
  propathEnvVar = "ablcontainer/ABLContainer.pl".
END.

environmentEnvVar = OS-GETENV("OPENEDGE_ENVIRONMENT").
IF environmentEnvVar = ""
  OR environmentEnvVar = ?
THEN DO:
  environmentEnvVar = "Production".
END.

RUN SetPropath(propathEnvVar).

DO ON STOP UNDO, LEAVE
   ON ERROR UNDO, LEAVE:
  LOG-MANAGER:WRITE-MESSAGE("Running...", "INFO").
  DYNAMIC-INVOKE("ABLContainer.Bootstrap.Bootstrap", "Start", environmentEnvVar).
END.
CATCH er AS Progress.Lang.Error :
  DEFINE VARIABLE errorNumber AS INTEGER NO-UNDO.
  DO errorNumber = 1 TO er:NumMessages:
    LOG-MANAGER:WRITE-MESSAGE( er:GetMessage(errorNumber), "ERROR").
    DYNAMIC-INVOKE("ABLContainer.Logging.Log", "Error", "ERROR: (~{ErrorMessage~})", NEW OpenEdge.Core.String(er:GetMessage(errorNumber))) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      LOG-MANAGER:WRITE-MESSAGE(ERROR-STATUS:GET-MESSAGE(errorNumber), "ERROR").
    END.
  END.
  
END CATCH.
FINALLY:
  LOG-MANAGER:WRITE-MESSAGE("Closing and flushing", "INFO").
  DYNAMIC-INVOKE("ABLContainer.Logging.Log", "CloseAndFlush") NO-ERROR.
  QUIT.
END FINALLY.

/* ***************************  Procedures  *************************** */

/* **********************  Internal Procedures  *********************** */

PROCEDURE ClearPropath:
  SESSION:BASE-ADE = "".
  PROPATH = "".
END PROCEDURE.

PROCEDURE SetPropath:
  DEFINE INPUT PARAMETER propathValue AS CHARACTER NO-UNDO.

  PROPATH = propathValue.
END PROCEDURE.
