library dartabaseMigration;

import "dart:convert";
import "dart:io";
import "dart:async";


import 'package:dartabase_core/dartabase_core.dart';
import 'package:dev_string_converter/dev_string_converter.dart' as DSC;
import 'package:postgresql/pool.dart';
import 'package:postgresql/postgresql.dart';

import 'package:sqljocky/sqljocky.dart';

part '../tool/dbhelper.dart';

part '../tool/migrationGenerator.dart';

part '../tool/modelGenerator.dart';

part '../tool/viewGenerator.dart';

part '../tool/serverGenerator.dart';

String uri;

Map schema;

List files;

int fileId = null;

String direction;

Map projectMapping;
int lastMigrationNumber;

Future initiateDartabase(path, projectName, bool exitAfter) async {
    String mappingsPath = "bin/projectsMapping.json";
    print("add project mapping ${projectName}:${path}");
    File file = new File(mappingsPath);
    if (file.existsSync()) {
        projectMapping = DBCore.jsonFilePathToMap(mappingsPath);
    } else {
        DBCore.mapToJsonFilePath({}, mappingsPath);
        projectMapping = DBCore.jsonFilePathToMap(mappingsPath);
    }
    projectMapping[projectName] = path;
    DBCore.mapToJsonFilePath(projectMapping, mappingsPath);
    Map config = {
        "adapter": "PGSQL",
        "database": "DBName",
        "username": "DBUsername",
        "password": "DBPassword",
        "host": "localhost",
        "port": "5432",
        "schemaVersion": "0",
        "ssl": "false"
    };
    Directory directory = new Directory("${path}/db/migrations");

    await directory.create(recursive: true);
    print("created directory ${directory.path}");

    print("creating $path/db/config.json");
    DBCore.mapToJsonFilePath(config, "$path/db/config.json");

    print("creating $path/db/schema.json");
    DBCore.mapToJsonFilePath({
    }, "$path/db/schema.json");

    print("creating $path/db/schemaVersion.json");
    Map schemaVersion = {
        "schemaVersion": ""
    };

    DBCore.mapToJsonFilePath(schemaVersion, "$path/db/schemaVersion.json");
    doExit(exitAfter);
}

/**Connects to a PG/MY-SQL Database (dependent on the db/config.json file).
 *
 * Executes the migration steps specified in the "migrationDirection" keyword inside the db/migrations/ files.
 * in ascending order which have not been migrated to the database.
 **/
/**Future<bool> run_new(String migrationDirection) async{
        direction = migrationDirection;
        schema = DBCore.loadSchemaToMap(DBCore.rootPath);
        //   var conn = await connectDB(DBCore.rootPath);
        migrate(conn);
        return true;
        }**/
Future connectDB(rootPath) async {
    try {
        DBCore.loadConfigFile(rootPath);
        var conn;
        if (DBCore.adapter == DBCore.PGSQL) {
            uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
            if (DBCore.ssl) {
                uri += "?sslmode=require";
            }
            Pool pool = new Pool(uri, minConnections: 1, maxConnections: 5);
            pool.messages.listen(print);
            await pool.start();
            print('Min connections established.');
            conn = await pool.connect();
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool;
            if (DBCore.ssl) {
                pool = new ConnectionPool(host: DBCore.host,
                        port: DBCore.port,
                        user: DBCore.username,
                        password: DBCore.password,
                        db: DBCore.database,
                        max: 5,
                        useSSL: true);
            } else {
                pool = new ConnectionPool(host: DBCore.host,
                        port: DBCore.port,
                        user: DBCore.username,
                        password: DBCore.password,
                        db: DBCore.database,
                        max: 5);
            }
            conn = pool;
        }
        return conn;
    } catch (e) {

    }
}

