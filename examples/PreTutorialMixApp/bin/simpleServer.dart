library example.server;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../lib/paths.dart';

part 'item.dart';

/* A simple web server that responds to **ALL** GET and **POST** requests
 * 
 * Browse to it using http://localhost:8080  
 * 
 * Provides CORS headers, so can be accessed from any other page
 */

final HOST = "127.0.0.1"; // eg: localhost 
final PORT = 8090; 

void main() {
  
  HttpServer.bind(HOST, PORT).then((server) {
    server.listen((HttpRequest request) {
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
        default: defaultHandler(request);
      }
    }, 
    onError: printError);
    
    print("Listening for GET and POST on http://$HOST:$PORT");
  },
  onError: printError);
}

/**
 * Handle GET requests 
 */
void handleGet(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");
  String path=req.uri.path;
  addCorsHeaders(res);

  if(path == "/$itemsLoadUrl"){
    Item.loadItems(res);
  }else if(path.contains("/$itemLoadUrl")){
    String id= path.split("/$itemLoadUrl/")[1];
    Item.loadItem(res, id);
  }else {
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
  String path=req.uri.path;
  addCorsHeaders(res);
  
  if(path == "/$itemSaveUrl"){
      Item.saveItem(req, res);
  } else if(path == "/$itemDeleteUrl"){
    Item.deleteItem(req, res);
  }
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

