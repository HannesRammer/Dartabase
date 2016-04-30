@HtmlImport('removeMigrationTable.html')
library dartabase.poly.removeMigrationTable;
import 'dart:async';

// Import the paper element from Polymer.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";
import "../poly/table.dart";
import "../poly/pm.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


@PolymerRegister('custom-remove-migration-table')
class RemoveMigrationTable extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNames;
    @property
    String selectedTable;

    @property
    List<Table> removeTables = new List();

    RemoveMigrationTable.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Table table = new Table();
        add("removeTables", table);
        List names = await project.getTableNames();
        List filteredNames = new List();
        for(String name in names){
            if(name.indexOf("_2_")<0){
                filteredNames.add(name);
            }
        }
        set("existingTableNames", filteredNames);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("removeTables", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }
}
