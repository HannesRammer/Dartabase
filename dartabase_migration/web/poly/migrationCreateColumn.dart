@HtmlImport('migrationCreateColumn.html')
library dartabase.poly.migrationCreateColumn;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';


@PolymerRegister('custom-migration-create-column')
class MigrationCreateColumn extends PolymerElement {
    @Property(notify: true)
    String tableName;
    @Property(notify: true)
    Map columns;
    @Property(notify: true)
    Map colorPalette;

    MigrationCreateColumn.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }


}
