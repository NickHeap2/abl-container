USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.test_Log: 
 
  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    Log:ClearData().

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformation(  ):

    Log:Information("TEST INFORMATION").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnError(  ):

    Log:Error("TEST ERROR").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnException(  ):

    DO ON ERROR UNDO, LEAVE:
      DEFINE VARIABLE hHandle AS HANDLE NO-UNDO.
      hHandle:ACCEPT-CHANGES().

      CATCH ex AS Progress.Lang.Error :
        Log:Error(ex).        
      END CATCH.
    END.

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnErrorWithAParam(  ):

    Log:Error("TEST DEBUG", BOX("PARAM1")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogAnErrorWithTwoParams(  ):

    Log:Error("TEST DEBUG", BOX("PARAM1"), BOX("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfo(  ):

    Log:Debug("TEST DEBUG").

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithAParam(  ):

    Log:Debug("TEST DEBUG", BOX("PARAM1")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithTwoParams(  ):

    Log:Debug("TEST DEBUG", BOX("PARAM1"), BOX("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithThreeParams(  ):

    Log:Debug("TEST DEBUG", BOX("PARAM1"), BOX("PARAM2"), BOX("PARAM3")).

  END METHOD.
  
  @Test.
  METHOD PUBLIC VOID canLogDebugInfoWithFourParams(  ):

    Log:Debug("TEST DEBUG", BOX("PARAM1"), BOX("PARAM2"), BOX("PARAM3"), BOX("PARAM4")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithAParam(  ):

    Log:Information("TEST INFORMATION", BOX("PARAM1")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithTwoParams(  ):

    Log:Information("TEST INFORMATION", BOX("PARAM1"), BOX("PARAM2")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canLogInformationWithThreeParams(  ):

    Log:Information("TEST INFORMATION", BOX("PARAM1"), BOX("PARAM2"), BOX("PARAM3")).

  END METHOD.
  
  @Test.
  METHOD PUBLIC VOID canLogInformationWithFourParams(  ):

    Log:Information("TEST INFORMATION", BOX("PARAM1"), BOX("PARAM2"), BOX("PARAM3"), BOX("PARAM4")).

  END METHOD.

END CLASS.