library dartabaseMigration;

import "dart:io";
import 'dart:convert';

import 'package:dartabase_core/dartabase_core.dart';
import 'package:route/url_pattern.dart';
import 'package:routes/server.dart';

import 'dartabaseMigration.dart' as DM;

part '../tool/dbhelper.dart';

part '../routes.dart';
part 'serverFunctions.dart';

/* A simple web server that responds to **ALL** GET and **POST** requests
 * Browse to it using http://localhost:8079  
 * Provides CORS headers, so can be accessed from any other page
 */
final String HOST = "127.0.0.1"; // eg: localhost
final num PORT = 8079;

void main() {
  HttpServer.bind(HOST, PORT).then((server) {
    var router = initRouter("C:\\Projects\\Dart\\dartabase\\dartabase_migration",server,serverRoutes);
    print("Listening for GET and POST on http://$HOST:$PORT");
  }, onError: printError);
}

void printError(error) => print(error);
