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
  projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
  projectMapping[projectName]=path;
  DBCore.mapToJsonFilePath(projectMapping, "projectsMapping.json");
  Map config={
    "adapter": "PGSQL",
    "database": "DBName",
    "username": "DBUsername",
    "password": "DBPassword",
    "host": "localhost",
    "port": "5432",
    "schemaVersion":"0"
  };
  var directory = new Directory("${path}/db/migrations");
  
  directory.create(recursive: true).then((_){
    print("created directory ${directory.path}");
    
    print("creating $path/db/config.json");
    DBCore.mapToJsonFilePath(config, "$path/db/config.json");
    
    print("creating $path/db/schema.json");
    DBCore.mapToJsonFilePath({}, "$path/db/schema.json");

    print("creating $path/db/schemaVersion.json");
    Map schemaVersion = {"schemaVersion":""};
    DBCore.mapToJsonFilePath(schemaVersion, "$path/db/schemaVersion.json");
  });
  
  }

/**Connects to a PG/MY-SQL Database (dependend on the db/config.json file).
* 
* Executes the migration steps specified in the "migrationDirection" keyword inside the db/migrations/ files.
* in ascending order which have not been migrated to the database. 
**/

void run(String migrationDirection) {
  
  direction = migrationDirection;
  schema = DBCore.loadSchemaToMap();
  DBCore.loadConfigFile();
  if (DBCore.adapter == DBCore.PGSQL) {
    uri = 'postgres://$DBCore.username:$DBCore.password@$DBCore.host:$DBCore.port/$DBCore.database';

    Pool pool = new Pool(uri, min: 1, max: 1);
    pool.start().then((_) {
      print('Min connections established.');
      pool.connect().then((conn) {
        migrate(conn).whenComplete(() {
          conn.close();
      });
      });
    });

  } else if (DBCore.adapter == DBCore.MySQL) {
    ConnectionPool pool = new ConnectionPool(host: DBCore.host, port: DBCore.port, user: DBCore.username, password: DBCore.password, db: DBCore.database, max: 5);
    migrate(pool);
  }
}
//TODO move to helper



Future migrate(conn) {
  DBCore.parsedMapping = DBCore.jsonFilePathToMap('../tool/typeMapper${DBCore.adapter}.json');

  var directory = new Directory("${DBCore.rootPath}/db/migrations");
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
      if (direction == "UP") {
        if (lastMigrationNumber >= fileId) {
          doFile(conn);
        }else{
          print("goal migration smaller than current migration");
        }
      }else if (direction == "DOWN") {
        if (lastMigrationNumber <= fileId) {
          doFile(conn);
        }else{
          print("goal migration higher than current migration");
        }
      }
      
  } else {
    print("\nno migration files in folder ${directory.path}");
    exit(0);
  }


}

void doFile(conn) {
  print("\n----------Start migration for file ${files[fileId].path}-------------");
  DBCore.parsedMap = DBCore.jsonFilePathToMap(files[fileId].path)["$direction"];
  if (DBCore.parsedMap != null) {
    createTable(conn);
  } else {
    print("migration direction '$direction' not specified in file ${files[fileId].path}");
    exit(0);
  }
//load with next file after this has finished

}

