USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

CLASS ABLContainer.Configuration.EnvVars:  
  DEFINE STREAM envVarStream.
  
  DEFINE PUBLIC STATIC PROPERTY SystemEnvVars AS IStringStringMap NO-UNDO
    GET.
    SET.
  
  METHOD STATIC VOID ClearEnvVars():
    IF VALID-OBJECT(SystemEnvVars) THEN DO:
      DELETE OBJECT SystemEnvVars NO-ERROR.
    END.
  END METHOD.

  METHOD STATIC CHARACTER GetEnvVar(varName AS CHARACTER):

    DEFINE VARIABLE importString AS CHARACTER FORMAT "X(1000)" NO-UNDO.
    
    INPUT STREAM envVarStream THROUGH VALUE("set " + varName).
    _IMPORT_ENV_VAR:
    REPEAT ON ENDKEY UNDO, LEAVE:
      IMPORT STREAM envVarStream UNFORMATTED importString.
      
      DEFINE VARIABLE envVarName AS CHARACTER NO-UNDO.
      DEFINE VARIABLE envVarValue AS CHARACTER NO-UNDO.
      DEFINE VARIABLE iFirstEquals AS INTEGER NO-UNDO.
      
      iFirstEquals = INDEX(importString, "=").
      IF iFirstEquals <= 0 THEN DO:
/*          MESSAGE "SKIPPING VALUE " + importString.*/
          NEXT _IMPORT_ENV_VAR.        
      END.

      envVarName = SUBSTRING(importString, 1, iFirstEquals - 1).
      envVarValue = SUBSTRING(importString, iFirstEquals + 1).
      
    END. /*_IMPORT_ENV_VAR*/
    INPUT STREAM envVarStream CLOSE.

    RETURN envVarValue.
  END METHOD.

  METHOD STATIC VOID GetEnvVars(filter AS CHARACTER):
    SystemEnvVars = NEW StringStringMap().
  
    DEFINE VARIABLE importString AS CHARACTER FORMAT "X(1000)" NO-UNDO.
    
    INPUT STREAM envVarStream THROUGH VALUE("set").
    _IMPORT_ENV_VAR:
    REPEAT ON ENDKEY UNDO, LEAVE:
      IMPORT STREAM envVarStream UNFORMATTED importString.
      
      DEFINE VARIABLE envVarName AS CHARACTER NO-UNDO.
      DEFINE VARIABLE envVarValue AS CHARACTER NO-UNDO.
      DEFINE VARIABLE iFirstEquals AS INTEGER NO-UNDO.
      
      
      
      iFirstEquals = INDEX(importString, "=").
      IF iFirstEquals <= 0 THEN DO:
/*          MESSAGE "SKIPPING VALUE " + importString.*/
          NEXT _IMPORT_ENV_VAR.        
      END.

      envVarName = SUBSTRING(importString, 1, iFirstEquals - 1).
      envVarValue = SUBSTRING(importString, iFirstEquals + 1).

      /* are we filtering out values? */
      IF filter <> "" THEN DO:
        IF NOT envVarName MATCHES filter THEN DO:
/*          MESSAGE envVarName + " DOESN'T MATCH FILTER " + filter.*/
          NEXT _IMPORT_ENV_VAR.
        END.
      END.

/*      MESSAGE "ADDING " + envVarName + ", " + envVarValue.*/
      SystemEnvVars:PUT(envVarName, envVarValue).
      
    END. /*_IMPORT_ENV_VAR*/
    INPUT STREAM envVarStream CLOSE.
  END METHOD.

END CLASS.