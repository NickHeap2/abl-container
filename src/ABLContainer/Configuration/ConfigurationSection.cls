USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Lang.*.
USING System.Collections.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.ConfigurationSection INHERITS System.Object:

  DEFINE VARIABLE configurationObject AS Configuration NO-UNDO.

  DEFINE PUBLIC PROPERTY Key AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC PROPERTY Path AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC PROPERTY Value AS CHARACTER NO-UNDO
    GET.
    SET.

  CONSTRUCTOR PUBLIC ConfigurationSection (configuration AS configuration):
    configurationObject = configuration.
  END CONSTRUCTOR.

  METHOD PUBLIC VOID Bind(bindObject AS System.Object):

    DEFINE VARIABLE sectionEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    sectionEnumerator = THIS-OBJECT:GetChildren().
    _SERILOG:
    DO WHILE(sectionEnumerator:MoveNext()):
      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(sectionEnumerator:Current:Value, ConfigurationSection).

      /* is this a value node? */      
      IF configurationSection:Value <> ? THEN DO:
        DYNAMIC-PROPERTY(bindObject, configurationSection:Key) = configurationSection:Value NO-ERROR.
      END.      
    END.

  END METHOD.

  METHOD PUBLIC "System.Collections.Generic.Dictionary<character, System.Object>+Enumerator" GetChildren():
    DEFINE VARIABLE childConfigurationSections AS "System.Collections.Generic.Dictionary<character, System.Object>" NO-UNDO.
    DEFINE VARIABLE configurationSection       AS ConfigurationSection                                              NO-UNDO.

    DEFINE VARIABLE parentLevel                AS INTEGER                                                           NO-UNDO.
    DEFINE VARIABLE childLevel                 AS INTEGER                                                           NO-UNDO.
    childConfigurationSections = NEW "System.Collections.Generic.Dictionary<character, System.Object>"().
    
    parentLevel = NUM-ENTRIES(THIS-OBJECT:Path, ":").

    DEFINE VARIABLE envVarName        AS CHARACTER                                                                NO-UNDO.
    DEFINE VARIABLE envVarValue       AS CHARACTER                                                                NO-UNDO.
    DEFINE VARIABLE configurationEnum AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>+Enumerator" NO-UNDO.

    configurationEnum = configurationObject:GetChildren().
    
    _ENV_VARS:
    DO WHILE(configurationEnum:MoveNext()):
      envVarName = STRING(configurationEnum:Current:Key).
      envVarValue = STRING(configurationEnum:Current:Value).

      /* get child sections */
      IF envVarName MATCHES THIS-OBJECT:Path + ":*" THEN DO:
        
        childLevel = NUM-ENTRIES(envVarName, ":").
        
        DEFINE VARIABLE childPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iLevel    AS INTEGER   NO-UNDO.
        childPath = "".
        DO iLevel = 1 TO parentLevel + 1:
          IF iLevel <> 1 THEN childPath = childPath + ":".
          childPath = childPath + ENTRY(iLevel, envVarName, ":").
        END.
        
        /* add this child path if not already present */
        IF NOT childConfigurationSections:ContainsKey(childPath) THEN DO:        
          configurationSection = NEW ConfigurationSection(configurationObject).
          configurationSection:Key = ENTRY(NUM-ENTRIES(childPath, ":"), childPath, ":").
          configurationSection:Path = childPath.
          
          /* is this a final value? */
          IF childLevel = parentLevel + 1 THEN DO:
            configurationSection:Value = envVarValue.
          END.
          ELSE DO:
            configurationSection:Value = ?.
          END.

          /*          MESSAGE "ConfigurationSection".                  */
          /*          MESSAGE "    Key->" + configurationSection:Key.  */
          /*          MESSAGE "    Path->" + configurationSection:Path.*/
          childConfigurationSections:Add(childPath, configurationSection).
        END.
      END.
    END.
    
    RETURN childConfigurationSections:GetEnumerator().
  END METHOD.

END CLASS.