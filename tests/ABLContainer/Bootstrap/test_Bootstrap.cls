USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Bootstrap.test_Bootstrap:

  DEFINE VARIABLE previousPropath AS CHARACTER NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    previousPropath = PROPATH.
    EnvVars:ClearEnvVars().
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

    Bootstrap:ConnectionStrings = NEW StringCollection().
    Bootstrap:LogicalDatabaseNames = NEW StringCollection().

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.nodb.json", TRUE)
      :AddJsonFile("appsettings.Development.json", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).
    Assert:Equals(Bootstrap:ConnectionStrings:Size, 0).

  END METHOD.

  METHOD PUBLIC VOID prepareDatabaseTest( ):
    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    Bootstrap:ConnectionStrings = NEW StringCollection().
    Bootstrap:LogicalDatabaseNames = NEW StringCollection().

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath("..")
      :AddJsonFile("appsettings.json", FALSE).
    configuration = configurationBuilder:Build().
    Assert:NotNull(configuration).

    Bootstrap:SetSettings(configuration).

    Assert:Equals(Bootstrap:ConnectionStrings:Size, 2).

    DEFINE VARIABLE connectionStringIterator AS IIterator NO-UNDO.
    connectionStringIterator = Bootstrap:ConnectionStrings:Iterator().
    Assert:NotNull(connectionStringIterator).

    DEFINE VARIABLE connectionString AS CHARACTER NO-UNDO.
    connectionString = CAST(connectionStringIterator:Next(), OpenEdge.Core.String):ToString().
    Assert:Equals("-ct 1 -db database1 -H localhost -S 10660 -ld database1 -U username -P password", connectionString).

    connectionString = CAST(connectionStringIterator:Next(), OpenEdge.Core.String):ToString().
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