library projectLabel;
import 'package:polymer/polymer.dart';
import "dart:html";
import "dart:convert" show JSON;
import "../poly/projectView.dart";

@CustomTag('custom-project-label')
class ProjectLabel extends PolymerElement {
  @observable String project = "none";
  @observable String path = "none";
  
     
  ProjectLabel.created() : super.created();
  
  ProjectView polyView ;
  
  void loadProject(){
    createProjectView();
    requestCurrentMigrationVersion();
    requestMigrations();  
  }
  
  createProjectView(){
    if(querySelectorAll("custom-project-view").isNotEmpty){
      polyView = querySelectorAll("custom-project-view")[0];
    }else{
      polyView = new Element.tag("custom-project-view");
      DivElement content = querySelector("#bottom_right");
      content.innerHtml="";
      content.append(polyView);
    }
    polyView.project = project ;
    polyView.path = path;
  }
  
  requestCurrentMigrationVersion(){
    var url = "http://127.0.0.1:8079/currentMigrationVersion?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateCurrentMigrationVersion);
  }

  updateCurrentMigrationVersion(responseText){
    polyView.currentMigration = responseText; 
  }
  
  requestMigrations(){
    var url = "http://127.0.0.1:8079/migrations?projectRootPath=${path}";
    var request = HttpRequest.getString(url).then(updateMigrations);
  }

  updateMigrations(responseText){
    polyView.migrations = JSON.decode(responseText); 
  }
}