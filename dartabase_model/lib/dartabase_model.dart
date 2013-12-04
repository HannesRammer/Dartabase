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
  
  Future delete() {
    var completer = new Completer();
    String tableName = "${this.runtimeType}".toLowerCase();
    
    String SQL="DELETE FROM $tableName WHERE id = ${this.id}";
    print(SQL);
    
    if (DBCore.adapter == DBCore.PGSQL) {
      
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          conn.execute(SQL).then((_) { 
            conn.close();
            completer.complete("done");
          });
        });
      });
      
    } else if (DBCore.adapter == DBCore.MySQL) {
      
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      pool.query(SQL).then((result) {
        completer.complete(result);
      });
     
    }
    return completer.future; 
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
              print(usedObjectData["insertValues"].toString());
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
        if(usedObjectData["createOrUpdate"]=="create"){
          String insertSQL="insert into $tableName (${usedObjectData["insertColumns"].join(",")}) values (${usedObjectData["insertSpaceholder"].join(",")}) ";
          print(insertSQL);
          
          ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
          pool.prepare(insertSQL).then((query) {
            query.execute(usedObjectData["insertValues"]).then((result) {
              completer.complete(result);
            });
          });  
        }else if(usedObjectData["createOrUpdate"]=="update"){
          String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
          print(updateSQL);
          
          ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
          pool.query(updateSQL).then((result) {
            completer.complete(result);
          });
        }
      }
    });
    return completer.future; 
  }
  Future findBy(String column, var value) {
    String tableName = "${this.runtimeType}".toLowerCase();
    String query = "SELECT * FROM $tableName WHERE $column = '$value' LIMIT 1";
    print(query);
    return find(query, false);
  }
  Future findById(num id) {
    return findBy("id", id);
  }
  
  Future findAllBy(String column, var value ) {
    String tableName = "${this.runtimeType}".toLowerCase();
    String query = "SELECT * FROM $tableName WHERE $column = '$value'";
    print(query);
    return find(query, true);
  }
  
  Future findAllById(num id) {
    return findAllBy("id", id);
  }
  
  Future find(String sql, bool resultAsList) {
    var completer = new Completer();
    
    print(this.runtimeType);
    
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
        results.listen((row) {
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
    return completer.future; 
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
          if(value >=id){
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
        results.listen((row) {
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