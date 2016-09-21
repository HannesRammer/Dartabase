part of dartabaseMigration;
//TODO think about making dartabase_core lib that gets imported by dartabase tools
class DBHelper {


    static void createDBTable(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("createDBTable", conn.query(sql).toList(), sql, exitAfter, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery("createDBTable", conn.query(sql), sql,exitAfter, fileId, conn, x, count);
        }
    }

    static void createDBColumn(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("createDBColumn", conn.query(sql).toList(), sql,exitAfter, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery("createDBColumn", conn.query(sql), sql,exitAfter, fileId, conn, x, count);
        }
    }

    static void removeDBColumn(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("removeDBColumn", conn.query(sql).toList(), sql,exitAfter, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery("removeDBColumn", conn.query(sql), sql,exitAfter, fileId, conn, x, count);
        }
    }

    static void createDBRelation(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("createDBRelation", conn.query(sql).toList(), sql,exitAfter, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery("createDBRelation", conn.query(sql), sql,exitAfter, fileId, conn, x, count);
        }
    }

    static void removeDBRelation(sql, conn, x, count, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("removeDBRelation", conn.query(sql).toList(), sql,exitAfter, fileId, conn, x, count);
        } else if (DBCore.adapter == DBCore.MySQL) {
            afterQuery("removeDBRelation", conn.query(sql), sql,exitAfter, fileId, conn, x, count);
        }
    }

    static void removeDBTable(sql, conn, bool exitAfter, fileId) {
        if (DBCore.adapter == DBCore.PGSQL) {
            afterQuery("removeDBTable", conn.query(sql).toList(), sql,exitAfter, fileId, conn);
        } else if (DBCore.adapter == DBCore.MySQL) {
            conn.query(sql);
            printQueryCompleted("removeDBTable", "table Removed", sql);
        }
    }

    static afterQuery(String actionType, response, String sql, bool exitAfter, fileId, [conn, x, count]) async {
        var result = await response;
        printQueryCompleted(actionType, result, sql);
        if (actionType == "createDBTable") {
            if (x == count - 1) {
                createColumn(conn,exitAfter, fileId);
            }
        }
        if (actionType == "createDBColumn") {
            if (x == count - 1) {
                removeColumn(conn,exitAfter, fileId);
            }
        }
        if (actionType == "removeDBColumn") {
            if (x == count) {
                createRelation(conn,exitAfter, fileId);
            }
        }
        if (actionType == "createDBRelation") {
            if (x == count - 1) {
                removeRelation(conn,exitAfter, fileId);
            }
        }
        if (actionType == "removeDBRelation") {
            if (x == count - 1) {
                removeTable(conn,exitAfter, fileId);
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

}