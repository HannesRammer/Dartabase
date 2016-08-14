part of dartabaseMigration;

//TODO think about making dartabase_core lib that gets imported by dartabase tools
class ServerGenerator {

    static run(Map tables, rootPath) async {
        createSimpleServer(rootPath);
        List tableNames = tables.keys.toList();
        tableNames.remove("relationDivider");
        tableNames.remove("schema_migrations");
        createServerFunctions(tableNames, rootPath);
        createDynamicServerFunctions(tableNames, tables, rootPath);
        generateRoutes(tableNames, rootPath);
    }

    /**
     *
     */
    static void createSimpleServer(String rootPath) {
        String simpleServerDART = '''
library ${DSC.toVarName(rootPath.split(new String.fromCharCode(92)).last)}.simple_server;

import "dart:io";

import 'package:dartabase_model/dartabase_model.dart';
import 'package:route/url_pattern.dart';
import 'package:routes/server.dart' as Routes;

import 'server_functions.dart';

part '../routes.dart';

/* A simple web server that responds to **ALL** GET and **POST** requests
 * Browse to it using http://localhost:8071
 * Provides CORS headers, so can be accessed from any other page
 */
final String HOST = "127.0.0.1"; // eg: localhost

final num PORT = 8071;

main() async {
    Model.initiate("${rootPath.replaceAll(new String.fromCharCode(92),new String.fromCharCodes([92,92]))}");
    var server = await HttpServer.bind(HOST, PORT);
    var router = Routes.initRouter(server, serverRoutes);
    print("Listening for GET and POST on http://\$HOST:\$PORT");
}

void printError(error) => print(error);
''';
        Directory dbModels = new Directory("${rootPath}/db/server");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(simpleServerDART, "${rootPath}/db/server/simple_server.dart");
            print("${rootPath}/db/server/simple_server.dart created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */
    static void createServerFunctions(List tableNames, String rootPath) {
        String simplefunctionImportDART = '''
library ${DSC.toVarName(rootPath.split(new String.fromCharCode(92)).last)}.server_function;

import 'dart:io';
import 'dart:convert';
import "package:routes/server.dart" as Routes;

${importSTRING(tableNames)}

${partSTRING(tableNames)}

''';
        Directory dbModels = new Directory("${rootPath}/db/server");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(simplefunctionImportDART, "${rootPath}/db/server/server_functions.dart");
            print("${rootPath}/db/server/server_functions.dart created");
            print("----------------------------------------------------------");
        });
    }

    /**
     *
     */

    static String importSTRING(tableNames) {
        String str = "";
        for (String name in tableNames) {
            str += "import '../models/${name}.dart';\n";
        }
        return str;
    }

    /**
     *
     */

    static String partSTRING(tableNames) {
        String str = "";
        for (String name in tableNames) {
            str += "part '${name}_functions.dart';\n";
        }
        return str;
    }

