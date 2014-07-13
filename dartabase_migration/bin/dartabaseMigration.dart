library dartabaseMigration;


import "dart:io";
import "dart:async";

import 'package:dartabase_core/dartabase_core.dart';

import 'package:postgresql/postgresql.dart';
import 'package:postgresql/postgresql_pool.dart';

import 'package:sqljocky/sqljocky.dart';

part '../tool/dbhelper.dart';

String uri;

Map schema ;

List files;

int fileId = null;

String direction;

Map projectMapping ;
int lastMigrationNumber;

void initiateDartabase(String path,String projectName) {
  print("add project mapping ${projectName}:${path}");
  File file = new File("projectsMapping.json");
  if(file.existsSync()){
    projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
    
  }else{
    DBCore.mapToJsonFilePath({}, "projectsMapping.json");
    projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
  }
  projectMapping[projectName]=path;
  DBCore.mapToJsonFilePath(projectMapping, "projectsMapping.json");
  Map config={
    "adapter": "PGSQL",
    "database": "DBName",
    "username": "DBUsername",
    "password": "DBPassword",
    "host": "localhost",
    "port": "5432",
    "schemaVersion":"0",
    "ssl": "false"
  };
  Directory directory = new Directory("${path}/db/migrations");
  
  directory.create(recursive: true).then((_){
    print("created directory ${directory.path}");
    
    print("creating $path/db/config.json");
    DBCore.mapToJsonFilePath(config, "$path/db/config.json");
    
    print("creating $path/db/schema.json");
    DBCore.mapToJsonFilePath({}, "$path/db/schema.json");

    print("creating $path/db/schemaVersion.json");
    Map schemaVersion = {"schemaVersion":""};
    DBCore.mapToJsonFilePath(schemaVersion, "$path/db/schemaVersion.json");
//    exit(0);

  });
}

/**Connects to a PG/MY-SQL Database (dependend on the db/config.json file).
* 
* Executes the migration steps specified in the "migrationDirection" keyword inside the db/migrations/ files.
* in ascending order which have not been migrated to the database. 
**/

Future run(String migrationDirection) {
  Completer completer = new Completer();
  direction = migrationDirection;
  schema = DBCore.loadSchemaToMap();
  DBCore.loadConfigFile();
  if (DBCore.adapter == DBCore.PGSQL) {
    uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
    if(DBCore.ssl){
      uri +="?sslmode=require";
    }
    Pool pool = new Pool(uri, min: 1, max: 1);
    pool.start().then((_) {
      print('Min connections established.');
      pool.connect().then((conn) {
        migrate(conn).then((_){
          completer.complete("done");
        });
      });
    });

  } else if (DBCore.adapter == DBCore.MySQL) {
    ConnectionPool pool;
    if(DBCore.ssl){
      pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5, useSSL: true);
    }else{
      pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
    }
    
    migrate(pool).then((_){
      completer.complete("done");
    });
  }
  return completer.future;
}
//TODO move to helper



Future migrate(conn) {
  Completer completer = new Completer();
  DBCore.parsedMapping = DBCore.jsonFilePathToMap('../tool/typeMapper${DBCore.adapter}.json');

  Directory directory = new Directory("${DBCore.rootPath}/db/migrations");
  files = directory.listSync();
  if (files.length > 0) {
    
      files.forEach((file){ 
        
        if(file.path.split("migrations")[1].replaceAll("\\","") == DBCore.schemaVersion ){
          if (direction == "UP") {
            fileId = files.indexOf(file)+1;
          
          } else if (direction == "DOWN") {
            fileId = files.indexOf(file);
          
          }
          
        }
      });
    
      
      if (fileId == null){
        if (direction == "UP") {
          fileId = 0;
        } else if (direction == "DOWN") {
          fileId = files.length - 1;
        }
      }
      if(lastMigrationNumber >= 0 && lastMigrationNumber <= files.length){
        //print("lastMigrationNumber$lastMigrationNumber");
        //print("fileId$fileId");
        
        if (direction == "UP") {
            if (lastMigrationNumber > fileId - 1) {
              doFile(conn);
            }else{
              print("goal migration smaller or equal current migration, maybe you wanted to revert migration via dbDown instead");
            }
          
          
        }else if (direction == "DOWN") {
          if (lastMigrationNumber <= fileId) {
            doFile(conn);
          }else{
            print("goal migration higher or equal current migration, maybe you wanted to migrate via dbUp instead");
          }
        }
      }else{
        print("goal migration number out of range. goal migration doesnt exist ");
      }
      completer.complete("done");
  } else {
    print("\nno migration files in folder ${directory.path}");
    completer.complete("done");
    
  }

  return completer.future;
}