Future run(String migrationDirection, bool exitAfter, fileId) async {
    var result;
    direction = migrationDirection;
    schema = DBCore.loadSchemaToMap(DBCore.rootPath);
    DBCore.loadConfigFile(DBCore.rootPath);
    if (DBCore.adapter == DBCore.PGSQL) {
        uri = 'postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}';
        if (DBCore.ssl) {
            uri += "?sslmode=require";
        }
        Pool pool = new Pool(uri, minConnections: 1, maxConnections: 1);
        await pool.start();
        print('Min connections established.');
        var conn = await pool.connect();
        await migrate(conn, exitAfter, fileId);
        result = "done";
    } else if (DBCore.adapter == DBCore.MySQL) {
        ConnectionPool pool;
        if (DBCore.ssl) {
            pool = new ConnectionPool(host: DBCore.host,
                    port: DBCore.port,
                    user: DBCore.username,
                    password: DBCore.password,
                    db: DBCore.database,
                    max: 5,
                    useSSL: true);
        } else {
            pool = new ConnectionPool(host: DBCore.host,
                    port: DBCore.port,
                    user: DBCore.username,
                    password: DBCore.password,
                    db: DBCore.database,
                    max: 5);
        }

        await migrate(pool, exitAfter, fileId);
        result = "done";
    }
    return result;
}


Future serverStatus(String rootPath) async {
    try {
        DBCore.loadConfigFile(rootPath);
        var conn = await connectDB(rootPath);
        var query;
        if (DBCore.adapter == DBCore.PGSQL) {
            query = await conn.query("SELECT 1").toList();
        } else if (DBCore.adapter == DBCore.MySQL) {
            //conn = await pool.ping();
            query = await conn.ping();
            query = await conn.query("SELECT 1");
        }

        return query;
    } catch (e) {
        print(e.toString());
        return e.toString();
    }
}
//TODO move to helper
Future migrate(conn, bool exitAfter, fileId) async {
    var result;
    DBCore.parsedMapping = DBCore.jsonFilePathToMap('bin/../tool/typeMapper${DBCore.adapter}.json');
    Directory directory = new Directory("${DBCore.rootPath}/db/migrations");
    files = directory.listSync();
    if (files.length > 0) {
        for (var file in files) {
            if (file.path.split("migrations")[1].replaceAll("\\", "") == DBCore.schemaVersion) {
                if (direction == "UP") {
                    fileId = files.indexOf(file) + 1;
                } else if (direction == "DOWN") {
                    fileId = files.indexOf(file);
                }
            }
        }
        if (fileId == null) {
            if (direction == "UP") {
                fileId = 0;
            } else if (direction == "DOWN") {
                fileId = files.length - 1;
            }
        }
        if (lastMigrationNumber >= 0 && lastMigrationNumber <= files.length) {
            //print("lastMigrationNumber$lastMigrationNumber");
            //print("fileId$fileId");
            if (direction == "UP") {
                if (lastMigrationNumber > fileId - 1) {
                    doFile(conn, exitAfter, fileId);
                } else {
                    print("goal migration smaller or equal current migration, maybe you wanted to revert migration via dbDown.dart instead");
                    doExit(exitAfter);
                }
            } else if (direction == "DOWN") {
                if (lastMigrationNumber <= fileId) {
                    doFile(conn, exitAfter, fileId);
                } else {
                    print("goal migration higher or equal current migration, maybe you wanted to migrate via dbUp.dart instead");
                    doExit(exitAfter);
                }
            }
        } else {
            print("goal migration number out of range. goal migration doesnt exist ");
            doExit(exitAfter);
        }
    } else {
        print("\nno migration files in folder ${directory.path}");
        doExit(exitAfter);
    }
}

void doExit(bool exitAfter) {
    if (exitAfter) {
        exit(0);
    }
}

Future doFile(conn, bool exitAfter, fileId) async {
    print("\n##########Start migration for fileId ${fileId}##########");
    print("\n----------Start migration for file ${files[fileId].path}-------------");
    DBCore.parsedMap = (DBCore.jsonFilePathToMap(files[fileId].path))["$direction"];
    if (DBCore.parsedMap != null) {
        await createTable(conn, exitAfter, fileId);
    } else {
        print("migration direction '$direction' not specified in file ${files[fileId].path}");
        doExit(exitAfter);
    }
//load with next file after this has finished
}

String notNull(String notNull) {
    if (notNull == "true") {
        return " NOT NULL ";
    } else {
        return "";
    }
}

String defaultValue(String dv) {
    if (dv != null && dv != "") {
        return " DEFAULT '${dv}' ";
    } else {
        return "";
    }
}

