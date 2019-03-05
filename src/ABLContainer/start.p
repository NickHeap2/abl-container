/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

SESSION:ERROR-STACK-TRACE=YES.

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */

RUN ClearPropath.
DEFINE VARIABLE propathEnvVar AS CHARACTER NO-UNDO.
propathEnvVar = OS-GETENV("BOOTSTRAP_PROPATH").
RUN SetPropath(propathEnvVar).

DYNAMIC-INVOKE("ABLContainer.Bootstrap.Bootstrap", "Start").

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
