part of dartabaseMigration;

//TODO think about making dartabase_core lib that gets imported by dartabase tools
class ModelGenerator {

    static Future createServerModel(String dbTableName, Map tableDesc, String rootPath) async {
        var className = DSC.toClassName(dbTableName);
        //var varName = DSC.toVarName(dbTableName);
        //var polyName = DSC.toPolyName(dbTableName);
        var tableName = DSC.toTableName(dbTableName);

        List toStringParts = [];
        Map columnsMap = tableDesc[dbTableName];
        await columnsMap.forEach((columnName, map) async {
            toStringParts.add("${columnName}=\$${columnName}");
        });

        String file = '''
import "package:dartabase_model/dartabase_model.dart";
class ${className} extends Model{

 ${await generateDynamicFields(columnsMap)}
 String toString() => "${className} ${toStringParts.join(":")}";
 //toJSON() is available through the "extends Model"
}

       ''';
        Directory dbModels = new Directory("${rootPath}/db/models");
        dbModels.create(recursive: true).then((_) {
            DBCore.stringToFilePath(file, "${rootPath}/db/models/${tableName}.dart");
            print("server model ${rootPath}/db/models/${tableName}.dart created");
            print("----------------------------------------------------------");
        });
    }

    static Future generateDynamicFields(Map columnsMap) async {
        String s = "";
        await columnsMap.forEach((columnName, map) async {
            s += "${DBCore.dartabaseTypeToDartType(map["type"].toString().split("(")[0].toUpperCase())} ${columnName};\n  ";
        });
        return s;
    }

}


