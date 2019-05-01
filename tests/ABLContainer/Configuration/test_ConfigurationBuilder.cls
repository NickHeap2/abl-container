USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Lang.*.
USING OpenEdge.Core.Assert FROM PROPATH.

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

    System.Environment:SetEnvironmentVariable("Application__stringSetting", "").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddDockerSecrets(  ):

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder:SetBasePath("..")
                        :AddKeyPerFile("secrets", TRUE).

    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    DEFINE VARIABLE configurationEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>+Enumerator" NO-UNDO.
    configurationEnumerator = configuration:GetChildren().
    Assert:NotNull(configurationEnumerator).

    DEFINE VARIABLE iChildCount AS INTEGER NO-UNDO.
    iChildCount = 0.
    DO WHILE(configurationEnumerator:MoveNext()):
      iChildCount = iChildCount + 1.

      DEFINE VARIABLE settingKey AS CHARACTER NO-UNDO.
      DEFINE VARIABLE settingValue AS CHARACTER NO-UNDO.
      settingKey = configurationEnumerator:Current:Key.
      settingValue = configurationEnumerator:Current:Value.
      Assert:NotNullOrEmpty(settingKey).
      Assert:NotNullOrEmpty(settingValue).
      MESSAGE settingKey "=" settingValue.
      Assert:Equals("docker:secret", settingKey).
      Assert:Equals("secret_value", settingValue).
    END.

    Assert:Equals(1, iChildCount).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddEnvVarsWithOverride(  ):

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

    System.Environment:SetEnvironmentVariable("Application__stringSetting","NewSettingValue").

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :AddEnvironmentVariables()
      :AddEnvironmentVariables().

    System.Environment:SetEnvironmentVariable("Application__stringSetting", "").

  END METHOD.


  @Test.
  METHOD PUBLIC VOID canAddEnvVarsWithPrefix(  ):

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.

    System.Environment:SetEnvironmentVariable("Application__stringSetting","NewSettingValue").

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder:AddEnvironmentVariables("Application__").

    System.Environment:SetEnvironmentVariable("Application__stringSetting", "").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddElasticsearchToSerilog(  ):

    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Name","Elasticsearch").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__nodeUris","http://localhost:9200").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__indexFormat","application-~{0:yyyy.MM.dd~}").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__emitEventFailure","ThrowException").

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.json", FALSE)
      :AddEnvironmentVariables().

    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

