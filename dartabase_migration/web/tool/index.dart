import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:params/client.dart';
import 'package:material_paper_colors/material_paper_colors.dart';

import 'package:polymer_elements/paper_toast.dart';
import '../poly/dartabaseMigration.dart';
import '../poly/project.dart';

import '../poly/createProject.dart';
import 'package:polymer/polymer.dart';


List<Project> projects = [];

Future main() async {
    // Actually registers the elements.

    await initPolymer();
    var div = querySelector("#warning");
    div.remove();

    //Polymer.onReady.then((e) {
    initParams();

    print("Request List");
    var url = "http://127.0.0.1:8079/projectMapping";
    //if(params["project"] == null){
    var responseText = await HttpRequest.getString(url);
    await displayProjects(responseText);
    /*}else{
        var request = HttpRequest.getString(url).then((responseText){
          displayProject(responseText,params["project"]);
        });
      }*/
   // });
}

 Future displayProjects(responseText) async{
    Map userProjects = JSON.decode(responseText);

    List maps = mapToList(userProjects);

     for(var pair in maps){

        Project project = new Project(name: pair[0], path: pair[1], colorPalette: getRandomColorPaletteT());
        await project.prepare();


        projects.add(project);
    }

    DartabaseMigration polyItem = new Element.tag("dartabase-migration");
    document.querySelector("#content").append(polyItem);
    polyItem.projects = projects;

}

List mapToList(Map map){
    List result = [];
    Iterable keys = map.keys;
    for(String key in keys){
        result.add([key,map[key]]);
    }
    return result;
}

