USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.mock_BindingObject INHERITS System.Object:

  DEFINE PUBLIC PROPERTY IntegerSetting AS INTEGER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC PROPERTY StringSetting AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC PROPERTY LogicalSetting AS LOGICAL NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC PROPERTY SpaceValues AS StringCollection NO-UNDO
    GET.
    SET.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  CONSTRUCTOR PUBLIC mock_BindingObject (  ):

    SpaceValues = NEW StringCollection().

  END CONSTRUCTOR.

END CLASS.