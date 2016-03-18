@HtmlImport('createMigration.html')
library dartabase.poly.createMigration;

// Import the paper element from Polymer.
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_input.dart';
import "../poly/createMigrationTable.dart";
import "../poly/createMigrationColumn.dart";
import "../poly/removeMigrationColumn.dart";
import "../poly/removeMigrationTable.dart";
import "../poly/project.dart";
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-create-migration')
class CreateMigration extends PolymerElement {
    @Property(notify: true)
    Project project;
    @Property(notify: true)
    String newMigrationName = "";
    @Property(notify: true)
    List<Table> createColumn = [];
    @Property(notify: true)
    List<Table> removeColumn = [];

    @Property(notify: true)
    List<Table> removeTable = [];
    @Property(notify: true)
    int editMode = 0;

    @Property(notify: true)
    List existingTableNames = [];
    @Property(notify: true)
    Map existingTables = {};

    CreateMigration.created() : super.created();

    @reflectable
    transition(e) {
        if (this.editMode == 0) {
            this.editMode = 1;
        } else {
            this.editMode = 0;
        }
    }


    @reflectable
    addColumn() {
        Table table = new Table();
        createColumn.add(table);
        existingTableNames = project.getTableNames();
    }

    @reflectable
    addRemoveColumn() {
        Table table = new Table();
        List columns = new List();
        table.columns = columns;
        removeColumn.add(table);
        existingTables = project.tables;
    }

    @reflectable
    addRemoveTable() {
        Table table = new Table();
        removeTable.add(table);
        existingTableNames = project.getTableNames();
    }

    @reflectable
    createMigration() {
        Map up = {"UP":{}};
        Map down = {"DOWN":{}};
    }

}
