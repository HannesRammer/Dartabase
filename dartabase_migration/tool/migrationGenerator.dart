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
    static Map map = {};

    static Map createMigration(Map migrationActionsMap){
        createTableJson(migrationActionsMap);
        createColumnJson(migrationActionsMap);
        removeColumnJson(migrationActionsMap);
        removeTableJson(migrationActionsMap);
        createRelationJson(migrationActionsMap);
        removeRelationJson(migrationActionsMap);
        print("Generated Migration:${map}");
        return map;
    }

    static void createTableJson(Map migrationActionsMap) {
        Map tables = {};
        for (var table in migrationActionsMap["createTables"]) {
            for (var column in table["columns"]) {
                tables["${table["name"]}"] = {
                    "${column["name"]}": {
                        "type":"${column["type"]}",
                        "default":"${column["def"]}",
                        "null":"${column["nil"]}"
                    }
                };
            }
        }
        map["createTable"] = tables;
    }


    static void createColumnJson(Map migrationActionsMap) {
        Map tables = {};
        for (var table in migrationActionsMap["createColumns"]) {
            for (var column in table["columns"]) {
                tables["${table['name']}"] = {
                    "${column['name']}": {
                        "type":"${column["type"]}",
                        "default":"${column["def"]}",
                        "null":"${column["nil"]}"
                    }
                };
            }
        }
        map["createColumn"] = tables;
    }

    static void removeColumnJson(Map migrationActionsMap) {
        Map tables = {};
        for (var table in migrationActionsMap["removeColumns"]) {
            tables["${table['name']}"] = new List();
            for (var column in table["columns"]) {
                tables["${table['name']}"].add(column["name"]);
            }
        }
        map["removeColumn"] = tables;
    }
    static void removeTableJson(Map migrationActionsMap) {
        List tables = [];
        for (var table in migrationActionsMap["removeTables"]) {
            tables.add(table["name"]);
        }
        map["removeTable"] = tables;
    }

    static void createRelationJson(Map migrationActionsMap) {
        List relations = [];
        for (var relation in migrationActionsMap["createRelations"]) {
            relations.add(relation);
        }
        map["createRelation"] = relations;
    }

    static void removeRelationJson(Map migrationActionsMap) {
        List relations = [];
        for (var relation in migrationActionsMap["removeRelations"]) {
            relations.add(relation[0].split("_2_"));

        }
        map["removeRelation"] = relations;
    }


}