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
  DYNAMIC-INVOKE("ABLContainer.Bootstrap.Bootstrap", "Start", environmentEnvVar) NO-ERROR.
END.
CATCH er AS Progress.Lang.Error :
  DYNAMIC-INVOKE("ABLContainer.Logging.Log", "Error", "ERROR: (~{ErrorMessage~})", BOX(er:GetMessage(1))) NO-ERROR.
END CATCH.
FINALLY:
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
