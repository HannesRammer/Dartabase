@HtmlImport('createMigrationColumn.html')
library dartabase.poly.createMigrationColumn;
import 'dart:async';
// Import the paper element from Polymer.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_button.dart';
import "../poly/columnView.dart";
import "../poly/table.dart";
import "../poly/pm.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


@PolymerRegister('custom-create-migration-column')
class CreateMigrationColumn extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNames;

    @property
    List<Table> createColumns = new List();

    CreateMigrationColumn.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    void addColumn(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        model.add("item.columns", {
            "name":"",
            "type":"",
            "def":"",
            "nil":true
        });
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Table table = new Table(name:"",columns: [{
            "name":"",
            "type":"",
            "def":"",
            "nil":true
        }]);
        add("createColumns", table);
        set("existingTableNames", await project.getTableNames());
    }

    @reflectable
    void cancelColumn(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        removeAt("createColumns.0.columns", model.index);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("createColumns", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');

    }
}
