import "dart:io";
import "dart:convert";
import "dart:async";
import 'package:dartabase_core/dartabase_core.dart';
import "dartabaseMigration.dart";

void main() {
  var state = null;
  var projectExistsInProjectMapping = false;
  var projectDoesntExistsInProjectMapping = true;
  
  print("|-------------------------|");
  print("|  Dartabase scaffolding  |");
  print("|-------------------------|");
  print("");
  
  projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
  
  print("\nProject name *:* Path *:* Current schema version");
  print("------------------------------------------------");
  Map schemaV;
  for(var name in projectMapping.keys){
    schemaV = DBCore.jsonFilePathToMap("${projectMapping[name]}/db/schemaVersion.json");
    print("$name *:* ${projectMapping[name]} *:* ${schemaV['schemaVersion']}");
    
  }
  
  print("Enter the project name and press the ENTER key to proceed");
    
  Stream<List<int>> stream = stdin;
  
  stream
    .transform(UTF8.decoder)
      .transform(new LineSplitter())
        .listen((String line) { /* Do something with line. */
    
    if(state == 0){
      projectExistsInProjectMapping = projectMapping[line] != null;
      projectDoesntExistsInProjectMapping = !projectExistsInProjectMapping;
              
      if(projectDoesntExistsInProjectMapping){
        print("Project '$line' unknown to dartabase, maybe you forgot to initiate your project with dbInit.dart ");
      }else if(projectExistsInProjectMapping){
        state = 1;
        
        String rootPath= projectMapping[line];
        Map rootSchema = DBCore.jsonFilePathToMap("${rootPath}/db/schemaVersion.json");
        
        print("specify a object you want to generate");
        print("");
        print("Usage: objectName[column_name:COLUMNTYPE] options");
        print("Options:");
        print("-m - generate migration file");
        print("-c - generate client views");
        print("-s - generate server object");
        print("");
        print("Example:");
        print("item[done:BOOLEAN, text:VARCHAR] -m -c -s");
        print("user_account[name:VARCHAR, age:INT] -m");
        DBCore.rootPath = rootPath;   
      }
    }else if(state == 1){
      if(DBCore.rootPath != null){
        line = line.replaceAll(" ", "");
        List split = line.split("[");
        String objectName = split[0];
        //transform columns and types into map
        List columns = split[1].split("]")[0].split(",");
        Map columnsMap = {};
        for(num i=0;i< columns.length;i++){
          List column = columns[i].split(":");
          columnsMap[column[0]] = column[1];
        }
        String options = split[1].split("]")[1];
                
        if (options.contains("-m")){
          createMigration(objectName,columnsMap);  
        }
        if (options.contains("-c")){
          createClientView(objectName,columnsMap);  
        }        
        if (options.contains("-s")){
          createServerModel(objectName,columnsMap);  
        }        
      }
    }
    if(state == null){
      state = 0;  
    }

   
            
        
      },
      onDone: () { /* No more lines */ 
        print("Dartabase migration created!");
      },
     onError: (e) { /* Error on input. */ 
       print("Dartabase migration error! $e");
     });
}

