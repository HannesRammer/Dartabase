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
  
  /**
   * Future hasOne(object) 
   * 
   * once future completes
   * 
   * returns an (character) object if one exists 
   * else 
   * returns null
   * 
   * player.hasOne(new Character()).then((character){
   *   if(character != null){
   *     //your code
   *   }else{
   *   }
   * };
   **/
  Future hasOne(object) {
    return has(object,false);
  }
  
  /**
   * Future hasMany(object) 
   * 
   * once future completes
   * 
   * returns a list of (character) objects if one exists 
   * else 
   * returns empty list
   *
   * player.hasManyWith(new Character()).then((characters){
   *   if(characters[0] != null){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future hasMany(object) {
    return has(object,true);
  }
  
  /**
   * Future hasOneWith(object,String column,String value) 
   * 
   * once future completes
   *  
   * returns an (character) object if one exists 
   * else 
   * returns null
   *  
   * player.hasOneWith(new Character(),'level','3').then((character){
   *   if(character != null){
   *     //your code
   *   }else{
   *   }
   * });
   * 
   **/
  Future hasOneWith(object,String column,String value) {
    return has(object,false,column,value);
  }
  
  /**
   * Future hasManyWith(object,String column,String value) 
   * 
   * once future completes
   *  
   * Returns a list of (character) objects if one exists 
   * else 
   * Returns empty list
   *
   * player.hasManyWith(new Character(),'level','3').then((characters){
   *   if(characters[0] != null){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future hasManyWith(object,String column,String value) {
    return has(object,true,column,value);
  }
  Future has(object,listOrValue,[String column,String value]) {
    var completer = new Completer();
    String initiatedObject = "${this.runtimeType}".toLowerCase();
    String relatedObject = "${object.runtimeType}".toLowerCase();
    
    List tableNames = [initiatedObject,relatedObject];
    tableNames.sort();
    String tableName = "${tableNames[0]}_2_${tableNames[1]}";
    String intiatiorString = "${initiatedObject}_id = ${this.id}";
    String sql2 = "SELECT a2p.${relatedObject}_id FROM ${tableName} a2p WHERE a2p.${intiatiorString}";
    String query = "SELECT p.* FROM ${relatedObject} p WHERE p.id IN(${sql2}) ";
    if(column != null && value != null){
      query += "AND p.$column = '$value'";
    }
    query += ";";
    //print(query);
    return object.find(query, listOrValue);
     
  }
  
  Future recieves(object) {
    var completer = new Completer();
    String initiatedObject = "${this.runtimeType}".toLowerCase();
    String relatedObject = "${object.runtimeType}".toLowerCase();
    
    List tableNames = [initiatedObject,relatedObject];
    tableNames.sort();
    String tableName = "${tableNames[0]}_2_${tableNames[1]}";
     
    
    String sql ="";
    String preSql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id) ";
    String postSql = "WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE ${initiatedObject}_id='${this.id}' AND ${relatedObject}_id='${object.id}');";
    
    print(sql);  
    
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      
      sql = preSql + "SELECT '${this.id}', '${object.id}' " + postSql;
        
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          conn.execute(sql).then((_) { 
            conn.close();
            completer.complete("done");
          });
        });
      });
      
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      
      sql = preSql + "SELECT * FROM (SELECT '${this.id}', '${object.id}') AS tmp " + postSql;
      
      pool.query(sql).then((result) {
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
    InstanceMirror instanceMirror = reflect(this);
    
    usedObjectDataFuture.then((Map usedObjectData){
      //*loop through schema attributes and create sql 
      var object = instanceMirror.reflectee;
      object.id = usedObjectData["objectId"];
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
                completer.complete(object);
              });
            }else if(usedObjectData["createOrUpdate"]=="update"){
              String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
              print(updateSQL);
              conn.execute(updateSQL).then((_) { 
                conn.close();
                completer.complete(object);
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
              completer.complete(object);
            });
          });  
        }else if(usedObjectData["createOrUpdate"]=="update"){
          String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
          print(updateSQL);
          
          ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
          pool.query(updateSQL).then((result) {
            completer.complete(object);
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
    
    //print(this.runtimeType);
    
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
              if(data != null && data.length > 0){
                completer.complete(data[0]);  
              }else{
                completer.complete(null);
              }
              
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
            if(data != null && data.length > 0){
              completer.complete(data[0]);  
            }else{
              completer.complete([]);
            }
          }
        });
      });
      pool.close();
    }
    return completer.future; 
  }

  
  InstanceMirror getMirrorOf(object){
    InstanceMirror instanceMirror = reflect(object); // Get an instance mirror
    //print(instanceMirror.reflectee == object); // true
    //print(instanceMirror.reflectee);  
    return instanceMirror;
  }
  Future<Map> getObjectScemaAttributes(object)
  {
    var completer = new Completer();
    getNewId().then((id){
      Map schema = DBCore.loadSchemaToMap();
      Map objectSchemaMap = schema["${object.runtimeType}".toLowerCase()];
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
        "createOrUpdate":createOrUpdate,
        "objectId":id
      });
    });
    return completer.future;
  }
  updateObjectId(object,int id)
  {
    Map schema = DBCore.loadSchemaToMap();
    Map objectSchemaMap = schema["${object.runtimeType}".toLowerCase()];
    Iterable columnNames = objectSchemaMap.keys;
    ClassMirror classMirror = reflectClass(object.runtimeType);
    var newInstanceObject = classMirror.newInstance(const Symbol(''), []);
        
    var i = 0;
    for(var column in columnNames){
      Symbol symbol = new Symbol(column);
      var value;
      if(row[i] == ""){
        value = DBCore.defaultValueFor(objectSchemaMap[column]);
      }else{
        value = row[i];
      }
      InstanceMirror field = newInstanceObject.setField(symbol,value);
      //print("$column -> ${value}");
      i++;
    }
    return newInstanceObject.reflectee;
  }
  setObjectScemaAttributes(object, row)
  {
    Map schema = DBCore.loadSchemaToMap();
    Map objectSchemaMap = schema["${object.runtimeType}".toLowerCase()];
    Iterable columnNames = objectSchemaMap.keys;
    ClassMirror classMirror = reflectClass(object.runtimeType);
    var newInstanceObject = classMirror.newInstance(const Symbol(''), []);
        
    var i = 0;
    for(var column in columnNames){
      Symbol symbol = new Symbol(column);
      var value;
      if(row[i] == ""){
        value = DBCore.defaultValueFor(objectSchemaMap[column]);
      }else{
        value = row[i];
      }
      InstanceMirror field = newInstanceObject.setField(symbol,value);
      //print("$column -> ${value}");
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
          String tableName = "${this.runtimeType}".toLowerCase();
          conn.query("SELECT MAX(ID) FROM ${tableName}").toList().then((rows) {
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
      String tableName = "${this.runtimeType}".toLowerCase();
      pool.query("SELECT MAX(ID) FROM ${tableName}").then((results) {
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