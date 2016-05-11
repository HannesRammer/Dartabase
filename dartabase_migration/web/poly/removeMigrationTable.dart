@HtmlImport('removeMigrationTable.html')
library dartabase.poly.removeMigrationTable;
import 'dart:async';

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";
import "../poly/pm.dart";



@PolymerRegister('custom-remove-migration-table')
class RemoveMigrationTable extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNames;

    @property
    String selectedTable;

    RemoveMigrationTable.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Map table = new Map();
        add("project.migrationActions.removeTables", table);
        List names = await project.getTableNames();
        List filteredNames = new List();
        for(String name in names){
            if(name.indexOf("_2_")<0){
                filteredNames.add(name);
            }
        }
        set("existingTableNames", filteredNames);
    }

    @Observe('selectedTable')
    Future updateColumns(String newSelectedTable) async {
        var columns = await project.getColumns(newSelectedTable);
        set("project.migrationActions.removeTables.0.columns", await project.getColumns(newSelectedTable));
        set("project.migrationActions.removeTables.0.name", newSelectedTable);

    }

    @reflectable
    void cancelTable(event, [_]) {
        set("project.migrationActions.removeTables", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }
}
