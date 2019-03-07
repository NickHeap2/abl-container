USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Bootstrap.test_Bootstrap: 
 
  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.
 
  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    previousPropath = PROPATH.
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canBuildConfiguration(  ):
    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = Bootstrap:BuildConfiguration("Development").
    Assert:NotNull(configuration).
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetSettings(  ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.nodb.json", TRUE)
      :AddJsonFile("appsettings.Development.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    PROPATH = previousPropath.
  END METHOD.

END CLASS.