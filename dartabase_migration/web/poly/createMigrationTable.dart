@HtmlImport("createMigrationTable.html")
library dartabase.poly.createMigrationTable;

// Import the paper element from Polymer.
import "package:polymer_elements/iron_pages.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_input.dart";
//import "../poly/columnView.dart";
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import "package:polymer/polymer.dart";
import "package:web_components/web_components.dart";

@PolymerRegister("custom-create-migration-table")
class CreateMigrationTable extends PolymerElement {
    @Property(notify: true)
    List<Table> createTables = new List();

    CreateMigrationTable.created() : super.created();

    @reflectable
    addTable(event, [_]) {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Table table = new Table(columns: [{
            "name":"",
            "type":"",
            "def":"",
            "nil":true
        }]);
        add("createTables", table);
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
    void cancelColumn(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        removeAt("createTables.0.columns", model.index);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("createTables", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }

    void ready() {
        print("$runtimeType::ready()");
    }


}
