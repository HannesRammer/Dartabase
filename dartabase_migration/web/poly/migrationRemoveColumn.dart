@HtmlImport('migrationRemoveColumn.html')
library dartabase.poly.migrationRemoveColumn;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_input.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-remove-column')
class MigrationRemoveColumn extends PolymerElement {
    @property
    String tableName;
    @property
    List columns;

    MigrationRemoveColumn.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }


}
