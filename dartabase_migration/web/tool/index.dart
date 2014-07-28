import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:params/client.dart';
import '../poly/dartabaseMigration.dart';
import '../poly/project.dart';
import 'package:material_paper_colors/material_paper_colors.dart';

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
      var request = HttpRequest.getString(url).then(displayProjects);
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
    projects.add(project);
    project.requestMigrations();
    
  });
  polyItem.projects = projects;
  querySelector("#content").append(polyItem);
}