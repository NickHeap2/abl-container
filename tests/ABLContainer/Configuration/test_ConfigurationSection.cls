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
   configuration = configurationBuilder
                     :Build().

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

    DEFINE VARIABLE bindingObject AS BindingObject NO-UNDO.
    bindingObject = NEW BindingObject().
    
    configurationSection:Bind(bindingObject).
    
    Assert:Equals(true, bindingObject:LogicalSetting).
    Assert:Equals(1, bindingObject:IntegerSetting).
    Assert:Equals("setting", bindingObject:StringSetting).

  END METHOD.

END CLASS.