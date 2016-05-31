import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:params/client.dart';
import 'package:material_paper_colors/material_paper_colors.dart';

import 'package:polymer_elements/paper_toast.dart';
import '../poly/dartabaseMigration.dart';
import '../poly/pm.dart';

import '../poly/createProject.dart';
import 'package:polymer/polymer.dart';


List<Project> projects = [];

Future main() async {
    await initPolymer();
    initParams();
    print("###########################START############################");
    //var div = querySelector("#warning");
    //div.remove();
    var url = "http://127.0.0.1:8079/projectMapping";
    var responseText = await HttpRequest.getString(url);
    await displayProjects(responseText);
}

Future displayProjects(responseText) async {
    Map userProjects = JSON.decode(responseText);
    for (String key in userProjects.keys) {
        Project project = new Project(name: key, path: userProjects[key], colorPalette: getRandomColorPaletteT());
        await project.prepare();
        projects.add(project);
        print(project.serverStatus);
        print(project.config["adapter"]);
    }
    DartabaseMigration polyItem = new Element.tag("dartabase-migration");
    polyItem.set('projects', projects);
    document.querySelector("#content").append(polyItem);
}
