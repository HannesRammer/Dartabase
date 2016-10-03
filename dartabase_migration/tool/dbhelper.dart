part of dartabaseMigration;
//TODO think about making dartabase_core lib that gets imported by dartabase tools
class DBHelper {


    static void createDBTable(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery(
                    "createDBTable",
                    conn.query(sql).toList(),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery(
                    "createDBTable",
                    conn.query(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery(
                    "createDBTable",
                    conn.execute(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        }
    }

    static void createDBColumn(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery(
                    "createDBColumn",
                    conn.query(sql).toList(),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery(
                    "createDBColumn",
                    conn.query(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery(
                    "createDBColumn",
                    conn.execute(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        }
    }

    static void removeDBColumn(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery(
                    "removeDBColumn",
                    conn.query(sql).toList(),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery(
                    "removeDBColumn",
                    conn.query(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery(
                    "removeDBColumn",
                    conn.execute(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        }
    }

    static void createDBRelation(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery(
                    "createDBRelation",
                    conn.query(sql).toList(),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery(
                    "createDBRelation",
                    conn.query(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery(
                    "createDBRelation",
                    conn.execute(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        }
    }

    static void removeDBRelation(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery(
                    "removeDBRelation",
                    conn.query(sql).toList(),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery(
                    "removeDBRelation",
                    conn.query(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery(
                    "removeDBRelation",
                    conn.execute(sql),
                    sql,
                    exitAfter,
                    fileId,
                    conn,
                    x,
                    count);
        }
    }

    static void removeDBTable(sql, conn, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("removeDBTable", conn.query(sql).toList(), sql, exitAfter, fileId, conn);
        } else if (DBCore.adapter == DBCore.MySQL) {
            //TODO check why dont use afterQuery
            conn.query(sql);
            printQueryCompleted("removeDBTable", "table Removed", sql);
        } else if (DBCore.adapter == DBCore.SQLite) {
            afterQuery("removeDBTable", conn.execute(sql), sql, exitAfter, fileId, conn);
        }
    }

    static afterQuery(String actionType, response, String sql, bool exitAfter, fileId, [conn, x, count]) async {
        var result = await response;
        printQueryCompleted(actionType, result, sql);
        if (actionType == "createDBTable") {
            if (x == count - 1) {
                createColumn(conn, exitAfter, fileId);
            }
        }
        if (actionType == "createDBColumn") {
            if (x == count - 1) {
                removeColumn(conn, exitAfter, fileId);
            }
        }
        if (actionType == "removeDBColumn") {
            if (x == count) {
                createRelation(conn, exitAfter, fileId);
            }
        }
        if (actionType == "createDBRelation") {
            if (x == count - 1) {
                removeRelation(conn, exitAfter, fileId);
            }
        }
        if (actionType == "removeDBRelation") {
            if (x == count - 1) {
                removeTable(conn, exitAfter, fileId);
            }
        }
    }

    static void printQueryCompleted(String type, result, String sql) {
        print("\ncompleted SQL Query: $sql");
        print("DB returned: $result");
        DBCore.mapToJsonFilePath(schema, '${DBCore.rootPath}/db/schema.json');
        print("Schema: $schema");
        print("${type} Finish");
    }

    static String primaryIDColumnString(String adapter) {
        String sql;
        if (adapter == DBCore.MySQL) {
            sql = "id ${DBCore.typeMapping("INT")} NOT NULL PRIMARY KEY";
        } else if (adapter == DBCore.PGSQL) {
            sql = "id ${DBCore.typeMapping("INT")} PRIMARY KEY";
        } else if (adapter == DBCore.SQLite) {
            sql = "id ${DBCore.typeMapping("INT")} NOT NULL PRIMARY KEY";
        }
        return sql;
    }

    static String dateTimeColumnString(String adapter) {
        String sql;
        if (adapter == DBCore.MySQL) {
            sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL";
        } else if (adapter == DBCore.PGSQL) {
            sql = "created_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL ";
        } else if (adapter == DBCore.SQLite) {
            sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL";
        }
        return sql;
    }

    static String pgTriggerForUpdatedAt(String tableName) {
        String sql = "";
        //sql += "CREATE OR REPLACE FUNCTION create_timestamp() RETURNS TRIGGER LANGUAGE plpgsql AS \$\$ BEGIN NEW.created_at = CURRENT_TIMESTAMP; RETURN NEW; END; \$\$; ";
        //sql += "CREATE TRIGGER create_trigger BEFORE INSERT ON $tableName FOR EACH ROW EXECUTE PROCEDURE create_timestamp();";
        sql += "CREATE OR REPLACE FUNCTION update_timestamp() RETURNS TRIGGER LANGUAGE plpgsql AS \$\$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; \$\$; ";
        sql += "CREATE TRIGGER update_trigger BEFORE UPDATE ON $tableName FOR EACH ROW EXECUTE PROCEDURE update_timestamp();";
        return sql;
    }

    static Future<String> removeColumnHelper(conn, tableName, columnNames, exitAfter, fileId) async {
        String sqlQuery = "";
        int i;

        if (DBCore.adapter == DBCore.SQLite) {
            String existingSqlStatement = await conn.query("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '${tableName}';");
            List existingColumnNames = schema[tableName].keys;
            List existingSqlStatementColumns = existingSqlStatement.toLowerCase().split("(")[1].split(")")[0].split(",");
            for (i = 0; i < columnNames.length; i++) {
                var columnName = columnNames[i];
                for (var j = 0; j < existingSqlStatementColumns.length; j++) {
                    if (existingSqlStatementColumns[j].split(" ")[0].contains(columnNames)) {
                        existingSqlStatementColumns.removeAt(j);
                    }
                }
                schema[tableName].remove(columnName);
            }
            String updatedSqlColumnStatement = existingSqlStatementColumns.join(",");

            sqlQuery = '''BEGIN TRANSACTION;
CREATE TEMPORARY TABLE ${tableName}_backup(${updatedSqlColumnStatement});
INSERT INTO ${tableName}_backup SELECT a,b FROM ${tableName};
DROP TABLE ${tableName};
CREATE TABLE ${tableName}(${updatedSqlColumnStatement});
INSERT INTO ${tableName} SELECT a,b FROM ${tableName}_backup;
DROP TABLE ${tableName}_backup;
COMMIT;
                    ''';
        } else {
            sqlQuery = "ALTER TABLE ${tableName} ";


            for (i = 0; i < columnNames.length; i++) {
                String columnName = columnNames[i];
                if (schema[tableName][columnName] != null) {
                    sqlQuery += "DROP COLUMN ${columnName} ";
                    if (i < columnNames.length - 1) {
                        sqlQuery += ", ";
                    }
                    schema[tableName].remove(columnName);
                    print("\nSCHEMA removeColumn OK: Column ${columnName} removed from table ${tableName}");
                } else {
                    print("\nSCHEMA removeColumn FAIL: Column ${columnName} doesnt exist, column not removed from table ${tableName}");
                }
            }
        }
        DBHelper.removeDBColumn(sqlQuery, conn, i, columnNames.length, exitAfter, fileId);
    }

}