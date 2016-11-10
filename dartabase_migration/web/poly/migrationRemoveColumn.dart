@HtmlImport("migrationRemoveColumn.html")
library dartabase.poly.migrationRemoveColumn;

import "package:web_components/web_components.dart" show HtmlImport;
import "package:polymer/polymer.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_input.dart";

@PolymerRegister("custom-migration-remove-column")
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
