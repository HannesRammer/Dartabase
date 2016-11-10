@HtmlImport("migrationCreateTable.html")
library dartabase.poly.migrationCreateTable;

import "package:web_components/web_components.dart" show HtmlImport;
import "package:polymer/polymer.dart";
import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_material.dart";

@PolymerRegister("custom-migration-create-table")
class MigrationCreateTable extends PolymerElement {
    @property
    String tableName;
    @property
    Map columns;

    MigrationCreateTable.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    List getColumnNames(Map columns) {
        List names = new List();
        if (columns != null) {
            names = columns.keys.toList();
        }
        return names;
    }

    @reflectable
    String getColumnType(var columns, var item, String dataType) {
        String val = "";
        if (columns != null && columns[item] != null) {
            if (columns[item].runtimeType == String) {
                val = columns[item];
            } else {
                if (columns[item][dataType] != null) {
                    val = columns[item][dataType].toString();
                }
            }
        }
        return val;
    }

    @reflectable
    String OLDgetColumnType(var columns, var item, String dataType) {
        String val = "";
        if (columns != null && columns[item] != null) {
            if (dataType == "string") {
                val = columns[item].toString();
            } else {
                if (columns[item][dataType] != null) {
                    return columns[item][dataType].toString();
                }
            }
        }
        return val;
    }

    @reflectable
    bool isString(var dataTypeStringOrMap, item) {
        bool val = false;
        if (dataTypeStringOrMap != null && dataTypeStringOrMap[item] != null) {
            val = dataTypeStringOrMap[item].runtimeType == String;
        }
        return val;
    }

}


