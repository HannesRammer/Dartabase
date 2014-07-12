library projectView;
import 'package:polymer/polymer.dart';
import "dart:html";
import "dart:convert" show JSON;
import "../poly/project.dart";

@CustomTag('custom-project-view')
class ProjectView extends PolymerElement {
  @published Project project = null;
  
  @observable Map schema= {};
  
  @observable String selectedMigration = "none" ;
  @observable num selectedIndex = 0;
  @observable String migrationDirection = "" ;
    
  
  ProjectView.created() : super.created();
  
    
  
  setActive(Event e, var detail, DivElement target){
    if(this.shadowRoot.querySelectorAll(".currentSelection").isNotEmpty){
      DivElement selectedDiv = this.shadowRoot.querySelectorAll(".currentSelection")[0];
      selectedDiv.classes.remove("currentSelection");    
    }
    if(target.classes.contains("olderMigration")){
      migrationDirection = "DOWN";
    }else if(target.classes.contains("newerMigration")){
      migrationDirection = "UP";
    }else if(target.classes.contains("currentMigration")){
      migrationDirection = "";
    }
    selectedMigration = target.id;
    selectedIndex = num.parse(target.getAttribute("index"));
    target.classes.add("currentSelection");
    loadMigrationView();
  }
  runMigration(){
    var url = "http://127.0.0.1:8079/runMigration?path=${project.path}&direction=${migrationDirection}";
    if(migrationDirection == "UP"){
      url+="&index=${selectedIndex-1}";
            
    }else if(migrationDirection == "DOWN"){
      url+="&index=${selectedIndex}";    
    }
    var request = HttpRequest.getString(url).then(updateView);
  }
  
  updateView(responseText){
    querySelector("#alert").appendText(responseText);
  }
  
  loadMigrationView(){
    var url = "http://127.0.0.1:8079/loadMigration?path=${project.path}&migrationVersion=${selectedMigration}";
    var request = HttpRequest.getString(url).then(updateMigrationView);
  }
  updateMigrationView(responseText){
    Map migration = JSON.decode(responseText);
    
    var container = this.shadowRoot.querySelectorAll(".migrationContentRight")[0];
    Element migrationView = new Element.tag("custom-migration-view");
    migrationView.migration = migration;
    migrationView.tables = migration['createTables'];
    migrationView.name = selectedMigration; 
    container.innerHtml ="";
    container.append(migrationView);
    }
  
}