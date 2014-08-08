library dartabase.poly.project;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;
import '../poly/migration.dart';

class Project extends Observable {
  final String name;
  final String path;
  final Map colorPalette;
  @published Map config;
  @observable List<Migration> migrations;

  @observable String serverStatus;
  @observable String migrationDirection = "";
  @observable Migration currentMigration;
  @observable Migration selectedMigration;

  Project({this.name, this.path, this.colorPalette, this.migrations});

  requestConfig() {
      var url = "http://127.0.0.1:8079/config?projectRootPath=${path}";
      var request = HttpRequest.getString(url).then(updateConfig);
  }

  updateConfig(String responseText) {
    config = new Map();
    config = JSON.decode(responseText);
  }
  
  requestMigrations() {
    var url = "http://127.0.0.1:8079/migrations?projectRootPath=${path}";
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
    var url = "http://127.0.0.1:8079/serverStatus?projectRootPath=${path}";
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
}
