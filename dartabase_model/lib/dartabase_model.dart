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

  /**
   * Future save() 
   * 
   * once future completes
   *  
   * Returns String "created" or "updated"
   * TODO chatch errors ?? needed here? 
   * 
   * player.save().then((process){
   *   if(process == "created" || process == "updated"){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future save() {
    Completer completer = new Completer();
    
    String tableName = DBCore.toTableName("${this.runtimeType}");
    
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
                completer.complete("created");
              });
            }else if(usedObjectData["createOrUpdate"]=="update"){
              String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
              print(updateSQL);
              conn.execute(updateSQL).then((_) { 
                conn.close();
                completer.complete("updated");
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
              completer.complete("created");
            });
          });  
        }else if(usedObjectData["createOrUpdate"]=="update"){
          String updateSQL="UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
          print(updateSQL);
          
          ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
          pool.query(updateSQL).then((result) {
            completer.complete("updated");
          });
        }
      }
    });
    return completer.future; 
  }
  
  Future find(String sql, bool resultAsList) {
    Completer completer = new Completer();
    
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
              completer.complete(null);
            }
          }
        });
      });
      pool.close();
    }
    return completer.future; 
  }

  /**
   * Future findBy(String column,var value) 
   * 
   * once future completes
   * 
   * returns an (player) object if one exists 
   * else 
   * returns null
   *
   * player.findBy("name","tim").then((player){
   *   if(player != null){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future findBy(String column, var value) {
    
    String tableName = DBCore.toTableName("${this.runtimeType}");
        
    String query = "SELECT * FROM $tableName WHERE $column = '$value' LIMIT 1";
    print(query);
    return find(query, false);
  }

  /**
   * Future findById(var id) 
   * 
   * once future completes
   * 
   * returns an (player) object if one exists 
   * else 
   * returns null
   *
   * player.findById("3").then((player){
   *   if(player != null){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future findById(var id) {
    return findBy("id", id);
  }
  
  /**
   * Future findAllBy(String column, var value) 
   * 
   * once future completes
   * 
   * returns a list of (player) objects if one exists 
   * else 
   * returns empty list
   *
   * player.findAllBy("name","tim").then((players){
   *   if(!players.isEmpty){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future findAllBy(String column, var value ) {
    
    String tableName = DBCore.toTableName("${this.runtimeType}");
        
    String query = "SELECT * FROM $tableName WHERE $column = '$value'";
    print(query);
    return find(query, true);
  }
  
  /**
   * Future findAll() 
   * 
   * once future completes
   * 
   * returns a list of (player) objects if one exists 
   * else 
   * returns empty list
   *
   * player.findAll().then((players){
   *   if(!players.isEmpty){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future findAll() {

    String tableName = DBCore.toTableName("${this.runtimeType}");
          
    String query = "SELECT * FROM $tableName";
    print(query);
    return find(query, true);
  }
  
  /**
   * Future delete() 
   * 
   * once future completes
   * 
   * deletes the object //TODO and all its relations
   * 
   * player.delete();
   * 
   **/
  Future delete() {
    Completer completer = new Completer();
    
    String tableName = DBCore.toTableName("${this.runtimeType}");
           
    //TODO recursive master slave dependency removal via
    //this.removeDependentRelations();
    String SQL="DELETE FROM $tableName WHERE id = ${this.id}";
    print(SQL);
    if(DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          conn.execute(SQL).then((result) { 
            conn.close();
            //completer.complete("deleted item with id ${this.id}");
            completer.complete(result);
          });
        });
      });
    }else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      pool.query(SQL).then((result) {
        //completer.complete("deleted item with id ${this.id}");
        completer.complete(result);
      });
    }
    return completer.future; 
  }

  //##########RELATIONS START############  
  
  /**
   * Future receive(object) 
   * 
   * once future completes
   * creates relation between the two objects (player and character)
   * ...
   * 
   * player.receive(character).then((result){
   *   
   * }); 
   * 
   **/
  Future receive(object) {
    Completer completer = new Completer();
    

    String initiatedObject = DBCore.toTableName("${this.runtimeType}");
    String relatedObject= DBCore.toTableName("${object.runtimeType}");
    
    List tableNames = [initiatedObject,relatedObject];
    tableNames.sort();
    String tableName = "${tableNames[0]}_2_${tableNames[1]}";
     
    //String sql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id); ";
    //String sql ="";
    //String preSql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id); ";
    //String postSql = "WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE ${initiatedObject}_id='${this.id}' AND ${relatedObject}_id='${object.id}');";
    
     
    String sql="INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id) VALUES ('${this.id}', '${object.id}')";
    
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      
      //sql = preSql + "SELECT '${this.id}', '${object.id}' " + postSql;
      print(sql);   
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          conn.execute(sql).then((result) { 
            conn.close();
            completer.complete(result);
          });
        });
      });
      
    } else if (DBCore.adapter == DBCore.MySQL) {
      ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
      //sql = preSql + "SELECT * FROM (SELECT '${this.id}', '${object.id}') AS tmp " + postSql;
      print(sql); 
      
      pool.query(sql).then((result) {
        completer.complete(result);
      });
    }
    return completer.future;
  }
  
  Future has(object,listOrValue,[String column,String value]) {
    Completer completer = new Completer();

    String initiatedObject = DBCore.toTableName("${this.runtimeType}");
    String relatedObject= DBCore.toTableName("${object.runtimeType}");
        
    List tableNames = [initiatedObject,relatedObject];
    tableNames.sort();
    String tableName = "${tableNames[0]}_2_${tableNames[1]}";
    String intiatiorString = "${initiatedObject}_id = ${this.id}";
    String limit = "";
    if(listOrValue){
      limit = " limit 1";
    }
    String sql2 = "SELECT a2p.${relatedObject}_id FROM ${tableName} a2p WHERE a2p.${intiatiorString} ";
    String query = "SELECT p.* FROM ${relatedObject} p WHERE p.id IN(${sql2}) ";
    if(column != null && value != null){
      query += "AND p.$column = '$value'";
    }
    if(listOrValue){
      query += " limit 1";
    }
    
    query += ";";
    //print(query);
    return object.find(query, listOrValue);
     
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
   *   if(!characters.isEmpty){
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
   *   if(!characters.isEmpty){
   *     //your code
   *   }else{
   *   }
   * }); 
   * 
   **/
  Future hasManyWith(object,String column,String value) {
    return has(object,true,column,value);
  }
  
  
  /**
   * Future remove(object) 
   * 
   * once future completes
   * remove relation between the two objects (player and character)
   * ...
   * 
   * player.remove(character).then((result){
   *   
   * }); 
   * 
   **/
  Future remove(object) {
    Completer completer = new Completer();

    String initiatedObject = DBCore.toTableName("${this.runtimeType}");
    String relatedObject= DBCore.toTableName("${object.runtimeType}");
            
    List tableNames = [initiatedObject,relatedObject];
    tableNames.sort();
    String tableName = "${tableNames[0]}_2_${tableNames[1]}";
     
    
    
    
    String SQL="DELETE FROM $tableName WHERE ${initiatedObject}_id = ${this.id} AND ${relatedObject}_id = ${object.id}";
    print(SQL);
    
    if (DBCore.adapter == DBCore.PGSQL) {
      
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          conn.execute(SQL).then((result) { 
            conn.close();
            completer.complete(result);
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
  
      
  //################HELPERMETHODS
  InstanceMirror getMirrorOf(object){
    InstanceMirror instanceMirror = reflect(object); // Get an instance mirror
    //print(instanceMirror.reflectee == object); // true
    //print(instanceMirror.reflectee);  
    return instanceMirror;
  }
  
  /**
   * Future getObjectScemaAttributes(object) 
   * 
   * once future completes
   * 
   * returns a map used to generate sql from object 
   * via scema attribute comparison 
   *  
   **/
  Future<Map> getObjectScemaAttributes(object)
  {
    Completer completer = new Completer();
    getNewId().then((id){
      Map schema = DBCore.loadSchemaToMap();
      
      String tableName= DBCore.toTableName("${object.runtimeType}");
          
      Map objectSchemaMap = schema["${tableName}"];
      Iterable columnNames = objectSchemaMap.keys;
      num objectId;
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
          objectId = id;
        }else if(column == "id" && value != null){
          if(value >=id){
            createOrUpdate="create";
            listValues.add(id);
            objectId = id;
          }else{
            createOrUpdate="update";
            updateWhere="id=$value";
            listValues.add(value);
            objectId = value;
          }
          insertColumns.add("id");
        }else if(column != "id" && value != null){
          insertColumns.add(column);
          var dbType = DBCore.dbType(objectSchemaMap[column]);
          if(dbType == "BOOLEAN"){
            if(value==false){
              value = '0';
            }else if(value==true){
              value = '1';
            }
          }
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
        "objectId":objectId
      });
    });
    return completer.future;
  }
  
  /**
   * Future setObjectScemaAttributes(object,row) 
   * 
   * once future completes
   * 
   * returns an updated object from map 
   * via scema attribute comparison 
   *  
   **/
  
  setObjectScemaAttributes(object, row)
  {
    Map schema = DBCore.loadSchemaToMap();
    String tableName = DBCore.toTableName("${object.runtimeType}");
              
    Map objectSchemaMap = schema["${tableName}"];
    
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
        var dbType = DBCore.dbType(objectSchemaMap[column]);
        if(dbType == "BOOLEAN"){
          if(row[i]==0 || row[i]=="0"){
            value = false;
          }else if(row[i]==1 || row[i]=="1"){
            value = true;
          }else{
            value = row[i];
          }
        }else{
          value = row[i];
        }
      }
      InstanceMirror field = newInstanceObject.setField(symbol,value);
      //print("$column -> ${value}");
      i++;
    }
    return newInstanceObject.reflectee;
  }
 
  Future getNewId() {
    Completer completer = new Completer();

    
    DBCore.loadConfigFile();
    if (DBCore.adapter == DBCore.PGSQL) {
      uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
      Pool pool = new Pool(uri, min: 1, max: 1);
      pool.start().then((_) {
        print('Min connections established.');
        pool.connect().then((conn) {
          List data = new List();

          String tableName = DBCore.toTableName("${this.runtimeType}");
          
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

      String tableName = DBCore.toTableName("${this.runtimeType}");
      
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
  Future removeDependentRelations(){
    Completer completer = new Completer();
    Map schema = DBCore.loadSchemaToMap();
    print(schema);
    
    //TODO 1.find relations
    String initiatedObject = DBCore.toTableName("${this.runtimeType}");
    
    Map m = {"a_2_m":{},"m_2_z":{}};
    List relationNames =[];
    List objectNames =[];
    List delRelations =[];
    m.keys.forEach((String tableName){
      relationNames.add(tableName);
      String relatedObject;
      if(tableName.contains("${initiatedObject}_2_")){
        relatedObject = tableName.split("${initiatedObject}_2_")[0];
        //tableNames.add(tableName);
        //objectNames.add(tableName.split("_2_"));
        //delRelations.add("DELETE t$tableName FROM $tableName as t$tableName WHERE ${initiatedObject}_id = '${this.id}'");
      }else if(tableName.contains("_2_${initiatedObject}")){
        relatedObject = tableName.split("_2_${initiatedObject}")[0];
        //tableNames.add(tableName);
        //objectNames.add(tableName.split("_2_"));
        //delRelations.add("DELETE t$tableName FROM $tableName as t$tableName WHERE ${initiatedObject}_id = '${this.id}'");
      }
      delRelations.add("DELETE t${relatedObject} " +
          "FROM ${relatedObject} as t${relatedObject}" +
          "JOIN ${tableName} as t${tableName}" + 
          "ON t${relatedObject}.id = t${tableName}.${relatedObject}_id" +
          "AND b.quizId = @quizId" +
          
          "DELETE t${tableName} WHERE quizId = @quizId") ;
    });
    
    
    
        
    //TODO 2.get related objects
    
    //TODO 2.get related objects
    

    /**String initiatedObject = "${this.runtimeType}".toLowerCase();
     *String relatedObject = "${object.runtimeType}".toLowerCase();
    *
    *List tableNames = [initiatedObject,relatedObject];
    *tableNames.sort();
    *String tableName = "${tableNames[0]}_2_${tableNames[1]}";
    **/
    return completer.future;
  }
  
  Map toJson() { 
      Map map = new Map();
      InstanceMirror im = reflect(this);
      ClassMirror cm = im.type;
      var decls = cm.declarations.values.where((dm) => dm is VariableMirror);
      decls.forEach((dm) {
        var key = MirrorSystem.getName(dm.simpleName);
        var val = im.getField(dm.simpleName).reflectee;
        if(val.runtimeType==DateTime){
          val = val.millisecondsSinceEpoch;
        }
        //print("val.runtimeType: ${val.runtimeType}");
        map[key] = val;
      });

      return map;
  }
}