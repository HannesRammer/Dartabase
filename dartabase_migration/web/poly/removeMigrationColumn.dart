@HtmlImport('removeMigrationColumn.html')
library dartabase.poly.removeMigrationColumn;

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

@PolymerRegister('custom-remove-migration-column')
class RemoveMigrationColumn extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNames;
    @property
    Map existingColumns;
    @property
    String selectedTable;
    @property
    String selectedColumn;

    @property
    List<Table> removeColumns = new List();

    RemoveMigrationColumn.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Table table = new Table(columns: []);
        add("removeColumns", table);
        set("existingTableNames", await project.getTableNames());
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("removeColumns", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }

    @Observe('selectedTable')
    Future updateColumns(String newSelectedTable) async {
        set("existingColumnNames", await project.getColumnNames(newSelectedTable));
    }
}
