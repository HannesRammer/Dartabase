import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:params/client.dart';
import '../poly/dartabaseMigration.dart';
import '../poly/project.dart';

/*
 * void main()
 * 
 * requests object from db if id is provided 
 * in location search string.
 * then calls displayList with response
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    Polymer.onReady.then((e) {     
      initParams();
      print("Request List");
      var url = "http://127.0.0.1:8079/projectMapping";
      var request = HttpRequest.getString(url).then(displayProjects);
    });
  });
}

/*
 * void displayUserAccount(responseText)
 * 
 * transforms the json response into a map,
 * passing it to the created poly object
*/
void displayProjects(responseText) {
  Map userProjects = JSON.decode(responseText);
  List projects = [];
  DartabaseMigration polyItem = new Element.tag("dartabase-migration");
      
  userProjects.forEach((k,v){
    
    projects.add(new Project(name:k,path:v,color:"#34ad48"));
    
    
  });
  polyItem.projects = projects;
  querySelector("#content").append(polyItem);
      
  //querySelector("dartabase-migration").projects = projects; 
  
}



  
