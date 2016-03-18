@HtmlImport('removeMigrationTable.html')
library dartabase.poly.removeMigrationTable;
// Import the paper element from Polymer.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


@PolymerRegister('custom-remove-migration-table')
class RemoveMigrationTable extends PolymerElement {
    @Property(notify: true)
    Table table;
    @Property(notify: true)
    Map colorPalette = {};
    @Property(notify: true)
    List existingTableNames = [];

    RemoveMigrationTable.created() : super.created();
}
