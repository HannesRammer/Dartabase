library dartabaseMigration;

import "dart:io";
import "dart:async";

import 'package:dartabase_core/dartabase_core.dart';

import 'package:postgresql/postgresql.dart';
import 'package:postgresql/postgresql_pool.dart';

import 'package:sqljocky/sqljocky.dart';
import 'dartabaseMigration.dart' as DM;

import 'dart:convert';
import 'package:params/server.dart';
part '../tool/dbhelper.dart';

//@dartabaseScaffoldPartial

/* A simple web server that responds to **ALL** GET and **POST** requests
 * 
 * Browse to it using http://localhost:8080  
 * 
 * Provides CORS headers, so can be accessed from any other page
 */

final HOST = "127.0.0.1"; // eg: localhost
final PORT = 8079;

void main() {
  HttpServer.bind(HOST, PORT).then((server) {
    server.listen((HttpRequest request) {
      initParams(request);
      switch (request.method) {
        case "GET":
          handleGet(request);
          break;
        case "POST":
          handlePost(request);
          break;
        case "OPTIONS":
          handleOptions(request);
          break;
        default:
          defaultHandler(request);
      }
    }, onError: printError);
    print("Listening for GET and POST on http://$HOST:$PORT");
    /* Process.run('C:\\dart\\chromium\\Chrome.exe', ['C:\\Projects\\Dart\\dartabase\\dartabase_migration\\web\\index.html']).then((ProcessResult pr){
              print(pr.exitCode);
            print(pr.stdout);
            print("#####################");
              print(pr.stderr);
          });
     */
  }, onError: printError);
}

/**
 * Handle GET requests 
 */
void handleGet(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");
  String path = req.uri.path;
  addCorsHeaders(res);

  /*START SCAFFOLD INPUT*/
  if (path == "/projectMapping") {
    loadProjectMapping(res);
  } else if (path.indexOf("/currentMigrationVersion") >= 0) {
    loadCurrentMigrationVersion(res);
  } else if (path.indexOf("/migrations") >= 0) {
    loadMigrations(res);
  } else if (path.indexOf("/initiateMigration") >= 0) {
    DM.initiateDartabase(params["projectRootPath"].replaceAll('%5C','\\'), params["name"]);
  } else if (path.indexOf("/runMigration") >= 0) {
      runMigration(res);
  }else {
    //@dartabaseScaffoldGet
    var err = "Could not find path: $path";
    closeResWith(res,err);
  }
}

/**
 * Handle POST requests 
 */
void handlePost(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");
  String path = req.uri.path;
  addCorsHeaders(res);

  /*START SCAFFOLD INPUT*/
  /*if(path == "/$userAccountSaveUrl"){
    UserAccount.saveUserAccount(req, res);
  } else if(path == "/$userAccountDeleteUrl"){
    UserAccount.deleteUserAccount(req, res);
  }*/
  /*END SCAFFOLD INPUT*/
  //@dartabaseScaffoldPost
}

/**
 * Add Cross-site headers to enable accessing this server from pages
 * not served by this server
 * 
 * See: http://www.html5rocks.com/en/tutorials/cors/ 
 * and http://enable-cors.org/server.html
 */
void addCorsHeaders(HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*, ");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

void handleOptions(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  print("${req.method}: ${req.uri.path}");
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

void defaultHandler(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  res.statusCode = HttpStatus.NOT_FOUND;
  closeResWith(res,"Not found: ${req.method}, ${req.uri.path}");
}
closeResWith(HttpResponse res,String object){
  res.write(object);
  res.close();
}

void printError(error) => print(error);


initiateGUI(HttpResponse res) {
  DM.projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");


  /*print("\nProject name *:* Path *:* Current schema version");
   print("-----------------------------");
   for(var name in projectMapping.keys){
     Map schemaV = DBCore.jsonFilePathToMap("${projectMapping[name]}/db/schemaVersion.json");
     print("$name *:* ${projectMapping[name]} *:* ${schemaV['schemaVersion']}");
   }*/


}

loadProjectMapping(HttpResponse res) {
  String text;
  DM.projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
  if (!DM.projectMapping.isEmpty) {
    print("found ${DM.projectMapping.length} userAccounts");
    text=JSON.encode(DM.projectMapping);
  } else {
    print(JSON.encode({"no projects found":""}));
    text="no projects found";
  }
  closeResWith(res,text);
}

loadCurrentMigrationVersion(HttpResponse res) {
  String text;
  Map schemaV = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/schemaVersion.json");
  if (!schemaV.isEmpty && !schemaV['schemaVersion'].isEmpty) {
    print("found current schema version ${schemaV['schemaVersion']}");
    text = schemaV['schemaVersion'];
  } else {
    print("no current schema version found");
    text = "no current schema version found";
  }
  closeResWith(res,text);
}

loadMigrations(HttpResponse res) {
  String text;
  Map rootSchema = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/schemaVersion.json");
  
  var state;
  List<Map> list;
  if(rootSchema['schemaVersion'] == ""){
    state = "newer";
    list = [{"index":0,"version":"no_migration","state":"current","actions":{}}];
  }else{
    state = "older";
    list = [{"index":0,"version":"no_migration","state":"older","actions":{}}];
  }
  
    
  Directory directory = new Directory("${params["projectRootPath"].replaceAll('%5C','\\')}/db/migrations");
  List<FileSystemEntity> files = directory.listSync();
  if (files.length > 0) {
    print("Migration number : Name");
    
    for (int i = 0; i < files.length; i++) {
      File file = new File(files[i].path);
      String version = file.path.split("migrations")[1].replaceAll("\\", "");
      if (rootSchema['schemaVersion'] == version) {
        list.add({"index":i+1,"version":version,"state":"current","actions":DBCore.jsonFilePathToMap(file.path)});
        print("${i+1} : $version <--- current version");
        state = "newer";
      } else {
        list.add({"index":i+1,"version":version,"state":state,"actions":DBCore.jsonFilePathToMap(file.path)});
        print("${i+1} : $version");
      }
      
    }
    text = JSON.encode(list);
  }else {
    print("no migrations found");
    text = JSON.encode(list);
  }
  closeResWith(res,text);
}

runMigration(HttpResponse res){
  DM.lastMigrationNumber = num.parse(params['index']);
  DBCore.rootPath = params["projectRootPath"].replaceAll('%5C','\\');
  DM.run(params["direction"]).then((_){
    closeResWith(res,"finished migration");  
  });
}

