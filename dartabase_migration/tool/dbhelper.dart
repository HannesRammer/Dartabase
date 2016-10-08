part of dartabaseMigration;
//TODO think about making dartabase_core lib that gets imported by dartabase tools
class DBHelper {


    static Future createDBTable(sql, conn, x, count, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("createDBTable", await conn.query(sql).toList(), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            await afterQuery("createDBTable", await conn.query(sql), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("createDBTable", await conn.execute(sql), sql, fileId, conn, x, count);
        }
    }

    static Future createDBColumn(sql, conn, x, count, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("createDBColumn", await conn.query(sql).toList(), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            await afterQuery("createDBColumn", await conn.query(sql), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("createDBColumn", await conn.execute(sql), sql, fileId, conn, x, count);
        }
    }

    static Future removeDBColumn(sql, conn, x, count, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("removeDBColumn", await conn.query(sql).toList(), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            await afterQuery("removeDBColumn", await conn.query(sql), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("removeDBColumn", await conn.execute(sql), sql, fileId, conn, x, count);
        }
    }

    static Future createDBRelation(sql, conn, x, count, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("createDBRelation", await conn.query(sql).toList(), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            await afterQuery("createDBRelation", await conn.query(sql), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("createDBRelation", await conn.execute(sql), sql, fileId, conn, x, count);
        }
    }

    static Future removeDBRelation(sql, conn, x, count, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("removeDBRelation", await conn.query(sql).toList(), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            await afterQuery("removeDBRelation", await conn.query(sql), sql, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("removeDBRelation", await conn.execute(sql), sql, fileId, conn, x, count);
        }
    }

    static Future removeDBTable(sql, conn, fileId) async {
        if (DBCore.adapter == DBCore.PGSQL) {
            await afterQuery("removeDBTable", await conn.query(sql).toList(), sql, fileId, conn);
        } else if (DBCore.adapter == DBCore.MySQL) {
            //TODO check why dont use afterQuery
            await conn.query(sql);
            printQueryCompleted("removeDBTable", "table Removed", sql);
        } else if (DBCore.adapter == DBCore.SQLite) {
            await afterQuery("removeDBTable", await conn.execute(sql), sql, fileId, conn);
        }
    }

    static Future afterQuery(String actionType, result, String sql, fileId, [conn, x, count]) async {
        printQueryCompleted(actionType, result, sql);
        if (actionType == "createDBTable") {
            if (x == count - 1) {
                await createColumn(conn, fileId);
            }
        }
        if (actionType == "createDBColumn") {
            if (x == count - 1) {
                await removeColumn(conn, fileId);
            }
        }
        if (actionType == "removeDBColumn") {
            if (x == count) {
                await createRelation(conn, fileId);
            }
        }
        if (actionType == "createDBRelation") {
            if (x == count - 1) {
                await removeRelation(conn, fileId);
            }
        }
        if (actionType == "removeDBRelation") {
            if (x == count - 1) {
                await removeTable(conn, fileId);
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
            sql =
            "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore
                    .typeMapping(
                    "TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL";
        } else if (adapter == DBCore.PGSQL) {
            sql = "created_at ${DBCore.typeMapping(
                    "TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at ${DBCore
                    .typeMapping(
                    "TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL ";
        } else if (adapter == DBCore.SQLite) {
            sql =
            "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore
                    .typeMapping(
                    "TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP";
            //    sql = "created_at ${DBCore.typeMapping("DATETIME")}, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL";
        }
        return sql;
    }

    static String pgTriggerForUpdatedAt(String tableName) {
        String sql = "";
        //sql += "CREATE OR REPLACE FUNCTION create_timestamp() RETURNS TRIGGER LANGUAGE plpgsql AS \$\$ BEGIN NEW.created_at = CURRENT_TIMESTAMP; RETURN NEW; END; \$\$; ";
        //sql += "CREATE TRIGGER create_trigger BEFORE INSERT ON $tableName FOR EACH ROW EXECUTE PROCEDURE create_timestamp();";
        sql +=
        "CREATE OR REPLACE FUNCTION update_timestamp() RETURNS TRIGGER LANGUAGE plpgsql AS \$\$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; \$\$; ";
        sql +=
        "CREATE TRIGGER update_trigger BEFORE UPDATE ON $tableName FOR EACH ROW EXECUTE PROCEDURE update_timestamp();";
        return sql;
    }

    static Future<String> removeColumnHelper(conn, tableName, columnNames, fileId) async {
        String sqlQuery = "";
        int i;

        if (DBCore.adapter == DBCore.SQLite) {
            String existingSqlStatement = await conn
                    .query("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '${tableName}';");
            List existingColumnNames = schema[tableName].keys;
            List existingSqlStatementColumns = existingSqlStatement.toLowerCase().split("(")[1].split(")")[0]
                    .split(",");
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
        await DBHelper.removeDBColumn(sqlQuery, conn, i, columnNames.length, fileId);
        return "";
    }

}


