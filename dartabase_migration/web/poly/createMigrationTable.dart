@HtmlImport('createMigrationTable.html')
library dartabase.poly.createMigrationTable;

// Import the paper element from Polymer.
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_input.dart';
import "../poly/columnView.dart";
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-create-migration-table')
class CreateMigrationTable extends PolymerElement {
    @Property(notify: true)
    List<Table> createTables = [];

    CreateMigrationTable.created() : super.created();

    @Property(notify: true)
    int editMode = 0;

    @reflectable
    addTable() {
        Table table = new Table(columns: []);
        table.columns.add({});
        createTables.add(table);
    }

    @reflectable
    transition(e) {
        if (this.editMode == 0) {
            this.editMode = 1;
        } else {
            this.editMode = 0;
        }
    }
}
