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

  @Test.
  METHOD PUBLIC VOID canCombinePaths(  ):

    DEFINE VARIABLE path1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE path2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE combinedPath AS CHARACTER NO-UNDO.
    path1 = "..".
    path2 = "secrets".
    combinedPath = FileSystem:CombinePaths(path1, path2).

    Assert:Equals("..~\secrets", combinedPath).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckIfDirectoryIsNotRooted(  ):

    DEFINE VARIABLE checkPath AS CHARACTER NO-UNDO.
    checkPath = "secrets".

    DEFINE VARIABLE isRooted AS LOGICAL NO-UNDO.
    isRooted = FileSystem:DirectoryIsRooted(checkPath).

    Assert:IsFalse(isRooted).

  END METHOD.


  @Test.
  METHOD PUBLIC VOID canCheckIfCombinedDirectoryIsNotRooted(  ):

    DEFINE VARIABLE path1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE path2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE combinedPath AS CHARACTER NO-UNDO.
    path1 = "..".
    path2 = "secrets".
    combinedPath = FileSystem:CombinePaths(path1, path2).

    DEFINE VARIABLE isRooted AS LOGICAL NO-UNDO.
    isRooted = FileSystem:DirectoryIsRooted(combinedPath).

    Assert:IsFalse(isRooted).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canCheckIfDirectoryIsRooted(  ):

    DEFINE VARIABLE path1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE path2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE combinedPath AS CHARACTER NO-UNDO.
    path1 = "..".
    path2 = "secrets".
    combinedPath = FileSystem:CombinePaths(path1, path2).
    FILE-INFO:FILE-NAME = combinedPath.
    combinedPath = FILE-INFO:FULL-PATHNAME.

    DEFINE VARIABLE isRooted AS LOGICAL NO-UNDO.
    isRooted = FileSystem:DirectoryIsRooted(combinedPath).

    Assert:IsTrue(isRooted).

  END METHOD.

END CLASS.