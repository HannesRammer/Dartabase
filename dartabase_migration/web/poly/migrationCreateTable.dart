@HtmlImport('migrationCreateTable.html')
library dartabase.poly.migrationCreateTable;

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-create-table')
class MigrationCreateTable extends PolymerElement {
    @Property(notify: true)
    String tableName = "";
    @Property(notify: true)
    Map columns = {};
    @Property(notify: true)
    Map colorPalette = {};

    MigrationCreateTable.created() : super.created();
}
