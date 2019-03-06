 
 /*------------------------------------------------------------------------
    File        : test_BindingObject
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Nick Heap
    Created     : Tue Mar 05 14:38:30 GMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Configuration.BindingObject INHERITS System.Object: 

  DEFINE PUBLIC PROPERTY IntegerSetting AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY StringSetting AS CHARACTER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY LogicalSetting AS LOGICAL NO-UNDO
  GET.
  SET.
  
END CLASS.