Future createTable(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["createTable"] != null) {
        Map ct = DBCore.parsedMap["createTable"];
        List tableNames = ct.keys.toList();
        for (int i = 0; i < tableNames.length; i++) {
            String tableName = tableNames[i];
            if (schema[tableName] == null) {
                String sqlQuery = "";
                List sqlList = ["CREATE TABLE IF NOT EXISTS ${tableName} ( ${DBHelper.primaryIDColumnString(DBCore.adapter)} "];
                Map columns = ct[tableName];
                List columnNames = columns.keys.toList();
                schema[tableName] = {};
                Map schemaTableMap = schema[tableName];
                schemaTableMap["id"] = {
                    "type": "INT"
                };
                for (int j = 0; j < columnNames.length; j++) {
                    String columnName = columnNames[j];
                    if (schemaTableMap[columnName] == null) {
                        if (columns[columnName].runtimeType == String) {
                            String columnType = columns[columnName];
                            sqlList.add("${columnName} ${DBCore.typeMapping(columnType)} ");
                            schemaTableMap[columnName] = columnType;
                        } else if (columns[columnName].runtimeType.toString() == "_InternalLinkedHashMap") {
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
                schemaTableMap["updated_at"] = {"type": "TIMESTAMP"};
                sqlList.add("${DBHelper.dateTimeColumnString(DBCore.adapter)});");
                //sqlQuery += ", ${DBHelper.dateTimeColumnString(DBCore.adapter)});";
                sqlQuery = sqlList.join(",");
                if (DBCore.adapter == DBCore.PGSQL) {
                    sqlQuery += DBHelper.pgTriggerForUpdatedAt(tableName);
                }
                print("\n+++++sqlQuery: $sqlQuery");
                DBHelper.createDBTable(sqlQuery, conn, i, tableNames.length, exitAfter, fileId);
            } else {
                print("\nSCHEMA createTable Cancle: Table ${tableName} already exists in schema, table and columns not added");
                await createColumn(conn, exitAfter, fileId);
            }
        }
    } else {
//print("\nNothing to add since 'createTable' is not specified in json");
        await createColumn(conn, exitAfter, fileId);
    }
}

Future createColumn(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["createColumn"] != null) {
        Map ct = DBCore.parsedMap["createColumn"];
        List tableNames = ct.keys.toList();
        for (int i = 0; i < tableNames.length; i++) {
            String tableName = tableNames[i];
            if (schema[tableName] != null) {
                String sqlQuery = "ALTER TABLE ${tableName} ";
                List sqlList = [];
                Map columns = ct["${tableName}"];
                List columnNames = columns.keys.toList();
                Map schemaTableMap = schema[tableName];
                for (int j = 0; j < columnNames.length; j++) {
                    String columnName = columnNames[j];
                    if (schema[tableName][columnName] == null) {
                        print(columns[columnName].runtimeType);
                        if (columns[columnName].runtimeType == String) {
                            String columnType = columns[columnName];
                            sqlList.add("ADD COLUMN ${columnName} ${DBCore.typeMapping(columnType)} ");
                            schemaTableMap[columnName] = columnType;
                        } else if (columns[columnName].runtimeType.toString() == "_InternalLinkedHashMap") {
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
                DBHelper.createDBColumn(sqlQuery, conn, i, tableNames.length, exitAfter, fileId);
            } else {
                print("\nSCHEMA createColumn FAIL: Table ${tableName} doesnt exists, columns not added");
                await removeColumn(conn, exitAfter, fileId);
            }
        }
    } else {
//print("\nNothing to add since 'createColumn' is not specified in json");
        await removeColumn(conn, exitAfter, fileId);
    }
}

Future removeColumn(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["removeColumn"] != null) {
        Map ct = DBCore.parsedMap["removeColumn"];
        List tableNames = ct.keys.toList();
        for (int i = 0; i < tableNames.length; i++) {
            String tableName = tableNames[i];
            if (schema[tableName] != null) {
                String sqlQuery = "ALTER TABLE ${tableName} ";
                List columnNames = ct["${tableName}"];
                int j;
                for (j = 0; j < columnNames.length; j++) {
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
//print("\n sqlQuery: $sqlQuery");
                DBHelper.removeDBColumn(sqlQuery, conn, j, columnNames.length, exitAfter, fileId);
            } else {
                print("\nSCHEMA removeColumn FAIL: Table ${tableName} doesnt exists, columns not removed");
                await createRelation(conn, exitAfter, fileId);
            }
        }
    } else {
//print("\nNothing to remove since 'removeColumn' is not specified in json");
        await createRelation(conn, exitAfter, fileId);
    }
}


Future createRelation(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["createRelation"] != null) {
        List relations = DBCore.parsedMap["createRelation"];
        Map dependencies;
        List tableNames;

        for (int i = 0; i < relations.length; i++) {
            if (relations[i].runtimeType.toString() == "List") {
                tableNames = [relations[i][0].toLowerCase(), relations[i][1].toLowerCase()];
            }
            tableNames.sort();
            String relationTable = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";
            String intType = DBCore.typeMapping("INT");
            if (schema[relationTable] == null) {
                List columns = ["${tableNames[0]}_id", "${tableNames[1]}_id"];
                String sqlQuery = "CREATE TABLE IF NOT EXISTS $relationTable ( ${columns[0]} $intType NOT NULL, ${columns[1]} $intType NOT NULL) ;";
                schema[relationTable] = {};
                Map schemaTableMap = schema[relationTable];
                schemaTableMap["id"] = {
                    "type": "INT"
                };
                for (int j = 0; j < columns.length; j++) {
                    String columnName = columns[j];
                    if (schemaTableMap[columnName] == null) {
                        schemaTableMap[columnName] = {
                            "null": "true",
                            "type": "INT"
                        };
                        print("\nSCHEMA createRelation OK: Column ${columnName} added to table ${relationTable}");
                    } else {
                        print("\nSCHEMA createRelation Cancle: Column ${columnName} already exists in table ${relationTable}, column not added");
                    }
                }
                print("\n+++++sqlQuery: $sqlQuery");
                DBHelper.createDBRelation(sqlQuery, conn, i, relations.length, exitAfter, fileId);
            } else {
                print("\nSCHEMA createRelation Cancle: Table ${relationTable} already exists in schema, relations not added");
                await removeRelation(conn, exitAfter, fileId);
            }
            print("\nSCHEMA createRelation Finish: Table $relationTable");
        }
    } else {
//print("\nNothing to relate since 'createRelation' is not specified in json");
        await removeRelation(conn, exitAfter, fileId);
    }
}

Future removeRelation(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["removeRelation"] != null) {
        List relations = DBCore.parsedMap["removeRelation"];
        for (int i = 0; i < relations.length; i++) {
            List tableNames = [relations[i][0].toLowerCase(), relations[i][1].toLowerCase()];
            tableNames.sort();
            String relationTable = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";
            if (schema[relationTable] != null) {
                schema.remove(relationTable);
                print(schema);
                String sqlQuery = "DROP TABLE IF EXISTS ${relationTable} ";
                DBHelper.removeDBRelation(sqlQuery, conn, i, relations.length, exitAfter, fileId);
            } else {
                print("\nSCHEMA removeRelation FAIL: Table ${relationTable} doesnt exists, relation not removed");
                await removeTable(conn, exitAfter, fileId);
            }
        }
    } else {
        //print("\nNothing to remove since 'removeRelation' is not specified in json");
        await removeTable(conn, exitAfter, fileId);
    }
}

Future removeTable(conn, bool exitAfter, fileId) async {
    if (DBCore.parsedMap["removeTable"] != null) {
        List tableNames = DBCore.parsedMap["removeTable"];
        for (int i = 0; i < tableNames.length; i++) {
            String tableName = tableNames[i];
            if (schema[tableName] != null) {
                schema.remove(tableName);
                print(schema);
                String sqlQuery = "DROP TABLE IF EXISTS ${tableName} ";
                DBHelper.removeDBTable(sqlQuery, conn, exitAfter, fileId);
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
    var result = await query;
    print("\n-----------------------End migration-----------------------");
    var filePath = files[fileId].path;
    String schemaVersion = filePath.split("migrations")[1].replaceAll("\\", "");
    DBCore.mapToJsonFilePath({"schemaVersion": schemaVersion},
            '${DBCore.rootPath}/db/schemaVersion.json');
    if (direction == "UP") {
        fileId++;
        if (fileId < files.length) {
            if (fileId <= lastMigrationNumber) {
                doFile(conn, exitAfter, fileId);
            } else {
                print("goal migration reached");
                doExit(exitAfter);
            }
        } else {
            print("goal migration reached");
            doExit(exitAfter);
        }
    } else if (direction == "DOWN") {
        fileId--;
        if (fileId >= 0) {
            if (fileId >= lastMigrationNumber) {
                doFile(conn, exitAfter, fileId);
            } else {
                var filePath = files[fileId].path;
                schemaVersion = filePath.split("migrations")[1].replaceAll("\\", "");
                DBCore.mapToJsonFilePath({
                    "schemaVersion": schemaVersion
                }, '${DBCore.rootPath}/db/schemaVersion.json');
                print("goal migration reached");
                doExit(exitAfter);
            }
        } else {
            DBCore.mapToJsonFilePath({
                "schemaVersion": ""
            }, '${DBCore.rootPath}/db/schemaVersion.json');
            print("goal migration reached");
            doExit(exitAfter);
        }
    }
}

Future extractExistingDatabaseTableNames(String rootPath) async {
    try {
        DBCore.loadConfigFile(rootPath);
        var conn = await connectDB(rootPath);
        var existingDatabaseTableNames = new List();
        if (DBCore.adapter == DBCore.PGSQL) {
            //query = await conn.query("SELECT 1").toList();
            String sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA='public' AND TABLE_CATALOG='${DBCore.database}';";
            print(sql);
            var results = await conn.query(sql).toList();

            await results.forEach((row) {
                print(row[0]);
                existingDatabaseTableNames.add(row[0]);
            });
        } else if (DBCore.adapter == DBCore.MySQL) {
            //conn = await pool.ping();
            String sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA='${DBCore.database}';";
            print(sql);
            var results = await conn.query(sql);

            await results.forEach((row) {
                print(row[0]);
                existingDatabaseTableNames.add(row[0]);
            });
        }

        return existingDatabaseTableNames;
    } catch (e) {
        print(e.toString());
        return e.toString();
    }
}

Future extractExistingTableDescription(String tableName, String rootPath) async {
    try {
        DBCore.loadConfigFile(rootPath);
        var conn = await connectDB(rootPath);
        Map existingDatabaseTableMap = new Map();
        if (DBCore.adapter == DBCore.PGSQL) {
            Map sqlToDartabase = DBCore.jsonFilePathToMap('bin/../tool/pGSQLToType.json');
            String sql = "SELECT column_name,data_type,is_nullable,column_default FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='${tableName}' AND TABLE_CATALOG='${DBCore.database}';";
            print(sql);
            var results = await conn.query(sql).toList();
            await results.forEach((row) {
                print(row.toString());
                String field = row[0].toString();
                String dbType = row[1].toString();
                String isNull = row[2].toString();
                String defaultValue = row[3].toString();
                if (defaultValue == "null") {
                    defaultValue = "";
                }
                if (existingDatabaseTableMap[tableName] == null) {
                    existingDatabaseTableMap[tableName] = {};
                }
                existingDatabaseTableMap[tableName][field] = {
                    "type":sqlToDartabase[dbType.split("(")[0].toLowerCase()],
                    "default":defaultValue,
                    "null":isNull
                };
            });
        } else if (DBCore.adapter == DBCore.MySQL) {
            Map sqlToDartabase = DBCore.jsonFilePathToMap('bin/../tool/mySQLToType.json');
            String sql = "DESC ${DBCore.database}.${tableName};";
            print(sql);
            var results = await conn.query(sql);
            await results.forEach((row) {
                print(row.toString());
                String field = row[0].toString();
                String dbType = row[1].toString();
                String isNull = row[2].toString();
                String priKey = row[3];
                String defaultValue = row[4].toString();
                if (defaultValue == "null") {
                    defaultValue = "";
                }
                String extra = row[5];
                if (existingDatabaseTableMap[tableName] == null) {
                    existingDatabaseTableMap[tableName] = {};
                }
                existingDatabaseTableMap[tableName][field] = {
                    "type":sqlToDartabase[dbType.split("(")[0].toUpperCase()],
                    "default":defaultValue,
                    "null":isNull
                };
            });
        }
        return existingDatabaseTableMap;
    } catch (e) {
        print(e.toString());
        return e.toString();
    }
}
