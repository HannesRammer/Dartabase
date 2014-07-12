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
    DM.initiateDartabase(params["path"].replaceAll('%5C','\\'), params["name"]);
  } else if (path.indexOf("/runMigration") >= 0) {
      runMigration(res);
  }
  else if (path.indexOf("/loadMigration") >= 0) {
    loadMigration(res);
  }else {
    //@dartabaseScaffoldGet
    var err = "Could not find path: $path";
    res.write(err);
    res.close();
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
  res.write("Not found: ${req.method}, ${req.uri.path}");
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
  DM.projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");

  if (!DM.projectMapping.isEmpty) {
    print("found ${DM.projectMapping.length} userAccounts");
    res.write(JSON.encode(DM.projectMapping));
    res.close();
  } else {
    print(JSON.encode({"no projects found":""}));
    res.write("no projects found");
    res.close();
  }
}

loadCurrentMigrationVersion(HttpResponse res) {

  Map schemaV = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/schemaVersion.json");
  if (!schemaV.isEmpty && !schemaV['schemaVersion'].isEmpty) {
    print("found current schema version");
    res.write(schemaV['schemaVersion']);
    res.close();
  } else {
    print("no current schema version found");
    res.write("no current schema version found");
    res.close();
  }
}

loadMigrations(HttpResponse res) {
  Map rootSchema = DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/schemaVersion.json");
  
  var state;
  List<Map> list;
  if(rootSchema['schemaVersion'] == ""){
    state = "newer";
    list = [{"index":"0","version":"no_migration","state":"current"}];
  }else{
    state = "older";
    list = [{"index":"0","version":"no_migration","state":"older"}];
  }
  
    
  Directory directory = new Directory("${params["projectRootPath"].replaceAll('%5C','\\')}/db/migrations");
  List files = directory.listSync();
  if (files.length > 0) {
    print("Migration number : Name");
    
    for (int i = 0; i < files.length; i++) {
      String version = files[i].path.split("migrations")[1].replaceAll("\\", "");
      if (rootSchema['schemaVersion'] == version) {
        list.add({"index":i+1,"version":version,"state":"current"});
        print("${i+1} : $version <--- current version");
        state = "newer";
      } else {
        list.add({"index":i+1,"version":version,"state":state});
        print("${i+1} : $version");
      }
      
    }
    res.write(JSON.encode(list));
    res.close();
  }else {
    print("no migrations found");
    res.write(JSON.encode(list));
    res.close();
  }
}

runMigration(HttpResponse res){
  DM.lastMigrationNumber = num.parse(params['index']);
  DBCore.rootPath = params["path"].replaceAll('%5C','\\');
  DM.run(params["direction"]);
  res.write("done");
  res.close();
}

loadMigration(HttpResponse res){
  List createTables=[];
  List createColumns=[];
  
  Map migration = DBCore.jsonFilePathToMap("${params["path"].replaceAll('%5C','\\')}/db/migrations/${params['migrationVersion']}");
  Map up = migration["UP"];
  Map createTable;
  Map createColumn;
  Map removeColumn;
  Map removeTable;
  if(up != null){
  createTable = up["createTable"];
  createColumn = up["createColumn"];
  removeColumn = up["removeColumn"];
  removeTable = up["removeTable"];
  }
  
  if(createTable != null){
    createTable.forEach((String tableName, Map tableColumns){
      List columns = [];
      tableColumns.forEach((String columnName, var columnOptions){
        if(columnOptions.runtimeType.toString()=="String"){
          columns.add({"name":columnName,"type":columnOptions,"hash":false});
        }else{
          columns.add({"name":columnName,"type":columnOptions['type'],"default":columnOptions['default'],"hash":true});
        }
      });
      Map table = {"name":tableName,"columns":columns};
      createTables.add(table);  
    });
  }

  if(createColumn != null){
    createColumn.forEach((String tableName, Map tableColumns){
      List columns = [];
      tableColumns.forEach((String columnName, var columnOptions){
        if(columnOptions.runtimeType.toString()=="String"){
          columns.add({"name":columnName,"type":columnOptions,"hash":false});
        }else{
          columns.add({"name":columnName,"type":columnOptions['type'],"default":columnOptions['default'],"hash":true});
        }
      });
      Map table = {"name":tableName,"columns":columns};
      createColumns.add(table);  
    });
  }

  res.write(JSON.encode({"createTables":createTables,"createColumns":createColumns}));
  res.close();
  
}