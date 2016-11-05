library dartabaseModel;

import "dart:mirrors";
import "dart:async";
import "package:dartabase_core/dartabase_core.dart";

import "package:postgresql/postgresql_pool.dart";

import "package:sqljocky2/sqljocky.dart";
import "package:sqlite/sqlite.dart"as sqlite;

var MAX = 1;

String uri;

var DBPOOL;

class Model {
    num _id;

    num get id => _id;

    static void initiate(String rootPath) {
        DBCore.rootPath = rootPath;
        DBCore.loadConfigFile(rootPath);
        print(rootPath);
        if (DBCore.adapter == DBCore.PGSQL) {
            uri = "postgres://${DBCore.username}:${DBCore.password}@${DBCore.host}:${DBCore.port}/${DBCore.database}";
            if (DBCore.ssl) {
                uri += "?sslmode=require";
            }
            DBPOOL = new Pool(uri, minConnections: 1, maxConnections: 10);
        } else if (DBCore.adapter == DBCore.MySQL) {
            if (DBCore.ssl) {
                DBPOOL = new ConnectionPool(host: DBCore.host,
                        port: DBCore.port,
                        user: DBCore.username,
                        password: DBCore.password,
                        db: DBCore.database,
                        max: 5,
                        useSSL: true);
            } else {
                DBPOOL = new ConnectionPool(host: DBCore.host,
                        port: DBCore.port,
                        user: DBCore.username,
                        password: DBCore.password,
                        db: DBCore.database,
                        max: 5);
            }
        } else if (DBCore.adapter == DBCore.SQLite) {
            var sqlitePath = DBCore.sqlitePath;
            DBPOOL = new sqlite.Database(sqlitePath);

        }
    }

    /**
     * Future save()
     *
     * once future completes
     *
     * Returns String "created" or "updated"
     * TODO chatch errors ?? needed here?
     *
     * old
     * player.save().then((process){
     *   if(process == "created" || process == "updated"){
     *     //your code
     *   }
     * });
     *
     * new
     * var process = await player.save();
     * if(process == "created" || process == "updated"){
     *   //your code
     * }
     *
     **/
    Future save() async {
        var result;

        String tableName = DBCore.toTableName("${this.runtimeType}");

        Map schema = DBCore.loadSchemaToMap(DBCore.rootPath);
        //Future<Map> usedObjectDataFuture = await getObjectSchemaAttributes(this);
        Map usedObjectData = await getObjectSchemaAttributes(this);
        InstanceMirror instanceMirror = reflect(this);

        //*loop through schema attributes and create sql
        var object = instanceMirror.reflectee;
        object.id = usedObjectData["objectId"];
        DBCore.loadConfigFile(DBCore.rootPath);
        if (DBCore.adapter == DBCore.PGSQL) {
            print(usedObjectData["insertValues"].toString());

            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            if (usedObjectData["createOrUpdate"] == "create") {
                String insertSQL = "insert into $tableName values (${usedObjectData["insertSpaceholder"].join(",")}) ";
                print(insertSQL);
                print(usedObjectData["insertValues"].toString());
                await conn.execute(insertSQL, usedObjectData["insertValues"]);
                conn.close();
                result = "created";
            } else if (usedObjectData["createOrUpdate"] == "update") {
                String updateSQL = "UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
                print(updateSQL);
                await conn.execute(updateSQL);
                conn.close();
                result = "updated";
            }
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;

            if (usedObjectData["createOrUpdate"] == "create") {
                String insertSQL = "insert into $tableName (${usedObjectData["insertColumns"].join(",")}) values (${usedObjectData["insertSpaceholder"].join(",")}) ";
                print(insertSQL);

                var query = await pool.prepare(insertSQL);
                var res = await query.execute(usedObjectData["insertValues"]);
                //savePool.close();
                result = "created";
            } else if (usedObjectData["createOrUpdate"] == "update") {
                String updateSQL = "UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
                print(updateSQL);

                var res = await pool.query(updateSQL);
                //savePool.close();
                result = "updated";
            }
        } else if (DBCore.adapter == DBCore.SQLite) {
            //TODO
            var pool = DBPOOL;

            if (usedObjectData["createOrUpdate"] == "create") {
                String insertSQL = "insert into $tableName (${usedObjectData["insertColumns"].join(",")}) values (${usedObjectData["insertValues"].join(",")}) ";
                print(insertSQL);

                var res = await pool.execute(insertSQL);
                //savePool.close();
                result = "created";
            } else if (usedObjectData["createOrUpdate"] == "update") {
                String updateSQL = "UPDATE $tableName SET ${usedObjectData["updateValues"].join(",")} WHERE ${usedObjectData["updateWhere"]}";
                print(updateSQL);

                var res = await pool.execute(updateSQL);
                //savePool.close();
                result = "updated";
        }
        }

        return result;
    }

