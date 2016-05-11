@HtmlImport("createMigrationTable.html")
library dartabase.poly.createMigrationTable;

import "package:web_components/web_components.dart" show HtmlImport;
import "package:polymer/polymer.dart";
import "package:polymer_elements/iron_pages.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_input.dart";
import "../poly/pm.dart";

@PolymerRegister("custom-create-migration-table")
class CreateMigrationTable extends PolymerElement {
    @Property(notify: true)
    Project project;

    CreateMigrationTable.created() : super.created();

    @reflectable
    addTable(event, [_]) {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Map table = {
            "columns" : [ {
                "name":"",
                "type":"",
                "default":"",
                "null":true
            }
            ]};
        add("project.migrationActions.createTables", table);
    }

    @reflectable
    void addColumn(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        model.add("item.columns", {
            "name":"",
            "type":"",
            "default":"",
            "null":true
        });
    }

    @reflectable
    void cancelColumn(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        removeAt(
                "project.migrationActions.createTables.0.columns", model.index);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("project.migrationActions.createTables", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
    }

    void ready() {
        print("$runtimeType::ready()");
    }


}
