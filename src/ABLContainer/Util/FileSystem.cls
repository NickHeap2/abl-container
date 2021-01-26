USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Util.FileSystem:

  DEFINE STATIC VARIABLE unixSeperator AS CHARACTER INITIAL "/" NO-UNDO.
  DEFINE STATIC VARIABLE windowsSeperator AS CHARACTER INITIAL "~\" NO-UNDO.

  METHOD STATIC LOGICAL FileExists(fileName AS CHARACTER):
    FILE-INFO:FILE-NAME = fileName.
    RETURN (FILE-INFO:FULL-PATHNAME <> ? AND FILE-INFO:FILE-TYPE MATCHES "*F*").
  END METHOD.

 
  METHOD STATIC LOGICAL DirectoryExists(dirPath AS CHARACTER):
    FILE-INFO:FILE-NAME = dirPath.
    RETURN (FILE-INFO:FULL-PATHNAME <> ? AND FILE-INFO:FILE-TYPE MATCHES "*D*").
  END METHOD.

  METHOD STATIC LOGICAL DirectoryIsRooted(dirPath AS CHARACTER):
    FILE-INFO:FILE-NAME = dirPath.
    
    RETURN (FILE-INFO:FULL-PATHNAME = FILE-INFO:PATHNAME). 
  END METHOD.

  METHOD STATIC CHARACTER CombinePaths(path1 AS CHARACTER, path2 AS CHARACTER):
    DEFINE VARIABLE pathSeparator AS CHARACTER NO-UNDO.
    
    pathSeparator = "".
    /* check path1 */
    IF path1 MATCHES "*" + unixSeperator + "*" THEN DO:
      pathSeparator = unixSeperator.
    END.
    ELSE IF path1 MATCHES "*" + windowsSeperator + "*" THEN DO:
      pathSeparator = windowsSeperator.
    END.
    /* check path2 */
    IF pathSeparator = "" THEN DO:
      IF path2 MATCHES "*" + unixSeperator + "*" THEN DO:
        pathSeparator = unixSeperator.
      END.
      ELSE IF path2 MATCHES "*" + windowsSeperator + "*" THEN DO:
        pathSeparator = windowsSeperator.
      END.    
    END.
    /*use os setting*/
    IF pathSeparator = "" THEN DO:
      IF OPSYS = "unix" THEN DO:
        pathSeparator = unixSeperator.
      END.
      ELSE DO:
        pathSeparator = windowsSeperator.
      END.
    END.    
    
    IF NOT (path1 MATCHES "*" + pathSeparator)
      AND NOT (path2 MATCHES pathSeparator + "*")
    THEN DO:
      RETURN path1 + pathSeparator + path2.
    END.
    ELSE DO:
      RETURN path1 + path2.
    END.

  END METHOD.


END CLASS.