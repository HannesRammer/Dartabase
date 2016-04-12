@HtmlImport('migrationCreateColumn.html')
library dartabase.poly.migrationCreateColumn;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


@PolymerRegister('custom-migration-create-column')
class MigrationCreateColumn extends PolymerElement {
    @property
    String tableName;
    @property
    Map columns;

    MigrationCreateColumn.created() : super.created();

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
            }else {
                if (columns[item][dataType] != null) {
                    val = columns[item][dataType].toString();
                }
            }
        }
        return val;
    }

    @reflectable
    bool isString(var dataTypeStringOrMap, item) {
        if (dataTypeStringOrMap != null &&
                dataTypeStringOrMap[item] != null) {
            return dataTypeStringOrMap[item].runtimeType == String;
        }
    }
}
