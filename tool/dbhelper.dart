part of dartabase;

class DBHelper {
  static Map jsonFilePathToMap(String path) {
    var file = new File(path);
    String fileText = file.readAsStringSync(encoding: Encoding.ASCII);
    if (fileText == "") {
      fileText = "{}";
    }
    return parse(fileText);
  }

  static Map loadSchemaToMap() {
    var schema = new File('$rootPath/db/schema.json');
    schema.writeAsStringSync("", encoding: Encoding.ASCII, mode: FileMode.APPEND);
    String fileText = schema.readAsStringSync(encoding: Encoding.ASCII);
    if (fileText == "") {
      fileText = "{}";
    }
    return parse(fileText);
  }

  static void mapToJsonFilePath(Map contentMap,String filePath) {
    String contentString = stringify(contentMap);
    var file = new File(filePath);
    
    file.writeAsStringSync(contentString, encoding: Encoding.ASCII);
    
  }

  static String typeMapping(String dartabaseType) {
    return parsedMapping[dartabaseType];
  }


  static void createDBTable(sql, conn, x, count) {
    if (adapter == PGSQL) {
      afterQuery("createDBTable", conn.query(sql).toList(), sql, conn, x, count);
    } else if (adapter == MySQL) {
      afterQuery("createDBTable", conn.query(sql), sql, conn, x, count);
    }
  }

  static void createDBColumn(sql, conn, x, count) {
    if (adapter == PGSQL) {
      afterQuery("createDBColumn", conn.query(sql).toList(), sql, conn, x, count);
    } else if (adapter == MySQL) {
      afterQuery("createDBColumn", conn.query(sql), sql, conn, x, count);
    }
  }

  static void removeDBColumn(sql, conn, x, count) {
    if (adapter == PGSQL) {
      afterQuery("removeDBColumn", conn.query(sql).toList(), sql, conn, x, count);
    } else if (adapter == MySQL) {
      afterQuery("removeDBColumn", conn.query(sql), sql, conn, x, count);
    }
  }

  static void removeDBTable(sql, conn) {
    if (adapter == PGSQL) {
      afterQuery("removeDBTable", conn.query(sql).toList(), sql);
    } else if (adapter == MySQL) {
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
    mapToJsonFilePath(schema,'$rootPath/db/schema.json');
    print("Schema: schema");
    print("${type}Column Finish");
  }
}