/*    DEFINE VARIABLE configurationEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>+Enumerator" NO-UNDO.*/
/*    configurationEnumerator = configuration:GetChildren().                                                                      */
/*    DO WHILE(configurationEnumerator:MoveNext()):                                                                               */
/*      MESSAGE SUBSTITUTE("  CONFIG &1=&2", configurationEnumerator:Current:Key, configurationEnumerator:Current:Value).         */
/*    END.                                                                                                                        */

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
    configurationSection = configuration:GetSection("Serilog").
    Assert:NotNull(configurationSection).

    configurationSection = configuration:GetSection("Serilog:WriteTo").
    Assert:NotNull(configurationSection).

    configurationSection = configuration:GetSection("Serilog:WriteTo:0").
    Assert:NotNull(configurationSection).

    configurationSection = configuration:GetSection("Serilog:WriteTo:0:Name").
    Assert:Equals("Console", configurationSection:Value).

    configurationSection = configuration:GetSection("Serilog:WriteTo:1:Name").
    Assert:Equals("Elasticsearch", configurationSection:Value).

    configurationSection = configuration:GetSection("Serilog:WriteTo:1").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE argsConfigurationSection AS ConfigurationSection NO-UNDO.
    argsConfigurationSection = configuration:GetSection("Serilog:WriteTo:1:Args").
    Assert:NotNull(argsConfigurationSection).

    DEFINE VARIABLE argsConfigurationEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    argsConfigurationEnumerator = argsConfigurationSection:GetChildren().
    Assert:NotNull(argsConfigurationEnumerator).

    DEFINE VARIABLE iChildCount AS INTEGER NO-UNDO.
    iChildCount = 0.
    DO WHILE(argsConfigurationEnumerator:MoveNext()):
      iChildCount = iChildCount + 1.

      DEFINE VARIABLE childSection0 AS ConfigurationSection NO-UNDO.
      childSection0 = CAST(argsConfigurationEnumerator:Current:Value, ConfigurationSection).
      Assert:NotNull(childSection0).

      IF (childSection0:Key = "nodeUris") THEN DO:
        Assert:Equals("http://localhost:9200", childSection0:Value).
      END.
      ELSE IF (childSection0:Key = "indexFormat") THEN DO:
        Assert:Equals("application-~{0:yyyy.MM.dd~}", childSection0:Value).
      END.
      ELSE IF (childSection0:Key = "emitEventFailure") THEN DO:
        Assert:Equals("ThrowException", childSection0:Value).
      END.
      ELSE DO:
        Assert:IsFalse(TRUE).
      END.
    END.
    Assert:Equals(3, iChildCount).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canAddNewArrayEnvVars(  ):

    System.Environment:SetEnvironmentVariable("ArrayTest__0__integerSetting","0").
    System.Environment:SetEnvironmentVariable("ArrayTest__0__stringSetting","Value 0").
    System.Environment:SetEnvironmentVariable("ArrayTest__1__integerSetting","1").
    System.Environment:SetEnvironmentVariable("ArrayTest__1__stringSetting","Value 1").

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    configurationBuilder = NEW ConfigurationBuilder().
    Assert:NotNull(configurationBuilder).

    configurationBuilder
      :AddEnvironmentVariables("ArrayTest__").

    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
    configurationSection = configuration:GetSection("ArrayTest").
    Assert:NotNull(configurationSection).

    DEFINE VARIABLE configurationSection0 AS ConfigurationSection NO-UNDO.
    configurationSection0 = configuration:GetSection("ArrayTest:0").
    Assert:NotNull(configurationSection0).

    DEFINE VARIABLE configurationEnumerator0 AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    configurationEnumerator0 = configurationSection0:GetChildren().
    Assert:NotNull(configurationEnumerator0).

    DEFINE VARIABLE iChildCount AS INTEGER NO-UNDO.
    iChildCount = 0.
    DO WHILE(configurationEnumerator0:MoveNext()):
      iChildCount = iChildCount + 1.

      DEFINE VARIABLE childSection0 AS ConfigurationSection NO-UNDO.
      childSection0 = CAST(configurationEnumerator0:Current:Value, ConfigurationSection).
      Assert:NotNull(childSection0).

      IF (childSection0:Key = "integerSetting") THEN DO:
        Assert:Equals("0", childSection0:Value).
      END.
      ELSE IF (childSection0:Key = "stringSetting") THEN DO:
        Assert:Equals("Value 0", childSection0:Value).
      END.
      ELSE DO:
        Assert:IsFalse(TRUE).
      END.
    END.
    Assert:Equals(2, iChildCount).

    DEFINE VARIABLE configurationSection1 AS ConfigurationSection NO-UNDO.
    configurationSection1 = configuration:GetSection("ArrayTest:1").
    Assert:NotNull(configurationSection1).

    DEFINE VARIABLE configurationEnumerator1 AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    configurationEnumerator1 = configurationSection1:GetChildren().
    Assert:NotNull(configurationEnumerator1).

    iChildCount = 0.
    DO WHILE(configurationEnumerator1:MoveNext()):
      iChildCount = iChildCount + 1.

      DEFINE VARIABLE childSection1 AS ConfigurationSection NO-UNDO.
      childSection1 = CAST(configurationEnumerator1:Current:Value, ConfigurationSection).
      Assert:NotNull(childSection1).

      IF (childSection1:Key = "integerSetting") THEN DO:
        Assert:Equals("1", childSection1:Value).
      END.
      ELSE IF (childSection1:Key = "stringSetting") THEN DO:
        Assert:Equals("Value 1", childSection1:Value).
      END.
      ELSE DO:
        Assert:IsFalse(TRUE).
      END.
    END.
    Assert:Equals(2, iChildCount).

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

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    System.Environment:SetEnvironmentVariable("Application__stringSetting", "").

    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Name","").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__nodeUris","").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__indexFormat","").
    System.Environment:SetEnvironmentVariable("Serilog__WriteTo__1__Args__emitEventFailure","").

    System.Environment:SetEnvironmentVariable("ArrayTest__0__integerSetting","").
    System.Environment:SetEnvironmentVariable("ArrayTest__0__stringSetting","").
    System.Environment:SetEnvironmentVariable("ArrayTest__1__integerSetting","").
    System.Environment:SetEnvironmentVariable("ArrayTest__1__stringSetting","").
  END METHOD.

END CLASS.
