//import '../poly/createProject.dart';


//import 'package:polymer_elements/iron_pages.dart';
//import 'package:polymer_elements/paper_material.dart';
//import 'package:polymer_elements/paper_button.dart';

//import '../poly/serverStatus.dart';
//import '../poly/projectView.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


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

    Migration(
            {this.index, this.version, this.colorPalette, this.actions, this.state});

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
    String migrationDirection;
    @reflectable
    Migration currentMigration;
    @reflectable
    Migration selectedMigration;

    Project({this.name, this.path, this.colorPalette, this.migrations});

    @reflectable
    Future prepare() async {
        await requestServerStatus();
        await requestConfig();
        await requestSchema();
        await requestMigrations();
    }

    @reflectable
    Future requestConfig() async {
        var url = "http://127.0.0.1:8079/requestConfig?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateConfig(responseText);
    }

    @reflectable
    updateConfig(String responseText) {
        config = new Map();
        config = JSON.decode(responseText);
    }

    @reflectable
    Future requestMigrations() async {
        var url = "http://127.0.0.1:8079/requestMigrations?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateMigrations(responseText);
    }

    @reflectable
    updateMigrations(String responseText) {
        migrations = new List();
        List<Map> migrationsList = JSON.decode(responseText);
        for (Map migMap in migrationsList) {
            Migration mig = new Migration(index: migMap['index'],
                    version: migMap['version'],
                    colorPalette: colorPalette,
                    actions: migMap['actions'],
                    state: migMap['state']);
            migrations.add(mig);
            if (mig.state == "curent") {
                selectedMigration = mig;
            }
        }
    }

    @reflectable
    Future requestServerStatus() async {
        var url = "http://127.0.0.1:8079/requestServerStatus?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateServerStatus(responseText);
    }

    @reflectable
    updateServerStatus(String responseText) {
        serverStatus = responseText;
    }

    @reflectable
    Migration getMigrationByIndex(num index) {
        Migration mig = new Migration();
        for (Migration m in migrations) {
            if (m.index == index) {
                mig = m;
            }
        }
        return mig;
    }

    @reflectable
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

    @reflectable
    Migration getCurrentMigration() {
        Migration mig = new Migration();
        /**migrations.forEach((Migration m) {
                if (m.state == "current") {
                mig = m;
                }
                });*/
        for (Migration m in migrations) {
            if (m.state == "current") {
                mig = m;
            }
        }
        return mig;
    }

    @reflectable
    Future requestSchema() async {
        var url = "http://127.0.0.1:8079/requestSchema?projectRootPath=${path}";
        String responseText = await HttpRequest.getString(url);
        updateSchema(responseText);
    }

    @reflectable
    updateSchema(String responseText) {
        var schema = JSON.decode(responseText);
        dependencyRelations = new Map();
        tables = new Map();
        for (String tableName in schema.keys) {
            var value = schema[tableName];
            if (tableName != "dependencyRelations") {
                tables[tableName] = value;
            } else {
                dependencyRelations = value;
            }
        }
    }

    @reflectable
    List getTableNames() {
        return tables.keys.toList();
    }

    @reflectable
    List getColumnNamesFor(String tableName) {
        return tables[tableName].keys.toList();
    }
}
