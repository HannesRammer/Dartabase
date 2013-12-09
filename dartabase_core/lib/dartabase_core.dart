library dartabaseCore;

import "dart:io";
import "dart:convert";

class DBCore {
  static String rootPath;
  static Map parsedMap ;

  static Map parsedMapping ;

  static String adapter;
  static String get MySQL => "MySQL";

  static String get PGSQL => "PGSQL";

  static String database;

  static String username;

  static String password;

  static String host;

  static int port;

  static String schemaVersion;
  
   static Map jsonFilePathToMap(String path) {
    var file = new File(path);
    String fileText = file.readAsStringSync(encoding: ASCII);
    if (fileText == "") {
      fileText = "{}";
    }
    return  JSON.decode(fileText);
  }
  
   static Map loadSchemaToMap() {
    var schema = new File('$rootPath/db/schema.json');
    schema.writeAsStringSync("", encoding: ASCII, mode: FileMode.APPEND);
    String fileText = schema.readAsStringSync(encoding: ASCII);
    if (fileText == "") {
      fileText = "{}";
    }
    return  JSON.decode(fileText);
  }
   
   static void mapToJsonFilePath(Map contentMap,String filePath) {
    String contentString = JSON.encode(contentMap);
    var file = new File(filePath);
    
    file.writeAsStringSync(contentString, encoding: ASCII);
    
  }
  
   static String typeMapping(String dartabaseType) {
     return parsedMapping[dartabaseType];
   }
   
   static defaultValueFor(var mapOrString) {
     String dartabaseType;
     if (mapOrString.runtimeType == String){
       return defaultForType(mapOrString);
     }else if(mapOrString.runtimeType.toString() == "_LinkedHashMap"){
       dartabaseType = mapOrString["type"];
       String defaultValue = mapOrString["default"];
       if(defaultValue == null){
         return defaultForType(dartabaseType);
       }else{
         return defaultValue;
       } 
     }
   }
   
   static defaultForType(dartabaseType){
     if(["BINT","BINT UNSIGNED","DOUBLE","FLOAT","FLOAT UNSIGNED","INT","INT UNSIGNED","SINT","SINT UNSIGNED","TINT","TINT UNSIGNED"].contains(dartabaseType)){
       return 0;  
     }else if(["DOUBLE","FLOAT","FLOAT UNSIGNED"].contains(dartabaseType)){
       return 0.0;  
     }else if(dartabaseType == "BOOLEAN"){
       return false;
     }else if(["CHAR", "LTEXT", "MTEXT", "TEXT", "TTEXT", "VARCHAR"].contains(dartabaseType))
     {       
       return "";
     }else if(["DATE", "DATETIME", "TIME", "TIMESTAMP"].contains(dartabaseType))
     {       
       return new DateTime.now();
     }else{
       /*
       "BINARY": "bytea",
       "BIT": "bytea",
       "BLOB": "bytea",
       "BYTEARRAY": "bytea",
       "LBLOB": "bytea",
       "MBLOB": "bytea",
       "TBLOB": "bytea",
       "VARBINARY": "bytea",*/
     }
   }
   static void loadConfigFile() {
//parsedMap = DBHelper.jsonFilePathToMap('$rootPath/db/configPGSQL.json');
//parsedMap = DBHelper.jsonFilePathToMap('$rootPath/db/configMYSQL.json');
     parsedMap = jsonFilePathToMap('$rootPath/db/config.json');
     adapter = parsedMap["adapter"];
     if (adapter != MySQL && adapter != PGSQL) {
       print("\nadapter in config file not correct!!! Should be '$MySQL' or '$PGSQL'!!!");
     }
     database = parsedMap["database"];
     username = parsedMap["username"];
     password = parsedMap["password"];
     host = parsedMap["host"];
     port = int.parse(parsedMap["port"]);
     
     schemaVersion = DBCore.jsonFilePathToMap('$rootPath/db/schemaVersion.json')["schemaVersion"];
   }
}