
part of dartabaseMigration;
loadProjectMapping(Map params, HttpResponse res) {
  String text;
  DM.projectMapping =  DBCore.jsonFilePathToMap("bin/projectsMapping.json");
  if (!DM.projectMapping.isEmpty) {
    print("found ${DM.projectMapping.length} userAccounts");
    text=JSON.encode(DM.projectMapping);
  } else {
    print(JSON.encode({"no projects found":""}));
    text=JSON.encode({"no projects found":""});
  }
  closeResWith(res,text);
}

 loadConfig(Map params, HttpResponse res) {
  Map config =  DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/config.json");
  closeResWith(res,JSON.encode(config));
}

Future loadMigrations(Map params, HttpResponse res) async{
  String text;
  Map rootSchema =  DBCore.jsonFilePathToMap("${params["projectRootPath"].replaceAll('%5C','\\')}/db/schemaVersion.json");

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

        list.add({"index":i+1,"version":version,"state":"current","actions":( DBCore.jsonFilePathToMap(file.path))});
        print("${i+1} : $version <--- current version");
        state = "newer";
      } else {
        list.add({"index":i+1,"version":version,"state":state,"actions":( DBCore.jsonFilePathToMap(file.path))});
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

Future runMigration(Map params, HttpResponse res)async{
  DM.lastMigrationNumber = num.parse(params['index']);
  DBCore.rootPath = params["projectRootPath"].replaceAll('%5C','\\');
  await DM.run(params["direction"]);
  closeResWith(res,"finished migration");

}

Future requestServerStatus(Map params, HttpResponse res)async{
  try {
    var result = await DM.serverStatus(params["projectRootPath"].replaceAll('%5C','\\'));
    closeResWith(res,"running");
  } catch(exception, stackTrace) {
    closeResWith(res,"connection problem");
  }
}

initiateDartabase(Map params, HttpResponse res){
  DM.initiateDartabase(params["projectRootPath"].replaceAll('%5C','\\'),params['name']);
}

saveConfig(Map params, HttpResponse res) {
 print(params.toString());
 String cleanConfig = params['config'].replaceAll('%5C','\\').replaceAll('%7B','{').replaceAll('%22','"').replaceAll('%7D','}');

 DBCore.stringToFilePath( cleanConfig , "${params['projectRootPath'].replaceAll('%5C','\\')}/db/config.json");
 closeResWith(res,"done");
}

loadSchema(Map params, HttpResponse res) {
  Map schema = DBCore.loadSchemaToMap(params["projectRootPath"].replaceAll('%5C','\\'));
  closeResWith(res,JSON.encode(schema));
}

