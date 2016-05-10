@HtmlImport('removeMigrationColumn.html')
library dartabase.poly.removeMigrationColumn;

import 'dart:async';

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_checkbox.dart";
import "../poly/pm.dart";


@PolymerRegister('custom-remove-migration-column')
class RemoveMigrationColumn extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNames;

    @property
    String selectedTable;
    @property
    Map selectedColumn;

    @property
    List existingColumnNames;




    RemoveMigrationColumn.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Map table = {
            "columns" : [ {
                "name":"",
                "type":"",
                "def":"",
                "nil":true
            }
            ]};
        add("project.migrationActions.removeColumns", table);
        set("existingTableNames", await project.getTableNames());
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("project.migrationActions.removeColumns", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }

    @Observe('selectedTable')
    Future updateColumns(String newSelectedTable) async {
        set("existingColumnNames",
                await project.getColumnNames(newSelectedTable));
        set("project.migrationActions.removeColumns.0.name", newSelectedTable);
    }

    @reflectable
    Future adaptColumnType(String tableName, String columnName) async {
        var column = await project.getColumnDetails(tableName, columnName);
        if (column != null) {
            set("selectedColumn", column);
            return "";
        }else{
            return "";
        }
    }


}
