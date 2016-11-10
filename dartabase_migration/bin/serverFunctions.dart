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
    Map config = DBCore.jsonFilePathToMap("${Uri.decodeQueryComponent(params["projectRootPath"])}/db/config.json");
    closeResWith(res, JSON.encode(config));
}

Future loadMigrations(Map params, HttpResponse res) async {
    String text;
    Map rootSchema = DBCore.jsonFilePathToMap("${Uri.decodeQueryComponent(params["projectRootPath"])}/db/schemaVersion.json");

    var state;
    List<Map> list;
    if (rootSchema["schemaVersion"] == "") {
        state = "newer";
        list = [{"index":0, "version":"no_migration", "state":"current", "actions":{}}];
    } else {
        state = "older";
        list = [{"index":0, "version":"no_migration", "state":"older", "actions":{}}];
    }

    Directory directory = new Directory("${Uri.decodeQueryComponent(params["projectRootPath"])}/db/migrations");
    List<FileSystemEntity> files = directory.listSync()..sort((a, b) => a.path.compareTo(b.path));

    if (files.length > 0) {
        print("Migration number : Name");

        for (int i = 0; i < files.length; i++) {
            File file = new File(files[i].path);
            String version = file.path.split("migrations")[1].replaceAll("\\", "");
            if (rootSchema["schemaVersion"] == version) {
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
    DM.lastMigrationNumber = num.parse(params["index"]);
    DBCore.rootPath = Uri.decodeQueryComponent(params["projectRootPath"]);
    await DM.run(Uri.decodeQueryComponent(params["direction"]), false, null);
    closeResWith(res, "finished migrating version ${params["index"]} ${Uri.decodeQueryComponent(params["direction"])}");
}

Future requestServerStatus(Map params, HttpResponse res) async {
    try {
        var result = await DM.serverStatus(Uri.decodeQueryComponent(params["projectRootPath"]));
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

    await DM.initiateDartabase(Uri.decodeQueryComponent(params["projectRootPath"]), params["name"], false);
    String cleanConfig = writeConfig(params);
    closeResWith(res, "done");
}

writeConfig(Map params) {
    String cleanConfig = Uri.decodeQueryComponent(params["config"]);
    DBCore.stringToFilePath(cleanConfig, "${Uri.decodeQueryComponent(params["projectRootPath"])}/db/config.json");
    return cleanConfig;
}

saveConfig(Map params, HttpResponse res) {
    print(params.toString());
    String cleanConfig = writeConfig(params);
    closeResWith(res, "done");
}

loadSchema(Map params, HttpResponse res) {
    Map schema = DBCore.loadSchemaToMap(Uri.decodeQueryComponent(params["projectRootPath"]));
    closeResWith(res, JSON.encode(schema));
}

createMigration(Map params, HttpResponse res) {
    print(params.toString());
    String cleanMigrationActions = Uri.decodeQueryComponent(params["migrationActions"]);
    Map cleanMigrationActionsMap = JSON.decode(cleanMigrationActions);

    String rootPath = "${Uri.decodeQueryComponent(params["projectRootPath"])}/db/migrations/${cleanMigrationActionsMap["generatedName"]}.json";
    DM.MigrationGenerator.createMigration(cleanMigrationActionsMap, rootPath);

    closeResWith(res, "migration created at $rootPath");
}

Future generateSchemaFromExistingDatabase(Map params, HttpResponse res) async {
    try {
        print(params.toString());
        String rootPath = Uri.decodeQueryComponent(params["projectRootPath"]);
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
        String rootPath = Uri.decodeQueryComponent(params["projectRootPath"]);
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
    String rootPath = Uri.decodeQueryComponent(params["projectRootPath"]);
    DM.schema = DBCore.loadSchemaToMap(rootPath);
    DM.ViewGenerator.run(DM.schema, rootPath);
    closeResWith(res, "views created at ${rootPath}/web/db/*");
}
generateServer(Map params, HttpResponse res) {
    print(params.toString());
    String rootPath = Uri.decodeQueryComponent(params["projectRootPath"]);
    DM.schema = DBCore.loadSchemaToMap(rootPath);
    DM.ServerGenerator.run(DM.schema, rootPath);
    closeResWith(res, "server created at ${rootPath}/db/server/*");
}