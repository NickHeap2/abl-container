USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.test_ConfigurationSection:

  DEFINE VARIABLE configuration AS Configuration NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.json", FALSE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCreateAConfigurationSection(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE configurationIterator AS IIterator NO-UNDO.

    configurationIterator = configurationSection:GetChildren().
    Assert:NotNull(configurationIterator).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canBindAnObject(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
    DEFINE VARIABLE arrayConfigurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE mock_bindingObject AS mock_BindingObject NO-UNDO.
    mock_bindingObject = NEW mock_BindingObject().

    configurationSection:Bind(mock_bindingObject).
    Assert:NotNull(configurationSection).
    Assert:IsTrue(mock_bindingObject:LogicalSetting).
    Assert:Equals(1, mock_bindingObject:IntegerSetting).
    Assert:Equals("setting", mock_bindingObject:StringSetting).

    arrayConfigurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(arrayConfigurationSection).

    arrayConfigurationSection:Bind(mock_bindingObject:SpaceValues).
    Assert:NotNull(mock_bindingObject:SpaceValues).
    Assert:NotZero(mock_bindingObject:SpaceValues:Size, "mock_bindingObject:SpaceValues:Count").
    
    DEFINE VARIABLE spaceValuesIterator AS IIterator NO-UNDO.
    spaceValuesIterator = mock_bindingObject:SpaceValues:Iterator().
    
    Assert:Equals("Serilog.Sinks.Console", CAST(spaceValuesIterator:Next(), OpenEdge.Core.String):ToString()).
    Assert:Equals("Serilog.Sinks.Elasticsearch", CAST(spaceValuesIterator:Next(), OpenEdge.Core.String):ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canBindAList(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    configurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE characterList AS StringCollection NO-UNDO.
    characterList = NEW StringCollection().

    configurationSection:Bind(characterList).

    Assert:Equals(2,characterList:Size).

    DEFINE VARIABLE characterListIterator AS IIterator NO-UNDO.
    characterListIterator = characterList:Iterator().

    Assert:Equals("Serilog.Sinks.Console", CAST(characterListIterator:Next(), OpenEdge.Core.String):ToString()).
    Assert:Equals("Serilog.Sinks.Elasticsearch", CAST(characterListIterator:Next(), OpenEdge.Core.String):ToString()).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetAnArray(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    configurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE characterArray AS OpenEdge.Core.String EXTENT NO-UNDO.

    characterArray = configurationSection:GetArray().

    Assert:Equals(2,EXTENT(characterArray)).
    Assert:Equals("Serilog.Sinks.Console",characterArray[1]:ToString()).
    Assert:Equals("Serilog.Sinks.Elasticsearch",characterArray[2]:ToString()).

  END METHOD.


END CLASS.