USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.ConfigurationSection INHERITS Progress.Lang.Object:

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

  METHOD PUBLIC VOID Bind(characterList AS StringCollection):

    DEFINE VARIABLE sectionEnumerator AS IIterator NO-UNDO.
    sectionEnumerator = THIS-OBJECT:GetChildren().
    _CHILDREN:
    DO WHILE(sectionEnumerator:HasNext()):
      DEFINE VARIABLE nextValue AS IMapEntry NO-UNDO.
      nextValue = CAST(sectionEnumerator:Next(), IMapEntry).
      
      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(nextValue:Value, ConfigurationSection).

      /* is this a value node? */
      IF configurationSection:Value <> ? THEN DO:
        characterList:Add(configurationSection:Value) NO-ERROR.
        IF ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
          UNDO, THROW NEW AppError(SUBSTITUTE("ERROR: [&1]", ERROR-STATUS:GET-MESSAGE(1))).
        END.
      END.
    END.

  END METHOD.

  METHOD PUBLIC LOGICAL Exists(  ):

    IF (THIS-OBJECT:VALUE <> ?
      AND THIS-OBJECT:VALUE <> "")
      /*TODO Need to check for children*/
    THEN DO:
      RETURN TRUE.
    END.

    RETURN FALSE.

  END METHOD.

  METHOD PUBLIC OpenEdge.Core.String EXTENT GetArray():
    DEFINE VARIABLE characterArray AS OpenEdge.Core.String EXTENT NO-UNDO.
    DEFINE VARIABLE characterList AS StringCollection NO-UNDO.
    characterList = NEW StringCollection().

    DEFINE VARIABLE sectionEnumerator AS IIterator NO-UNDO.
    sectionEnumerator = THIS-OBJECT:GetChildren().
    _CHILDREN:
    DO WHILE(sectionEnumerator:HasNext()):
      DEFINE VARIABLE nextValue AS IMapEntry NO-UNDO.
      nextValue = CAST(sectionEnumerator:Next(), IMapEntry).

      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(nextValue:Value, ConfigurationSection).

      /* is this a value node? */
      IF configurationSection:Value <> ? THEN DO:
        characterList:Add(configurationSection:Value) NO-ERROR.
      END.
    END.
    EXTENT(characterArray) = ?.
    EXTENT(characterArray) = characterList:Size.
    characterArray = characterList:ToStringArray().

    RETURN characterArray.
  END METHOD.

  METHOD PUBLIC VOID Bind(bindObject AS Progress.Lang.Object):

    DEFINE VARIABLE sectionEnumerator AS IIterator NO-UNDO.
    sectionEnumerator = THIS-OBJECT:GetChildren().
    _CHILDREN:
    DO WHILE(sectionEnumerator:HasNext()):
      DEFINE VARIABLE nextValue AS IMapEntry NO-UNDO.
      nextValue = CAST(sectionEnumerator:Next(), IMapEntry).
    
      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(nextValue:Value, ConfigurationSection).

      /* is this a value node? */
      IF configurationSection:Value <> ? THEN DO:
        DYNAMIC-PROPERTY(bindObject, configurationSection:Key) = configurationSection:Value NO-ERROR.
      END.
    END.

  END METHOD.

  METHOD PUBLIC ConfigurationSection GetSection(sectionName AS CHARACTER):
    RETURN configurationObject:GetSection(THIS-OBJECT:Path + ":" + sectionName).
  END METHOD.

  METHOD PUBLIC IIterator GetChildren():
    DEFINE VARIABLE childConfigurationSections AS IMap                 NO-UNDO.
    DEFINE VARIABLE configurationSection       AS ConfigurationSection NO-UNDO.

    DEFINE VARIABLE parentLevel                AS INTEGER                                                           NO-UNDO.
    DEFINE VARIABLE childLevel                 AS INTEGER                                                           NO-UNDO.
    childConfigurationSections = NEW Map().

    parentLevel = NUM-ENTRIES(THIS-OBJECT:Path, ":").

    DEFINE VARIABLE envVarName        AS CHARACTER                                                                NO-UNDO.
    DEFINE VARIABLE envVarValue       AS CHARACTER                                                                NO-UNDO.
    DEFINE VARIABLE configurationEnum AS IIterator NO-UNDO.

    configurationEnum = configurationObject:GetChildren().

    _ENV_VARS:
    DO WHILE(configurationEnum:HasNext()):
      DEFINE VARIABLE nextValue AS IMapEntry NO-UNDO.
      nextValue = CAST(configurationEnum:Next(), IMapEntry).

      envVarName = STRING(nextValue:Key).
      envVarValue = STRING(nextValue:Value).

/*      MESSAGE "CHECK->" + envVarName.*/
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
        IF NOT childConfigurationSections:ContainsKey(NEW OpenEdge.Core.String(childPath)) THEN DO:
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
          childConfigurationSections:Put(NEW OpenEdge.Core.String(childPath), configurationSection).
        END.
      END.
    END.

    RETURN childConfigurationSections:EntrySet:Iterator().
  END METHOD.

END CLASS.