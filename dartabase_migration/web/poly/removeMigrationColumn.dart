@HtmlImport('removeMigrationColumn.html')
library dartabase.poly.removeMigrationColumn;
// Import the paper element from Polymer.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";
import "../poly/table.dart";
import "../poly/project.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-remove-migration-column')
class RemoveMigrationColumn extends PolymerElement {
    @Property(notify: true)
    Project project;
    @Property(notify: true)
    Table table;
    @Property(notify: true)
    Map existingTables = {};
    @Property(notify: true)
    Map existingColumns = {};

    RemoveMigrationColumn.created() : super.created();

    @reflectable
    void addColumn() {
        if (table.columns == null) {
            table.columns = [];
        }
        table.columns.add([]);
        print(2);
    }

    @reflectable
    void updateColumns(event, detail, target) {
        print(2);
    }
}