    /**
     *
     */
    static void createDynamicServerFunctions(List dbTableNames, Map tables, String rootPath) {
        for (String dbTableName in dbTableNames) {
            var className = DSC.toClassName(dbTableName);
            var varName = DSC.toVarName(dbTableName);
            var polyName = DSC.toPolyName(dbTableName);
            var tableName = DSC.toTableName(dbTableName);

            String dynamicFunctions = '''
part of ${DSC.toVarName(rootPath.split(new String.fromCharCode(92)).last)}.server_function;

list${className}(Map params, HttpResponse res) async {
    String text;
    List <${className}> ${varName} = await new ${className}().findAll();
    List <Map> encodable${className} = [];
    if (!${varName}.isEmpty) {
        for (${className} ${varName}_element in ${varName}) {
            Map ${varName}_map = await ${varName}_element.toJson();
            print("found \${${varName}_map} ${varName}");
            encodable${className}.add(${varName}_map);
        }
        text = JSON.encode(encodable${className});
    } else {
        String text = JSON.encode({"no ${varName} found":""});
        print(text);
    }
    Routes.closeResWith(res, text);
}

load${className}(Map params, HttpResponse res) async {
    String text;
    ${className} ${varName} = await new ${className}().findById(params["${tableName}_id"]);
    if (${varName} != null) {
        Map ${varName}_map = await ${varName}.toJson();
        print("found \${${varName}_map} ${varName}");
        text = JSON.encode(${varName}_map);
    } else {
        String text = JSON.encode({"no ${varName} found for ${tableName}_id \${params["${tableName}_id"]}":""});
        print(text);
    }
    Routes.closeResWith(res, text);
}

save${className}(Map params, HttpResponse res) async {
    String text;
    var cleanJSON = JSON.decode(params["${tableName}"].replaceAll('%5C', '\\\\').replaceAll('%7B', '{').replaceAll('%22', '"')
            .replaceAll('%20', ' ').replaceAll('%7D', '}').replaceAll('%5B', '[')
            .replaceAll('%5D', ']'));
    ${className} ${varName} = await new ${className}().findById(cleanJSON["id"]);

    if (${varName} != null) {
        ${saveString(tableName, varName, tables, rootPath)}
        var response = await ${varName}.save();
        if (response == "created" || response == "updated") {
            Map ${varName}_map = await ${varName}.toJson();
            print("found \${${varName}_map} ${varName}");
            text = JSON.encode(${varName}_map);
        } else {
            String text = JSON.encode({"no ${varName} found for ${tableName}_id \${cleanJSON["id"]}":""});
            print(text);
        }
        Routes.closeResWith(res, text);
    }
}

delete${className}(Map params, HttpResponse res) async {
    String text;
    ${className} ${varName} = await new ${className}().findById(params["${tableName}_id"]);
    if (${varName} != null) {
        Map ${varName}_map = await ${varName}.toJson();
        print("removing \${${varName}_map} ${varName}");
        await ${varName}.delete();
        text = JSON.encode(${varName}_map);
    } else {
        String text = JSON.encode({"no ${varName} found for ${tableName}_id \${params["${tableName}_id"]}":""});
        print(text);
    }
    Routes.closeResWith(res, text);
}
''';
            Directory dbModels = new Directory("${rootPath}/db/server");
            dbModels.create(recursive: true).then((_) {
                DBCore.stringToFilePath(dynamicFunctions, "${rootPath}/db/server/${tableName}_functions.dart");
                print("${rootPath}/db/server/server_functions.dart created");
                print("----------------------------------------------------------");
            });
        }
    }

    static String saveString(tableName, varName, tables, rootPath) {
        String str = "";
        //tableNames.remove("relationDivider");
        Map table = tables[tableName];
        List columnNames = table.keys.toList();
        for (String columnName in columnNames) {
            str += '${varName}.${columnName} = cleanJSON["$columnName"];\n';
        }
        return str;
    }

    /**
     *
     */
    static void generateRoutes(List dbTableNames, String rootPath) {
        String dynamicFunctions = '''
part of ${DSC.toVarName(rootPath.split(new String.fromCharCode(92)).last)}.simple_server;

final Map serverRoutes={

 ${generateRoutesString(dbTableNames)}
};

''';
        DBCore.stringToFilePath(dynamicFunctions, "${rootPath}/db/routes.dart");
        print("${rootPath}/db/routes.dart created");
        print("----------------------------------------------------------");
    }

    /**
     *
     */

    static String generateRoutesString(tableNames) {
        String str = "";
        List list = [];
        for (String dbTableName in tableNames) {
            var className = DSC.toClassName(dbTableName);
            var varName = DSC.toVarName(dbTableName);
            var polyName = DSC.toPolyName(dbTableName);
            var tableName = DSC.toTableName(dbTableName);

            str =
            ''' 'list${className}':{'url':new UrlPattern(r'/list${className}'),'method':'POST','action': list${className} ,'async':true},
         'load${className}':{'url':new UrlPattern(r'/load${className}'),'method':'POST','action': load${className} ,'async':true},
         'save${className}':{'url':new UrlPattern(r'/save${className}'),'method':'POST','action': save${className},'async':true },
         'delete${className}':{'url':new UrlPattern(r'/delete${className}'),'method':'POST','action': delete${className},'async':true }
         ''';
            list.add(str);
        }

        return (list.join(","));
    }

}