USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.Log:

  DEFINE STATIC VARIABLE propertyDictionary AS IStringKeyedMap NO-UNDO.

  DEFINE PRIVATE STATIC VARIABLE errorLevel AS INTEGER INITIAL 0 NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE warningLevel AS INTEGER INITIAL 1 NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE informationLevel AS INTEGER INITIAL 2 NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE debugLevel AS INTEGER INITIAL 3 NO-UNDO.

  DEFINE PRIVATE STATIC VARIABLE textFormat AS INTEGER INITIAL 0 NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE jsonFormat AS INTEGER INITIAL 1 NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE compactJsonFormat AS INTEGER INITIAL 2 NO-UNDO.

  DEFINE PRIVATE STATIC VARIABLE messageTemplate AS CHARACTER NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE parsedMessage AS CHARACTER NO-UNDO.
  DEFINE PRIVATE STATIC VARIABLE paramMessage AS CHARACTER NO-UNDO.

  DEFINE STATIC PUBLIC PROPERTY TestMode AS LOGICAL INITIAL FALSE NO-UNDO
    GET.
    SET.
    
  DEFINE STATIC PUBLIC PROPERTY LastLogMessage AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE STATIC PUBLIC PROPERTY LastConsoleLog AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE STATIC PUBLIC PROPERTY LastLogManagerLog AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE STATIC PUBLIC PROPERTY LogLevelPrefix AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE STATIC PUBLIC PROPERTY LogToConsole AS LOGICAL INITIAL FALSE NO-UNDO
    GET.
    SET.

  DEFINE STATIC PUBLIC PROPERTY LogToLogManager AS LOGICAL INITIAL TRUE NO-UNDO
    GET.
    SET.

  DEFINE PRIVATE STATIC VARIABLE logFormat AS INTEGER INITIAL 0 NO-UNDO.
  DEFINE STATIC PUBLIC PROPERTY LoggingFormat AS CHARACTER INITIAL "Text" NO-UNDO
    GET:
      CASE logFormat:
        WHEN Log:jsonFormat THEN DO:
          RETURN "Json".
        END.
        WHEN Log:compactJsonFormat THEN DO:
          RETURN "CompactJson".
        END.
        OTHERWISE DO:
          RETURN "Text".
        END.
      END CASE.
    END GET.
    SET (newValue AS CHARACTER):
      CASE newValue:
        WHEN "Json" THEN DO:
          logFormat = Log:jsonFormat.
        END.
        WHEN "CompactJson" THEN DO:
          logFormat = Log:compactJsonFormat.
        END.
        OTHERWISE DO:
          logFormat = Log:textFormat.
        END.
      END CASE.
    END SET.

  DEFINE PRIVATE STATIC VARIABLE minLevel AS INTEGER INITIAL 2 NO-UNDO.
  DEFINE STATIC PUBLIC PROPERTY MinimumLevel AS CHARACTER NO-UNDO
    GET:
      CASE minLevel:
        WHEN Log:errorLevel THEN DO:
          RETURN "Error".
        END.
        WHEN Log:warningLevel THEN DO:
          RETURN "Warning".
        END.
        WHEN Log:debugLevel THEN DO:
          RETURN "Debug".
        END.
        OTHERWISE DO:
          RETURN "Information".
        END.
      END CASE.
    END GET.
    SET (newValue AS CHARACTER):
      CASE newValue:
        WHEN "Error" THEN DO:
          minLevel = Log:errorLevel.
        END.
        WHEN "Warning" THEN DO:
          minLevel = Log:warningLevel.
        END.
        WHEN "Debug" THEN DO:
          minLevel = Log:debugLevel.
        END.
        OTHERWISE DO:
          minLevel = Log:informationLevel.
        END.
      END CASE.
    END SET.


  METHOD PRIVATE STATIC VOID ParseProperties():
      IF NOT VALID-OBJECT(propertyDictionary) THEN DO:
        RETURN.
      END.
  
      DEFINE VARIABLE propertyIterator AS IIterator NO-UNDO.
      propertyIterator = propertyDictionary:EntrySet:Iterator().
      
      _PROPERTIES:
      DO WHILE(propertyIterator:HasNext()):
        DEFINE VARIABLE propertyKey   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE propertyValue AS CHARACTER NO-UNDO.
      
        DEFINE VARIABLE currentProperty AS IMapEntry NO-UNDO.
        currentProperty = CAST(propertyIterator:Next(), IMapEntry).
  
        propertyKey = currentProperty:Key:ToString().
        propertyValue = GetValueForParam(currentProperty:Value).
  
        Log:paramMessage = SUBSTITUTE("&1, '&2': &3", Log:paramMessage, propertyKey, propertyValue). 
      END.
  END METHOD.


  METHOD PRIVATE STATIC VOID LogMessage(logLevel AS CHARACTER):
    DEFINE VARIABLE logMessage AS CHARACTER NO-UNDO.

    /*format the message*/
    IF Log:logFormat = Log:jsonFormat THEN DO:
      logMessage = SUBSTITUTE("~{'@timestamp': '&1', 'level': '&2', 'message': '&3', 'messageTemplate': '&4'&5~}", ISO-DATE(NOW), LogLevelPrefix + logLevel, Log:parsedMessage, Log:messageTemplate, Log:paramMessage).
    END.
    ELSE IF Log:logFormat = Log:compactJsonFormat THEN DO:
      logMessage = SUBSTITUTE("~{'@t': '&1', '@l': '&2', '@m': '&3', '@mt': '&4'&5~}", ISO-DATE(NOW), LogLevelPrefix + logLevel, Log:parsedMessage, Log:messageTemplate, Log:paramMessage).
    END.
    ELSE DO:
      logMessage = Log:parsedMessage.
    END.

    /*save last message for testing*/  
    Log:LastLogMessage = logMessage.

    /*actually log it*/
    IF Log:LogToConsole THEN DO:
      IF TestMode = TRUE THEN DO:
        Log:LastConsoleLog = logMessage.
      END.
      ELSE DO:
        MESSAGE logMessage.
      END.
    END.
    IF Log:LogToLogManager THEN DO:
      IF TestMode = TRUE THEN DO:
        Log:LastLogManagerLog = "[01/02/03@04:05:06.789+0000] P-000001 T-123456789 1 4GL " + STRING(Log:LogLevelPrefix + logLevel, "X(14)") + " " + logMessage.
      END.
      ELSE DO:
        LOG-MANAGER:WRITE-MESSAGE(logMessage, logLevel) NO-ERROR.
      END.
    END.
  END METHOD.

  METHOD PRIVATE STATIC CHARACTER GetValueForParam(param1 AS Progress.Lang.Object):
    DEFINE VARIABLE paramValue AS CHARACTER NO-UNDO.
    
    IF TYPE-OF(param1, OpenEdge.Core.DateTimeHolder) THEN DO:
      DEFINE VARIABLE dateTimeParam AS DATETIME NO-UNDO.
      dateTimeParam = CAST(param1, OpenEdge.Core.DateTimeHolder):Value.
      
      IF dateTimeParam = ? THEN DO:
        paramValue = "null".
      END.
      ELSE DO:
        paramValue = "'" + ISO-DATE(dateTimeParam) + "'".
      END.
    END.
    ELSE IF TYPE-OF(param1, OpenEdge.Core.String) THEN DO:
      paramValue = "'" + REPLACE(param1:ToString(), "~n", "\n") + "'".
      IF paramValue = ? THEN DO:
        paramValue = "null".
      END.
    END.
    ELSE IF TYPE-OF(param1, OpenEdge.Core.LogicalValue) THEN DO:
      DEFINE VARIABLE logicalValueParam AS OpenEdge.Core.LogicalValue NO-UNDO.
      logicalValueParam = CAST(param1, OpenEdge.Core.LogicalValue).

      logicalValueParam:Format = "true/false".
      paramValue = logicalValueParam:ToString().
    END.
    ELSE DO:
      paramValue = param1:ToString().
    END.

    RETURN paramValue.
  END METHOD.

  METHOD PRIVATE STATIC VOID ParseParam(param1 AS Progress.Lang.Object):
    DEFINE VARIABLE paramName AS CHARACTER NO-UNDO.
    DEFINE VARIABLE paramValue AS CHARACTER NO-UNDO.

    DEFINE VARIABLE iStartBrace AS INTEGER NO-UNDO.
    DEFINE VARIABLE iEndBrace AS INTEGER NO-UNDO.

    iStartBrace = INDEX(Log:parsedMessage, "~{").
    iEndBrace = INDEX(Log:parsedMessage, "~}").
    IF iStartBrace > 0
      AND iEndBrace > 0
    THEN DO:
      /*get param name*/
      paramName = SUBSTRING(parsedMessage, iStartBrace + 1, (iEndBrace - iStartBrace) - 1).

      paramValue = GetValueForParam(param1).

      /*replace valuename with value in message*/
      Log:parsedMessage = REPLACE(parsedMessage, SUBSTITUTE("~{&1~}", paramName), REPLACE(paramValue, "'", "")).

      /*add*/
      Log:paramMessage = SUBSTITUTE("&1, '&2': &3", Log:paramMessage, paramName, paramValue). 
    END.
  END METHOD.

  METHOD PRIVATE STATIC VOID InitMessageParse(msg AS CHARACTER):
    Log:messageTemplate = msg.
    /* escape newlines */
    Log:parsedMessage = REPLACE(msg, "~n", "\n").
    Log:paramMessage = "".
  END METHOD.

  /* Error */
  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER):
    Log:InitMessageParse(msg).

    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseParam(param3).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseParam(param3).
    Log:ParseParam(param4).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseParam(param3).
    Log:ParseParam(param4).
    Log:ParseParam(param5).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseParam(param3).
    Log:ParseParam(param4).
    Log:ParseParam(param5).
    Log:ParseParam(param6).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogItAt (logLevel AS CHARACTER, eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    Log:InitMessageParse(msg).

    Log:ParseParam(param1).
    Log:ParseParam(param2).
    Log:ParseParam(param3).
    Log:ParseProperties().

    Log:LogMessage(logLevel).
  END METHOD.

  METHOD STATIC VOID LogIt (logLevel AS CHARACTER, msg AS CHARACTER, propertiesArray AS Progress.Lang.Object EXTENT):
    Log:InitMessageParse(msg).

    DEFINE VARIABLE propertyNum AS INTEGER NO-UNDO.
    DO propertyNum = 1 TO EXTENT(propertiesArray):
      Log:ParseParam(propertiesArray[propertyNum]).
    END.
    Log:ParseProperties().

    Log:LogMessage(logLevel).
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

  METHOD STATIC VOID Error (msg AS CHARACTER, propertiesArray AS Progress.Lang.Object EXTENT):
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
    DEFINE VARIABLE errorMessage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE errorNumber AS INTEGER NO-UNDO.
    DO errorNumber = 1 TO er:NumMessages:
      IF errorNumber > 1 THEN errorMessage = errorMessage + ", ".
      errorMessage = errorMessage + er:GetMessage(errorNumber).
    END.

    IF SESSION:ERROR-STACK-TRACE = TRUE THEN DO:
      Log:Error("ERROR: ~{ErrorMessage~}~n~{ErrorStack~}", NEW OpenEdge.Core.String(errorMessage), NEW OpenEdge.Core.String(er:CallStack)).
    END.
    ELSE DO:
      Log:Error("ERROR: ~{ErrorMessage~}", NEW OpenEdge.Core.String(errorMessage)).
    END.
  END METHOD.

  /* Information */
  METHOD STATIC VOID Information (msg AS CHARACTER):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Information (msg AS CHARACTER, propertiesArray AS Progress.Lang.Object EXTENT):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogIt ("INFO", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogItAt ("INFO", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogItAt ("INFO", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:informationLevel THEN RETURN.
    LogItAt ("INFO", eventTime, msg, param1, param2, param3).
  END METHOD.

  /* Debug */
  METHOD STATIC VOID Debug (msg AS CHARACTER):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Debug (msg AS CHARACTER, propertiesArray AS Progress.Lang.Object EXTENT):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogIt ("DEBUG", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogItAt ("DEBUG", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogItAt ("DEBUG", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID DebugAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:debugLevel THEN RETURN.
    LogItAt ("DEBUG", eventTime, msg, param1, param2, param3).
  END METHOD.

  /* Warning */
  METHOD STATIC VOID Warning (msg AS CHARACTER):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1, param2, param3).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1, param2, param3, param4).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1, param2, param3, param4, param5).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object, param4 AS Progress.Lang.Object, param5 AS Progress.Lang.Object, param6 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, param1, param2, param3, param4, param5, param6).
  END METHOD.

  METHOD STATIC VOID Warning (msg AS CHARACTER, propertiesArray AS Progress.Lang.Object EXTENT):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogIt ("WARN", msg, propertiesArray).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogItAt ("WARN", eventTime, msg, param1).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogItAt ("WARN", eventTime, msg, param1, param2).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, msg AS CHARACTER, param1 AS Progress.Lang.Object, param2 AS Progress.Lang.Object, param3 AS Progress.Lang.Object):
    IF Log:minLevel < Log:warningLevel THEN RETURN.
    LogItAt ("WARN", eventTime, msg, param1, param2, param3).
  END METHOD.


  /* others */

  METHOD STATIC VOID Fatal (msg AS CHARACTER):
    LogIt("FATAL", msg).
  END METHOD.

  METHOD STATIC PUBLIC LOGICAL IsDebugEnabled ():
    RETURN (Log:minLevel = Log:debugLevel).
  END METHOD.

  METHOD STATIC VOID CloseAndFlush ():
    LOG-MANAGER:CLOSE-LOG().
  END METHOD.

  METHOD PUBLIC STATIC VOID ClearData():
    Log:LastLogMessage = "".
    Log:LastConsoleLog = "".
    Log:LastLogManagerLog = "".
    ResetContext().
  END.

  /* properties */

  METHOD STATIC PUBLIC LogProperty PushProperty(contextName AS CHARACTER, contextValue AS Progress.Lang.Object):
    IF NOT VALID-OBJECT(propertyDictionary) THEN DO:
      Log:propertyDictionary = NEW StringKeyedMap().
    END.
  
    propertyDictionary:Put(contextName, contextValue).
    
    RETURN NEW LogProperty(contextName).
  END METHOD.

  METHOD STATIC PUBLIC LogProperty PushProperty(contextName AS CHARACTER, contextValue AS Progress.Lang.Object, destructureObjects AS LOGICAL):
    IF NOT VALID-OBJECT(propertyDictionary) THEN DO:
      Log:propertyDictionary = NEW StringKeyedMap().
    END.

    /* destructure? */
    propertyDictionary:Put(contextName, contextValue).
    
    RETURN NEW LogProperty(contextName).
  END METHOD.

  METHOD STATIC PUBLIC VOID DisposeProperty(contextName AS CHARACTER):
    propertyDictionary:Remove(contextName) NO-ERROR.
  END METHOD.

  METHOD STATIC PUBLIC VOID ResetContext():
    IF VALID-OBJECT(propertyDictionary) THEN DO:
      propertyDictionary:Clear().
    END.
  END METHOD.



END CLASS.
