using ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.Log: 
  DEFINE STATIC VARIABLE propertiesArray1 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray2 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray3 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray4 AS CLASS System.Array NO-UNDO.
  DEFINE STATIC VARIABLE propertiesArray5 AS CLASS System.Array NO-UNDO.

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

  METHOD STATIC System.Array ToArray1(messageValue AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray1) THEN DO:
      propertiesArray1 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 1).
    END.
    propertiesArray1:SetValue(messageValue, 0).

    RETURN propertiesArray1.
  END METHOD.

  METHOD STATIC System.Array ToArray2(messageValue1 AS System.Object, messageValue2 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray2) THEN DO:
      propertiesArray2 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 2).
    END.

    propertiesArray2:SetValue(messageValue1, 0).
    propertiesArray2:SetValue(messageValue2, 1).
    RETURN propertiesArray2.
  END METHOD.
  
  METHOD STATIC System.Array ToArray3(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray3) THEN DO:
      propertiesArray3 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 3).
    END.

    propertiesArray3:SetValue(messageValue1, 0).
    propertiesArray3:SetValue(messageValue2, 1).
    propertiesArray3:SetValue(messageValue3, 2).
    RETURN propertiesArray3.
  END METHOD.

  METHOD STATIC System.Array ToArray4(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object):
    IF NOT VALID-OBJECT(propertiesArray4) THEN DO:
      propertiesArray4 = System.Array:CreateInstance(Progress.Util.TypeHelper:GetType("System.Object"), 4).
    END.

    propertiesArray4:SetValue(messageValue1, 0).
    propertiesArray4:SetValue(messageValue2, 1).
    propertiesArray4:SetValue(messageValue3, 2).
    propertiesArray4:SetValue(messageValue4, 3).
    RETURN propertiesArray4.
  END METHOD.

  METHOD STATIC System.Array ToArray5(messageValue1 AS System.Object, messageValue2 AS System.Object, messageValue3 AS System.Object, messageValue4 AS System.Object, messageValue5 AS System.Object):
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

  METHOD STATIC VOID ClearData():
    DELETE OBJECT Log:propertiesArray1 NO-ERROR.
    DELETE OBJECT Log:propertiesArray2 NO-ERROR.
    DELETE OBJECT Log:propertiesArray3 NO-ERROR.
    DELETE OBJECT Log:propertiesArray4 NO-ERROR.
    DELETE OBJECT Log:propertiesArray5 NO-ERROR.
  END.

END CLASS.