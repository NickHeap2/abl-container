USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.* FROM ASSEMBLY.
USING Serilog.Events.* FROM ASSEMBLY.
USING Serilog.Parsing.* FROM ASSEMBLY.
USING System.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.Log:
  DEFINE STATIC VARIABLE propertiesArray1 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray2 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray3 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray4 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray5 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray6 AS CLASS System.Array NO-UNDO.

  DEFINE STATIC VARIABLE propertyTokenClass AS CLASS Progress.Lang.Class NO-UNDO.
  DEFINE STATIC VARIABLE messageTemplateParser AS CLASS MessageTemplateParser NO-UNDO.

  METHOD STATIC PUBLIC LOGICAL IsDebugEnabled ():
    RETURN Serilog.Log:IsEnabled(LogEventLevel:Debug).
  END METHOD.

  METHOD STATIC PUBLIC LOGICAL IsVerboseEnabled ():
    RETURN Serilog.Log:IsEnabled(LogEventLevel:Verbose).
  END METHOD.

  METHOD STATIC PUBLIC VOID CloseAndFlush ():
    Serilog.Log:CloseAndFlush().
  END METHOD.

  METHOD STATIC PUBLIC System.IDisposable PushProperty(contextName AS CHARACTER, contextValue AS System.Object):
    RETURN Serilog.Context.LogContext:PushProperty(contextName, contextValue, FALSE).
  END METHOD.

  METHOD STATIC PUBLIC System.IDisposable PushProperty(contextName AS CHARACTER, contextValue AS System.Object, destructureObjects AS LOGICAL):
    RETURN Serilog.Context.LogContext:PushProperty(contextName, contextValue, destructureObjects).
  END METHOD.

  METHOD STATIC PUBLIC VOID ResetContext():
    Serilog.Context.LogContext:Reset().
  END METHOD.

  METHOD STATIC VOID Write (eventTime AS DATETIME, level AS LogEventLevel, exception AS Exception, messageTemplateText AS CHARACTER, properties AS System.Array):

    DEFINE VARIABLE eventDateTimeOffset AS DateTimeOffset NO-UNDO.
    eventDateTimeOffset = NEW DateTimeOffset(eventTime).

    IF NOT VALID-OBJECT(messageTemplateParser) THEN DO:
      messageTemplateParser = NEW MessageTemplateParser().
    END.

    DEFINE VARIABLE messageTemplate AS MessageTemplate NO-UNDO.
    messageTemplate = messageTemplateParser:Parse(messageTemplateText).

    DEFINE VARIABLE propertiesList AS CLASS "System.Collections.Generic.List<Serilog.Events.LogEventProperty>" NO-UNDO.
    propertiesList = NEW "System.Collections.Generic.List<Serilog.Events.LogEventProperty>"().

    DEFINE VARIABLE tokensEnumerator AS "System.Collections.Generic.IEnumerator<Serilog.Parsing.MessageTemplateToken>" NO-UNDO.
    tokensEnumerator = messageTemplate:Tokens:GetEnumerator().

    IF NOT VALID-OBJECT(propertyTokenClass) THEN DO:
      propertyTokenClass = GET-CLASS(PropertyToken).
    END.

    DEFINE VARIABLE thisProperty AS INTEGER NO-UNDO.
    thisProperty = 0.
    _TOKENS:
    DO WHILE tokensEnumerator:MoveNext():
      IF (tokensEnumerator:Current:GetClass() <> propertyTokenClass) THEN NEXT _TOKENS.

      DEFINE VARIABLE propertyToken AS PropertyToken NO-UNDO.
      propertyToken = CAST(tokensEnumerator:Current, PropertyToken).
      DEFINE VARIABLE prop AS LogEventProperty NO-UNDO.

      prop = NEW LogEventProperty(propertyToken:PropertyName, NEW ScalarValue(properties:GetValue(thisProperty))).
      propertiesList:Add(prop).

      thisProperty = thisProperty + 1.
    END.

    DEFINE VARIABLE logEvent AS LogEvent NO-UNDO.
    logEvent = NEW LogEvent(eventDateTimeOffset, level, exception, messageTemplate, propertiesList).

    Serilog.Log:Logger:Write(logEvent).

    DELETE OBJECT tokensEnumerator NO-ERROR.
    DELETE OBJECT messageTemplate NO-ERROR.
    DELETE OBJECT propertiesList NO-ERROR.
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue AS System.Object):
    Log:Write(eventTime, LogEventLevel:Warning, ?, messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Log:Write(eventTime, LogEventLevel:Warning, ?, messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD STATIC VOID WarningAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    Log:Write(eventTime, LogEventLevel:Warning, ?, messageTemplate, ToArray3(messageValue1, messageValue2, messageValue3)).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue AS System.Object):
    Log:Write(eventTime, LogEventLevel:Information, ?, messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Log:Write(eventTime, LogEventLevel:Information, ?, messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD STATIC VOID InformationAt (eventTime AS DATETIME, messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    Log:Write(eventTime, LogEventLevel:Information, ?, messageTemplate, ToArray3(messageValue1, messageValue2, messageValue3)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER):
    Serilog.Log:Logger:Information(messageTemplate).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray3(messageValue1, messageValue2, messageValue3)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray4(messageValue1, messageValue2, messageValue3, messageValue4)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object, messageValue5 AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray5(messageValue1, messageValue2, messageValue3, messageValue4, messageValue5)).
  END METHOD.

  METHOD STATIC VOID Information (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object, messageValue5 AS System.Object, messageValue6 AS System.Object):
    Serilog.Log:Logger:Information(messageTemplate, ToArray6(messageValue1, messageValue2, messageValue3, messageValue4, messageValue5, messageValue6)).
  END METHOD.

  METHOD STATIC VOID Error (messageTemplate AS CHARACTER):
    Serilog.Log:Logger:Error(messageTemplate).
  END METHOD.

  METHOD STATIC VOID Error (er AS Progress.Lang.Error):
    IF SESSION:ERROR-STACK-TRACE = TRUE THEN DO:
      Serilog.Log:Logger:Error("ERROR: ~{ErrorMessage~}~n~{ErrorStack~}", ToArray2(BOX(er:GetMessage(1)), BOX(er:CallStack))).
    END.
    ELSE DO:
      Serilog.Log:Logger:Error("ERROR: ~{ErrorMessage~}", ToArray1(BOX(er:GetMessage(1)))).
    END.
  END METHOD.

  METHOD STATIC VOID Error (messageTemplate AS CHARACTER, messageValue AS System.Object):
    Serilog.Log:Logger:Error(messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID Error (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Serilog.Log:Logger:Error(messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD STATIC VOID Debug (messageTemplate AS CHARACTER):
    Serilog.Log:Logger:Debug(messageTemplate).
  END METHOD.

  METHOD STATIC VOID Debug (messageTemplate AS CHARACTER, messageValue AS System.Object):
    Serilog.Log:Logger:Debug(messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID Debug (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Serilog.Log:Logger:Debug(messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD STATIC VOID Debug (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    Serilog.Log:Logger:Debug(messageTemplate, ToArray3(messageValue1, messageValue2, messageValue3)).
  END METHOD.

  METHOD STATIC VOID Debug (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object):
    Serilog.Log:Logger:Debug(messageTemplate, ToArray4(messageValue1, messageValue2, messageValue3, messageValue4)).
  END METHOD.

  METHOD STATIC VOID Warning (messageTemplate AS CHARACTER):
    Serilog.Log:Logger:Warning(messageTemplate).
  END METHOD.

  METHOD STATIC VOID Warning (messageTemplate AS CHARACTER, messageValue AS System.Object):
    Serilog.Log:Logger:Warning(messageTemplate, ToArray1(messageValue)).
  END METHOD.

  METHOD STATIC VOID Warning (messageTemplate AS CHARACTER, messageValue1 AS System.Object, messageValue2 AS System.Object):
    Serilog.Log:Logger:Warning(messageTemplate, ToArray2(messageValue1, messageValue2)).
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray1(messageValue AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray1) THEN DO:
      propertiesArray1 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 1).
    END.
    propertiesArray1:SetValue(messageValue, 0).

    RETURN propertiesArray1.
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray2(messageValue1 AS System.Object, messageValue2 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray2) THEN DO:
      propertiesArray2 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 2).
    END.

    propertiesArray2:SetValue(messageValue1, 0).
    propertiesArray2:SetValue(messageValue2, 1).
    RETURN propertiesArray2.
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray3(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray3) THEN DO:
      propertiesArray3 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 3).
    END.

    propertiesArray3:SetValue(messageValue1, 0).
    propertiesArray3:SetValue(messageValue2, 1).
    propertiesArray3:SetValue(messageValue3, 2).
    RETURN propertiesArray3.
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray4(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray4) THEN DO:
      propertiesArray4 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 4).
    END.

    propertiesArray4:SetValue(messageValue1, 0).
    propertiesArray4:SetValue(messageValue2, 1).
    propertiesArray4:SetValue(messageValue3, 2).
    propertiesArray4:SetValue(messageValue4, 3).
    RETURN propertiesArray4.
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray5(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object, messageValue5 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray5) THEN DO:
      propertiesArray5 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 5).
    END.

    propertiesArray5:SetValue(messageValue1, 0).
    propertiesArray5:SetValue(messageValue2, 1).
    propertiesArray5:SetValue(messageValue3, 2).
    propertiesArray5:SetValue(messageValue4, 3).
    propertiesArray5:SetValue(messageValue5, 4).
    RETURN propertiesArray5.
  END METHOD.

  METHOD PRIVATE STATIC System.Array ToArray6(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object, messageValue5 AS System.Object, messageValue6 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray6) THEN DO:
      propertiesArray6 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 6).
    END.

    propertiesArray6:SetValue(messageValue1, 0).
    propertiesArray6:SetValue(messageValue2, 1).
    propertiesArray6:SetValue(messageValue3, 2).
    propertiesArray6:SetValue(messageValue4, 3).
    propertiesArray6:SetValue(messageValue5, 4).
    propertiesArray6:SetValue(messageValue6, 5).
    RETURN propertiesArray6.
  END METHOD.

  METHOD PUBLIC STATIC VOID ClearData():
    DELETE OBJECT Log:propertiesArray1 NO-ERROR.
    DELETE OBJECT Log:propertiesArray2 NO-ERROR.
    DELETE OBJECT Log:propertiesArray3 NO-ERROR.
    DELETE OBJECT Log:propertiesArray4 NO-ERROR.
    DELETE OBJECT Log:propertiesArray5 NO-ERROR.
    DELETE OBJECT Log:propertiesArray6 NO-ERROR.
  END.

END CLASS.