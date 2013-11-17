library dartabaseModel;

import "dart:io";
import "dart:convert";
import "dart:mirrors";
//import 'package:json_object/json_object.dart';

import "dart:async";
import 'package:dartabase_core/dartabase_core.dart';

import 'package:postgresql/postgresql.dart';
import 'package:postgresql/postgresql_pool.dart';

import 'package:sqljocky/sqljocky.dart';


var MAX = 1;

String uri;


class Model {
  num _id;
  num get id => _id;
  static void initiate(String rootPath){
    DBCore.rootPath = rootPath; 
    DBCore.loadConfigFile();
    print(rootPath);
  }
  
  
  Future save() {
    var completer = new Completer();
    
    String tableName = "${this.runtimeType}".toLowerCase();
    Map schema = DBCore.loadSchemaToMap();
    Future<Map> usedObjectDataFuture = getObjectScemaAttributes(this);
    usedObjectDataFuture.then((Map usedObjectData){
      //*loop through schema attributes and create sql 
      DBCore.loadConfigFile();
      if (DBCore.adapter == DBCore.PGSQL) {
        
        print(usedObjectData["insertValues"].toString());
         
        uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
        
        
        Pool pool = new Pool(uri, min: 1, max: 1);
        pool.start().then((_) {
          print('Min connections established.');
          pool.connect().then((conn) {
            if(usedObjectData["createOrUpdate"]=="create"){
              String insertSQL="insert into $tableName values (${usedObjectData["insertSpaceholder"].join(",")}) ";
              print(insertSQL);
              conn.execute(insertSQL, usedObjectData["insertValues"]).then((_) { 
                conn.close();
                completer.complete("done");
              });
            }else if(usedObjectData["createOrUpdate"]=="update"){
              String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
              print(updateSQL);
              conn.execute(updateSQL).then((_) { 
                conn.close();
                completer.complete("done");
              });
              
            }
            
            
          });
        });
        
      } else if (DBCore.adapter == DBCore.MySQL) {
        String insertSQL="replace into $tableName (${usedObjectData["insertColumns"].join(",")}) values (${usedObjectData["insertSpaceholder"].join(",")}) ";
        print(insertSQL);
        
        ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
        pool.prepare(insertSQL).then((query) {
          query.execute(usedObjectData["insertValues"]).then((result) {
//          print("New user's id: ${result.insertId}");
            completer.complete(result);
          });
        });
      }
    });
    return completer.future; 
  }
  Future find_by(String column, var value) {
    String tableName = "${this.runtimeType}".toLowerCase();
    String query = "SELECT * FROM $tableName WHERE $column = '$value' LIMIT 1";
    print(query);
    return find(query, false);
    
  }
  Future find_by_id(num id) {
    return find_by("id", id);
  }
  
  Future find_all_by(String column, var value ) {
    String tableName = "${this.runtimeType}".toLowerCase();
    String query = "SELECT * FROM $tableName WHERE $column = '$value'";
    print(query);
    return find(query, true);
  }
  
  Future find_all_by_id(num id) {
    return find_all_by("id", id);
  }
  