void doFile(conn) {
  print("\n----------Start migration for file ${files[fileId].path}-------------");
  DBCore.parsedMap = DBCore.jsonFilePathToMap(files[fileId].path)["$direction"];
  if (DBCore.parsedMap != null) {
    createTable(conn);
  } else {
    print("migration direction '$direction' not specified in file ${files[fileId].path}");
  }
//load with next file after this has finished

}

String notNull(String notNull){ 
  
  if(notNull=="true"){
    return " NOT NULL ";
  }else{
    return "";
  }
}
String defaultValue(String dv){
  if(dv != null){
    return " DEFAULT '${dv}' ";
  }else{
    return "";
  }
}
void createTable(conn) {
  if (DBCore.parsedMap["createTable"] != null) {
    Map ct = DBCore.parsedMap["createTable"];
    List tableNames = ct.keys.toList();
    for (int i = 0;i < tableNames.length;i++) {
      String tableName = tableNames[i];
      if (schema[tableName] == null) {
        String sqlQuery="";
        List sqlList = ["CREATE TABLE IF NOT EXISTS ${tableName} ( ${DBHelper.primaryIDColumnString(DBCore.adapter)} "];
        Map columns = ct[tableName];
        List columnNames = columns.keys.toList();
        schema[tableName] = {};
        Map schemaTableMap = schema[tableName];
        schemaTableMap["id"] = {"type":"INT"};
        for (int j = 0;j < columnNames.length;j++) {
          String columnName = columnNames[j];
          if (schemaTableMap[columnName] == null) {
            if (columns[columnName].runtimeType == String){
              
              String columnType = columns[columnName];
              sqlList.add("${columnName} ${DBCore.typeMapping(columnType)} ");
              schemaTableMap[columnName] = columnType;
            }else if(columns[columnName].runtimeType.toString() == "_LinkedHashMap"){
              Map columnOptions = columns[columnName];
              String columnType = columnOptions["type"];
              sqlList.add("${columnName} ${DBCore.typeMapping(columnType)} ${notNull(columnOptions["null"])} ${defaultValue(columnOptions["default"])} ");
              schemaTableMap[columnName] = columnOptions; 
            }
            print("\nSCHEMA createTable OK: Column ${columnName} added to table ${tableName}");
          } else {
            print("\nSCHEMA createTable Cancle: Column ${columnName} already exists in table ${tableName}, column not added");
          }
        }
        schemaTableMap["created_at"] = "TIMESTAMP";
        schemaTableMap["updated_at"] = {"type":"TIMESTAMP"};
        sqlList.add("${DBHelper.dateTimeColumnString(DBCore.adapter)});");
        //sqlQuery += ", ${DBHelper.dateTimeColumnString(DBCore.adapter)});";
        sqlQuery = sqlList.join(",");
        if(DBCore.adapter == DBCore.PGSQL){
          sqlQuery += DBHelper.pgTriggerForUpdatedAt(tableName);
        }
        
        print("\n+++++sqlQuery: $sqlQuery");
        DBHelper.createDBTable(sqlQuery, conn,i,tableNames.length);
      } else {
        print("\nSCHEMA createTable Cancle: Table ${tableName} already exists in schema, table and columns not added");
        createColumn(conn);
      }
    }
  } else {
//print("\nNothing to add since 'createTable' is not specified in json");
    createColumn(conn);
  }

}

