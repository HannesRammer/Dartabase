library dartabase.poly.project;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;
import '../poly/migration.dart';

class Project extends Observable {
  final String name;
  final String path;
  @observable Map colorPalette = toObservable({});
  @observable Map config = toObservable({});
  @observable List<Migration> migrations  = toObservable([]);
  @observable Map tables = toObservable({});
  @observable Map dependencyRelations = toObservable({});

  @observable String serverStatus;
  @observable String migrationDirection = "";
  @observable Migration currentMigration=toObservable(new Migration());
  @observable Migration selectedMigration =toObservable(new Migration());

  Project({this.name, this.path, this.colorPalette, this.migrations});

  void prepare(){
    requestServerStatus();
    requestConfig();
    requestSchema(); 
    requestMigrations();
  }
  
  requestConfig() {
      var url = "http://127.0.0.1:8079/requestConfig?projectRootPath=${path}";
      var request = HttpRequest.getString(url).then(updateConfig);
  }

  updateConfig(String responseText) {
    config = new Map();
    config = JSON.decode(responseText);
  }
  
  requestMigrations() {
    var url = "http://127.0.0.1:8079/requestMigrations?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateMigrations);
  }

  updateMigrations(String responseText) {
    migrations = new List();
    List<Map> migrationsList = JSON.decode(responseText);
    migrationsList.forEach((Map migMap) {
      Migration mig = new Migration(index: migMap['index'], version: migMap['version'],colorPalette:colorPalette, actions: migMap['actions'], state: migMap['state']);
      migrations.add(mig);
      if (mig.state == "curent") {
        selectedMigration = mig;
      }
    });
  }

  requestServerStatus() {
    var url = "http://127.0.0.1:8079/requestServerStatus?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateServerStatus);
  }

  updateServerStatus(String responseText) {
    serverStatus = responseText;
  }

  Migration getMigrationByIndex(num index) {
    Migration mig;
    migrations.forEach((Migration m) {
      if (m.index == index) {
        mig = m;
      }
    });
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
    Migration mig;
    migrations.forEach((Migration m) {
      if (m.state == "current") {
        mig = m;
      }
    });
    return mig;
  }
  
  requestSchema(){
    var url = "http://127.0.0.1:8079/requestSchema?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateSchema);
  }
  
  updateSchema(String responseText) {
    var schema = JSON.decode(responseText);
    dependencyRelations = new Map();
    tables = new Map();
    schema.forEach((String tableName,value){
      if(tableName != "dependencyRelations"){
        tables[tableName] = value;
      }else{
        dependencyRelations = value;
      }
    });
  }
}
