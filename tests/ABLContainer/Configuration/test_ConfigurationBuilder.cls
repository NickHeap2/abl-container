USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.test_ConfigurationBuilder: 
 
  @Setup.
  METHOD PUBLIC VOID setUp(  ):

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCreateAConfigurationBuilder(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().

  END METHOD.

  @Test(expected="Progress.Lang.AppError"). 
  METHOD PUBLIC VOID canThrowOnMissingNoneOptionalFile(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder:AddJsonFile("../missing.json", FALSE).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canIgnoreMissingOptionalFile(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder:AddJsonFile("../missing.json", TRUE).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddExistingJsonFile(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder:AddJsonFile("../appsettings.json", FALSE).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddFileWithBasePath(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder
       :SetBasePath("..")
       :AddJsonFile("appsettings.json", FALSE).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddEnvVars(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   System.Environment:SetEnvironmentVariable("Application__stringSetting","NewSettingValue").

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder:AddEnvironmentVariables().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddEnvVarsWithPrefix(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   System.Environment:SetEnvironmentVariable("Application__stringSetting","NewSettingValue").

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder:AddEnvironmentVariables("Application__").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canBuildConfigurationWithMultipleSources(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder
       :SetBasePath("..")
       :AddJsonFile("appsettings.json", FALSE)
       :AddEnvironmentVariables()
       :Build().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canOverrideSettings(  ):

   DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

   configurationBuilder = NEW ConfigurationBuilder().
   configurationBuilder
       :SetBasePath("..")
       :AddJsonFile("appsettings.json", FALSE)
       :AddJsonFile("appsettings.json", FALSE).

  END METHOD.

END CLASS.