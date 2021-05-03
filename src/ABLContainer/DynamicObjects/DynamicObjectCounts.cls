USING ABLContainer.DynamicObjects.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.DynamicObjects.DynamicObjectCounts INHERITS Progress.Lang.Object:

  DEFINE PUBLIC PROPERTY DatasetCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY DataSourceCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY BufferCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY ProcedureCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY QueryCount AS INTEGER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY ObjectCount AS INTEGER NO-UNDO
  GET.
  SET.

  METHOD PUBLIC STATIC DynamicObjectCounts GetDynamicObjectCounts(  ):

    DEFINE VARIABLE dynamicObjectCounts AS DynamicObjectCounts NO-UNDO.

    DEFINE VARIABLE hTemp   AS HANDLE               NO-UNDO.
    DEFINE VARIABLE hObject AS HANDLE               NO-UNDO.
    DEFINE VARIABLE vTemp   AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE oObject AS Progress.Lang.Object NO-UNDO.
    DEFINE VARIABLE oTemp   AS Progress.Lang.Object NO-UNDO.
    DEFINE VARIABLE itemCount AS INTEGER              NO-UNDO.

    dynamicObjectCounts = NEW DynamicObjectCounts().

    itemCount = 0.
    ASSIGN hObject = SESSION:FIRST-DATASET.
    DO WHILE hObject <> ?:
        ASSIGN hTemp   = hObject
               hObject = hObject:NEXT-SIBLING
               itemCount = itemCount + 1.
        /*MESSAGE 'ProDataSet, Handle=' hTemp
                            ', Name=' hTemp:NAME
                         ', Dynamic=' hTemp:DYNAMIC VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:DatasetCount = itemCount.

    itemCount = 0.
    ASSIGN hObject = SESSION:FIRST-DATA-SOURCE.
    DO WHILE hObject <> ?:
        ASSIGN hTemp   = hObject
               hObject = hObject:NEXT-SIBLING
               vTemp   = (IF hTemp:QUERY = ? THEN ? ELSE hTemp:QUERY:PREPARE-STRING)
               itemCount = itemCount + 1.
        /*MESSAGE 'DataSource, Handle=' hTemp
                            ', Name=' hTemp:NAME
                           ', Query=' vTemp VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:DataSourceCount = itemCount.

    itemCount = 0.
    ASSIGN hObject = SESSION:FIRST-BUFFER.
    DO WHILE hObject <> ?:
        ASSIGN hTemp   = hObject
               hObject = hObject:NEXT-SIBLING
               itemCount = itemCount + 1.
        /*MESSAGE 'Buffer, Handle=' hTemp
                        ', Name=' hTemp:NAME
                       ', Table=' hTemp:TABLE
                     ', Dynamic=' hTemp:DYNAMIC
                     ', DataSet=' hTemp:DATASET VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:BufferCount = itemCount.

    itemCount = 0.
    ASSIGN hObject = SESSION:FIRST-PROCEDURE.
    DO WHILE hObject <> ?:
        ASSIGN hTemp   = hObject
               hObject = hObject:NEXT-SIBLING
               itemCount = itemCount + 1.
        /*MESSAGE 'Procedure, Handle='hTemp
                          ', Name=' hTemp:NAME VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:ProcedureCount = itemCount.

    itemCount = 0.
    ASSIGN hObject = SESSION:FIRST-QUERY.
    DO WHILE hObject <> ?:
        ASSIGN hTemp   = hObject
               hObject = hObject:NEXT-SIBLING
               itemCount = itemCount + 1.
        /*MESSAGE 'Query, Handle=' hTemp
                       ', Name=' hTemp:NAME
                    ', Dynamic=' hTemp:DYNAMIC
                      ', Query=' hTemp:PREPARE-STRING VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:QueryCount = itemCount.

    itemCount = 0.
    ASSIGN oObject = SESSION:FIRST-OBJECT.
    DO WHILE oObject <> ?:
        ASSIGN oTemp   = oObject
               oObject = oObject:NEXT-SIBLING
               itemCount = itemCount + 1.
        /*MESSAGE 'Object, Name=' oTemp:ToString() VIEW-AS ALERT-BOX.*/
    END.
    dynamicObjectCounts:ObjectCount = itemCount.

    RETURN dynamicObjectCounts.

  END METHOD.

END CLASS.

