USING ABLContainer.DynamicObjects.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.DynamicObjectsLogger IMPLEMENTS ILogEnricher:

  METHOD PUBLIC VOID GetProperties(  ):

    DEFINE VARIABLE dynamicObjectCounts AS DynamicObjectCounts NO-UNDO.

    dynamicObjectCounts = ABLContainer.DynamicObjects.DynamicObjectCounts:GetDynamicObjectCounts().

    Log:PushProperty("DatasetCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:DatasetCount)).

    Log:PushProperty("DataSourceCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:DataSourceCount)).

    Log:PushProperty("BufferCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:BufferCount)).

    Log:PushProperty("ProcedureCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:ProcedureCount)).

    Log:PushProperty("QueryCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:QueryCount)).

    Log:PushProperty("ObjectCount", NEW OpenEdge.Core.Integer(dynamicObjectCounts:ObjectCount)).

  END METHOD.

END CLASS.
