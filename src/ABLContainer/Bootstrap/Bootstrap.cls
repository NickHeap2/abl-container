USING ABLContainer.Logging.* FROM PROPATH.
USING ABLContainer.Bootstrap.* FROM PROPATH.
USING ABLContainer.Configuration.* FROM PROPATH.
USING Progress.Lang.*.
USING Serilog.* FROM ASSEMBLY.
USING Serilog.Log.* FROM ASSEMBLY.
USING Serilog.Sinks.* FROM ASSEMBLY.
USING System.Collections.Generic.* FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.Bootstrap.Bootstrap: 

  DEFINE PUBLIC STATIC PROPERTY ConnectionStrings AS "System.Collections.Generic.List<character>" NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY StartupProcedure AS CHARACTER NO-UNDO
    GET.
    SET.

  DEFINE PUBLIC STATIC PROPERTY UseProfiler AS LOGICAL NO-UNDO
    GET.
    SET.

  METHOD PUBLIC STATIC Configuration BuildConfiguration(environment AS CHARACTER):

    DEFINE VARIABLE configurationBuilder AS ConfigurationBuilder NO-UNDO.
    DEFINE VARIABLE configuration        AS Configuration        NO-UNDO.

    configurationBuilder = NEW ConfigurationBuilder().
    configurationBuilder
      :SetBasePath(".")
      :AddJsonFile("appsettings.json", TRUE)
      :AddJsonFile(SUBSTITUTE("appsettings.&1.json", environment), TRUE)
      :AddEnvironmentVariables().
    configuration = configurationBuilder:Build().
    ABLContainer.Configuration.Configuration:Current = configuration.
    
    RETURN configuration.
  END METHOD.
  
  METHOD PUBLIC STATIC VOID SetSettings(configuration AS Configuration):
    /* configure logging first */
    SetSeriLogSettings(configuration).

    SetOpenEdgeSettings(configuration).

  END METHOD.
  
  METHOD PUBLIC STATIC VOID Start(environment AS CHARACTER):
    ConnectionStrings = NEW "System.Collections.Generic.List<character>"().

    DEFINE VARIABLE configuration AS Configuration NO-UNDO.
    configuration = BuildConfiguration(environment).

    SetSettings(configuration).

    Log:Information("StartupProcedure: ~{StartupProcedure~}", BOX(StartupProcedure)).
    Log:Information("ProPath: ~{ProPath~}", BOX(PROPATH)).
    Log:Information("UseProfiler: ~{UseProfiler~}", BOX(UseProfiler)).

    IF (NOT ConnectToDatabases()) THEN DO:
      RETURN.
    END.
    ELSE DO:
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
    
      /*    MESSAGE "StartupProcedure->" + StartupProcedure.*/
      /*    MESSAGE "ProPath->" + UseProPath.               */
      /*    MESSAGE "UseProfiler->" + STRING(UseProfiler).  */
    
      /* try and run the startup procedure */
      IF StartupProcedure = ""
        OR (SEARCH(StartupProcedure) = ?
        AND SEARCH(REPLACE(StartupProcedure, ".p", ".r")) = ?)
      THEN DO:
        MESSAGE "proc not found".
        Log:Error("ERROR: startup procedure (~{StartupProcedure~}) not found!", BOX(StartupProcedure)).
        RETURN.
      END.
    
      _RUNNING_LOOP:
      DO ON STOP UNDO, LEAVE
        ON ERROR UNDO, LEAVE:
        
        RUN VALUE(StartupProcedure).
    
        CATCH er AS Progress.Lang.Error :
          MESSAGE "fatal error".
          Log:Error("Fatal error (~{ErrorType~}) [~{ErrorMessage~}].", BOX(STRING(er)), BOX(er:GetMessage(1))).
          LEAVE _RUNNING_LOOP.
        END CATCH.
      END.
    END. /* databases connected */

    IF UseProfiler THEN DO:
      /*turn off profiler and flush the data*/
      PROFILER:ENABLED = FALSE.
      PROFILER:PROFILING = FALSE.
      PROFILER:WRITE-DATA().
    END.

  END METHOD.  
  
  METHOD PUBLIC STATIC VOID SetSeriLogSettings(configuration AS Configuration):
    DEFINE VARIABLE serilogSection AS ConfigurationSection NO-UNDO.
    serilogSection = configuration:GetSection("SeriLog").
    IF NOT VALID-OBJECT(serilogSection) THEN DO:
      RETURN.
    END.
  
    DEFINE VARIABLE loggerConfiguration AS LoggerConfiguration NO-UNDO.
    loggerConfiguration = NEW loggerConfiguration().
  
    DEFINE VARIABLE keyvaluepairs AS "IList<System.Collections.Generic.KeyValuePair<character, character>>" NO-UNDO.
    keyvaluepairs = NEW "List<System.Collections.Generic.KeyValuePair<character, character>>"().
  
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
          keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("using:" + cLastPart, usingSection:Value)).
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
            keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("minimum-level", minLevelSection:Value)). 
          END. 
          ELSE IF minLevelSection:Key = "Override" THEN DO:
            DEFINE VARIABLE overrideEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
            overrideEnumerator = minLevelSection:GetChildren().
            _OVERRIDE:
            DO WHILE(overrideEnumerator:MoveNext()):
              DEFINE VARIABLE overrideSection AS ConfigurationSection NO-UNDO.
              overrideSection = CAST(overrideEnumerator:Current:Value, ConfigurationSection).
          
              keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("minimum-level:override:" + overrideSection:Key, overrideSection:Value)).              
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
      
          DEFINE VARIABLE writeToName              AS CHARACTER                                                                    NO-UNDO.

          DEFINE VARIABLE nameSection AS ConfigurationSection NO-UNDO.
          nameSection = writeToSection:GetSection("Name").
          IF nameSection:VALUE = ? THEN DO:
            NEXT _WRITETO.
          END.

          writeToName = nameSection:Value.
          keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<System.String, System.String>"("write-to:" + writeToName, "")).
      
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
                keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("write-to:" + writeToName + "." + argsSection:Key, argsSection:Value)).
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
          /*          MESSAGE SUBSTITUTE("Enrich &1->&2", usingSection:Key, usingSection:Value).*/

          IF enrichSection:Key = "WithMachineName" THEN DO:
            keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("enrich:with-property:MachineName", System.Environment:MachineName)).
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

          keyvaluepairs:Add(NEW "System.Collections.Generic.KeyValuePair<character, character>"("enrich:with-property:" + propertySection:Key, propertySection:Value)).
        END. /*_PROPERTY*/
      END.
  
    END. /*SERILOG*/

    loggerConfiguration:ReadFrom:KeyValuePairs(keyvaluepairs).
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
      Log:Debug("  ~{Key~}=~{Value~}", BOX(configurationEnumerator:Current:Key), BOX(configurationEnumerator:Current:Value)).            
    END.
  
  END METHOD.
  
  METHOD PUBLIC STATIC LOGICAL ConnectToDatabases():
    DEFINE VARIABLE connectionStringsEnumerator AS "System.Collections.Generic.List<character>+Enumerator" NO-UNDO.
    
    connectionStringsEnumerator = ConnectionStrings:GetEnumerator().
    DO WHILE(connectionStringsEnumerator:MoveNext()):
      DEFINE VARIABLE databaseConnectionString AS CHARACTER NO-UNDO.
        
      databaseConnectionString = connectionStringsEnumerator:Current.

      Log:Information("Connecting to database with connection string (~{ConnectionString~})...", BOX(databaseConnectionString)).
      CONNECT VALUE(databaseConnectionString) NO-ERROR.
      IF ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
        Log:Error("ERROR: Couldn't connect to database!").
        Log:Error("ERROR: ~{ErrorMessage~}", BOX(ERROR-STATUS:GET-MESSAGE(1))).
        RETURN FALSE.
      END.
    END.
  
    RETURN TRUE.
  END.
  
  METHOD PUBLIC STATIC VOID SetOpenEdgeSettings(configuration AS Configuration):
    DEFINE VARIABLE openedgeSection AS ConfigurationSection NO-UNDO.
    openedgeSection = configuration:GetSection("OpenEdge").
    IF NOT VALID-OBJECT(openedgeSection) THEN DO:
      RETURN.
    END.
    
    DEFINE VARIABLE openedgeEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    openedgeEnumerator = openedgeSection:GetChildren().
    _OPENEDGE:
    DO WHILE(openedgeEnumerator:MoveNext()):

      DEFINE VARIABLE configurationSection AS ConfigurationSection NO-UNDO.
      configurationSection = CAST(openedgeEnumerator:Current:Value, ConfigurationSection).
      
      /*      MESSAGE SUBSTITUTE("configurationSection &1->&2", configurationSection:Key, configurationSection:Value).*/
      
      IF configurationSection:Key = "startupProcedure" THEN DO:
        Bootstrap:StartupProcedure = configurationSection:Value.
      END.
      ELSE IF configurationSection:Key = "propath" THEN DO:
        PROPATH = configurationSection:Value.
      END.
      ELSE IF configurationSection:Key = "profiler" THEN DO:
        Bootstrap:UseProfiler = LOGICAL(configurationSection:VALUE).
      END.
      ELSE IF configurationSection:Key = "databases" THEN DO:
        DEFINE VARIABLE databaseSection     AS ConfigurationSection                                                         NO-UNDO.
        DEFINE VARIABLE databasesEnumerator AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.
    
        databasesEnumerator = configurationSection:GetChildren().
    
        _DATABASE:
        DO WHILE(databasesEnumerator:MoveNext()):

          databaseSection = CAST(databasesEnumerator:Current:Value, ConfigurationSection).
          /*          MESSAGE SUBSTITUTE("databaseSection &1->&2", databaseSection:Key, databaseSection:Value).*/
          DEFINE VARIABLE dbSettingSection         AS ConfigurationSection                                                         NO-UNDO.
          DEFINE VARIABLE databaseEnumerator       AS "System.Collections.Generic.Dictionary<CHARACTER, System.Object>+Enumerator" NO-UNDO.

          DEFINE VARIABLE databaseConnectionString AS CHARACTER                                                                    NO-UNDO.

          databaseConnectionString = "".          
          databaseEnumerator = databaseSection:GetChildren().
          _DB_SETTING:
          DO WHILE(databaseEnumerator:MoveNext()):
            dbSettingSection = CAST(databaseEnumerator:Current:Value, ConfigurationSection).
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
            END.
            ELSE IF dbSettingSection:Key = ("username") THEN DO:
              databaseConnectionString = databaseConnectionString + " -U " + dbSettingSection:Value.
            END.
            ELSE IF dbSettingSection:Key = ("password") THEN DO:
              databaseConnectionString = databaseConnectionString + " -P " + dbSettingSection:Value.
            END.
          END. /*_DB_SETTING*/

          IF databaseConnectionString <> "" THEN DO:
            /*remove first blank */
            databaseConnectionString = TRIM(databaseConnectionString).
            ABLContainer.Bootstrap.Bootstrap:ConnectionStrings:Add(databaseConnectionString).
          END.
    
        END. /*_DATABASE*/
  
      END. /*databases*/

    END. /*_OPENEDGE*/

  END METHOD.
  

END CLASS.