USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING ABLContainer.DockerSwarm.* FROM PROPATH.
USING ABLContainer.Logging.* FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Bootstrap.Bootstrap:

  DEFINE PUBLIC STATIC PROPERTY ConnectionStrings AS StringCollection NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY LogicalDatabaseNames AS StringCollection NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY StartupProcedure AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY UseProfiler AS LOGICAL NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY VersionNumber AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY DatabaseRetryMaxSeconds AS INTEGER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY DatabaseRetryMaxAttempts AS INTEGER NO-UNDO
    GET.
    SET.

  METHOD PUBLIC STATIC Configuration BuildConfiguration(environment AS CHARACTER):

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath(".")
      :AddJsonFile("appsettings.json", TRUE)
      :AddJsonFile("appsettings.override.json", TRUE)
      :AddJsonFile(SUBSTITUTE("appsettings.&1.json", environment), TRUE)
      :AddKeyPerFile(".\secrets", TRUE)
      :AddKeyPerFile("C:\ProgramData\Docker\secrets", TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    ABLContainer.Configuration.Configuration:Current = configuration.

    RETURN configuration.

    CATCH ae AS Progress.Lang.AppError :
      MESSAGE ae:GetMessage(1) VIEW-AS ALERT-BOX.
/*      LOG-MANAGER:WRITE-MESSAGE(ae:GetMessage(1), "ERROR") NO-ERROR.*/
      RETURN ?.
    END CATCH.
    CATCH e AS Progress.Lang.Error :
      MESSAGE ae:GetMessage(1) VIEW-AS ALERT-BOX.
/*      LOG-MANAGER:WRITE-MESSAGE(e:GetMessage(1), "ERROR") NO-ERROR.*/
      RETURN ?.
    END CATCH.

  END METHOD.

  METHOD PUBLIC STATIC VOID SetSettings(configuration AS Configuration):
    /* configure logging first */
    SetLoggingSettings(configuration).

    SetOpenEdgeSettings(configuration).

  END METHOD.

  METHOD PUBLIC STATIC VOID Start(environment AS CHARACTER):
    ConnectionStrings = NEW StringCollection().
    LogicalDatabaseNames = NEW StringCollection().
    VersionNumber = "1.1.1".
    DatabaseRetryMaxSeconds = 60.
    DatabaseRetryMaxAttempts = 0.

    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = BuildConfiguration(environment).
    IF NOT VALID-OBJECT(configuration) THEN DO:
/*      MESSAGE "Configuration could not be loaded!".*/
      MESSAGE "Configuration could not be loaded!" VIEW-AS ALERT-BOX.
      RETURN.
    END.

    SetSettings(configuration).

    Log:Information("OpenEdge version: ~{OpenEdgeVersion~}", NEW OpenEdge.Core.String(PROVERSION(1))).
    /*TODO*//* can't do this on linux */
/*    Log:Information(".net runtime version: ~{DotnetRuntimeVersion~}", System.Environment:Version).*/

    Log:Information("ABLContainer version: ~{ABLContainerVersion~}", NEW OpenEdge.Core.String(VersionNumber)).
    Log:Information("StartupProcedure: ~{StartupProcedure~}", NEW OpenEdge.Core.String(StartupProcedure)).
    Log:Information("ProPath: ~{ProPath~}", NEW OpenEdge.Core.String(PROPATH)).
    Log:Information("UseProfiler: ~{UseProfiler~}", NEW OpenEdge.Core.LogicalValue(UseProfiler)).

    IF (NOT ConnectToDatabases()) THEN RETURN.

    IF UseProfiler THEN DO:
      OS-CREATE-DIR VALUE("profile").

      PROFILER:ENABLED = TRUE.
      PROFILER:DIRECTORY = "profile".
      PROFILER:FILE-NAME = SUBSTITUTE("profile/profiler_&1_&2_&3@&4.prof", YEAR(TODAY), MONTH(TODAY), DAY(TODAY), REPLACE(STRING(TIME, "HH:MM:SS"),":","")).
      PROFILER:LISTINGS = TRUE.
      PROFILER:DESCRIPTION = "PROFILER".
      PROFILER:PROFILING = TRUE.
      PROFILER:TRACE-FILTER = "*".
    END.

    /* try and run the startup procedure */
    IF StartupProcedure = ""
      OR (SEARCH(StartupProcedure) = ?
      AND SEARCH(REPLACE(StartupProcedure, ".p", ".r")) = ?)
    THEN DO:
      Log:Error("ERROR: startup procedure (~{StartupProcedure~}) not found!", NEW OpenEdge.Core.String(StartupProcedure)).
      RETURN.
    END.

    _RUNNING_LOOP:
    DO ON STOP UNDO, LEAVE
      ON ERROR UNDO, LEAVE:

      RUN VALUE(StartupProcedure).

      CATCH er AS Progress.Lang.Error :
        Log:Error("Fatal error (~{ErrorType~}) [~{ErrorMessage~}].", NEW OpenEdge.Core.String(STRING(er)), NEW OpenEdge.Core.String(er:GetMessage(1))).
        LEAVE _RUNNING_LOOP.
      END CATCH.
    END.

    IF UseProfiler THEN DO:
      /*turn off profiler and flush the data*/
      PROFILER:ENABLED = FALSE.
      PROFILER:PROFILING = FALSE.
      PROFILER:WRITE-DATA().
    END.

  END METHOD.

  METHOD PUBLIC STATIC VOID SetLoggingSettings(configuration AS Configuration):

    DEFINE VARIABLE dockerSwarmDetails AS DockerSwarmDetails NO-UNDO.
    dockerSwarmDetails = GetSwarmDetails().

    DEFINE VARIABLE logSection AS ConfigurationSection NO-UNDO.
    logSection = configuration:GetSection("Logging").
    IF NOT VALID-OBJECT(logSection) THEN DO:
      RETURN.
    END.
    
    logSection:Bind("ABLContainer.Logging.Log").

  END METHOD.

  METHOD PUBLIC STATIC VOID SetSeriLogSettings(configuration AS Configuration):

    DEFINE VARIABLE dockerSwarmDetails AS DockerSwarmDetails NO-UNDO.
    dockerSwarmDetails = GetSwarmDetails().

  /*TODO*//***
    DEFINE VARIABLE addTestingLogger AS LOGICAL NO-UNDO.
    DEFINE VARIABLE addPerformanceLogging AS LOGICAL NO-UNDO.
    DEFINE VARIABLE addDynamicObjectLogging AS LOGICAL NO-UNDO.

    DEFINE VARIABLE serilogSection AS ConfigurationSection NO-UNDO.
    serilogSection = configuration:GetSection("SeriLog").
    IF NOT VALID-OBJECT(serilogSection) THEN DO:
      RETURN.
    END.

    IF NOT VALID-OBJECT(ABLContainer.Configuration.Configuration:Current) THEN UNDO, THROW NEW AppError("No current configuration is set!").

    DEFINE VARIABLE loggerConfiguration AS LoggerConfiguration NO-UNDO.
    loggerConfiguration = NEW loggerConfiguration().

    DEFINE VARIABLE keyvaluepairs AS StringStringMap NO-UNDO.
    keyvaluepairs = NEW StringStringMap().

    DEFINE VARIABLE addLogContext AS LOGICAL NO-UNDO.

    DEFINE VARIABLE serilogEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    serilogEnumerator = serilogSection:GetChildren().
    _SERILOG:
    DO WHILE(serilogEnumerator:MoveNext()):

      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(serilogEnumerator:Current:Value, ConfigurationSection).

      /*      MESSAGE SUBSTITUTE("configurationSection &1->&2", configurationSection:Key, configurationSection:Value).*/

      IF configurationSection:Key = "Using" THEN DO:
        DEFINE VARIABLE usingEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
        usingEnumerator = configurationSection:GetChildren().
        _USING:
        DO WHILE(usingEnumerator:MoveNext()):
          DEFINE VARIABLE usingSection AS ConfigurationSection NO-UNDO.
          usingSection = CAST(usingEnumerator:Current:Value, ConfigurationSection).
          /*          MESSAGE SUBSTITUTE("Using &1->&2", usingSection:Key, usingSection:Value).*/

          DEFINE VARIABLE cLastPart AS CHARACTER NO-UNDO.
          cLastPart = SUBSTRING(usingSection:Value, R-INDEX(usingSection:Value, ".") + 1).
          keyvaluepairs:Put("using:" + cLastPart, usingSection:Value).
        END. /*_USING*/
      END.
      ELSE IF configurationSection:Key = "MinimumLevel" THEN DO:
        DEFINE VARIABLE minLevelEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
        minLevelEnumerator = configurationSection:GetChildren().
        _MINLEVEL:
        DO WHILE(minLevelEnumerator:MoveNext()):
          DEFINE VARIABLE minLevelSection AS ConfigurationSection NO-UNDO.
          minLevelSection = CAST(minLevelEnumerator:Current:Value, ConfigurationSection).

          IF minLevelSection:Key = "Default" THEN DO:
            keyvaluepairs:Put("minimum-level", minLevelSection:Value).
          END.
          ELSE IF minLevelSection:Key = "Override" THEN DO:
            DEFINE VARIABLE overrideEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
            overrideEnumerator = minLevelSection:GetChildren().
            _OVERRIDE:
            DO WHILE(overrideEnumerator:MoveNext()):
              DEFINE VARIABLE overrideSection AS ConfigurationSection NO-UNDO.
              overrideSection = CAST(overrideEnumerator:Current:Value, ConfigurationSection).

              keyvaluepairs:Put("minimum-level:override:" + overrideSection:Key, overrideSection:Value).
            END.
          END.
        END.
      END.
      ELSE IF configurationSection:Key = "WriteTo" THEN DO:
        DEFINE VARIABLE writeToEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
        writeToEnumerator = configurationSection:GetChildren().
        _WRITETO:
        DO WHILE(writeToEnumerator:MoveNext()):
          DEFINE VARIABLE writeToSection AS ConfigurationSection NO-UNDO.
          writeToSection = CAST(writeToEnumerator:Current:Value, ConfigurationSection).

          DEFINE VARIABLE nameSection AS ConfigurationSection NO-UNDO.
          nameSection = writeToSection:GetSection("Name").
          IF nameSection:VALUE = ? THEN DO:
            NEXT _WRITETO.
          END.

          DEFINE VARIABLE writeToName AS CHARACTER NO-UNDO.
          writeToName = nameSection:Value.

          IF writeToName = "Testing" THEN DO:
            addTestingLogger = TRUE.
            NEXT _WRITETO.
          END.

          keyvaluepairs:Put("write-to:" + writeToName, "").

          DEFINE VARIABLE writeToSettingEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
          writeToSettingEnumerator = writeToSection:GetChildren().
          _WRITETO_SETTINGS:
          DO WHILE(writeToSettingEnumerator:MoveNext()):
            DEFINE VARIABLE writeToSettingSection AS ConfigurationSection NO-UNDO.
            writeToSettingSection = CAST(writeToSettingEnumerator:Current:Value, ConfigurationSection).

            /*            MESSAGE SUBSTITUTE("writeToSettingSection &1->&2", writeToSettingSection:Key, writeToSettingSection:Value).*/
            IF writeToSettingSection:Key = "Args" THEN DO:
              DEFINE VARIABLE argsEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
              argsEnumerator = writeToSettingSection:GetChildren().
              _ARGS:
              DO WHILE(argsEnumerator:MoveNext()):
                DEFINE VARIABLE argsSection AS ConfigurationSection NO-UNDO.
                argsSection = CAST(argsEnumerator:Current:Value, ConfigurationSection).

                /*                MESSAGE SUBSTITUTE("argsSection &1->&2", argsSection:Key, argsSection:Value).*/
                keyvaluepairs:Put("write-to:" + writeToName + "." + argsSection:Key, argsSection:Value).
              END. /*_ARGS*/
            END.
          END. /*_WRITETO_SETTINGS*/

        END. /*_WRITETO*/
      END.
      ELSE IF configurationSection:Key = "Enrich" THEN DO:
        DEFINE VARIABLE enrichEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
        enrichEnumerator = configurationSection:GetChildren().
        _ENRICH:
        DO WHILE(enrichEnumerator:MoveNext()):
          DEFINE VARIABLE enrichSection AS ConfigurationSection NO-UNDO.
          enrichSection = CAST(enrichEnumerator:Current:Value, ConfigurationSection).
          /*          MESSAGE SUBSTITUTE("Enrich &1->&2", enrichSection:Key, enrichSection:Value).*/

          IF enrichSection:Value = "WithMachineName" THEN DO:
            keyvaluepairs:Put("enrich:with-property:MachineName", System.Environment:MachineName).
          END.
          ELSE IF enrichSection:Value = "FromLogContext" THEN DO:
            addLogContext = TRUE.
          END.
          ELSE IF enrichSection:Value = "WithPerformanceCounts" THEN DO:
            addPerformanceLogging = TRUE.
          END.
          ELSE IF enrichSection:Value = "WithDynamicObjectCounts" THEN DO:
            addDynamicObjectLogging = TRUE.
          END.
          ELSE IF enrichSection:Value = "WithSwarmNodeID" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmNodeID", dockerSwarmDetails:Node:ID, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmNodeID", dockerSwarmDetails:Node:ID).
          END.
          ELSE IF enrichSection:Value = "WithSwarmNodeHostname" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmNodeHostname", dockerSwarmDetails:Node:Hostname, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmNodeHostname", dockerSwarmDetails:Node:Hostname).
          END.
          ELSE IF enrichSection:Value = "WithSwarmServiceID" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmServiceID", dockerSwarmDetails:Service:ID, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmServiceID", dockerSwarmDetails:Service:ID).
          END.
          ELSE IF enrichSection:Value = "WithSwarmServiceName" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmServiceName", dockerSwarmDetails:Service:Name, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmServiceName", dockerSwarmDetails:Service:Name).
          END.
          ELSE IF enrichSection:Value = "WithSwarmServiceLabels" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmServiceLabels", dockerSwarmDetails:Service:Labels, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmServiceLabels", dockerSwarmDetails:Service:Labels).
          END.
          ELSE IF enrichSection:Value = "WithSwarmTaskID" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmTaskID", dockerSwarmDetails:Task:ID, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmTaskID", dockerSwarmDetails:Task:ID).
          END.
          ELSE IF enrichSection:Value = "WithSwarmTaskName" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmTaskName", dockerSwarmDetails:Task:Name, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmTaskName", dockerSwarmDetails:Task:Name).
          END.
          ELSE IF enrichSection:Value = "WithSwarmTaskSlot" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("SwarmTaskSlot", dockerSwarmDetails:Task:Slot, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:SwarmTaskSlot", dockerSwarmDetails:Task:Slot).
          END.
          ELSE IF enrichSection:Value = "WithProcessId" THEN DO:
/*            Serilog.Context.LogContext:PushProperty("ProcessId", System.Diagnostics.Process:GetCurrentProcess():Id, FALSE).*/
            keyvaluepairs:Put("enrich:with-property:ProcessId", STRING(System.Diagnostics.Process:GetCurrentProcess():Id)).
          END.
        END. /*_ENRICH*/
      END.
      ELSE IF configurationSection:Key = "Properties" THEN DO:
        DEFINE VARIABLE propertyEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
        propertyEnumerator = configurationSection:GetChildren().
        _PROPERTY:
        DO WHILE(propertyEnumerator:MoveNext()):
          DEFINE VARIABLE propertySection AS ConfigurationSection NO-UNDO.
          propertySection = CAST(propertyEnumerator:Current:Value, ConfigurationSection).
          /*          MESSAGE SUBSTITUTE("Properties &1->&2", usingSection:Key, usingSection:Value).*/

          keyvaluepairs:Put("enrich:with-property:" + propertySection:Key, propertySection:Value).
        END. /*_PROPERTY*/
      END.

    END. /*SERILOG*/

    loggerConfiguration:ReadFrom:KeyValuePairs(keyvaluepairs).
    IF addLogContext THEN DO:
      loggerConfiguration:Enrich:FromLogContext().
    END.

    /* allow hook into logs for testing */
    IF addTestingLogger THEN DO:
      DEFINE VARIABLE textFormatter AS ITextFormatter NO-UNDO.
      textFormatter = DYNAMIC-INVOKE("ABLContainer.Logging.TestFormatter", "GetFormatter").
      loggerConfiguration = Serilog.ConsoleLoggerConfigurationExtensions:Console(loggerConfiguration:WriteTo, textFormatter, LogEventLevel:Debug, ?, ?).
    END.

    /* add performance context to logs */
    IF addPerformanceLogging THEN DO:
      DEFINE VARIABLE performanceLoggingEnrichers AS ILogEventEnricher EXTENT 1 NO-UNDO.
      performanceLoggingEnrichers[1] = NEW PerformanceLogger().

      loggerConfiguration:Enrich:With(performanceLoggingEnrichers).
    END.

    /* add dynamic object context to logs */
    IF addDynamicObjectLogging THEN DO:
      DEFINE VARIABLE dynamicObjectEnrichers AS ILogEventEnricher EXTENT 1 NO-UNDO.
      dynamicObjectEnrichers[1] = NEW DynamicObjectsLogger().

      loggerConfiguration:Enrich:With(dynamicObjectEnrichers).
    END.

    Serilog.Debugging.SelfLog:Enable(System.Console:Error).
    Serilog.Log:Logger = loggerConfiguration:CreateLogger().

    Serilog.Log:Logger:Information("Serilog has been configured.").

    DEFINE VARIABLE kvpEnumerator AS "System.Collections.Generic.IEnumerator<System.Collections.Generic.KeyValuePair<character, character>>" NO-UNDO.
    kvpEnumerator = keyvaluepairs:GetEnumerator().
    DO WHILE(kvpEnumerator:MoveNext()):
      Serilog.Log:Logger:Debug(SUBSTITUTE("    Serilog setting: &1=&2", kvpEnumerator:Current:Key, kvpEnumerator:Current:Value)).
    END.

    DEFINE VARIABLE configurationEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, CHARACTER>+Enumerator" NO-UNDO.
    configurationEnumerator = ABLContainer.Configuration.Configuration:Current:GetChildren().

    Log:Debug("Configuration").
    DO WHILE(configurationEnumerator:MoveNext()):
      Log:Debug("  ~{Key~}=~{Value~}", NEW OpenEdge.Core.String(configurationEnumerator:Current:Key), NEW OpenEdge.Core.String(configurationEnumerator:Current:Value)).
    END.*/
  END METHOD.

  METHOD PRIVATE STATIC DockerSwarmDetails GetSwarmDetails():
    DEFINE VARIABLE dockerSwarmDetails AS DockerSwarmDetails NO-UNDO.

    dockerSwarmDetails = NEW DockerSwarmDetails().
    dockerSwarmDetails:Node = NEW Node().
    dockerSwarmDetails:Node:ID = EnvVars:GetEnvVar("SWARM_NODE_ID").
    dockerSwarmDetails:Node:Hostname = EnvVars:GetEnvVar("SWARM_NODE_HOSTNAME").

    dockerSwarmDetails:Service = NEW Service().
    dockerSwarmDetails:Service:ID = EnvVars:GetEnvVar("SWARM_SERVICE_ID").
    dockerSwarmDetails:Service:Name = EnvVars:GetEnvVar("SWARM_SERVICE_NAME").
    dockerSwarmDetails:Service:Labels = EnvVars:GetEnvVar("SWARM_SERVICE_LABELS").

    dockerSwarmDetails:Task = NEW Task().
    dockerSwarmDetails:Task:ID = EnvVars:GetEnvVar("SWARM_TASK_ID").
    dockerSwarmDetails:Task:Name = EnvVars:GetEnvVar("SWARM_TASK_NAME").
    dockerSwarmDetails:Task:Slot = EnvVars:GetEnvVar("SWARM_TASK_SLOT").

    RETURN dockerSwarmDetails.
  END METHOD.

  METHOD PUBLIC STATIC LOGICAL ConnectToDatabases():
    DEFINE VARIABLE connectRetrySeconds AS INTEGER NO-UNDO.
    DEFINE VARIABLE connectRetryAttempt AS INTEGER NO-UNDO.

    connectRetrySeconds = 1.
    connectRetryAttempt = 1.
    _CONNECT_DATABASES:
    DO WHILE TRUE ON ERROR UNDO, RETURN FALSE:
      IF (DatabaseConnectionAttempt()) THEN LEAVE _CONNECT_DATABASES.

      /* incremental pause up to the limit */
      Log:Information("Pausing ~{PauseSeconds~} seconds for databases to become available...", NEW OpenEdge.Core.Integer(connectRetrySeconds)).
      PAUSE connectRetrySeconds NO-MESSAGE.
      connectRetrySeconds = connectRetrySeconds * 2.
      IF connectRetrySeconds > DatabaseRetryMaxSeconds THEN DO:
        connectRetrySeconds = DatabaseRetryMaxSeconds.
      END.

      /* limit the max attempts? */
      IF DatabaseRetryMaxAttempts > 0 THEN DO:
        IF connectRetryAttempt >= DatabaseRetryMaxAttempts THEN DO:
          Log:Error("Databases not connected after ~{ConnectionAttempts~} attempts!", NEW OpenEdge.Core.Integer(connectRetryAttempt)).
          RETURN FALSE.
        END.

        connectRetryAttempt = connectRetryAttempt + 1.
      END.
    END. /*_CONNECT_DATABASES*/

    RETURN TRUE.
  END METHOD.

  METHOD PUBLIC STATIC LOGICAL DatabaseConnectionAttempt():
    DEFINE VARIABLE logicalDatabaseNamesEnumerator AS IIterator NO-UNDO.
    DEFINE VARIABLE connectionStringsEnumerator AS IIterator NO-UNDO.

    connectionStringsEnumerator = ConnectionStrings:Iterator().
    logicalDatabaseNamesEnumerator = LogicalDatabaseNames:Iterator().
    _CONNECT_DATABASE:
    DO WHILE(connectionStringsEnumerator:HasNext()):
      DEFINE VARIABLE currentConnectionString AS OpenEdge.Core.String NO-UNDO.
      currentConnectionString = CAST(connectionStringsEnumerator:Next(), OpenEdge.Core.String).
      DEFINE VARIABLE databaseConnectionString AS CHARACTER NO-UNDO.
      databaseConnectionString = currentConnectionString:ToString().

      DEFINE VARIABLE currentLogicalDatabaseName AS OpenEdge.Core.String NO-UNDO.
      currentLogicalDatabaseName = CAST(logicalDatabaseNamesEnumerator:Next(), OpenEdge.Core.String).
      DEFINE VARIABLE logicalDatabaseName AS CHARACTER NO-UNDO.
      logicalDatabaseName = currentLogicalDatabaseName:ToString().

      IF CONNECTED(logicalDatabaseName) THEN DO:
        NEXT _CONNECT_DATABASE.
      END.

      DEFINE VARIABLE redactedDatabaseConnectionString AS CHARACTER NO-UNDO.
      redactedDatabaseConnectionString = databaseConnectionString.

      DEFINE VARIABLE passwordIndex AS INTEGER NO-UNDO.
      passwordIndex = LOOKUP("-P", redactedDatabaseConnectionString, " ").
      IF passwordIndex <> 0 THEN DO:
        passwordIndex = passwordIndex + 1.
        ENTRY(passwordIndex, redactedDatabaseConnectionString, " ") = FILL("*", LENGTH(ENTRY(passwordIndex, redactedDatabaseConnectionString, " "))).
      END.

      Log:Information("Connecting to database with connection string (~{ConnectionString~})...", NEW OpenEdge.Core.String(redactedDatabaseConnectionString)).
      DO ON ERROR UNDO, LEAVE
         ON STOP UNDO, LEAVE:
        CONNECT VALUE(databaseConnectionString) NO-ERROR.
      END.
      IF ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
        Log:Error("ERROR: Couldn't connect to database! [~{ErrorMessage~}]", NEW OpenEdge.Core.String(ERROR-STATUS:GET-MESSAGE(1))).
        RETURN FALSE.
      END.
    END. /*_CONNECT_DATABASE*/

    RETURN TRUE.
  END.

  METHOD PUBLIC STATIC VOID SetOpenEdgeSettings(configuration AS Configuration):
    DEFINE VARIABLE openedgeSection AS ConfigurationSection NO-UNDO.
    openedgeSection = configuration:GetSection("OpenEdge").
    IF NOT VALID-OBJECT(openedgeSection) THEN DO:
      RETURN.
    END.

    DEFINE VARIABLE openedgeIterator AS IIterator NO-UNDO.
    openedgeIterator = openedgeSection:GetChildren().
    _OPENEDGE:
    DO WHILE(openedgeIterator:HasNext()):
      DEFINE VARIABLE nextConfigurationSection AS IMapEntry NO-UNDO.
      nextConfigurationSection = CAST(openedgeIterator:Next(), IMapEntry).

      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(nextConfigurationSection:Value, ConfigurationSection).

/*      MESSAGE SUBSTITUTE("configurationSection &1->&2", configurationSection:Key, configurationSection:Value).*/

      IF configurationSection:Key = "startupProcedure" THEN DO:
        Bootstrap:StartupProcedure = configurationSection:Value.
      END.
      ELSE IF configurationSection:Key = "propath" THEN DO:
        /* trap error here as change of propath whilst .pl is loaded causes error */
        PROPATH = configurationSection:Value NO-ERROR.
      END.
      ELSE IF configurationSection:Key = "profiler" THEN DO:
        Bootstrap:UseProfiler = LOGICAL(configurationSection:Value).
      END.
      ELSE IF configurationSection:Key = "databases" THEN DO:
        DEFINE VARIABLE databaseSection     AS ConfigurationSection NO-UNDO.
        DEFINE VARIABLE databasesIterator AS IIterator            NO-UNDO.

        databasesIterator = configurationSection:GetChildren().
        _DATABASE:
        DO WHILE(databasesIterator:HasNext()):
          DEFINE VARIABLE nextDatabaseSection AS IMapEntry NO-UNDO.
          nextDatabaseSection = CAST(databasesIterator:Next(), IMapEntry).

          databaseSection = CAST(nextDatabaseSection:Value, ConfigurationSection).
          /*          MESSAGE SUBSTITUTE("databaseSection &1->&2", databaseSection:Key, databaseSection:Value).*/
          DEFINE VARIABLE dbSettingSection         AS ConfigurationSection NO-UNDO.
          DEFINE VARIABLE databaseIterator         AS IIterator            NO-UNDO.

          DEFINE VARIABLE databaseConnectionString AS CHARACTER                                                                    NO-UNDO.

          databaseConnectionString = " -ct 1".
          databaseIterator = databaseSection:GetChildren().
          _DB_SETTING:
          DO WHILE(databaseIterator:HasNext()):
            DEFINE VARIABLE nextDbSettingSection AS IMapEntry NO-UNDO.
            nextDbSettingSection = CAST(databaseIterator:Next(), IMapEntry).

            dbSettingSection = CAST(nextDbSettingSection:Value, ConfigurationSection).
            /*            MESSAGE SUBSTITUTE("dbSettingSection &1->&2", dbSettingSection:Key, dbSettingSection:Value).*/

            IF dbSettingSection:Key = ("db") THEN DO:
              databaseConnectionString = databaseConnectionString + " -db " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("host") THEN DO:
              databaseConnectionString = databaseConnectionString + " -H " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("port") THEN DO:
              databaseConnectionString = databaseConnectionString + " -S " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("logical") THEN DO:
              databaseConnectionString = databaseConnectionString + " -ld " + dbSettingSection:Value.
              ABLContainer.Bootstrap.Bootstrap:LogicalDatabaseNames:Add(dbSettingSection:Value).
            END.
            ELSE IF dbSettingSection:Key = ("username") THEN DO:
              databaseConnectionString = databaseConnectionString + " -U " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("password") THEN DO:
              databaseConnectionString = databaseConnectionString + " -P " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("other") THEN DO:
              databaseConnectionString = databaseConnectionString + " " + dbSettingSection:Value.
            END.
          END. /*_DB_SETTING*/

          IF databaseConnectionString <> "" THEN DO:
            /*remove first blank */
            databaseConnectionString = TRIM(databaseConnectionString).
            ABLContainer.Bootstrap.Bootstrap:ConnectionStrings:Add(databaseConnectionString).
          END.

        END. /*_DATABASE*/

      END. /*databases*/
      ELSE IF configurationSection:Key = "databaseRetryMaxSeconds" THEN DO:
        databaseRetryMaxSeconds = INTEGER(configurationSection:Value) NO-ERROR.
      END. /*databaseRetryMaxSeconds*/
      ELSE IF configurationSection:Key = "databaseRetryMaxAttempts" THEN DO:
        DatabaseRetryMaxAttempts = INTEGER(configurationSection:Value) NO-ERROR.
      END. /*databaseRetryMaxAttempts*/

    END. /*_OPENEDGE*/

  END METHOD.


END CLASS.
