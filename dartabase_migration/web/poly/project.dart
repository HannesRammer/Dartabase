import 'dart:html';
import 'dart:convert' show JSON;

class Project {
  final String name;
  final String path;
  final List colorPalette;
  List migrations;
  String currentMigration;
  Project({this.name, this.path, this.colorPalette,this.migrations,this.currentMigration});
  
  
  requestMigrations(){
    var url = "http://127.0.0.1:8079/migrations?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateMigrations);
  }

  updateMigrations(String responseText){
    migrations = JSON.decode(responseText); 
  }
  
  requestCurrentMigrationVersion(){
    var url = "http://127.0.0.1:8079/currentMigrationVersion?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateCurrentMigrationVersion);
  }

  updateCurrentMigrationVersion(String responseText){
    currentMigration = responseText; 
  }

}