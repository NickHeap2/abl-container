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

    configurationSection = configuration:GetSection("Application").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE mock_bindingObject AS mock_BindingObject NO-UNDO.
    mock_bindingObject = NEW mock_BindingObject().
    
    configurationSection:Bind(mock_bindingObject).
    
    Assert:Equals(true, mock_bindingObject:LogicalSetting).
    Assert:Equals(1, mock_bindingObject:IntegerSetting).
    Assert:Equals("setting", mock_bindingObject:StringSetting).

  END METHOD.

END CLASS.