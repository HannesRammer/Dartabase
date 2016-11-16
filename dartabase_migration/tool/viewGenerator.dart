part of dartabaseMigration;

//TODO think about making dartabase_core lib that gets imported by dartabase tools
class ViewGenerator {

    static run(Map tables, rootPath) async {
        createIndexHTML(rootPath);
        createIndexDART(rootPath);
        createMainPolyHTML(rootPath);

        List tableNames = tables.keys.toList();
        tableNames.remove("relationDivider");
        tableNames.remove("schema_migrations");
        createMainPolyDART(tableNames, rootPath);
        await createDynamicPolyHTML(tables, rootPath);
        createDynamicPolyDART(tableNames, rootPath);
    }

    /**
     *
     */
    static void createIndexHTML(String rootPath) {
        String indexHTML = '''
<!DOCTYPE html>
<!--
 Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code
 is governed by a BSD-style license that can be found in the LICENSE file.
-->
<html>
<head>
   <meta charset="utf-8">
   <meta http-equiv="X-UA-Compatible" content="IE=edge">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <meta name="scaffolded-by" content="https://github.com/google/stagehand">
   <title>${DSC.toVarName(rootPath
                                                                .split(new String.fromCharCode(92))
                                                                .last
                                                                .split(new String.fromCharCode(47))
                                                                .last)}</title>
   <!-- Add to homescreen for Chrome on Android -->
   <meta name="mobile-web-app-capable" content="yes">
   <link rel="icon" sizes="192x192" href="../images/touch/chrome-touch-icon-192x192.png">
   <!-- Add to homescreen for Safari on iOS -->
   <meta name="apple-mobile-web-app-capable" content="yes">
   <meta name="apple-mobile-web-app-status-bar-style" content="black">
   <meta name="apple-mobile-web-app-title" content="Web Starter Kit">
   <link rel="apple-touch-icon-precomposed" href="../apple-touch-icon-precomposed.png">
   <!-- Tile icon for Win8 (144x144 + tile color) -->
   <meta name="msapplication-TileImage" content="images/touch/ms-touch-icon-144x144-precomposed.png">
   <meta name="msapplication-TileColor" content="#3372DF">
   <!--  Polyfill of Custom Elements and HTML Imports -->
   <script src="packages/web_components/webcomponents-lite.min.js"></script>
   <script defer type="application/dart" src="index.dart"></script>
   <script defer src="packages/browser/dart.js"></script>
   <!-- example of using a paper element -->
   <link rel="import" href="packages/polymer_elements/roboto.html">
</head>
<body unresolved>
<main-app></main-app>
</body>
</html>
''';
        Directory dbModels = new Directory("${rootPath}/web/db/poly");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(indexHTML, "${rootPath}/web/db/index.html");
            print("${rootPath}/web/db/index.html created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */
    static void createIndexDART(String rootPath) {
        String indexDART = '''
// Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "poly/main_app.dart";
import "package:polymer/polymer.dart";

/// [MainApp] used!
main() async {
 await initPolymer();
}
''';
        Directory dbModels = new Directory("${rootPath}/web/db/poly");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(indexDART, "${rootPath}/web/db/index.dart");
            print("${rootPath}/web/db/index.html created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */
    static void createMainPolyHTML(String rootPath) {
        String mainPolyHTML = '''
<!--
 Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code
 is governed by a BSD-style license that can be found in the LICENSE file.
-->

<dom-module id="main-app">
   <template>
       <style>
           :host {
               display: block;
           }

           ul {
               list-style-type: none;
               margin: 0;
               padding: 50px 0;
               background-color: #f1f1f1;
               height: 100%; /* Full height */
               position: fixed; /* Make it stick, even on scroll */
               overflow: auto; /* Enable scrolling if the sidenav has too much content */

               width: 200px;
           }

           #project_menu {
               width: 200px;

           }

           #project_content {
               margin-left: 200px;
               overflow-y: scroll;
               overflow-x: auto;
               height: 830px;
           }

           a {
               display: block;
               color: #000;
               padding: 8px 0 8px 16px;
               text-decoration: none;
               opacity: 0.35;
           }

           .active {
               opacity: 1 !important;
           }

           a:hover {
               opacity: 0.6 !important;
           }

           .hidden {
               display: none;
           }

           .yellow {
               background: #FBBC05;
               background: linear-gradient(to right, #FBBC05, #FBBC05, #FBBC05, #FBBC05, #FBBC05, #FBBC05, #FBBC05, #FBBC05, rgba(0, 0, 0, 0));
               color: black;

           }

           .blue {
               background: #4285F4;
               background: linear-gradient(to right, #4285F4, #4285F4, #4285F4, #4285F4, #4285F4, #4285F4, #4285F4, #4285F4, rgba(0, 0, 0, 0));
               color: black;
           }

           .green {
               background: #34A853;
               background: linear-gradient(to right, #34A853, #34A853, #34A853, #34A853, #34A853, #34A853, #34A853, #34A853, rgba(0, 0, 0, 0));
               color: black;
           }

           .red {
               background: #EA4335;
               background: linear-gradient(to right, #EA4335, #EA4335, #EA4335, #EA4335, #EA4335, #EA4335, #EA4335, #EA4335, rgba(0, 0, 0, 0));
               color: black;
           }

       </style>
       <nav id="project_menu">
           <ul>
           </ul>
       </nav>
       <div id="project_content">
       </div>
   </template>
</dom-module>
''';
        Directory dbModels = new Directory("${rootPath}/web/db/poly");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(mainPolyHTML, "${rootPath}/web/db/poly/main_app.html");
            print("${rootPath}/web/db/poly/main_app.html created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */
    static void createMainPolyDART(List dbTableNames, String rootPath) {
        String str = "[\"${dbTableNames.join("\",\"")}\"]";
        String mainPolyDART = '''
// Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.
@HtmlImport("main_app.html")
library ${DSC.toVarName(rootPath
                                                                 .split(new String.fromCharCode(92))
                                                                 .last
                                                                 .split(new String.fromCharCode(47))
                                                                 .last)}.poly.main_app;

import "dart:html";

import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_checkbox.dart";
import "package:polymer/polymer.dart";
import "package:web_components/web_components.dart";

${ generateImportString(dbTableNames)}

/// Uses [PaperInput]
@PolymerRegister("main-app")
class MainApp extends PolymerElement {
   /// Constructor used to create instance of MainApp.
   MainApp.created() : super.created();
   @property
   List colors = ["blue", "yellow", "green", "red"];
   @property
   List tableList = ${str};

   void ready() {
       UListElement menu = querySelector("ul");
''';
        int counter = 0;
        for (String tableName in dbTableNames) {
            mainPolyDART += generateLinkAndContentString(tableName, counter);
            if (counter == 3) {
                counter = 0;
            } else {
                counter++;
            }
        }
        mainPolyDART += '''
   }

   Element createLink(modelName, create, container, color) {
       LIElement li = new LIElement();
       AnchorElement a = new AnchorElement(href: "#\$modelName");
       a.classes.add(color);
       a.classes.add("active");
       a.classes.add("main-app");
       a.setInnerHtml(modelName);
       a.onClick.listen((MouseEvent event) {
           Element target = event.target;
           target.classes.toggle("active");
           container.classes.add("main-app");
           create.classes.add("main-app");
           container.classes.toggle("hidden");
           create.classes.toggle("hidden");
       });
       li.append(a);
       return li;
   }

   Element createContent(create, container, color) {
       create.classes;
       container.classes;
       create.set("state", "create");
       container.set("state", "showAll");
       create.classes.add("main");
       container.classes.add("main");
       create.classes.add("main-app");
       container.classes.add("main-app");
       container.set("color", color);
       return container;
   }
}
''';
        Directory dbModels = new Directory("${rootPath}/web/db/poly");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(mainPolyDART, "${rootPath}/web/db/poly/main_app.dart");
            print("${rootPath}/web/db/poly/main_app.dart created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */
    static String generateImportString(dbTableNames) {
        String str = "";
        for (String dbTableName in dbTableNames) {
            str += "import \"${DSC.toTableName(dbTableName)}.dart\";\n";
        }
        return str;
    }

    /**
     *
     */
    static String generateLinkAndContentString(dbTableName, colorId) {
        String str = "";
        var className = DSC.toClassName(dbTableName);
        var varName = DSC.toVarName(dbTableName);
        var polyName = "db-${DSC.toPolyName(dbTableName)}";
        //var tableName = "${DSC.toTableName(dbTableName)}";

        str += '''
           ${className} ${varName}Container = new Element.tag("${polyName}");
           ${className} ${varName}Create = new Element.tag("${polyName}");
           LIElement li${className} = createLink("${dbTableName}",${varName}Create, ${varName}Container, colors[${colorId}]);
           ${className} ${varName} = createContent(${varName}Create, ${varName}Container, colors[${colorId}]);
           menu.append(li${className});
           querySelector("#project_content").append(${varName}Create);
           querySelector("#project_content").append(${varName});\n
''';
        return str;
    }

    /**
     *
     */
    static List listString(dbTableNames) {
        List list = [];
        for (var dbTableName in dbTableNames) {
            list.add(dbTableName.toString());
        }
        return list;
    }

    /**
     *
     */
    static createDynamicPolyHTML(Map dbTables, String rootPath) async {
        List dbTableNames = dbTables.keys.toList();
        for (String dbTableName in dbTableNames) {
            var className = DSC.toClassName(dbTableName);
            var varName = DSC.toVarName(dbTableName);
            var polyName = "db-${DSC.toPolyName(dbTableName)}";
            var tableName = "${DSC.toTableName(dbTableName)}";
            String dynamicPolyHTML = '''
<!--
 Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code
 is governed by a BSD-style license that can be found in the LICENSE file.
-->
<dom-module id="${polyName}">
   <style>
       :host {
           display: block;
           --paper-input-container-disabled: {
               opacity: 0.9;

           };
           --my-toolbar-color: black;
       }

       .container {
           vertical-align: middle;
           text-align: center;
           padding: 10px;
       }

       .column {
           display: table;
       }

       .column paper-input {
           display: table-cell;
           padding: 0px 10px;
           float: left;
           min-width: 100px;
       }

       .column paper-button {
           top: 15px;
           margin: 0px 5px;
       }

       a:hover {
           opacity: 0.6 !important;
       }

       .hidden {
           display: none;
       }

       paper-material {
           --shadow-elevation-4dp: {

               /** box-shadow: 0px 4px 5px 0 rgba(0, 129, 198, 0.14),
               // 0px 1px 10px 0 rgba(0, 129, 198, 0.12),
               // -19px 2px 4px -1px rgba(0, 129, 198, 0.6);
               /**/
               box-shadow: 0px 4px 5px 0 var(--my-toolbar-color),
               0px 1px 10px 0 var(--my-toolbar-color),
               -19px 2px 4px -1px var(--my-toolbar-color);

           };
           width: 95%;
           margin: 5px auto;
           padding: 10px;
           height: 100%;
           overflow: auto;
       }
   </style>
   <template>
       <div id="${tableName}_content">
           <template is="dom-if" if="{{ isCreate(state) }}">
               <div id="${tableName}_create">
                   <div class="column">
                       <form is="iron-form" id="formGet" method="get" action="/" on-iron-form-submit="initiateCreate">
                           ${await createDynamicPolyHTMLString(dbTables, dbTableName, false, rootPath)}
                           <paper-button type="button" on-tap="clickHandler" raised>create</paper-button>
                       </form>
                   </div>
               </div>
           </template>

           <template is="dom-if" if="{{ isShowAll(state) }}">
               <paper-material id="${tableName}_container" elevation="2">
                   <div id="${tableName}_list">
                   </div>
               </paper-material>
           </template>
           <template is="dom-if" if="{{ isShow(state) }}">
               <div id="${tableName}_show">
                   <div class="column">
                       ${await createDynamicPolyHTMLString(dbTables, dbTableName, true, rootPath)}
                       <paper-button type="button" on-tap="edit" raised>edit</paper-button>
                       <paper-button on-tap="delete" raised>delete</paper-button>
                   </div>
               </div>
           </template>
           <template is="dom-if" if="{{ isEdit(state) }}">
               <div id="${tableName}_edit">
                   <div class="column">
                       ${await createDynamicPolyHTMLString(dbTables, dbTableName, false, rootPath)}
                       <paper-button on-tap="cancel" raised>cancel</paper-button>
                       <paper-button on-tap="save" raised>save</paper-button>
                   </div>
               </div>
           </template>
       </div>
   </template>
</dom-module>
''';
            Directory dbModels = new Directory("${rootPath}/web/db/poly");
            dbModels.create(recursive: true).then((_) {
                DBCore.stringToFilePath(dynamicPolyHTML, "${rootPath}/web/db/poly/${tableName}.html");
                print("${rootPath}/web/db/poly/${tableName}.html created");
                print("----------------------------------------------------------");
            });
        }
    }

    /**
     *
     */
    //static Future createDynamicPolyHTMLString(Map tables, bool disabled, String rootPath) async {
    static Future createDynamicPolyHTMLString(var tables, var tableName, bool disabled, String rootPath) async {
        String str = "";

        if (tableName != "relationDivider") {
            Map columns = tables[tableName];
            await columns.forEach((columnName, column) {
                if (disabled || (columnName == "id" || columnName == "created_at" || columnName == "updated_at")) {
                    if (column["type"] == "BOOLEAN") {
                        str +=
                        '''
                       <paper-checkbox label="${columnName}" checked="{{${DSC.toVarName(tableName)}Map.${columnName}}}" disabled></paper-checkbox>\n''';
                    } else {
                        str +=
                        '''
                       <paper-input label="${columnName}" value="{{${DSC.toVarName(tableName)}Map.${columnName}}}" disabled></paper-input>\n''';
                    }
                } else {
                    if (column["type"] == "BOOLEAN") {
                        str +=
                        '''
                       <paper-checkbox label="${columnName}" checked="{{${DSC.toVarName(tableName)}Map.${columnName}}}" ></paper-checkbox>\n''';
                    } else {
                        if ([
                            "BINT", "BINT UNSIGNED", "DOUBLE", "FLOAT", "FLOAT UNSIGNED", "INT", "INT UNSIGNED", "SINT",
                            "SINT UNSIGNED", "TINT", "TINT UNSIGNED"
                        ].contains(column["type"])) {
                            str += '''<paper-input label="${columnName}" value="{{${DSC.toVarName(tableName)}Map.${columnName}}}" auto-validate="" allowed-pattern="[0-9]"
                            error-message="integers only 0-9 !"></paper-input>\n''';
                        } else if (["DOUBLE", "FLOAT", "FLOAT UNSIGNED"].contains(column["type"])) {
                            str += '''<paper-input label="${columnName}" value="{{${DSC.toVarName(tableName)}Map.${columnName}}}" auto-validate="" allowed-pattern="[0-9,.]" error-message="allowed
                            chars
                            "0-9" "," and "." only!"></paper-input>\n''';
                        } else {
                            str += '''<paper-input label="${columnName}" value="{{${DSC.toVarName(tableName)}Map.${columnName}}}"></paper-input>\n''';
                        }
                    }
                }
            });
        }
        return str;
    }

    /**
     *
     */
    static void createDynamicPolyDART(List dbTableNames, String rootPath) {
        for (String dbTableName in dbTableNames) {
            var className = DSC.toClassName(dbTableName);
            var varName = DSC.toVarName(dbTableName);
            var polyName = "db-${DSC.toPolyName(dbTableName)}";
            var tableName = "${DSC.toTableName(dbTableName)}";
            String dynamicPolyDART = '''
// Copyright (c) 2016, Hannes.Rammer@gmail.com. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.
@HtmlImport("${tableName}.html")
library ${DSC.toVarName(rootPath
                                                                                                 .split(new String.fromCharCode(92))
                                                                                                 .last
                                                                                                 .split(new String.fromCharCode(47))
                                                                                                 .last)}.lib.${tableName};

import "dart:html";
import "dart:async";
import "dart:convert";

import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_checkbox.dart";
import "package:polymer_elements/iron_form.dart";
import "package:polymer/polymer.dart";
import "package:web_components/web_components.dart";
import "${tableName}.dart";

/// Uses [PaperInput]
@PolymerRegister("${polyName}")
class ${className} extends PolymerElement {

   @Property(notify: true)
   Map ${varName}Map;
   @Property(notify: true)
   String state;
   @Property(notify: true)
   Map backup${className}Map;
   @Property(notify: true)
   String color;

   /// Constructor used to create instance.
   ${className}.created() : super.created();


   @reflectable
   isShowAll(var currentState) {
       if (currentState == "showAll") {
           showAll();
       }
       return currentState == "showAll";
   }

   @reflectable
   showAll() {
       HttpRequest request = new HttpRequest(); // create a new XHR
       // add an event handler that is called when the request finishes
       request.onReadyStateChange.listen((_) {
           if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
               print(request.responseText); // output the response from the server
               List ${varName}List = JSON.decode(request.responseText);
               if(${varName}List != null){
                 for (Map ${varName} in ${varName}List) {
                     ${className} ${varName}Element = new Element.tag("${polyName}");
                     ${varName}Element.set("${varName}Map", ${varName});
                     ${varName}Element.set("state", "show");
                     querySelector("#${tableName}_list").append(${varName}Element);
                 }
               }
           }
       });
       var url = "http://127.0.0.1:8071/list${className}";
       request.open("POST", url);
       request.send();
       //await request.onLoadEnd.first;
   }

   @reflectable
   isShow(var currentState) {
       if (currentState == "show") {
           show();
       }
       return currentState == "show";
   }

   @reflectable
   show() {
       HttpRequest request = new HttpRequest(); // create a new XHR
       request.onReadyStateChange.listen((_) {
           if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
               set("${varName}Map",${varName}Map);
               print(request.responseText); // output the response from the server
           }
       });
       var url = "http://127.0.0.1:8071/load${className}?${tableName}_id=\${${varName}Map["id"]}";
       request.open("POST", url);
       request.send();
       //await request.onLoadEnd.first;
   }

   @reflectable
   isEdit(var currentState) {
       return currentState == "edit";
   }

   @reflectable
   edit(Event event, [_]) {
       set("backup${className}Map", JSON.decode(JSON.encode(${varName}Map)));
       set("state", "edit");
   }

   @reflectable
   cancel(Event event, [_]) {
       set("${varName}Map", JSON.decode(JSON.encode(backup${className}Map)));
       set("backup${className}Map", {});
       set("state", "show");
   }

   @reflectable
   save(Event event, [_]) {
       HttpRequest request = new HttpRequest(); // create a new XHR
       // add an event handler that is called when the request finishes
       request.onReadyStateChange.listen((_) {
           if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
               print(request.responseText); // output the response from the server
               Map ${varName} = JSON.decode(request.responseText);
               set("state", "show");
           }
       });
       var url = "http://127.0.0.1:8071/save${className}?${tableName}=\${Uri.encodeQueryComponent(JSON.encode(${varName}Map))}";

       request.open("POST", url);
       request.send();
       //await request.onLoadEnd.first;
   }

   @reflectable
   delete(Event event, [_]) {
       HttpRequest request = new HttpRequest(); // create a new XHR
       // add an event handler that is called when the request finishes
       request.onReadyStateChange.listen((_) {
           if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
               print(request.responseText); // output the response from the server
               window.location.reload();
           }
       });
       var url = "http://127.0.0.1:8071/delete${className}?id=\${${varName}Map["id"]}";

       request.open("POST", url);
       request.send();
       //await request.onLoadEnd.first;
   }

   @reflectable
   isCreate(var currentState) {
       return currentState == "create";
   }

   @reflectable
   Future initiateCreate(Event event, [_])  async{
       HttpRequest request = new HttpRequest(); // create a new XHR
       // add an event handler that is called when the request finishes
       request.onReadyStateChange.listen((_) {
           if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
               print(request.responseText); // output the response from the server
               Map ${varName} = JSON.decode(request.responseText);
               window.location.reload();
           }
       });
       var url = "http://127.0.0.1:8071/save${className}?${tableName}=\${Uri.encodeQueryComponent(JSON.encode(${varName}Map))}";

       request.open("POST", url);
       request.send();
       //await request.onLoadEnd.first;
   }

   @reflectable
   void clickHandler(Event event, [_]) {
       (((Polymer.dom(event) as PolymerEvent).localTarget as Element).parent as FormElement).submit();
   }

// Optional lifecycle methods - uncomment if needed.

   /// Called when an instance of main-app is inserted into the DOM.
   attached() {
       customStyle["--my-toolbar-color"] = color;
       updateStyles();
       super.attached();
   }

   ready(){
       set("${varName}Map", {});
   }
}
''';
            Directory dbModels = new Directory("${rootPath}/web/db/poly");
            dbModels.create(recursive: true).then((_) {
                DBCore.stringToFilePath(dynamicPolyDART, "${rootPath}/web/db/poly/${tableName}.dart");
                print("${rootPath}/web/db/poly/${tableName}.dart created");
                print("----------------------------------------------------------");
            });
        }
    }
}