  Future find(String sql, bool resultAsList) {
    var completer = new Completer();
    
    print(this.runtimeType);
    
    //List usedObjectData = objectScemaAttributes(this);
    //*loop through schema attributes and fill object via reflections and mirrors
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
  
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          List data = new List();
          conn.query(sql).toList().then((rows) {
            for (var row in rows) {
              var object = setObjectScemaAttributes(this , row);  
              data.add(object);
            }
          }).then((_) { 
            conn.close();
            if(resultAsList == true){
              completer.complete(data);  
            }
            else if(resultAsList == false){
              completer.complete(data[0]);
            }
          });
        });
      });
  
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      List row;
      pool.query(sql).then((results) {
        List data = new List();
        results.stream.listen((row) {
          var object = setObjectScemaAttributes(this , row);  
          data.add(object);
        }).asFuture().then((_){
          if(resultAsList == true){
            completer.complete(data);  
          }
          else if(resultAsList == false){
            completer.complete(data[0]);
          }
            
        });
        
        
        
        
      });
      pool.close();
      
    }
    //return this as future???
    return completer.future; 
    //get schema
    //filter scema for this.runtimeType
    //if exists connect to db and fill 'this' with db values 
   // "select * from ${this.runtimeType}";
  }

  
  InstanceMirror getMirrorOf(object){
    InstanceMirror instanceMirror = reflect(object); // Get an instance mirror
    print(instanceMirror.reflectee == object); // true
    print(instanceMirror.reflectee);  
    return instanceMirror;
    
  }
  Future<Map> getObjectScemaAttributes(object)
  {
    var completer = new Completer();
    getNewId().then((id){
      Map schema = DBCore.loadSchemaToMap();
      Map objectSchemaMap = schema["${object.runtimeType}"];
      Iterable columnNames = objectSchemaMap.keys;
      
      InstanceMirror instanceMirror = reflect(object);
      List insertColumns = [];
      List insertSpaceholder = [];
      List listValues = [];
      Map mapValues;
      String createOrUpdate;
      var insertValues;
      List updateValues = [];
      String updateWhere;
      var i = 0;
      for(var column in columnNames){
        Symbol symbol =new Symbol(column);
        InstanceMirror field = instanceMirror.getField(symbol);
        
        var value = field.reflectee;
        

        if(column == "id" && value == null){
          createOrUpdate = "create";
          insertColumns.add("id");
          listValues.add(id);
        }else if(column == "id" && value != null){
          if(value >id){
            createOrUpdate="create";
            listValues.add(id);  
          }else{
            createOrUpdate="update";
            updateWhere="id=$value";
            listValues.add(value);
          }
          insertColumns.add("id");
        }else if(column != "id" && value != null){
          insertColumns.add(column);
          listValues.add(value);
          updateValues.add("${column}='${value}'");
          
        }else if(column != "id" && value == null){
          insertColumns.add(column);
          listValues.add(DBCore.defaultValueFor(objectSchemaMap[column]));
          //updateValues.add("${column}=${DBCore.defaultValueFor(objectSchemaMap[column])}");
        }
        if (DBCore.adapter == DBCore.PGSQL) {
          insertSpaceholder.add("@${column}");
        }else if (DBCore.adapter == DBCore.MySQL) {
          insertSpaceholder.add("?");
        }
        i+=1;
      }
      if (DBCore.adapter == DBCore.PGSQL) {
        insertValues = new Map.fromIterables(insertColumns, listValues); 
      }else if (DBCore.adapter == DBCore.MySQL) {
        insertValues = listValues;
      }
      completer.complete({
        "insertColumns":insertColumns, 
        "insertSpaceholder":insertSpaceholder, 
        "insertValues":insertValues, 
        "updateValues":updateValues, 
        "updateWhere":updateWhere, 
        "createOrUpdate":createOrUpdate
      });
    });
    return completer.future;
  }
  setObjectScemaAttributes(object,row)
  {
    Map schema = DBCore.loadSchemaToMap();
    Map objectSchemaMap = schema["${object.runtimeType}"];
    Iterable columnNames = objectSchemaMap.keys;
    ClassMirror classMirror = reflectClass(object.runtimeType);
    var newInstanceObject = classMirror.newInstance(const Symbol(''), []);
        
    var i = 0;
    for(var column in columnNames){
      Symbol symbol = new Symbol(column);
      var value;
      if(row[i] == ""){
        var dartatype = objectSchemaMap[column];
        value = DBCore.defaultValueFor(dartatype);
      }else{
        value = row[i];
      }
      InstanceMirror field = newInstanceObject.setField(symbol,value);
      print("$column -> ${value}");
      i++;
    }
    return newInstanceObject.reflectee;
    //return completer.future;
  }
 
  Future getNewId() {
    var completer = new Completer();

    
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          List data = new List();
          conn.query("SELECT MAX(ID) FROM ${this.runtimeType}").toList().then((rows) {
            num value ;
            
            if(rows[0].max == null){
              value = 1;
            }else{
              value = rows[0].max + 1;
            }
            print("new Index ${value}");
            completer.complete(value);
            
          });
        });
      });
  
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      List row;
      pool.query("SELECT MAX(ID) FROM ${this.runtimeType}").then((results) {
        List data = new List();
        results.stream.listen((row) {
          num value ;
          
          if(row[0] == null){
            value = 1;
          }else{
            value = row[0] + 1;
          }
          print("new Index ${value}");
          completer.complete(value);
        });
      });
      pool.close();
    }
    return completer.future;
  }
}