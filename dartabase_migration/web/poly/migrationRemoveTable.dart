@HtmlImport('migrationRemoveTable.html')
library dartabase.poly.migrationRemoveTable;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_input.dart';


@PolymerRegister('custom-migration-remove-table')
class MigrationRemoveTable extends PolymerElement {
    @property
    String tableName = "";

    MigrationRemoveTable.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

}
