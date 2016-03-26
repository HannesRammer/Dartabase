@HtmlImport('migrationRemoveTable.html')
library dartabase.poly.migrationRemoveTable;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-remove-table')
class MigrationRemoveTable extends PolymerElement {
    @Property(notify: true)
    String table = "";
    @Property(notify: true)
    Map colorPalette = {};

    MigrationRemoveTable.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

}
//https://api.openload.co/1/file/info?file=iMc0mI4qZWA&login=5c711f956ecf1178&key=p5NvLZn1
//https://api.openload.co/1/file/ul?