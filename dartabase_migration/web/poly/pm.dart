/**
class Migration extends JsProxy {
    @reflectable
    final num index;
    @reflectable
    final String version;
    @reflectable
    Map colorPalette;
    @reflectable
    Map actions;
    @reflectable
    String state;

    Migration({this.index, this.version, this.colorPalette, this.actions, this.state});

}

class Project extends JsProxy {
    @reflectable
    final String name;
    @reflectable
    final String path;

    @reflectable
    Map colorPalette;
    @reflectable
    Map config;
    @reflectable
    List<Migration> migrations;
    @reflectable
    Map tables;
    @reflectable
    Map dependencyRelations;

    @reflectable
    String serverStatus;
    @reflectable
    String migrationDirection = "";
    @reflectable
    Migration currentMigration = new Migration();
    @reflectable
    Migration selectedMigration = new Migration();

    Project({this.name, this.path, this.colorPalette, this.migrations});

    Future prepare() async {
        await requestServerStatus();
        await requestConfig();
        await requestSchema();
        await requestMigrations();
    }

    Future requestConfig() async {
        var url = "http://127.0.0.1:8079/requestConfig?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateConfig(responseText);
    }

    updateConfig(String responseText) {
        config = new Map();
        config = JSON.decode(responseText);
    }

    Future requestMigrations() async {
        var url = "http://127.0.0.1:8079/requestMigrations?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateMigrations(responseText);
    }

    updateMigrations(String responseText) {
        migrations = new List();
        List<Map> migrationsList = JSON.decode(responseText);
        /**migrationsList.forEach((Map migMap) {
                Migration mig = toObservable(new Migration(index: migMap['index'],
                version: migMap['version'],
                colorPalette: colorPalette,
                actions: migMap['actions'],
                state: migMap['state']));
                migrations.add(mig);
                if (mig.state == "curent") {
                selectedMigration = mig;
                }
                });*/
        for (Map migMap in migrationsList) {
            Migration mig = new Migration(index: migMap['index'], version: migMap['version'], colorPalette: colorPalette, actions: migMap['actions'], state: migMap['state']);
            migrations.add(mig);
            if (mig.state == "curent") {
                selectedMigration = mig;
            }
        }
    }

    Future requestServerStatus() async {
        var url = "http://127.0.0.1:8079/requestServerStatus?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateServerStatus(responseText);
    }

    updateServerStatus(String responseText) {
        serverStatus = responseText;
    }

    Migration getMigrationByIndex(num index) {
        Migration mig = new Migration();
        /**migrations.forEach((Migration m) {
                if (m.index == index) {
                mig = m;
                }
                });**/
        for(Migration m in migrations){
            if (m.index == index) {
                mig = m;
            }
        }
        return mig;
    }

    void setSelectedMigrationByIndex(num index) {
        selectedMigration = getMigrationByIndex(index);
        if (selectedMigration.state == "older") {
            migrationDirection = "DOWN";
        } else if (selectedMigration.state == "newer") {
            migrationDirection = "UP";
        } else if (selectedMigration.state == "curent") {
            migrationDirection = "";
        }
    }

    Migration getCurrentMigration() {
        Migration mig = new Migration();
        /**migrations.forEach((Migration m) {
                if (m.state == "current") {
                mig = m;
                }
                });*/
        for(Migration m in migrations){
            if (m.state == "current") {
                mig = m;
            }
        }
        return mig;
    }

    Future requestSchema() async {
        var url = "http://127.0.0.1:8079/requestSchema?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateSchema(responseText);
    }

    updateSchema(String responseText) {
        var schema = JSON.decode(responseText);
        dependencyRelations = new Map();
        tables = new Map();
        schema.forEach((String tableName, value) {
            if (tableName != "dependencyRelations") {
                tables[tableName] = value;
            } else {
                dependencyRelations = value;
            }
        });

    }

    List getTableNames() {
        return tables.keys.toList();
    }


    List getColumnNamesFor(String tableName) {
        return tables[tableName].keys.toList();
    }
}
*/