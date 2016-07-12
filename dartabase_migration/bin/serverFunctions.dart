part of dartabaseMigration;

loadProjectMapping(Map params, HttpResponse res) {
    String text;
    DM.projectMapping = DBCore.jsonFilePathToMap("bin/projectsMapping.json");
    if (!DM.projectMapping.isEmpty) {
        print("found ${DM.projectMapping.length} userAccounts");
        text = JSON.encode(DM.projectMapping);
    } else {
        print(JSON.encode({"no projects found":""}));
        text = JSON.encode({"no projects found":""});
    }
    closeResWith(res, text);
}

loadConfig(Map params, HttpResponse res) {
    Map config = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C', '\\')}/db/config.json");
    closeResWith(res, JSON.encode(config));
}

Future loadMigrations(Map params, HttpResponse res) async {
    String text;
    Map rootSchema = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C', '\\')}/db/schemaVersion.json");

    var state;
    List<Map> list;
    if (rootSchema['schemaVersion'] == "") {
        state = "newer";
        list = [{"index":0, "version":"no_migration", "state":"current", "actions":{}}];
    } else {
        state = "older";
        list = [{"index":0, "version":"no_migration", "state":"older", "actions":{}}];
    }

    Directory directory = new Directory("${params["projectRootPath"].replaceAll('%5C', '\\')}/db/migrations");
    List<FileSystemEntity> files = directory.listSync();
    if (files.length > 0) {
        print("Migration number : Name");

        for (int i = 0; i < files.length; i++) {
            File file = new File(files[i].path);
            String version = file.path.split("migrations")[1].replaceAll("\\", "");
            if (rootSchema['schemaVersion'] == version) {
                list.add({
                    "index":i + 1,
                    "version":version,
                    "state":"current",
                    "actions":(DBCore.jsonFilePathToMap(file.path))
                });
                print("${i + 1} : $version <--- current version");
                state = "newer";
            } else {
                list.add({
                    "index":i + 1,
                    "version":version,
                    "state":state,
                    "actions":(DBCore.jsonFilePathToMap(file.path))
                });
                print("${i + 1} : $version");
            }
        }
        text = JSON.encode(list);
    } else {
        print("no migrations found");
        text = JSON.encode(list);
    }
    closeResWith(res, text);
}

Future runMigration(Map params, HttpResponse res) async {
    DM.lastMigrationNumber = num.parse(params['index']);
    DBCore.rootPath = params["projectRootPath"].replaceAll('%5C', '\\');
    await DM.run(params["direction"], false, null);
    closeResWith(res, "finished migrating version ${params['index']} ${params["direction"]}");
}

Future requestServerStatus(Map params, HttpResponse res) async {
    try {
        var result = await DM.serverStatus(params["projectRootPath"].replaceAll('%5C', '\\'));
        if (result.toString().toLowerCase().contains("error")) {
            closeResWith(res, result);
        } else {
            closeResWith(res, "running");
        }
    } catch (exception, stackTrace) {
        closeResWith(res, "connection problem $stackTrace");
    }
}

Future initiateDartabase(Map params, HttpResponse res) async {
    print(params.toString());

    await DM.initiateDartabase(params["projectRootPath"].replaceAll('%5C', '\\'), params['name'], false);
    String cleanConfig = writeConfig(params);
    closeResWith(res, "done");
}

writeConfig(Map params) {
    String cleanConfig = params['config'].replaceAll('%5C', '\\').replaceAll('%7B', '{').replaceAll('%22', '"').replaceAll('%7D', '}');

    DBCore.stringToFilePath(cleanConfig, "${params['projectRootPath'].replaceAll('%5C', '\\')}/db/config.json");
    return cleanConfig;
}

saveConfig(Map params, HttpResponse res) {
    print(params.toString());
    String cleanConfig = writeConfig(params);
    closeResWith(res, "done");
}

loadSchema(Map params, HttpResponse res) {
    Map schema = DBCore.loadSchemaToMap(params["projectRootPath"].replaceAll('%5C', '\\'));
    closeResWith(res, JSON.encode(schema));
}

createMigration(Map params, HttpResponse res) {
    print(params.toString());
    String cleanMigrationActions = params['migrationActions'].replaceAll('%5C', '\\').replaceAll('%7B', '{').replaceAll('%22', '"')
            .replaceAll('%20', ' ').replaceAll('%7D', '}').replaceAll('%5B', '[')
            .replaceAll('%5D', ']');
    Map cleanMigrationActionsMap = JSON.decode(cleanMigrationActions);

    String rootPath = "${params['projectRootPath'].replaceAll(
            '%5C', '\\')}/db/migrations/${cleanMigrationActionsMap["generatedName"]}.json";
    DM.MigrationGenerator.createMigration(cleanMigrationActionsMap, rootPath);

    closeResWith(res, "migration created at $rootPath");
}

Future generateSchemaFromExistingDatabase(Map params, HttpResponse res) async {
    try {
        print(params.toString());
        String rootPath = params["projectRootPath"].replaceAll('%5C', '\\');
        var tableNames = await DM.extractExistingDatabaseTableNames(rootPath);
        Map m = {};

        for (String tableName in tableNames) {
            if (tableName.contains("_2_")) {
                m.addAll({"relationDivider":"2"});
            } else if (tableName.contains("_to_")) {
                m.addAll({"relationDivider":"to"});
            }
            Map tableDesc = await DM.extractExistingTableDescription(tableName, rootPath);
            m.addAll(tableDesc);
        }
        DBCore.mapToJsonFilePath(m, "${rootPath}/db/schema.json");

        closeResWith(res, "generated SchemaFromExistingDatabase at ${rootPath}/db/schema.dart");
    } catch (exception, stackTrace) {
        closeResWith(res, "connection problem $stackTrace");
    }
}

Future generateModels(Map params, HttpResponse res) async {
    try {
        print(params.toString());
        String rootPath = params["projectRootPath"].replaceAll('%5C', '\\');
        var tableNames = await DM.extractExistingDatabaseTableNames(rootPath);
        Map m = {};
        for (String tableName in tableNames) {
            var tableDesc = await DM.extractExistingTableDescription(tableName, rootPath);
            m.addAll(tableDesc);
            DM.ModelGenerator.createServerModel(tableName, tableDesc, rootPath);
        }
        closeResWith(res, "models created at ${rootPath}/db/models/*.dart");
    } catch (exception, stackTrace) {
        closeResWith(res, "connection problem $stackTrace");
    }
}

generateViews(Map params, HttpResponse res) {
    print(params.toString());
    String rootPath = params["projectRootPath"].replaceAll('%5C', '\\');
    DM.schema = DBCore.loadSchemaToMap(rootPath);
    DM.ViewGenerator.run(DM.schema, rootPath);
    closeResWith(res, "views created at ${rootPath}/web/db/*");
}
generateServer(Map params, HttpResponse res) {
    print(params.toString());
    String rootPath = params["projectRootPath"].replaceAll('%5C', '\\');
    DM.schema = DBCore.loadSchemaToMap(rootPath);
    DM.ServerGenerator.run(DM.schema, rootPath);
    closeResWith(res, "server created at ${rootPath}/db/server/*");
}