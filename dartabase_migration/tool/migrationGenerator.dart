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

    static Map createMigration(Map migrationActionsMap) {
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


        print("Generated Migration:${map}");
        return map;
    }

    static void createTableJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {
            if(tables["${table["name"]}"] == null){
                tables["${table["name"]}"] = {};
            }
            for (var column in table["columns"]) {
                if(tables["${table["name"]}"]["${column["name"]}"] == null){
                    tables["${table["name"]}"]["${column["name"]}"] = {};
                }
                tables["${table["name"]}"]["${column["name"]}"] = {
                    "type":"${column["type"]}",
                    "default":"${column["default"]}",
                    "null":"${column["null"]}"
                };
            }
        }
        map[direction]["createTable"] = tables;
    }

    static void createColumnJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {

            if(tables["${table["name"]}"] == null){
                tables["${table["name"]}"] = {};
            }
            for (var column in table["columns"]) {
                if(tables["${table["name"]}"]["${column["name"]}"] == null){
                    tables["${table["name"]}"]["${column["name"]}"] = {};
                }
                tables["${table["name"]}"]["${column["name"]}"] = {
                    "type":"${column["type"]}",
                    "default":"${column["default"]}",
                    "null":"${column["null"]}"
                };
            }
        }
        map[direction]["createColumn"] = tables;
    }

    static void removeColumnJson(List migrationActionsMap, String direction) {
        Map tables = {};
        for (var table in migrationActionsMap) {
            tables["${table['name']}"] = new List();
            for (var column in table["columns"]) {
                tables["${table['name']}"].add(column["name"]);
            }
        }
        map[direction]["removeColumn"] = tables;
    }

    static void removeTableJson(List migrationActionsMap, String direction) {
        List tables = [];
        for (var table in migrationActionsMap) {
            tables.add(table["name"]);
        }
        map[direction]["removeTable"] = tables;
    }

    static void createRelationJson(List migrationActionsMap, String direction) {
        List relations = [];
        for (var relation in migrationActionsMap) {
            relations.add(relation);
        }
        map[direction]["createRelation"] = relations;
    }

    static void removeRelationJson(List migrationActionsMap, String direction) {
        List relations = [];
        for (var relation in migrationActionsMap) {
            relations.add(relation[0].split("_2_"));
        }
        map[direction]["removeRelation"] = relations;
    }
}