    Future find(String sql, bool resultAsList) async {
        var result;

        //print(this.runtimeType);

        //*loop through schema attributes and fill object via reflections and mirrors
        DBCore.loadConfigFile(DBCore.rootPath);
        if (DBCore.adapter == DBCore.PGSQL) {
            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            List data = new List();
            var rows = await conn.query(sql).toList();
            for (var row in rows) {
                var object = await setObjectSchemaAttributes(this, row);
                data.add(object);
            }
            conn.close();
            if (resultAsList == true) {
                result = data;
            } else if (resultAsList == false) {
                if (data != null && data.length > 0) {
                    result = data[0];
                } else {
                    result = null;
                }
            }
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;
            List row;
            var results = await pool.query(sql);
            List data = new List();
            await results.forEach((row) async {
                var object = await setObjectSchemaAttributes(this, row);
                data.add(object);
            });
            if (resultAsList == true) {
                //pool.close();
                result = data;
            } else if (resultAsList == false) {
                if (data != null && data.length > 0) {
                    //pool.close();
                    result = data[0];
                } else {
                    //pool.close();
                    result = null;
                }
            }
        } else if (DBCore.adapter == DBCore.SQLite) {
            var pool = DBPOOL;
            List results= [];
            List data = new List();
            final subscription = pool.query(sql).listen(await (row) async {
                    results.add(row);
                    var object = await setObjectSchemaAttributes(this, row);
                    data.add(object);
            });
            await subscription.asFuture();
            if (resultAsList == true) {
                //pool.close();
                result = data;
            } else if (resultAsList == false) {
                if (data != null && data.length > 0) {
                    //pool.close();
                    result = data[0];
                } else {
                    //pool.close();
                    result = null;
        }
            }
        }

        return result;
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
     * var player = await player.findBy("name","tim");
     * if(player != null){
     *   //your code
     * }
     *
     *
     **/
    Future findBy(String column, var value) async {
        String tableName = DBCore.toTableName("${this.runtimeType}");

        String query = "SELECT * FROM $tableName WHERE $column = \"$value\" LIMIT 1";
        print(query);
        return (await find(query, false));
    }

    /**
     * Future findById(var id)
     *
     * once future completes
     *
     * returns an (player) object if one exists
     * else
     * returns null
     * var player = await player.findById("3");
     * if(player != null){
     *   //your code
     * }
     **/
    Future findById(var id) async {
        return (await findBy("id", id));
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
     * var players = await player.findAllBy("name","tim");
     * if(!players.isEmpty){
     *   //your code
     * }
     *
     **/
    Future findAllBy(String column, var value) async {
        String tableName = DBCore.toTableName("${this.runtimeType}");

        String query = "SELECT * FROM $tableName WHERE $column = \"$value\"";
        print(query);
        return (await find(query, true));
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
     * var players = await player.findAll();
     * if(!players.isEmpty){
     *   //your code
     * }
     *
     **/
    Future findAll() async {
        String tableName = DBCore.toTableName("${this.runtimeType}");

        String query = "SELECT * FROM $tableName";
        print(query);
        return (await find(query, true));
    }

    /**
     * Future delete()
     *
     * once future completes
     *
     * deletes the object //TODO and all its relations
     *
     * await player.delete();
     * //your code
     *
     **/
    Future delete() async {
        var result;
        String tableName = DBCore.toTableName("${this.runtimeType}");
        //TODO recursive master slave dependency removal via
        //this.removeDependentRelations();
        String SQL = "DELETE FROM $tableName WHERE id = ${this.id}";
        print(SQL);
        if (DBCore.adapter == DBCore.PGSQL) {
            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            result = conn.execute(SQL);
            conn.close();
            //completer.complete("deleted item with id ${this.id}");
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;
            result = await pool.query(SQL);
        } else if (DBCore.adapter == DBCore.SQLite) {
            var pool = DBPOOL;
            result = await pool.execute(SQL);
        }

        return result;
    }

//##########RELATIONS START############

    /**
     * Future receive(object)
     *
     * once future completes
     * creates relation between the two objects (player and character)
     * ...
     *
     * var result = await player.receive(character);
     * //your code
     *
     **/
    Future receive(object) async {
        var result;
        String initiatedObject = DBCore.toTableName("${this.runtimeType}");
        String relatedObject = DBCore.toTableName("${object.runtimeType}");
        List tableNames = [initiatedObject, relatedObject];
        tableNames.sort();
        String tableName = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";
        //String sql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id); ";
        //String sql ="";
        //String preSql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id); ";
        //String postSql = "WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE ${initiatedObject}_id=\"${this.id}\" AND ${relatedObject}_id=\"${object.id}\");";
        String sql = "INSERT INTO $tableName (${initiatedObject}_id, ${relatedObject}_id) VALUES (\"${this.id}\", \"${object.id}\")";

        DBCore.loadConfigFile(DBCore.rootPath);
        if (DBCore.adapter == DBCore.PGSQL) {
            print(sql);
            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            result = await conn.execute(sql);
            conn.close();
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;
            print(sql);
            result = await pool.query(sql);
            //pool.close();
        } else if (DBCore.adapter == DBCore.SQLite) {
            var pool = DBPOOL;
            print(sql);
            result = await pool.execute(sql);
        }

        return result;
    }

    Future has(object, listOrValue, [String column, String value]) async {
        Completer completer = new Completer();
        String initiatedObject = DBCore.toTableName("${this.runtimeType}");
        String relatedObject = DBCore.toTableName("${object.runtimeType}");
        List tableNames = [initiatedObject, relatedObject];
        tableNames.sort();
        String tableName = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";
        String intiatiorString = "${initiatedObject}_id = ${this.id}";
        String limit = "";
        if (listOrValue) {
            limit = " limit 1";
        }
        String sql2 = "SELECT a2p.${relatedObject}_id FROM ${tableName} a2p WHERE a2p.${intiatiorString} ";
        String query = "SELECT p.* FROM ${relatedObject} p WHERE p.id IN(${sql2}) ";
        if (column != null && value != null) {
            query += "AND p.$column = \"$value\"";
        }
        if (listOrValue) {
            query += " limit 1";
        }
        query += ";";
        //print(query);
        return (await object.find(query, listOrValue));
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
     * var character = await player.hasOne(new Character());
     * if(character != null){
     *   //your code
     * }
     *
     **/
    Future hasOne(object) async {
        return (await has(object, false));
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
     * var characters = await player.hasMany(new Character());
     * if(!characters.isEmpty){
     *   //your code
     * }
     *
     **/
    Future hasMany(object) async {
        return (await has(object, true));
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
     * old
     * player.hasOneWith(new Character(),"level","3").then((character){
     *   if(character != null){
     *     //your code
     *   }
     * });
     *
     * new
     * var character = await player.hasOneWith(new Character(),"level","3");
     * if(character != null){
     *   //your code
     * }
     *
     **/
    Future hasOneWith(object, String column, String value) async {
        return (await has(object, false, column, value));
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
     * old
     * player.hasManyWith(new Character(),"level","3").then((characters){
     *   if(!characters.isEmpty){
     *     //your code
     *   }else{
     *   }
     * });
     *
     * new
     * var characters = player.hasManyWith(new Character(),"level","3");
     * if(!characters.isEmpty){
     *   //your code
     * }
     *
     **/
    Future hasManyWith(object, String column, String value) async {
        return (await has(object, true, column, value));
    }


    /**
     * Future remove(object)
     *
     * once future completes
     * remove relation between the two objects (player and character)
     * ...
     *
     * old
     * player.remove(character).then((result){
     *   //your code
     * });
     *
     * new
     * var result = await player.remove(character);
     * //your code
     *
     **/
    Future remove(object) async {
        var result;

        String initiatedObject = DBCore.toTableName("${this.runtimeType}");
        String relatedObject = DBCore.toTableName("${object.runtimeType}");

        List tableNames = [initiatedObject, relatedObject];
        tableNames.sort();
        String tableName = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";

        String SQL = "DELETE FROM $tableName WHERE ${initiatedObject}_id = ${this.id} AND ${relatedObject}_id = ${object.id}";
        print(SQL);

        if (DBCore.adapter == DBCore.PGSQL) {
            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            result = await conn.execute(SQL);
            conn.close();
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;
            result = await pool.query(SQL);
            //pool.close();
        } else if (DBCore.adapter == DBCore.SQLite) {
            var pool = DBPOOL;
            result = await pool.execute(SQL);

        }

        return result;
    }


//################HELPERMETHODS
    InstanceMirror getMirrorOf(object) {
        InstanceMirror instanceMirror = reflect(object); // Get an instance mirror
        //print(instanceMirror.reflectee == object); // true
        //print(instanceMirror.reflectee);
        return instanceMirror;
    }

    /**
     * Future getObjectSchemaAttributes(object)
     *
     * once future completes
     *
     * returns a map used to generate sql from object
     * via schema attribute comparison
     *
     **/
    Future<Map> getObjectSchemaAttributes(object) async {
        var id = await getNewId();
        Map schema = DBCore.loadSchemaToMap(DBCore.rootPath);

        String tableName = DBCore.toTableName("${object.runtimeType}");

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
        for (var column in columnNames) {
            Symbol symbol = new Symbol(column);
            InstanceMirror field = instanceMirror.getField(symbol);
            var value = field.reflectee;
            if (column == "id" && value == null) {
                createOrUpdate = "create";
                insertColumns.add("id");
                listValues.add(id);
                objectId = id;
            } else if (column == "id" && value != null) {
                if (value >= id) {
                    createOrUpdate = "create";
                    listValues.add(id);
                    objectId = id;
                } else {
                    //TODO  check if object with id=value exists
                    //what to do when object is updated after deletion
                    createOrUpdate = "update";
                    updateWhere = "id=$value";

                    if(DBCore.adapter==DBCore.SQLite){
                        listValues.add("${value}");
                    }else{
                    listValues.add(value);
                    }
                    objectId = value;
                }
                insertColumns.add("id");
            } else if (column != "id" && value != null) {
                if (value == "" && DBCore.adapter==DBCore.SQLite) {
                    value ="''";
                }
                insertColumns.add(column);
                var dbType = DBCore.dbType(objectSchemaMap[column]);
                if (dbType == "BOOLEAN") {
                    if (value == false) {
                        value = "0";
                    } else if (value == true) {
                        value = "1";
                    }
                }
                if (column == "updated_at") {
                    DateTime dT = new DateTime.now();

                    var month = "${dT.month}".length == 1 ? "0${dT.month}" : "${dT.month}";
                    var day = "${dT.day}".length == 1 ? "0${dT.day}" : "${dT.day}";
                    var hour = "${dT.hour}".length == 1 ? "0${dT.hour}" : "${dT.hour}";
                    var minute = "${dT.minute}".length == 1 ? "0${dT.minute}" : "${dT.minute}";
                    var second = "${dT.second}".length == 1 ? "0${dT.second}" : "${dT.second}";
                    value = "${dT.year}-$month-$day $hour:$minute:$second";
                }

                listValues.add(value);
                updateValues.add("${column}=\"${value}\"");
            } else if (column != "id" && value == null) {
                insertColumns.add(column);
                if (column == "created_at" && DBCore.adapter==DBCore.SQLite) {
                    DateTime dT = new DateTime.now();

                    var month = "${dT.month}".length == 1 ? "0${dT.month}" : "${dT.month}";
                    var day = "${dT.day}".length == 1 ? "0${dT.day}" : "${dT.day}";
                    var hour = "${dT.hour}".length == 1 ? "0${dT.hour}" : "${dT.hour}";
                    var minute = "${dT.minute}".length == 1 ? "0${dT.minute}" : "${dT.minute}";
                    var second = "${dT.second}".length == 1 ? "0${dT.second}" : "${dT.second}";
                    value = "\"${dT.year}-$month-$day $hour:$minute:$second\"";
                    listValues.add(value);
                }else{
                    value = DBCore.defaultValueFor(objectSchemaMap[column]);
                    if (value == "" && DBCore.adapter==DBCore.SQLite) {
                        value = "''";
                    }
                    listValues.add(value);
                }

            }
            if (DBCore.adapter == DBCore.PGSQL) {
                insertSpaceholder.add("@${column}");
            } else if (DBCore.adapter == DBCore.MySQL) {
                insertSpaceholder.add("?");
            } else if (DBCore.adapter == DBCore.SQLite) {
                insertSpaceholder.add(value);
            }

            i += 1;
        }
        if (DBCore.adapter == DBCore.PGSQL) {
            insertValues = new Map.fromIterables(insertColumns, listValues);
        } else if (DBCore.adapter == DBCore.MySQL) {
            insertValues = listValues;
        } else if (DBCore.adapter == DBCore.SQLite) {
            insertValues = listValues;
        }

        return {
            "insertColumns":insertColumns,
            "insertSpaceholder":insertSpaceholder,
            "insertValues":insertValues,
            "updateValues":updateValues,
            "updateWhere":updateWhere,
            "createOrUpdate":createOrUpdate,
            "objectId":objectId
        };
    }

    /**
     * Future setObjectSchemaAttributes(object,row)
     *
     * once future completes
     *
     * returns an updated object from map
     * via schema attribute comparison
     *
     **/

    Future setObjectSchemaAttributes(object, row) async {
        Map schema = DBCore.loadSchemaToMap(DBCore.rootPath);
        String tableName = DBCore.toTableName("${object.runtimeType}");

        Map objectSchemaMap = schema["${tableName}"];

        Iterable columnNames = objectSchemaMap.keys;
        ClassMirror classMirror = reflectClass(object.runtimeType);
        var newInstanceObject = classMirror.newInstance(const Symbol(""), []);

        var i = 0;
        for (var column in columnNames) {
            Symbol symbol = new Symbol(column);
            var value;
            if (row[i] == "") {
                value = DBCore.defaultValueFor(objectSchemaMap[column]);
            } else {
                var dbType = DBCore.dbType(objectSchemaMap[column]);
                if (dbType == "BOOLEAN") {
                    if (row[i] == 0 || row[i] == "0") {
                        value = false;
                    } else if (row[i] == 1 || row[i] == "1") {
                        value = true;
                    } else {
                        value = row[i];
                    }
                } else {
                    value = row[i];
                }
            }
            InstanceMirror field = newInstanceObject.setField(symbol, value);
            //print("$column -> ${value}");
            i++;
        }
        return newInstanceObject.reflectee;
    }

    Future getNewId() async {
        var result;
        DBCore.loadConfigFile(DBCore.rootPath);
        if (DBCore.adapter == DBCore.PGSQL) {
            Pool pool = DBPOOL;
            await pool.start();
            print("Min connections established.");
            var conn = await pool.connect();
            List data = new List();
            String tableName = DBCore.toTableName("${this.runtimeType}");
            var rows = await conn.query("SELECT MAX(ID) FROM ${tableName}").toList();
            num value;
            if (rows[0].max == null) {
                value = 1;
            } else {
                value = rows[0].max + 1;
            }
            print("new Index ${value}");
            result = value;
        } else if (DBCore.adapter == DBCore.MySQL) {
            ConnectionPool pool = DBPOOL;
            List row;
            String tableName = DBCore.toTableName("${this.runtimeType}");

            var results = await pool.query("SELECT MAX(ID) FROM ${tableName}");
            List data = new List();
            await results.forEach((row) async {
                num value;

                if (row[0] == null) {
                    value = 1;
                } else {
                    value = row[0] + 1;
                }
                print("new Index ${value}");
                //pool.close();
                result = value;
            });
        } else if (DBCore.adapter == DBCore.SQLite) {
            var pool = DBPOOL;
            String tableName = DBCore.toTableName("${this.runtimeType}");

            var sub = await pool.query("SELECT MAX(id) from ${tableName}").listen((rows) async {
                num value;
                if (rows[0] == null) {
                    value = 1;
                } else {
                    value = rows[0] + 1;
        }
                print("new Index ${value}");
                result = value;
            });
            await sub.asFuture();
        }

        return result;
    }

    Future removeDependentRelations() async {
        var result;
        Map schema = DBCore.loadSchemaToMap(DBCore.rootPath);
        print(schema);

        //TODO 1.find relations
        String initiatedObject = DBCore.toTableName("${this.runtimeType}");

        Map m = {"a_${DBCore.getRelationDivider(DBCore.rootPath)}_m":{}, "m_${DBCore.getRelationDivider(DBCore.rootPath)}_z":{}};
        List relationNames = [];
        List objectNames = [];
        List delRelations = [];
        await m.keys.forEach((String tableName) {
            relationNames.add(tableName);
            String relatedObject;
            if (tableName.contains("${initiatedObject}_${DBCore.getRelationDivider(DBCore.rootPath)}_")) {
                relatedObject = tableName.split("${initiatedObject}_${DBCore.getRelationDivider(DBCore.rootPath)}_")[0];
                //tableNames.add(tableName);
                //objectNames.add(tableName.split("_2_"));
                //delRelations.add("DELETE t$tableName FROM $tableName as t$tableName WHERE ${initiatedObject}_id = \"${this.id}\"");
            } else if (tableName.contains("_${DBCore.getRelationDivider(DBCore.rootPath)}_${initiatedObject}")) {
                relatedObject = tableName.split("_${DBCore.getRelationDivider(DBCore.rootPath)}_${initiatedObject}")[0];
                //tableNames.add(tableName);
                //objectNames.add(tableName.split("_2_"));
                //delRelations.add("DELETE t$tableName FROM $tableName as t$tableName WHERE ${initiatedObject}_id = \"${this.id}\"");
            }
            delRelations.add("DELETE t${relatedObject} " +
                    "FROM ${relatedObject} as t${relatedObject}" +
                    "JOIN ${tableName} as t${tableName}" +
                    "ON t${relatedObject}.id = t${tableName}.${relatedObject}_id" +
                    "AND b.quizId = @quizId" +

                    "DELETE t${tableName} WHERE quizId = @quizId");
        });


        //TODO 2.get related objects

        //TODO 2.get related objects


        /**String initiatedObject = "${this.runtimeType}".toLowerCase();
         *String relatedObject = "${object.runtimeType}".toLowerCase();
         *
         *List tableNames = [initiatedObject,relatedObject];
         *tableNames.sort();
         *String tableName = "${tableNames[0]}_${DBCore.getRelationDivider(DBCore.rootPath)}_${tableNames[1]}";
         **/
        return result;
    }

    Future<Map> toJson() async {
        Map map = new Map();
        InstanceMirror im = reflect(this);
        ClassMirror cm = im.type;
        var decls = cm.declarations.values.where((dm) => dm is VariableMirror);
        await decls.forEach((dm) {
            var key = MirrorSystem.getName(dm.simpleName);
            var val = im
                    .getField(dm.simpleName)
                    .reflectee;
            if (val.runtimeType == DateTime) {
                val = val.millisecondsSinceEpoch;
            }
            print("val.runtimeType: ${val.runtimeType}");
            if (val.runtimeType == Blob) {
                map[key] = val.toString();
            } else {

                map[key] = val;
            }
        });

        return map;
    }

}