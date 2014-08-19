import 'dart:html';
import 'dart:convert' show JSON;

import 'package:polymer/polymer.dart';
import 'package:params/client.dart';
import 'package:material_paper_colors/material_paper_colors.dart';

import '../poly/dartabaseMigration.dart';
import '../poly/project.dart';

List<Project> projects = [];
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    Polymer.onReady.then((e) {     
      initParams();
      querySelector("#green").style.backgroundColor =Green["500"];
      querySelector("#green").style.color =GreenT["500"][1];

      print("Request List");
      var url = "http://127.0.0.1:8079/projectMapping";
      //if(params["project"] == null){
        var request = HttpRequest.getString(url).then(displayProjects);      
      /*}else{
        var request = HttpRequest.getString(url).then((responseText){
          displayProject(responseText,params["project"]);
        });
      }*/
      
    });
  });
}

void displayProjects(responseText) {
  Map userProjects = JSON.decode(responseText);
  DartabaseMigration polyItem = new Element.tag("dartabase-migration");
  var counter=0;
  userProjects.forEach((k,v){
    counter++;
    Project project = new Project(name:k,path:v,colorPalette:getRandomColorPaletteT());
    project.requestServerStatus();

    projects.add(project);
    project.requestConfig();
    project.requestMigrations();
    
    
  });
  polyItem.projects = projects;
  querySelector("#content").append(polyItem);
}

