/**library dartabase.poly.project;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:observe/observe.dart';
import 'package:observe/mirrors_used.dart';

import 'dart:convert' show JSON;
import '../poly/migration.dart';


class Project extends Observable {
    final String name;
    final String path;
    @observable Map colorPalette = toObservable({});
    @observable Map config = toObservable({});
    @observable List<Migration> migrations = toObservable([]);
    @observable Map tables = toObservable({});
    @observable Map dependencyRelations = toObservable({});

    @observable String serverStatus;
    @observable String migrationDirection = "";
    @observable Migration currentMigration = toObservable(new Migration());
    @observable Migration selectedMigration = toObservable(new Migration());

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
        config = toObservable(new Map());
        config = JSON.decode(responseText);
    }

    Future requestMigrations() async {
        var url = "http://127.0.0.1:8079/requestMigrations?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateMigrations(responseText);
    }

    updateMigrations(String responseText) {
        migrations = toObservable(new List());
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
            Migration mig = toObservable(new Migration(index: migMap['index'], version: migMap['version'], colorPalette: colorPalette, actions: migMap['actions'], state: migMap['state']));
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
        Migration mig = toObservable(new Migration());
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
        Migration mig = toObservable(new Migration());
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
        dependencyRelations = toObservable(new Map());
        tables = toObservable(new Map());
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