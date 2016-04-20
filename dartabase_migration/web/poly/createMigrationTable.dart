@HtmlImport('createMigrationTable.html')
library dartabase.poly.createMigrationTable;

// Import the paper element from Polymer.
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_input.dart';
import "../poly/columnView.dart";
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-create-migration-table')
class CreateMigrationTable extends PolymerElement {
    @property
    List createTables;

    CreateMigrationTable.created() : super.created();

    @reflectable
    addTable(event, [_]) {
        createTables = [];
        //Table table = new Table(columns: []);
        List table = {"tableName":"columnNam]}
        table.columns.add({});
        createTables.add(table);

    }

    @reflectable
    transition(event, [_]) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
    }

    void ready() {
        print("$runtimeType::ready()");
    }


}
