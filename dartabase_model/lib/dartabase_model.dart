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
  
  static void initiate(String rootPath){
    DBCore.rootPath = rootPath; 
    print(rootPath);
  }
  
  
  Future save() {
    var completer = new Completer();
    
    String tableName = "${this.runtimeType}".toLowerCase();
    Map schema = DBCore.loadSchemaToMap();
    List usedObjectData = getObjectScemaAttributes(this);
    String insertSQL="insert into $tableName (${usedObjectData[0].join(",")}) values (${usedObjectData[1].join(",")}) ";
    print(insertSQL);
    //*loop through schema attributes and create sql 
    
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://$DBCore.username:$DBCore.password@$DBCore.host:$DBCore.port/$DBCore.database';
  
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          //migrate(conn);
        });
      });
  
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      pool.prepare(insertSQL).then((query) {
        query.execute(usedObjectData[2]).then((result) {
          print("New user's id: ${result.insertId}");
          completer.complete(result);
        });
      });
    }
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
      uri = 'postgres://$DBCore.username:$DBCore.password@$DBCore.host:$DBCore.port/$DBCore.database';
  
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          //migrate(conn);
        });
      });
  
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      List row;
      pool.query(sql).then((results) {
//        for (var field in results.fields){
//          print('Name: ${field.name}');
//          
//        }
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
  List getObjectScemaAttributes(object)
  {
    Map schema = DBCore.loadSchemaToMap();
    Iterable columnNames = schema["${object.runtimeType}"].keys;
    InstanceMirror instanceMirror = reflect(object);
    List usedColumns = [];
    List usedSpaceholder = [];
    List usedValues = [];
    for(var column in columnNames){
      Symbol symbol =new Symbol(column);
      InstanceMirror field = instanceMirror.getField(symbol);
      
      var value = field.reflectee;
      if(value != null){
        usedColumns.add(column);
        usedSpaceholder.add("?");
        usedValues.add(value);
        
        print(value);
      }
    }
    return [usedColumns, usedSpaceholder, usedValues];
  }
  setObjectScemaAttributes(object,row)
  {
    
    Map schema = DBCore.loadSchemaToMap();
    Iterable columnNames = schema["${object.runtimeType}"].keys;
    ClassMirror classMirror = reflectClass(object.runtimeType);
    var newInstanceObject = classMirror.newInstance(const Symbol(''), []);
        
    var i = 0;
    for(var column in columnNames){
      Symbol symbol = new Symbol(column);
      InstanceMirror field = newInstanceObject.setField(symbol,row[i]);
      print("$column -> ${row[i]}");
      i++;
    }
    return newInstanceObject.reflectee;
  }
 
  
}