void createColumn(conn) {
  if (DBCore.parsedMap["createColumn"] != null) {
    Map ct = DBCore.parsedMap["createColumn"];
    List tableNames = ct.keys.toList();
    for (int i = 0;i < tableNames.length;i++) {
      String tableName = tableNames[i];
      if (schema[tableName] != null) {
        String sqlQuery = "ALTER TABLE ${tableName} ";
        List sqlList = [];
        
        Map columns = ct["${tableName}"];
        List columnNames = columns.keys.toList();
        Map schemaTableMap = schema[tableName];
        for (int j = 0;j < columnNames.length;j++) {
          String columnName = columnNames[j];
          
          if (schema[tableName][columnName] == null) {
            print(columns[columnName].runtimeType);
            if (columns[columnName].runtimeType == String){
              String columnType = columns[columnName];
              sqlList.add("ADD COLUMN ${columnName} ${DBCore.typeMapping(columnType)} ");
              schemaTableMap[columnName] = columnType;
            }else if(columns[columnName].runtimeType.toString() == "_LinkedHashMap"){
              Map columnOptions = columns[columnName];
              String columnType = columnOptions["type"];
              sqlList.add("ADD COLUMN ${columnName} ${DBCore.typeMapping(columnType)} ${notNull(columnOptions["notNull"])} ${defaultValue(columnOptions["default"])} ");
              schemaTableMap[columnName] = columnOptions; 
            }
            print("\nSCHEMA createColumn OK: Column ${columnName} added to table ${tableName}");
          } else {

            print("\nSCHEMA createColumn Cancle: Column ${columnName} already exists in ${tableName}, columns not added");
          }
        }
        sqlQuery += sqlList.join(",");
        print("\n+++++sqlQuery: $sqlQuery");
        DBHelper.createDBColumn(sqlQuery, conn,i,tableNames.length);
      } else {
        print("\nSCHEMA createColumn FAIL: Table ${tableName} doesnt exists, columns not added");
        removeColumn(conn);
      }
    }
  } else {
//print("\nNothing to add since 'createColumn' is not specified in json");
    removeColumn(conn);
  }
}

void removeColumn(conn) {
  if (DBCore.parsedMap["removeColumn"] != null) {
    Map ct = DBCore.parsedMap["removeColumn"];
    List tableNames = ct.keys.toList();
    for (int i = 0;i < tableNames.length;i++) {
      String tableName = tableNames[i];
      if (schema[tableName] != null) {
        String sqlQuery = "ALTER TABLE ${tableName} ";
        List columnNames = ct["${tableName}"];
        int j;
        for ( j = 0;j < columnNames.length;j++) {
          if (schema[tableName][columnNames[j]] != null) {
            sqlQuery += "DROP COLUMN ${columnNames[j]} ";
            if (j < columnNames.length - 1) {
              sqlQuery += ", ";
            }
            schema[tableName].remove(columnNames[j]);
            print("\nSCHEMA removeColumn OK: Column ${columnNames[j]} removed from table ${tableName}");
          } else {
            print("\nSCHEMA removeColumn FAIL: Column ${columnNames[j]} doesnt exist, column not removed from table ${tableName}");
          }
        }
//print("\nsqlQuery: $sqlQuery");
        DBHelper.removeDBColumn(sqlQuery, conn,j,columnNames.length);
      } else {
        print("\nSCHEMA removeColumn FAIL: Table ${tableName} doesnt exists, columns not removed");
        createRelation(conn);
      }
    }
  } else {
//print("\nNothing to remove since 'removeColumn' is not specified in json");
    createRelation(conn);
  }
}


