USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.Log:

  DEFINE STATIC VARIABLE propertyDictionary AS IStringStringMap NO-UNDO.

  METHOD STATIC VOID WriteProperties (logLevel AS CHARACTER):
      DEFINE VARIABLE propertyIterator AS IIterator NO-UNDO.
      propertyIterator = propertyDictionary:EntrySet:Iterator().
      
      _PROPERTIES:
      DO WHILE(propertyIterator:HasNext()):
        DEFINE VARIABLE propertyKey   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE propertyValue AS CHARACTER NO-UNDO.
      
        DEFINE VARIABLE currentProperty AS IMapEntry NO-UNDO.
        currentProperty = CAST(propertyIterator:Next(), IMapEntry).
  
        propertyKey = currentProperty:Key:ToString().
        propertyValue = currentProperty:Value:ToString().
  
      END.      
  
      LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("[&1]=[&2]", propertyKey, propertyValue), logLevel).
  END METHOD.

  /* Error */
  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    
    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param3:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param3:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param4:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param3:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param4:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param5:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param3:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param4:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param5:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param6:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE("[" + STRING(eventTime) + "]" + msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE("[" + STRING(eventTime) + "]" + msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LOG-MANAGER:WRITE-MESSAGE("[" + STRING(eventTime) + "]" + msg, logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param1:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param2:ToString(), logLevel).
    LOG-MANAGER:WRITE-MESSAGE(param3:ToString(), logLevel).

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, propertiesArray AS OpenEdge.Core.String EXTENT):
    LOG-MANAGER:WRITE-MESSAGE(msg, logLevel).
    
    DEFINE VARIABLE stringNum AS INTEGER NO-UNDO.

    DO stringNum = 1 TO EXTENT(propertiesArray):
      LOG-MANAGER:WRITE-MESSAGE(propertiesArray[stringNum]:ToString(), logLevel).
    END.

    IF VALID-OBJECT(propertyDictionary) THEN DO:
      WriteProperties(logLevel).
    END.
  END METHOD.

  /* Error */
  METHOD STATIC VOID Error (msg AS CHARACTER):
    LogIt ("ERROR", msg).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    LogIt ("ERROR", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Error (msg AS CHARACTER, propertiesArray AS OpenEdge.Core.String EXTENT):
    LogIt ("ERROR", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID ErrorAt (msg AS CHARACTER, eventTime AS DATETIME, param1 AS Progress.Lang.Object):
    LogItAt ("ERROR", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID ErrorAt (msg AS CHARACTER, eventTime AS DATETIME, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogItAt ("ERROR", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID ErrorAt (msg AS CHARACTER, eventTime AS DATETIME, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogItAt ("ERROR", eventTime, msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Error (er AS Progress.Lang.Error):
    IF SESSION:ERROR-STACK-TRACE = TRUE THEN DO:
      Log:Error("ERROR: ~{ErrorMessage~}~n~{ErrorStack~}", NEW OpenEdge.Core.String(er:GetMessage(1)), NEW OpenEdge.Core.String(er:CallStack)).
    END.
    ELSE DO:
      Log:Error("ERROR: ~{ErrorMessage~}", NEW OpenEdge.Core.String(er:GetMessage(1))).
    END.
  END METHOD.

  /* Information */
  METHOD STATIC VOID Information (msg AS CHARACTER):
    LogIt ("INFO", msg).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    LogIt ("INFO", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, propertiesArray AS OpenEdge.Core.String EXTENT):
    LogIt ("INFO", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogItAt ("INFO", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogItAt ("INFO", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogItAt ("INFO", eventTime, msg, param1, param2, param3).
  END METHOD.

  /* Debug */
  METHOD STATIC VOID Debug (msg AS CHARACTER):
    LogIt ("DEBUG", msg).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    LogIt ("DEBUG", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, propertiesArray AS OpenEdge.Core.String EXTENT):
    LogIt ("DEBUG", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogItAt ("DEBUG", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogItAt ("DEBUG", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogItAt ("DEBUG", eventTime, msg, param1, param2, param3).
  END METHOD.

  /* Warning */
  METHOD STATIC VOID Warning (msg AS CHARACTER):
    LogIt ("WARN", msg).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    LogIt ("WARN", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, propertiesArray AS OpenEdge.Core.String EXTENT):
    LogIt ("WARN", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    LogItAt ("WARN", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    LogItAt ("WARN", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    LogItAt ("WARN", eventTime, msg, param1, param2, param3).
  END METHOD.


  /* others */

  METHOD STATIC VOID Fatal (msg AS CHARACTER):
    LOG-MANAGER:WRITE-MESSAGE(msg, "FATAL").
  END METHOD.

  METHOD STATIC PUBLIC LOGICAL IsDebugEnabled ():
    RETURN TRUE.
  END METHOD.

  METHOD STATIC PUBLIC LOGICAL IsVerboseEnabled ():
    RETURN TRUE.
  END METHOD.

  METHOD STATIC VOID CloseAndFlush ():
    LOG-MANAGER:CLOSE-LOG().
  END METHOD.

  METHOD PUBLIC STATIC VOID ClearData():
  END.

  /* properties */

  METHOD STATIC PUBLIC LogProperty PushProperty(contextName AS CHARACTER, contextValue AS Progress.Lang.Object):
    propertyDictionary:Put(contextName, contextValue:ToString()).
    
    RETURN NEW LogProperty(contextName).
  END METHOD.

  METHOD STATIC PUBLIC LogProperty PushProperty(contextName AS CHARACTER, contextValue AS Progress.Lang.Object, destructureObjects AS LOGICAL):
    /* destructure? */
    propertyDictionary:Put(contextName, contextValue:ToString()).
    
    RETURN NEW LogProperty(contextName).
  END METHOD.

  METHOD STATIC PUBLIC VOID DisposeProperty(contextName AS CHARACTER):
    propertyDictionary:Remove(contextName).
  END METHOD.

  METHOD STATIC PUBLIC VOID ResetContext():
    propertyDictionary:Clear().
  END METHOD.



END CLASS.
