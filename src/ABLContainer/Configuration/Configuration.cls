USING ABLContainer.Configuration.*.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.Configuration:

  DEFINE VARIABLE configurationDictionary AS IStringStringMap NO-UNDO.

  DEFINE PUBLIC STATIC PROPERTY Current AS Configuration NO-UNDO
    GET.
    SET.

  CONSTRUCTOR PUBLIC Configuration (configDictionary AS IStringStringMap):
    configurationDictionary = configDictionary.

  END CONSTRUCTOR.

  METHOD PUBLIC IIterator GetChildren():

    RETURN configurationDictionary:EntrySet:Iterator().
  END METHOD.

  METHOD PUBLIC ConfigurationSection GetSection(sectionName AS CHARACTER):
    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = NEW ConfigurationSection(THIS-OBJECT).
    configurationSection:Key = ENTRY(NUM-ENTRIES(sectionName, ":"), sectionName, ":").
    configurationSection:Path = sectionName.

    DEFINE VARIABLE configKey               AS CHARACTER NO-UNDO.
    DEFINE VARIABLE configValue             AS CHARACTER NO-UNDO.
    DEFINE VARIABLE configurationIterator AS IIterator NO-UNDO.
    configurationIterator = configurationDictionary:EntrySet:Iterator().
    _SECTIONS:
    DO WHILE(configurationIterator:HasNext()):
      DEFINE VARIABLE currentConfiguration AS IMapEntry NO-UNDO.
      currentConfiguration = CAST(configurationIterator:Next(), IMapEntry).

      configKey = currentConfiguration:Key:ToString().
      configValue = currentConfiguration:Value:ToString().

      /*TODO - this should be equals? */
      IF configKey MATCHES sectionName THEN DO:
        configurationSection:Value = configValue.
        LEAVE _SECTIONS.
      END.
    END.

    RETURN configurationSection.
  END METHOD.

  METHOD PUBLIC CHARACTER Item (key AS CHARACTER):

    IF configurationDictionary:ContainsKey(key) THEN DO:
      
      RETURN STRING(configurationDictionary:Get(key)).
    END.
    ELSE DO:
      RETURN ?.
    END.

  END METHOD.

END CLASS.
