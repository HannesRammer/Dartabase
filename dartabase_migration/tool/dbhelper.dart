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
            if (x == count - 1) {
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

    static Future<String> createColumnHelper(conn, tableNames, tableName, ct, fileId, x) async {
        String sqlQuery = "";

        if (DBCore.adapter == DBCore.SQLite) {
            Map columns = ct["${tableName}"];
            List columnNames = columns.keys.toList();

            for (int j = 0; j < columnNames.length; j++) {
                sqlQuery = "ALTER TABLE ${tableName} ";
                List sqlList = [];
                Map schemaTableMap = schema[tableName];
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
                        sqlList.add("ADD COLUMN ${columnName} ${DBCore
                                .typeMapping(columnType)} ${notNull(columnOptions["notNull"])} ${defaultValue(columnOptions["default"])} ");
                        schemaTableMap[columnName] = columnOptions;
                    }
                    print("\nSCHEMA createColumn OK: Column ${columnName} added to table ${tableName}");
                } else {
                    print("\nSCHEMA createColumn Cancle: Column ${columnName} already exists in ${tableName}, columns not added");
                }
                sqlQuery += sqlList.join(",");
                sqlQuery += ";";
                print("\n+++++sqlQuery: $sqlQuery");
                await DBHelper.createDBColumn(sqlQuery, conn, x, tableNames.length, fileId);
            }
        } else {
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
                        sqlList.add("ADD COLUMN ${columnName} ${DBCore
                                .typeMapping(columnType)} ${notNull(columnOptions["notNull"])} ${defaultValue(columnOptions["default"])} ");
                        schemaTableMap[columnName] = columnOptions;
                    }
                    print("\nSCHEMA createColumn OK: Column ${columnName} added to table ${tableName}");
                } else {
                    print("\nSCHEMA createColumn Cancle: Column ${columnName} already exists in ${tableName}, columns not added");
                }
            }
            sqlQuery += sqlList.join(",");
            print("\n+++++sqlQuery: $sqlQuery");
            await DBHelper.createDBColumn(sqlQuery, conn, x, tableNames.length, fileId);
        }
        return "";
    }

    static Future<String> removeColumnHelper(conn, tableName, columnNames, fileId, x) async {
        String sqlQuery = "";
        print(DBCore.adapter);

        if (DBCore.adapter == DBCore.SQLite) {
            var existingSqlStatement;
            var count = await conn
                    .execute("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '${tableName}';", callback: (row) {
                existingSqlStatement = row[0].toLowerCase();
            });
            String split1 = "";
            if (existingSqlStatement.indexOf("${tableName} (") > -1) {
                split1 = existingSqlStatement.split("${tableName} (")[1];
            } else if (existingSqlStatement.indexOf("${tableName}(") > -1) {
                split1 = existingSqlStatement.split("${tableName}(")[1];
            }

            List existingSqlStatementColumns = split1.substring(0, split1.length - 1).split(",");
            List insertSqlStatementColumns = [];
            for (int i = 0; i < columnNames.length; i++) {
                x = i;
                var columnName = columnNames[i];
                for (var j = 0; j < existingSqlStatementColumns.length; j++) {
                    String existingSqlStatementColumn = existingSqlStatementColumns[j].trim().split(" ")[0].replaceAll("\"", "");
                    if (existingSqlStatementColumn == columnName) {
                        existingSqlStatementColumns.removeAt(j);
                    } else {
                        if (insertSqlStatementColumns.indexOf(existingSqlStatementColumn) == -1) {
                            insertSqlStatementColumns.add(existingSqlStatementColumn);
                        }
                    }
                }
                schema[tableName].remove(columnName);
            }
            String createSqlColumnStatement = existingSqlStatementColumns.join(",");

            String insertSqlColumnStatement = insertSqlStatementColumns.join(",");
            await conn.execute("CREATE TABLE ${tableName}_backup(${createSqlColumnStatement});");
            await conn.execute("INSERT INTO ${tableName}_backup SELECT ${insertSqlColumnStatement} FROM ${tableName};");
            await conn.execute("DROP TABLE ${tableName};");
            await conn.execute("CREATE TABLE ${tableName}(${createSqlColumnStatement});");
            await conn.execute("INSERT INTO ${tableName} SELECT ${insertSqlColumnStatement} FROM ${tableName}_backup;");
            await DBHelper.removeDBColumn("DROP TABLE ${tableName}_backup;", conn, x, columnNames.length, fileId);
        } else {
            sqlQuery = "ALTER TABLE ${tableName} ";
            for (int i = 0; i < columnNames.length; i++) {
                x = i;
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
            await DBHelper.removeDBColumn(sqlQuery, conn, x, columnNames.length, fileId);
        }
        return "";
    }
}