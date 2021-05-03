USING ABLContainer.Configuration.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.test_EnvVars:

  @Setup.
  METHOD PUBLIC VOID setUp(  ):
    System.Environment:SetEnvironmentVariable("Application__stringSetting","NewSettingValue").
    EnvVars:ClearEnvVars().  
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canGetEnvVars(  ):

    EnvVars:GetEnvVars("*__*").
    Assert:NotNull(EnvVars:SystemEnvVars).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReadAnEnvVars(  ):
    DEFINE VARIABLE varValue AS CHARACTER NO-UNDO.
    varValue = EnvVars:GetEnvVar("Application__stringSetting").
    
    Assert:Equals("NewSettingValue", varValue).
    
  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReadEnvVars(  ):

    EnvVars:GetEnvVars("*__*").
    Assert:NotNull(EnvVars:SystemEnvVars).

    Assert:Equals(1, EnvVars:SystemEnvVars:Size).

    DEFINE VARIABLE envVarIterator AS IIterator NO-UNDO.
    envVarIterator = EnvVars:SystemEnvVars:EntrySet:Iterator().
    Assert:NotNull(envVarIterator).
    
    DEFINE VARIABLE nextEnvVarObject AS Progress.Lang.Object NO-UNDO.
    nextEnvVarObject = envVarIterator:Next().
    /*Assert:IsType(nextEnvVarObject, GET-CLASS("OpenEdge.Core.Collections.IMapEntry")).*/
    
    DEFINE VARIABLE nextEnvVar AS IMapEntry NO-UNDO.
    nextEnvVar = CAST(nextEnvVarObject, IMapEntry).
    Assert:NotNull(nextEnvVar).
    
    DEFINE VARIABLE envVarName AS CHARACTER NO-UNDO.
    envVarName = nextEnvVar:Key:ToString().
    Assert:Equals("Application__stringSetting", envVarName).
    
    DEFINE VARIABLE envVarValue AS CHARACTER NO-UNDO.
    envVarValue = nextEnvVar:Value:ToString().
    Assert:Equals("NewSettingValue", envVarValue).

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown():
    System.Environment:SetEnvironmentVariable("Application__stringSetting", "").

  END METHOD.

END CLASS.