part of dartabaseMigration;
//TODO think about making dartabase_core lib that gets imported by dartabase tools
class DBHelper {
  


  static void createDBTable(sql, conn, x, count) {
    if (DBCore.adapter == DBCore.PGSQL) {
      afterQuery("createDBTable", conn.query(sql).toList(), sql, conn, x, count);
    } else if (DBCore.adapter == DBCore.MySQL) {
      afterQuery("createDBTable", conn.query(sql), sql, conn, x, count);
    }
  }

  static void createDBColumn(sql, conn, x, count) {
    if (DBCore.adapter == DBCore.PGSQL) {
      afterQuery("createDBColumn", conn.query(sql).toList(), sql, conn, x, count);
    } else if (DBCore.adapter == DBCore.MySQL) {
      afterQuery("createDBColumn", conn.query(sql), sql, conn, x, count);
    }
  }

  static void removeDBColumn(sql, conn, x, count) {
    if (DBCore.adapter == DBCore.PGSQL) {
      afterQuery("removeDBColumn", conn.query(sql).toList(), sql, conn, x, count);
    } else if (DBCore.adapter == DBCore.MySQL) {
      afterQuery("removeDBColumn", conn.query(sql), sql, conn, x, count);
    }
  }

  static void removeDBTable(sql, conn) {
    if (DBCore.adapter == DBCore.PGSQL) {
      afterQuery("removeDBTable", conn.query(sql).toList(), sql);
    } else if (DBCore.adapter == DBCore.MySQL) {
      afterQuery("removeDBTable", conn.query(sql), sql);
    }
  }

  static void afterQuery(actionType, response, sql, [conn, x, count]) {
    response.then((result) {
      printQueryCompleted(actionType, result, sql);
      if (actionType == "createDBTable") {
        if (x == count - 1) {
          createColumn(conn);
        }
      }
      if (actionType == "createDBColumn") {
        if (x == count - 1) {
          removeColumn(conn);
        }
      }
      if (actionType == "removeDBColumn") {
        if (x == count) {
          removeTable(conn);
        }
      }
    });
  }

  static void printQueryCompleted(String type, result, String sql) {
    print("\ncompleted SQL Query: $sql");
    print("DB returned: $result");
    DBCore.mapToJsonFilePath(schema,'${DBCore.rootPath}/db/schema.json');
    print("Schema: schema");
    print("${type}Column Finish");
  }
}