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

    Bootstrap:ConnectionStrings = NEW "System.Collections.Generic.List<character>"().

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.nodb.json", TRUE)
      :AddJsonFile("appsettings.Development.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).
    Assert:Equals(Bootstrap:ConnectionStrings:Count, 0).

  END METHOD.

  METHOD PUBLIC VOID prepareDatabaseTest( ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    Bootstrap:ConnectionStrings = NEW "System.Collections.Generic.List<character>"().

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.json", FALSE).
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    Assert:Equals(Bootstrap:ConnectionStrings:Count, 2).

    DEFINE VARIABLE connectionString AS CHARACTER NO-UNDO.
    connectionString = Bootstrap:ConnectionStrings:Item[0].
    Assert:Equals("-ct 1 -db database1 -H localhost -S 10660 -ld database1 -U username -P password", connectionString).

    connectionString = Bootstrap:ConnectionStrings:Item[1].
    Assert:Equals("-ct 1 -db database2 -H localhost -S 10661 -ld database2 -U username -P password -B 1000 -Mm 3000", connectionString).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canSetDatabaseSettings(  ):

    THIS-OBJECT:prepareDatabaseTest().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canFailDatabaseConnections(  ):
    THIS-OBJECT:prepareDatabaseTest().

    DEFINE VARIABLE didConnectToDatabases AS LOGICAL NO-UNDO.
    didConnectToDatabases = Bootstrap:DatabaseConnectionAttempt().
    Assert:IsFalse(didConnectToDatabases).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canRetryDatabaseConnections(  ):
    THIS-OBJECT:prepareDatabaseTest().

    DEFINE VARIABLE didConnectToDatabases AS LOGICAL NO-UNDO.
    didConnectToDatabases = Bootstrap:ConnectToDatabases().
    Assert:IsFalse(didConnectToDatabases).

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    PROPATH = previousPropath.
  END METHOD.

END CLASS.