createMigration(String tableName, Map columnsMap){
  List columnsList = [];
  columnsMap.forEach((key,value){
    columnsList.add('"${key}" = "${value}"');
  });
      
  String migration =''' 
{
  "UP": {
      "createTable": {
          "$tableName": {${columnsList.join(",")}}
      }
  },
  "DOWN": {
      "removeTable": [
          "$tableName"
      ]
  }
}
  ''';
  DateTime dT = new DateTime.now();
   
  var month = "${dT.month}".length == 1 ? "0${dT.month}" : "${dT.month}";
  var day = "${dT.day}".length == 1 ? "0${dT.day}" : "${dT.day}";
  var hour = "${dT.hour}".length == 1 ? "0${dT.hour}" : "${dT.hour}";
  var minute = "${dT.minute}".length == 1 ? "0${dT.minute}" : "${dT.minute}";
  var second = "${dT.second}".length == 1 ? "0${dT.second}" : "${dT.second}";
  String dateTime = "${dT.year}$month$day$hour$minute$second";
  DBCore.stringToFilePath(migration, "${DBCore.rootPath}/db/migrations/${dateTime}_create_$tableName.json");
  print("migration ${DBCore.rootPath}/db/migrations/${dateTime}_create_$tableName.json created");
}
createServerModel(String tableName, Map columnsMap){
  List nameParts = tableName.split("_");
  String className = "";
  String varName = "";
  for(num i=0;i<nameParts.length;i++){
    String part = nameParts[i];
    if(i==0){
      varName += part;
    }else{
      varName += part.substring(0,1).toUpperCase() + part.substring(1);
    }
    className += part.substring(0,1).toUpperCase() + part.substring(1);
  }
  
  List toStringParts = [];
  columnsMap.forEach((key,v){
    toStringParts.add("${key}=\$${key}");
  });
  
   
  String file = '''
part of example.server;
class ${className} extends Model{
  num id;
//TODO*******************generate params 
  String text;
  bool done;
//-----------------------------------
  DateTime created_at;
  DateTime updated_at;
  
  String toString() => "${className} id=\$id:${toStringParts.join(":")}:created_at:\$created_at:updated_at:\$updated_at";

  //return all ${className}s
  static load${className}s(HttpResponse res){
    new ${className}().findAll().then((List ${varName}s){
      if(!${varName}s.isEmpty){
        List jsonList=[];
        ${varName}s.forEach((${className} ${varName}){
          Map ${varName}Map = ${varName}.toJson();
          print(${varName}Map);
          jsonList.add(${varName}Map);
        });
        print("found \$\{${varName}s.length\} ${varName}s");
        res.write(JSON.encode(jsonList));
      }else{
        print("no ${varName}s found");
        res.write("no ${varName}s found");
      }
      res.close();  
    });
  }
  
  //return ${varName} by id
  static load${className}(HttpResponse res,id){
    new ${className}().findById(int.parse(id)).then((${varName}){
      if(${varName} != null){
        Map ${varName}Map = ${varName}.toJson();
        print("found ${varName} \$${varName}Map");
        res.write(JSON.encode(${varName}Map));
      }else{
        print("no ${varName} found with id \$id");
        res.write("no ${varName} found with id \$id");
      }
      res.close();  
    });
  }
  
  //save ${varName}
  static save${className}(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      Map postDataMap = JSON.decode(new String.fromCharCodes(buffer));
      if(postDataMap['id'] == null){
        print("creating ${varName} with data \$postDataMap");
        fill(new ${className}(),postDataMap,res);
      }else{
        new ${className}().findById(postDataMap['id']).then((${varName}){
          print("updating ${varName} \${${varName}.id} with data \$postDataMap");
          fill(${varName},postDataMap,res);
        });
      }
    }, onError: printError);
  }
  
  //delete ${varName}
  static delete${className}(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      Map postDataMap = JSON.decode(new String.fromCharCodes(buffer));
      if(postDataMap['id'] == null){
        print("no ${varName} id provided");
        res.write("no ${varName} id provided");
      }else{
        var id = postDataMap['id'];
        new ${className}().findById(id).then((${varName}){
          if(${varName} != null){
            print("found ${varName} with id \$id for deletion");
            ${varName}.delete().then((result){
              print("\$result");
              res.write("\$result");
            });
          }else{
            print("no ${varName} with id \$id found for deletion");
            res.write("no ${varName} with id \$id found for deletion");
          }
          res.close();  
        });
      }
    }, onError: printError);
  }

  static fill(${className} ${varName},Map dataMap, HttpResponse res){
//TODO*******************generate params
    ${varName}.done = dataMap['done'];
    ${varName}.text = dataMap['text'];
//--------------------------------------
    ${varName}.save().then((process){
      if(process == "created" || process == "updated"){
        new ${className}().findById(${varName}.id).then((${className} reloaded${className}){
          print("\$process ${varName} \$reloaded${className}");
          print("\$process ${varName} \${reloaded${className}.toJson()}");
          res.write(JSON.encode(reloaded${className}.toJson()));
          res.close();
        });
      }else{
        print("object not saved during 'process': \$process");
        res.write("object not saved during 'process': \$process");
        res.close();
      }
    });
  }
}

  ''';
  DBCore.stringToFilePath(file, "${DBCore.rootPath}/bin/${varName}.dart");
  print("server model ${DBCore.rootPath}/bin/${varName}.dart created");
}

