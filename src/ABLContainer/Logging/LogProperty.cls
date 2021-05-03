USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.LogProperty: 

  DEFINE PUBLIC PROPERTY PropertyName AS CHARACTER NO-UNDO
    GET.
    SET.
  
  CONSTRUCTOR PUBLIC LogProperty (propertyName AS CHARACTER):
    THIS-OBJECT:PropertyName = propertyName.
  END CONSTRUCTOR.

  METHOD PUBLIC VOID Dispose():
    Log:DisposeProperty(THIS-OBJECT:PropertyName) NO-ERROR.
  END METHOD.

END CLASS.