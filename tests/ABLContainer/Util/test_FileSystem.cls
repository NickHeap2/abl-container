USING ABLContainer.Util.* FROM PROPATH.
USING OpenEdge.Core.Assert FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Util.test_FileSystem:

  @Test.
  METHOD PUBLIC VOID canCheckDirectoryDoesExist(  ):
    
    DEFINE VARIABLE dirExists AS LOGICAL  NO-UNDO.
    dirExists = FileSystem:DirectoryExists("ABLContainer").

    Assert:IsTrue(dirExists).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckDirectoryDoesntExist(  ):
    
    DEFINE VARIABLE dirExists AS LOGICAL  NO-UNDO.
    dirExists = FileSystem:DirectoryExists("ABLNontainer").

    Assert:IsFalse(dirExists).

  END METHOD.

@Test.
  METHOD PUBLIC VOID canCheckFileDoesExist(  ):
    
    DEFINE VARIABLE fileExists AS LOGICAL  NO-UNDO.
    fileExists = FileSystem:FileExists("ABLContainer/Bootstrap/test_Bootstrap.cls").

    Assert:IsTrue(fileExists).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckFileDoesntExist(  ):
    
    DEFINE VARIABLE fileExists AS LOGICAL  NO-UNDO.
    fileExists = FileSystem:FileExists("ABLContainer/Bootstrap/test_NoneBootstrap.cls").

    Assert:IsFalse(fileExists).

  END METHOD.

END CLASS.