void createRelation(conn) {
  if (DBCore.parsedMap["createRelation"] != null) {
    
    List relations = DBCore.parsedMap["createRelation"];
    Map dependencies;
    List masterList = [];
    List slaveList = [];
    List tableNames;
    if(schema["dependencyRelations"] != null){
      dependencies = schema["dependencyRelations"];
      if(dependencies["masterList"] == null){
        masterList=[];
      }else{
        masterList = dependencies["masterList"];  
      }
      if(dependencies["slaveList"] == null){
        slaveList=[];
      }else{
        slaveList = dependencies["slaveList"];
      }
    }else{
      dependencies = {};
      schema["dependencyRelations"] = dependencies;
      masterList = [];
      slaveList = [];
    }
    for (int i = 0;i < relations.length;i++) {
      if (relations[i].runtimeType.toString() == "List"){
        tableNames = [relations[i][0].toLowerCase(),relations[i][1].toLowerCase()];
      }else if(relations[i].runtimeType.toString() == "_LinkedHashMap"){
        String master = relations[i]["master"];
        String slave = relations[i]["slave"];
        tableNames=[master,slave];
        List list;
        if(dependencies[master] != null){
          list = dependencies[master];
        }else{
          list = [];
        }
        if(list.contains(slave)){
          
        }else{
          list.add(slave); 
        }
        if(masterList.contains(master)){
          
        }else{
          masterList.add(master); 
        }
        if(slaveList.contains(slave)){
          
        }else{
          slaveList.add(slave); 
        }
        dependencies[master] = list;
        dependencies["masterList"] = masterList;
        dependencies["slaveList"] = slaveList;
        
        schema["dependencyRelations"] = dependencies;
        
      }

      tableNames.sort();
      String relationTable = "${tableNames[0]}_2_${tableNames[1]}";
      
      String intType = DBCore.typeMapping("INT");
      
      if (schema[relationTable] == null) {
        List columns = ["${tableNames[0]}_id","${tableNames[1]}_id"];
        
        String sqlQuery = "CREATE TABLE IF NOT EXISTS $relationTable ( ${columns[0]} $intType NOT NULL, ${columns[1]} $intType NOT NULL) ;";
        
        
        schema[relationTable] = {};
        Map schemaTableMap = schema[relationTable];
        schemaTableMap["id"] = {"type":"INT"};
        for (int j = 0;j < columns.length;j++) {
          String columnName = columns[j];
          if (schemaTableMap[columnName] == null) {
            schemaTableMap[columnName] = {"null":"true","type":"INT"}; 
            print("\nSCHEMA createRelation OK: Column ${columnName} added to table ${relationTable}");
          } else {
            print("\nSCHEMA createRelation Cancle: Column ${columnName} already exists in table ${relationTable}, column not added");
          }
        }
        print("\n+++++sqlQuery: $sqlQuery");
        DBHelper.createDBRelation(sqlQuery, conn,i,relations.length);
      } else {
        print("\nSCHEMA createRelation Cancle: Table ${relationTable} already exists in schema, relations not added");
        removeRelation(conn);
      }
      print("\nSCHEMA createRelation Finish: Table $relationTable");
    }
  } else {
//print("\nNothing to relate since 'createRelation' is not specified in json");
    removeRelation(conn);
  }
}
void removeRelation(conn) {
  if (DBCore.parsedMap["removeRelation"] != null) {
    List relations = DBCore.parsedMap["removeRelation"];
    for (int i = 0;i < relations.length;i++) {
      List tableNames = [relations[i][0].toLowerCase(),relations[i][1].toLowerCase()];
      tableNames.sort();
      String relationTable = "${tableNames[0]}_2_${tableNames[1]}";
      if (schema[relationTable] != null) {
        schema.remove(relationTable);
        print(schema);
        String sqlQuery = "DROP TABLE IF EXISTS ${relationTable} ";
        DBHelper.removeDBRelation(sqlQuery, conn,i,relations.length);
      } else {
        print("\nSCHEMA removeRelation FAIL: Table ${relationTable} doesnt exists, relation not removed");
        removeTable(conn);
      }
    }
  } else {
    //print("\nNothing to remove since 'removeRelation' is not specified in json");
    removeTable(conn);
  }
}

void removeTable(conn) {
  if (DBCore.parsedMap["removeTable"] != null) {
    List tableNames = DBCore.parsedMap["removeTable"];
    for (int i = 0;i < tableNames.length;i++) {
      String tableName = tableNames[i];
      if (schema[tableName] != null) {
        schema.remove(tableName);
        print(schema);
        String sqlQuery = "DROP TABLE IF EXISTS ${tableName} ";
        DBHelper.removeDBTable(sqlQuery, conn);

      } else {
        print("\nSCHEMA removeTable FAIL: Table ${tableName} doesnt exists, tables not removed");
      }
    }
  } else {
    //print("\nNothing to remove since 'removeTable' is not specified in json");
  }
  Future query;
  if (DBCore.adapter == DBCore.PGSQL) {
    query = conn.query("SELECT 1").toList();

  } else if (DBCore.adapter == DBCore.MySQL) {
    query = conn.query("SELECT 1");
  }
  query.then((result) {

    print("\n-----------------------End migration-----------------------");
    var filePath = files[fileId].path;
    String schemaVersion = filePath.split("migrations")[1].replaceAll("\\","");
    DBCore.mapToJsonFilePath({"schemaVersion":schemaVersion},'${DBCore.rootPath}/db/schemaVersion.json');
    if (direction == "UP") {
      fileId++;
      if (fileId < files.length) {
        if(fileId <= lastMigrationNumber){
          doFile(conn);
        }else{
          print("goal migration reached");
          //exit(0);
        }
        
      }else{
        print("goal migration reached");
        //exit(0);
      }
      
    } else if (direction == "DOWN") {
      fileId--;
      if (fileId >= 0) {
        if(fileId >= lastMigrationNumber){
            doFile(conn);
        }else{
          var filePath = files[fileId].path;
          schemaVersion = filePath.split("migrations")[1].replaceAll("\\","");
          DBCore.mapToJsonFilePath({"schemaVersion":schemaVersion},'${DBCore.rootPath}/db/schemaVersion.json');
          print("goal migration reached");
          //exit(0);
        }
      }else{
        DBCore.mapToJsonFilePath({"schemaVersion":""},'${DBCore.rootPath}/db/schemaVersion.json');
        print("goal migration reached");
        //exit(0);
      }
    }

  });
}