createClientView(String tableName, Map columnsMap){

  List nameParts = tableName.split("_");
  String className = "";
  String varName = "";
  for(num i=0;i<nameParts.length;i++){
    String part = nameParts[i];
    if(i==0){
      varName += part;
    }else{
      varName += part.substring(0,1).toUpperCase() + part.substring(1);
    }
    className += part.substring(0,1).toUpperCase() + part.substring(1);
  }
  String polyName = nameParts.join("-");

  var viewPath = "${DBCore.rootPath}/web/${varName}";
  var polyPath = "${DBCore.rootPath}/web/poly";
  String createDart = '''
import 'package:polymer/polymer.dart';
import 'dart:html';
import '../../lib/paths.dart';
import '../../lib/params.dart';

DivElement content = querySelector("#content");

Map params = {};
  
/*
 * displays form to create a new object
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    querySelector("#view_${tableName}s").onClick.listen((e) => window.location.assign(${varName}sUrl));
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    params = loadParams(window);
    Element polyItem = new Element.tag('custom-${polyName}');
    polyItem.apperance = "create";
    content.append(polyItem);
  });
}
  ''';

  String createHtml = '''
<!DOCTYPE html>
<html>
  <head>
    <title>Create ${className}</title>
    <link rel="import" href="../poly/${varName}.html">
    <script type="application/dart"> export 'create.dart'; </script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
    <h1>Create ${className}</h1>
    <div id="warning">Dart is not running</div>
    <nav>
      <button id="view_${tableName}s" title="View ${className}s">View ${className}s</button>
      <button id="home" title="HOME">HOME</button>
    </nav>
    <div id="content"></div>
  </body>
</html>
  ''';

  String editDart = '''
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import '../../lib/paths.dart';
import '../../lib/params.dart';

DivElement content = querySelector("#content");

Map params = {};
  
/*
 * void main()
 * 
 * requests object from db if id is provided 
 * in location search string.
 * then calls displayEdit${className} with response
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    querySelector("#view_${tableName}s").onClick.listen((e) => window.location.assign(${varName}sUrl));
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    params = loadParams(window);
    if(params['id'] != null){
      String id = params['id'];
      print("requesting ${className} with \$id");
      var url = "http://127.0.0.1:8090/\$${varName}LoadUrl/\$id";
      var request = HttpRequest.getString(url).then(displayEdit${className});
    }
    else{
      content.text="no ${className} id available";
    }
  });
}

/*
 * void displayEdit${className}(responseText)
*/
void displayEdit${className}(String responseText) {
  Map ${varName} = JSON.decode(responseText);
  Element polyItem = new Element.tag('custom-${polyName}');
  polyItem.object = toObservable(${varName});
  polyItem.apperance = "edit";
  content.append(polyItem);
}
  ''';
  
  String editHtml = '''
<!DOCTYPE html>
<html>
  <head>
    <title>${className} Edit</title>
    <link rel="import" href="../poly/${varName}.html">
    <script type="application/dart"> export 'edit.dart'; </script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
    <h1>${className} Edit</h1>
    <div id="warning">Dart is not running</div>
    <nav>
      <button id="view_${tableName}s" title="View ${className}s">View ${className}s</button>
      <button id="home" title="HOME">HOME</button>
    </nav>
    <div id="content"></div>
  </body>
</html>
  ''';

  String viewDart = '''
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import '../../lib/paths.dart';
import '../../lib/params.dart';

DivElement content = querySelector("#content");

Map params = {};

/*
 * void main()
 * 
 * requests object from db if id is provided 
 * in location search string.
 * then calls display${className} with response
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    querySelector("#view_${tableName}s").onClick.listen((e) => window.location.assign(${varName}sUrl));
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    params = loadParams(window);
    if(params['id'] != null){
      String id = params['id'];
      print("requesting ${className} with \$id");
      var url = "http://127.0.0.1:8090/\$${varName}LoadUrl/\$id";
      var request = HttpRequest.getString(url).then(display${className});
    }
    else{
      content.text="no ${className} id available";
    }
  });
}

/*
 * void display${className}(responseText)
*/
void display${className}(String responseText) {
  Map ${varName} = JSON.decode(responseText);
  Element polyItem = new Element.tag('custom-${polyName}');
  polyItem.object = toObservable(${varName});
  polyItem.apperance = "view";
  polyItem.pagination = true;
  content.append(polyItem);
}
  ''';

  String viewHtml = '''
<!DOCTYPE html>
<html>
  <head>
    <title>${className} View</title>
    <link rel="import" href="../poly/${varName}.html">
    <script type="application/dart"> export 'view.dart'; </script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
    <h1>${className} View</h1>
    <div id="warning">Dart is not running</div>
    <nav>
      <button id="view_${tableName}s" title="View ${className}s">View ${className}s</button>
      <button id="home" title="HOME">HOME</button>
    </nav>
    <div id="content"></div>
  </body>
</html>
  ''';

  String indexDart = '''
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import '../../lib/paths.dart';
import '../../lib/params.dart';

DivElement content = querySelector("#content");

Map params = {};
  
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
    params = loadParams(window);
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    querySelector("#create").onClick.listen((e){ 
      if(params["inlineEdit"]=="true"){
        appendAsyncEmpty${className}();
      }else{
        window.location.assign(${varName}CreateUrl);
      }
    });
    print("Request List");
    var url = "http://127.0.0.1:8090/\$${varName}sLoadUrl";
    var request = HttpRequest.getString(url).then(displayList);
  });
}

/*
 * void display${className}(responseText)
 * 
 * transforms the json response into a map,
 * passing it to the created poly object
*/
void displayList(responseText) {
  List ${varName}s = JSON.decode(responseText);
  Element polyItemHeader = new Element.tag('custom-${polyName}');
  polyItemHeader.apperance = "header";
  if(params["inlineEdit"] == "true"){
    polyItemHeader.inlineEdit = true;
  }
  content.append(polyItemHeader);
  append${className}s(${varName}s);
}

Element setAsyncEditOption(polyItem){
  polyItem.inlineEdit = true;
  polyItem.onClick.listen((event){ 
    if(polyItem.apperance == "index"){
      polyItem.apperance = "edit";
      polyItem.title="click to edit!";  
    }
  });
  return polyItem;
}

void appendAsyncEmpty${className}(){
  Element polyItem = new Element.tag('custom-${polyName}');
  polyItem.apperance = "create";
  polyItem = setAsyncEditOption(polyItem);
  content.append(polyItem);
}

void append${className}s(List ${varName}s){
  ${varName}s.forEach((${varName}){
      Element polyItem = new Element.tag('custom-${polyName}');
      polyItem.object = ${varName};
      polyItem.apperance = "index";
      if(params["inlineEdit"] == "true"){
        polyItem = setAsyncEditOption(polyItem);
      }
      content.append(polyItem);
    });
}
  ''';
  
  String indexHtml = '''
<!DOCTYPE html>
<html>
  <head>
    <title>${className}s View</title>
    <link rel="import" href="../poly/${varName}.html">
    <script type="application/dart"> export 'index.dart'; </script>
    <script src="packages/browser/dart.js"></script>
    <link rel="stylesheet" href="index.css">
  </head>
  <body>
    <h1>${className}s View</h1>
    <div id="warning">Dart is not running</div>
    <nav>
      <button id="home" title="HOME">HOME</button>
      <button id="create" title="Create ${className}">Create ${className}</button>
    </nav>
    <div id="content"></div>
  </body>
</html>
  ''';

  String polyDart = '''
import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;
import 'dart:html';
import '../../lib/paths.dart';

@CustomTag('custom-${polyName}')
class ${className} extends PolymerElement {
  @observable Map object = toObservable({});
  @observable bool pagination = false;
  @observable bool inlineEdit = false;
  @observable String apperance = "view";
    
  ${className}.created() : super.created();
  
  void view(){
    window.location.assign("\$${varName}ViewUrl?id=\${object['id']}");
  }
  
  void edit(){
    window.location.assign("\$${varName}EditUrl?id=\${object['id']}");
  }
  
  void next(){
      window.location.assign("\$${varName}ViewUrl?id=\${object['id'] + 1}");
  }
  
  void prev(){
      window.location.assign("\$${varName}ViewUrl?id=\${object['id'] - 1}");
  }
  
  void save(){
    print("Saving structured data");
    // Setup the request
    var request = new HttpRequest();
    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE &&
          (request.status == 200 || request.status == 0)) {
        // data saved OK.
        print(" Data saved successfully");
        // update the UI
        var jsonString = request.responseText;
        //querySelector("#content").appendText(jsonString);
        if(inlineEdit){
          this.object = toObservable(JSON.decode(jsonString));
          this.apperance = "index";
        }else{
          window.location.assign(${varName}sUrl);
        }
      }
    });
    request.open("POST", "http://127.0.0.1:8090/\$${varName}SaveUrl");
    request.send(JSON.encode(object));
  }
  
  void delete(){
    print("Delete object with id \${object['id']}");
    // Setup the request
    var request = new HttpRequest();
    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE &&
          (request.status == 200 || request.status == 0)) {
        // ${varName} deleted OK.
        print("${className} deleted successfully");
        // update the UI
        var jsonString = request.responseText;
        querySelector("#content").appendText("done \$jsonString");
        if(this.inlineEdit){
          this.remove();
        }else{
          window.location.assign(${varName}sUrl);
        }
      }
    });
    request.open("POST", "http://127.0.0.1:8090/\$${varName}DeleteUrl");
    request.send(JSON.encode(object));
  }
}
''';

    String polyHtml = '''
<!DOCTYPE html>
<polymer-element name="custom-${polyName}">
  <template>
    <link rel="stylesheet" href="${varName}.css">
  
    <template if="{{apperance == 'header'}}">
      <div class="custom-${polyName}">
        <div style="display:none;">Done:</div>
        <span>ID:</span>
        <span>Text:</span>
        <span>created at:</span>
        <span>updated at:</span>
        <template if="{{inlineEdit == false}}" > 
          <span>view</span>
          <span>edit</span>
        </template>
      </div>  
    </template>
    
    <template if="{{apperance == 'index'}}">
      <div class="custom-${polyName}" id="${tableName}_{{object['id']}}">
        <span id="id">{{object['id']}}</span>
//TODO*******************generate params
        <input id="done" type="checkbox" checked="{{object['done']}}" disabled>
        <label class="deactivated_toggle" for="done"></label>
        <span id="text">{{object['text']}}</span>
//--------------------------------------
        <span id="created_at">{{object['created_at']}}</span>
        <span id="updated_at">{{object['updated_at']}}</span>
        <template if="{{inlineEdit == false}}" > 
          <span id="view"><button on-click="{{view}}">view</button></span>
          <span id="edit"><button on-click="{{edit}}">edit</button></span>
        </template>
      </div>  
    </template>
    
    <template if="{{apperance == 'view'}}">
      <div class="custom--${polyName}" id="${tableName}_{{object['id']}}">
        <span id="id">ID: {{object['id']}}</span>
//TODO*******************generate params
        <input id="done" type="checkbox" checked="{{object['done']}}" disabled>
        <label class="deactivated_toggle" for="done"></label>
        <span id="text">Text: {{object['text']}}</span>
//--------------------------------------
        <span id="created_at">created at: {{object['created_at']}}</span>
        <span id="updated_at">updated at: {{object['updated_at']}}</span>
        <template if="{{inlineEdit == false}}" > 
          <span id="view"><button on-click="{{view}}">view</button></span>
          <span id="edit"><button on-click="{{edit}}">edit</button></span>
          <template if="{{pagination == true}}" >
            <span id="next"><button on-click="{{next}}">next</button></span>
            <span id="prev"><button on-click="{{prev}}">prev</button></span>
          </template>
        </template>
      </div>  
    </template>
    
    <template if="{{apperance == 'edit'}}">
      <div class="custom-${polyName}" id="${tableName}_{{object['id']}}">
        ID: <input id="id" type="text" value="{{object['id']}}" disabled> 
//TODO*******************generate params
        <input id="done" type="checkbox" checked="{{object['done']}}">
        <label class="toggle" for="done"></label>
        Text: <input id="text" type="text" value="{{object['text']}}"> 
//--------------------------------------
        created at: <input type="text" value="{{object['created_at']}}" disabled>
        updated at: <input type="text" value="{{object['updated_at']}}" disabled>
        <button on-click="{{save}}">save</button>
        <button on-click="{{delete}}">delete</button>
      </div>
      
    </template>
    
    <template if="{{apperance == 'create'}}">
      <div class="custom-${polyName}" id="${tableName}_{{object['id']}}">
//TODO*******************generate params
        <input id="done" type="checkbox" checked="{{object['done']}}">
        <label class="toggle" for="done"></label>
        Text: <input id="text" type="text" value="{{object['text']}}"> 
//--------------------------------------
        <button on-click="{{save}}">save</button>
      </div>
      
    </template>
  </template>
  
  <script type="application/dart" src="${varName}.dart"></script>
</polymer-element>
''';
  Directory viewDir = new Directory("${viewPath}");
  Directory polyDir = new Directory("${polyPath}");
    

  viewDir.create(recursive: true).then((_){
    DBCore.stringToFilePath(createDart, "${viewPath}/create.dart");
    print("client view ${viewPath}/create.dart created");
      
    DBCore.stringToFilePath(createHtml, "${viewPath}/create.html");
    print("client view ${viewPath}/create.html created");
      
    DBCore.stringToFilePath(editDart, "${viewPath}/edit.dart");
    print("client view ${viewPath}/edit.dart created");

    DBCore.stringToFilePath(editHtml, "${viewPath}/edit.html");
    print("client view ${viewPath}/edit.html created");
      
    DBCore.stringToFilePath(viewDart, "${viewPath}/view.dart");
    print("client view ${viewPath}/view.dart created");

    DBCore.stringToFilePath(viewHtml, "${viewPath}/view.html");
    print("client view ${viewPath}/view.html created");
  
    DBCore.stringToFilePath(indexDart, "${viewPath}/index.dart");
    print("client view ${viewPath}/index.dart created");
  
    DBCore.stringToFilePath(indexHtml, "${viewPath}/index.html");
    print("client view ${viewPath}/index.html created");

    polyDir.create(recursive: true).then((_){
    DBCore.stringToFilePath(polyDart, "${polyPath}/${varName}.dart");
    print("poly view ${polyPath}/${varName}.dart created");
      
    DBCore.stringToFilePath(polyHtml, "${polyPath}/${varName}.html");
    print("poly view ${polyPath}/${varName}.html created");
    
    DateTime dT = new DateTime.now();
       
    var month = "${dT.month}".length == 1 ? "0${dT.month}" : "${dT.month}";
    var day = "${dT.day}".length == 1 ? "0${dT.day}" : "${dT.day}";
    var hour = "${dT.hour}".length == 1 ? "0${dT.hour}" : "${dT.hour}";
    var minute = "${dT.minute}".length == 1 ? "0${dT.minute}" : "${dT.minute}";
    var second = "${dT.second}".length == 1 ? "0${dT.second}" : "${dT.second}";
    String dateTime = "${dT.year}$month$day$hour$minute$second";
        
String pathString = '''  
/*
*${className}paths generated ${dateTime} by scaffolding     
*/
//${className} client paths
final ${varName}sUrl = "../${varName}/index.html";
final ${varName}CreateUrl = "../${varName}/create.html";
final ${varName}ViewUrl = "../${varName}/view.html";
final ${varName}EditUrl = "../${varName}/edit.html";

//${className} server paths
final ${varName}sLoadUrl = "load${className}s";
final ${varName}LoadUrl = "load${className}";
final ${varName}SaveUrl = "save${className}";
final ${varName}DeleteUrl = "delete${className}";
''';

      var pathPath = "${DBCore.rootPath}/lib/paths.dart";
      var file = new File(pathPath);
      file.writeAsStringSync(pathString, encoding: ASCII, mode:FileMode.APPEND);
      print("paths for ${className} added to ${pathPath}"); 
    });
  });
  
  
}