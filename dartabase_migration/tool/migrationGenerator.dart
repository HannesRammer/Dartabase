part of dartabaseMigration;

//TODO think about making dartabase_core lib that gets imported by dartabase tools
class MigrationGenerator {


    /*static void createTableJson(var project){
        String string = '''"createTable": {\n''';
        String tables = "";
        for(var table in project.migrationActions.createTables){
            string += '''  "${table.name}": { \n''';
            List list =[];
            for(var column in table.columns) {
                list.add('''    "${column.name}": {"type":"${column.type}","default":"${column.def}","null":"${column.nil}"}''');
            }
            string += list.join(",\n");
        }
        string += '''  }''';
        string += '''}''';
        DBCore.mapToJsonFilePath(string,"")
    }
*/
    static Map map = {"UP":{}, "DOWN":{}};

    static void createMigration(Map migrationActionsMap, String rootPath) {
        Map migration = generateMigration(migrationActionsMap);
        DBCore.mapToJsonFilePath(migration, rootPath);
    }

    static Map generateMigration(Map migrationActionsMap) {
        map = {"UP":{}, "DOWN":{}};
        createTableJson(migrationActionsMap["createTables"], "UP");
        createColumnJson(migrationActionsMap["createColumns"], "UP");
        removeColumnJson(migrationActionsMap["removeColumns"], "UP");
        removeTableJson(migrationActionsMap["removeTables"], "UP");
        createRelationJson(migrationActionsMap["createRelations"], "UP");
        removeRelationJson(migrationActionsMap["removeRelations"], "UP");

        createTableJson(migrationActionsMap["removeTables"], "DOWN");
        createColumnJson(migrationActionsMap["removeColumns"], "DOWN");
        removeColumnJson(migrationActionsMap["createColumns"], "DOWN");
        removeTableJson(migrationActionsMap["createTables"], "DOWN");
        createRelationJson(migrationActionsMap["removeRelations"], "DOWN");
        removeRelationJson(migrationActionsMap["createRelations"], "DOWN");

        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        String prettyprint = encoder.convert(map);

        print("Generated Migration:${prettyprint}");
        return map;
    }

    static String defaultValue(var value) {
        if (value == null) {
            return "";
        } else {
            return value;
        }
    }

    static bool nullValue(var value) {
        if (value == null || value == "true") {
            return true;
        } else if (value == "false") {
            return false;
        } else {
            return value;
        }
    }

    static void createTableJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {
            if (tables["${table["name"]}"] == null) {
                tables["${table["name"]}"] = {};
            }
            for (var column in table["columns"]) {
                if (column["name"] != "id" && column["name"] != "created_at" &&
                        column["name"] != "updated_at") {
                    if (tables["${table["name"]}"]["${column["name"]}"] ==
                            null) {
                        tables["${table["name"]}"]["${column["name"]}"] = {};
                    }
                    String defVal = defaultValue(column["default"]);
                    bool nullVal = nullValue(column["null"]);
                    tables["${table["name"]}"]["${column["name"]}"] = {
                        "type":"${column["type"]}",
                        "default":"${defVal}",
                        "null":"${nullVal}"
                    };
                }
            }
        }
        if (tables.length > 0) {
            map[direction]["createTable"] = tables;
        }
    }

    static void createColumnJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {
            if (tables["${table["name"]}"] == null) {
                tables["${table["name"]}"] = {};
            }
            for (var column in table["columns"]) {
                if (column["name"] != "id" && column["name"] != "created_at" &&
                        column["name"] != "updated_at") {
                    if (tables["${table["name"]}"]["${column["name"]}"] ==
                            null) {
                        tables["${table["name"]}"]["${column["name"]}"] = {};
                    }
                    String defVal = defaultValue(column["default"]);
                    bool nullVal = nullValue(column["null"]);

                    tables["${table["name"]}"]["${column["name"]}"] = {
                        "type":"${column["type"]}",
                        "default":"${defVal}",
                        "null":"${nullVal}"
                    };
                }
            }
        }
        if (tables.length > 0) {
            map[direction]["createColumn"] = tables;
        }
    }

    static void removeColumnJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {
            tables["${table['name']}"] = new List();
            for (var column in table["columns"]) {
                tables["${table['name']}"].add(column["name"]);
            }
        }
        if (tables.length > 0) {
            map[direction]["removeColumn"] = tables;
        }
    }

    static void removeTableJson(List migrationActionsMap, String direction) {
        List tables = [];
        for (var table in migrationActionsMap) {
            tables.add(table["name"]);
        }
        if (tables.length > 0) {
            map[direction]["removeTable"] = tables;
        }
    }

    static void createRelationJson(List migrationActionsMap, String direction) {
        List relations = [];
        for (var relation in migrationActionsMap) {
            if (relation["selectedTableOne"] != null) {
                List names = [relation["selectedTableOne"], relation["selectedTableTwo"]];
                names.sort();
                relations.add(names);
            } else {
                if(relation["selectedRelation"].indexOf("_${DBCore.getRelationDivider(DBCore.rootPath)}_") > -1){
                    relations.add(relation["selectedRelation"].split("_${DBCore.getRelationDivider(DBCore.rootPath)}_"));
                }
            }
        }
        if (relations.length > 0) {
            map[direction]["createRelation"] = relations;
        }
    }

    static void removeRelationJson(List migrationActionsMap, String direction) {
        List relations = [];
        for (var relation in migrationActionsMap) {
            if (relation["selectedTableOne"] != null) {
                List names = [relation["selectedTableOne"], relation["selectedTableTwo"]];
                names.sort();
                relations.add(names);
            } else {
                if(relation["selectedRelation"].indexOf("_${DBCore.getRelationDivider(DBCore.rootPath)}_") > -1){
                    relations.add(relation["selectedRelation"].split("_${DBCore.getRelationDivider(DBCore.rootPath)}_"));
                }
            }
        }
        if (relations.length > 0) {
            map[direction]["removeRelation"] = relations;
        }
    }
}