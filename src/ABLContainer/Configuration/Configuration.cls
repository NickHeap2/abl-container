USING ABLContainer.Configuration.*.
USING Progress.Lang.*.
USING System.Collections.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.Configuration: 

  DEFINE VARIABLE configurationDictionary AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>" NO-UNDO.

  DEFINE PUBLIC STATIC PROPERTY Current AS Configuration NO-UNDO
    GET.
    SET.

  CONSTRUCTOR PUBLIC Configuration (configDictionary AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>"):
    configurationDictionary = configDictionary.

  END CONSTRUCTOR.

  METHOD PUBLIC "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>+Enumerator" GetChildren():

    RETURN configurationDictionary:GetEnumerator().
  END METHOD.

  METHOD PUBLIC ConfigurationSection GetSection(sectionName AS CHARACTER):
    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = NEW ConfigurationSection(THIS-OBJECT).
    configurationSection:Key = ENTRY(NUM-ENTRIES(sectionName, ":"), sectionName, ":").
    configurationSection:Path = sectionName.

    DEFINE VARIABLE configKey         AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE configValue       AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE configurationEnum AS IDictionaryEnumerator NO-UNDO.   
    configurationEnum = configurationDictionary:GetEnumerator().
    _ENV_VARS:
    DO WHILE(configurationEnum:MoveNext()):
      configKey = STRING(configurationEnum:Key).
      configValue = STRING(configurationEnum:Value).
      
      IF configKey MATCHES sectionName THEN DO:
        configurationSection:Value = configValue.
        LEAVE _ENV_VARS.
      END.
    END.
    
    RETURN configurationSection.
  END METHOD.
  
  METHOD PUBLIC CHARACTER Item (key AS CHARACTER):

    IF configurationDictionary:ContainsKey(key) THEN DO:
      RETURN configurationDictionary[key].
    END.
    ELSE DO:
      RETURN ?.
    END.

  END METHOD.
  

END CLASS.