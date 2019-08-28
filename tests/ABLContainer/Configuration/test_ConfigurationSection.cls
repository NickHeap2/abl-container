USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Lang.*.
USING OpenEdge.Core.Assert FROM PROPATH.

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

    DEFINE VARIABLE configurationEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.

    configurationEnumerator = configurationSection:GetChildren().
    Assert:NotNull(configurationEnumerator).
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
    Assert:Equals(TRUE, mock_bindingObject:LogicalSetting).
    Assert:Equals(1, mock_bindingObject:IntegerSetting).
    Assert:Equals("setting", mock_bindingObject:StringSetting).

    arrayConfigurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(arrayConfigurationSection).

    arrayConfigurationSection:Bind(mock_bindingObject:SpaceValues).
    Assert:NotNull(mock_bindingObject:SpaceValues).
    Assert:NotZero(mock_bindingObject:SpaceValues:Count, "mock_bindingObject:SpaceValues:Count").
    Assert:Equals("Serilog.Sinks.Console", mock_bindingObject:SpaceValues:Item[0]).
    Assert:Equals("Serilog.Sinks.Elasticsearch", mock_bindingObject:SpaceValues:Item[1]).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canBindAList(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    configurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE characterList AS "System.Collections.Generic.List<CHARACTER>" NO-UNDO.
    characterList = NEW "System.Collections.Generic.List<CHARACTER>"().

    configurationSection:Bind(characterList).

    Assert:Equals(2,characterList:Count).
    Assert:Equals("Serilog.Sinks.Console",characterList:Item[0]).
    Assert:Equals("Serilog.Sinks.Elasticsearch",characterList:Item[1]).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetAnArray(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    configurationSection = configurationSection:GetSection("SpaceValues").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE characterArray AS CHARACTER EXTENT NO-UNDO.

    characterArray = configurationSection:GetArray().

    Assert:Equals(2,EXTENT(characterArray)).
    Assert:Equals("Serilog.Sinks.Console",characterArray[1]).
    Assert:Equals("Serilog.Sinks.Elasticsearch",characterArray[2]).

  END METHOD.


END CLASS.