void createTable(conn) {
  if (DBCore.parsedMap["createTable"] != null) {
    Map ct = DBCore.parsedMap["createTable"];
    List tableNames = ct.keys.toList();
    for (var i = 0;i < tableNames.length;i++) {
      if (schema[tableNames[i]] == null) {
        String sqlQuery = "CREATE TABLE IF NOT EXISTS ${tableNames[i]} ( ${DBCore.primaryIDColumnString(DBCore.adapter)}";
        Map columns = ct[tableNames[i]];
        List columnNames = columns.keys.toList();
        schema[tableNames[i]] = {};
        Map schemaTableMap = schema[tableNames[i]];
        schemaTableMap["id"] = "INT";
        for (int j = 0;j < columnNames.length;j++) {
          if (schemaTableMap[columnNames[j]] == null) {

            String columnType = columns[columnNames[j]];
            sqlQuery += "${columnNames[j]} ${DBCore.typeMapping(columnType)} ";
            if (j < columnNames.length - 1) {
              sqlQuery += ", ";
            }
            schemaTableMap[columnNames[j]] = columnType;
            print("\nSCHEMA createTable OK: Column ${columnNames[j]} added to table ${tableNames[i]}");
          } else {
            print("\nSCHEMA createTable Cancle: Column ${columnNames[j]} already exists in table ${tableNames[i]}, column not added");
          }
        }
        sqlQuery += ")";
//   print("\nsqlQuery: $sqlQuery");
        DBHelper.createDBTable(sqlQuery, conn,i,tableNames.length);
      } else {
        print("\nSCHEMA createTable Cancle: Table ${tableNames[i]} already exists in schema, table and columns not added");
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
    for (var i = 0;i < tableNames.length;i++) {
      if (schema[tableNames[i]] != null) {
        String sqlQuery = "ALTER TABLE ${tableNames[i]} ";
        Map columns = ct["${tableNames[i]}"];
        List columnNames = columns.keys.toList();
        Map schemaTableMap = schema[tableNames[i]];
        for (var j = 0;j < columnNames.length;j++) {
          String columnType = columns[columnNames[j]];
          if (schema[tableNames[i]][columnNames[j]] == null) {
            sqlQuery += "ADD COLUMN ${columnNames[j]} ${DBCore.typeMapping(columnType)} ";
            if (j < columnNames.length - 1) {
              sqlQuery += ", ";
            }
            schema[tableNames[i]][columnNames[j]] = columnType;
            schemaTableMap[columnNames[j]] = columnType;
            print("\nSCHEMA createColumn OK: Column ${columnNames[j]} added to table ${tableNames[i]}");
          } else {

            print("\nSCHEMA createColumn Cancle: Column ${columnNames[j]} already exists in ${tableNames[i]}, columns not added");
          }
        }
//     print("\nsqlQuery: $sqlQuery");
        DBHelper.createDBColumn(sqlQuery, conn,i,tableNames.length);
      } else {
        print("\nSCHEMA createColumn FAIL: Table ${tableNames[i]} doesnt exists, columns not added");
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
    for (var i = 0;i < tableNames.length;i++) {
      if (schema[tableNames[i]] != null) {
        String sqlQuery = "ALTER TABLE ${tableNames[i]} ";
        List columnNames = ct["${tableNames[i]}"];
        int j;
        for ( j = 0;j < columnNames.length;j++) {
          if (schema[tableNames[i]][columnNames[j]] != null) {
            sqlQuery += "DROP COLUMN ${columnNames[j]} ";
            if (j < columnNames.length - 1) {
              sqlQuery += ", ";
            }
            schema[tableNames[i]].remove(columnNames[j]);
            print("\nSCHEMA removeColumn OK: Column ${columnNames[j]} removed from table ${tableNames[i]}");
          } else {
            print("\nSCHEMA removeColumn FAIL: Column ${columnNames[j]} doesnt exist, column not removed from table ${tableNames[i]}");
          }
        }
//print("\nsqlQuery: $sqlQuery");
        DBHelper.removeDBColumn(sqlQuery, conn,j,columnNames.length);
      } else {
        print("\nSCHEMA removeColumn FAIL: Table ${tableNames[i]} doesnt exists, columns not removed");
        removeTable(conn);
      }
    }
  } else {
//print("\nNothing to remove since 'removeColumn' is not specified in json");
    removeTable(conn);
  }
}

void removeTable(conn) {
  if (DBCore.parsedMap["removeTable"] != null) {
    List tableNames = DBCore.parsedMap["removeTable"];
    for (var i = 0;i < tableNames.length;i++) {
      if (schema[tableNames[i]] != null) {
        schema.remove(tableNames[i]);
        String sqlQuery = "DROP TABLE IF EXISTS ${tableNames[i]} ";
//   print("\nsqlQuery: $sqlQuery");
        DBHelper.removeDBTable(sqlQuery, conn);

      } else {
        print("\nSCHEMA removeTable FAIL: Table ${tableNames[i]} doesnt exists, tables not removed");
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
    var schemaVersion = filePath.split("migrations")[1].replaceAll("\\","");
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