USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING System.Collections.* FROM ASSEMBLY.
USING System.IO.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.ConfigurationBuilder: 

  DEFINE VARIABLE basePath                AS CHARACTER                                                     NO-UNDO.
  DEFINE VARIABLE configurationDictionary AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>" NO-UNDO.

  METHOD PRIVATE VOID AddArraySetting(settingName AS CHARACTER, propertyType AS INTEGER, propertyIndex AS INTEGER, theArray AS JsonArray):
    DEFINE VARIABLE settingValue AS CHARACTER NO-UNDO.
    
    IF propertyType = 2 THEN DO:
      settingValue = STRING(theArray:GetInteger(propertyIndex)).
    END.
    ELSE IF propertyType = 3 THEN DO:
      settingValue = STRING(theArray:GetLogical(propertyIndex)).
    END.
    ELSE DO:
      settingValue = theArray:GetCharacter(propertyIndex).
    END.

    IF configurationDictionary:ContainsKey(settingName) THEN DO:
      configurationDictionary[settingName] = settingValue.
    END.
    ELSE DO:
      configurationDictionary:Add(settingName, settingValue).
    END.
  END METHOD.

  METHOD PRIVATE VOID AddSetting(settingName AS CHARACTER, propertyType AS INTEGER, propertyName AS CHARACTER, theObject AS JsonObject):
    DEFINE VARIABLE settingValue AS CHARACTER NO-UNDO.
    
    IF propertyType = 2 THEN DO:
      settingValue = STRING(theObject:GetInteger(propertyName)).
    END.
    ELSE IF propertyType = 3 THEN DO:
      settingValue = STRING(theObject:GetLogical(propertyName)).
    END.
    ELSE DO:
      settingValue = theObject:GetCharacter(propertyName).
    END.

    IF configurationDictionary:ContainsKey(settingName) THEN DO:
      configurationDictionary[settingName] = settingValue.
    END.
    ELSE DO:
      configurationDictionary:Add(settingName, settingValue).
    END.
  END METHOD.

  METHOD PUBLIC ConfigurationBuilder AddJsonFile(fileName AS CHARACTER, optional AS LOGICAL):
    DEFINE VARIABLE parser            AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE appsettingsObject AS JsonObject        NO-UNDO.

    IF basePath <> "" THEN DO:
      fileName = System.IO.Path:Combine(basePath, fileName).
    END.

    IF NOT File:Exists(fileName) THEN DO:
      IF optional = FALSE THEN DO:
        UNDO, THROW NEW Progress.Lang.AppError("File doesn't exist!").
      END.
      RETURN THIS-OBJECT.
    END.

    parser = NEW Progress.Json.ObjectModel.ObjectModelParser().
    appsettingsObject = CAST(parser:ParseFile(fileName), JsonObject).
    
    AddObjectValues("", appsettingsObject).
    
    RETURN THIS-OBJECT.
  END METHOD.
    
  CONSTRUCTOR PUBLIC ConfigurationBuilder (  ):
    configurationDictionary = NEW "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>"().
  END CONSTRUCTOR.

  METHOD PUBLIC ConfigurationBuilder AddEnvironmentVariables():
    RETURN THIS-OBJECT:AddEnvironmentVariables("").
  END METHOD.

  METHOD PUBLIC ConfigurationBuilder AddEnvironmentVariables(prefix AS CHARACTER):
    DEFINE VARIABLE envVars AS IDictionary NO-UNDO.
    envVars = System.Environment:GetEnvironmentVariables().
    
    DEFINE VARIABLE dictEnum AS IDictionaryEnumerator NO-UNDO.

    dictEnum = envVars:GetEnumerator().

    DEFINE VARIABLE envVarName  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE envVarValue AS CHARACTER NO-UNDO.

    _ENV_VARS:
    DO WHILE(dictEnum:MoveNext()):
      envVarName = STRING(dictEnum:Key).
      envVarValue = STRING(dictEnum:Value).

      IF (prefix <> ""
        AND NOT envVarName BEGINS prefix)
        OR NOT envVarName MATCHES "*__*"
      THEN DO:
        NEXT _ENV_VARS.
      END.

      envVarName = REPLACE(envVarName, "__", ":").

      /*      MESSAGE envVarName "->" envVarValue.*/
      IF configurationDictionary:ContainsKey(envVarName) THEN DO:
        configurationDictionary[envVarName] = envVarValue.
      END.
      ELSE DO:
        configurationDictionary:Add(envVarName, envVarValue).
      END.
      
    END.
    
    RETURN THIS-OBJECT.
  END METHOD.


  METHOD PRIVATE VOID AddObjectValues(baseSetting AS CHARACTER, theObject AS JsonObject):
        
    DEFINE VARIABLE propertyNames AS CHARACTER EXTENT NO-UNDO.
    propertyNames = theObject:GetNames().
    
    DEFINE VARIABLE propertyName      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE propertyType      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE propertyNameIndex AS INTEGER   NO-UNDO.
    DO propertyNameIndex = 1 TO EXTENT(propertyNames):
      
      propertyName = propertyNames[propertyNameIndex].
      propertyType = theObject:GetType(propertyName).

      IF propertyType = 4 THEN DO:
        DEFINE VARIABLE propertyObject AS JsonObject NO-UNDO.
        propertyObject = theObject:GetJsonObject(propertyName).
        AddObjectValues(baseSetting + propertyName + ":", propertyObject).
      END.
      ELSE IF propertyType = 5 THEN DO:
        DEFINE VARIABLE theArray AS JsonArray NO-UNDO.
      
        theArray = theObject:GetJsonArray(propertyName).
    
        DEFINE VARIABLE arrayObject    AS JsonObject NO-UNDO.
        DEFINE VARIABLE arrayEntryType AS INTEGER    NO-UNDO.
        DEFINE VARIABLE arrayIndex     AS INTEGER    NO-UNDO.
        DO arrayIndex = 1 TO theArray:LENGTH:
        
          arrayEntryType = theArray:GetType(arrayIndex).
        
          IF arrayEntryType = 4 THEN DO:
            arrayObject = theArray:GetJsonObject(arrayIndex).
            AddObjectValues(baseSetting + propertyName + ":" + STRING(arrayIndex - 1) + ":", arrayObject).          
          END.
          ELSE DO:
            AddArraySetting(baseSetting + propertyName + ":" + STRING(arrayIndex - 1), arrayEntryType, arrayIndex, theArray).
          END.
        END.
      END.
      ELSE DO:
        AddSetting(baseSetting + propertyName, propertyType, propertyName, theObject).
      END.
    END.
    EXTENT(propertyNames) = ?.
    
  END METHOD.

  METHOD PUBLIC Configuration Build():
    
    RETURN NEW Configuration(configurationDictionary).
  END METHOD.

  METHOD PUBLIC ConfigurationBuilder SetBasePath(pathName AS CHARACTER):
    
    basePath = pathName.
    
    RETURN THIS-OBJECT.
  END METHOD.

END CLASS.