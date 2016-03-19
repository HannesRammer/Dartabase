@HtmlImport('createMigrationColumn.html')
library dartabase.poly.createMigrationColumn;

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
    @Property(notify: true)
    Table table;
    @Property(notify: true)
    List existingTableNames;

    CreateMigrationColumn.created() : super.created();

    @reflectable
    void addColumn(event, [_]) {
        if (table.columns == null) {
            table.columns = [];
        }
        table.columns.add([]);
    }
}
