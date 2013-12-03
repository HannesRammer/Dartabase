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
      afterQuery("removeDBTablen", conn.query(sql).toList(), sql, conn);
    } else if (DBCore.adapter == DBCore.MySQL) {
      conn.query(sql);
      printQueryCompleted("removeDBTable", "table Removed", sql);
    }
  }

  static void afterQuery(String actionType, response, String sql, [conn, x, count]) {
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
    print("Schema: $schema");
    print("${type} Finish");
  }
  
  static String primaryIDColumnString(String adapter) {
    String sql;
    if(adapter == DBCore.MySQL){
      sql = "id ${DBCore.typeMapping("INT")} NOT NULL PRIMARY KEY";
    }else if(adapter == DBCore.PGSQL){
      sql = "id ${DBCore.typeMapping("INT")} PRIMARY KEY";
    }
    return sql;
  }
   
   static String dateTimeColumnString(String adapter) {
     String sql ;
     
     if(adapter == DBCore.MySQL){
       sql = "created_at ${DBCore.typeMapping("DATETIME")} NOT NULL DEFAULT NOW(), updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP";
     }else if(adapter == DBCore.PGSQL){
       sql = "created_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at ${DBCore.typeMapping("TIMESTAMP")} NOT NULL DEFAULT CURRENT_TIMESTAMP";
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