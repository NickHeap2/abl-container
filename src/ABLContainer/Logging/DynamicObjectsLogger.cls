USING ABLContainer.DynamicObjects.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.Core.* FROM ASSEMBLY.
USING Serilog.Events.* FROM ASSEMBLY.
USING System.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Logging.DynamicObjectsLogger IMPLEMENTS ILogEventEnricher :

  METHOD PUBLIC VOID Enrich (logEvent AS CLASS LogEvent, propertyFactory AS CLASS ILogEventPropertyFactory):

    DEFINE VARIABLE dynamicObjectCounts AS DynamicObjectCounts NO-UNDO.

    dynamicObjectCounts = ABLContainer.DynamicObjects.DynamicObjectCounts:GetDynamicObjectCounts().

    DEFINE VARIABLE logEventProperty AS LogEventProperty NO-UNDO.

    logEventProperty = propertyFactory:CreateProperty("DatasetCount", dynamicObjectCounts:DatasetCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

    logEventProperty = propertyFactory:CreateProperty("DataSourceCount", dynamicObjectCounts:DataSourceCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

    logEventProperty = propertyFactory:CreateProperty("BufferCount", dynamicObjectCounts:BufferCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

    logEventProperty = propertyFactory:CreateProperty("ProcedureCount", dynamicObjectCounts:ProcedureCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

    logEventProperty = propertyFactory:CreateProperty("QueryCount", dynamicObjectCounts:QueryCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

    logEventProperty = propertyFactory:CreateProperty("ObjectCount", dynamicObjectCounts:ObjectCount, FALSE).
    logEvent:AddOrUpdateProperty(logEventProperty).

  END METHOD.

END CLASS.
