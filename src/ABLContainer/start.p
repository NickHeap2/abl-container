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

DYNAMIC-INVOKE("ABLContainer.Bootstrap.Bootstrap", "Start", environmentEnvVar).

QUIT.

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
