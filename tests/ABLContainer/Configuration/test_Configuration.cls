USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.test_Configuration:

  DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.
  DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.json", FALSE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    ABLContainer.Configuration.Configuration:Current = configuration.
    Assert:NotNull(ABLContainer.Configuration.Configuration:Current).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCreateAConfiguration(  ):
    DEFINE VARIABLE newConfiguration AS Configuration NO-UNDO.
    newConfiguration = configurationBuilder:Build().
    Assert:NotNull(newConfiguration).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetAConfigurationValue(  ):

    DEFINE VARIABLE configurationValue AS CHARACTER NO-UNDO.

    configurationValue = configuration:Item("Application:integerSetting").
    Assert:Equals("1", configurationValue).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReturnNullForMissingSetting(  ):

    DEFINE VARIABLE configurationValue AS CHARACTER NO-UNDO.

    configurationValue = configuration:Item("Application:missingSetting").
    Assert:Equals(?, configurationValue).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReturnANullForAMissingValue(  ):

    DEFINE VARIABLE configurationValue AS CHARACTER NO-UNDO.

    configurationValue = configuration:Item("Application:missingSetting").
    Assert:Equals(?, configurationValue).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReturnAnIterator(  ):

    DEFINE VARIABLE configurationIterator AS IIterator NO-UNDO.

    configurationIterator = configuration:GetChildren().
    Assert:NotNull(configurationIterator).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetASection(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).
    Assert:Equals("Application", configurationSection:Key).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetASectionWithValue(  ):

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.

    configurationSection = configuration:GetSection("Application:stringSetting").
    Assert:NotNull(configurationSection).
    Assert:Equals("stringSetting", configurationSection:Key).
    Assert:Equals("Application:stringSetting", configurationSection:Path).
    Assert:Equals("setting", configurationSection:Value).

  END METHOD.

END CLASS.