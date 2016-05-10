@HtmlImport('migrationRemoveRelation.html')
library dartabase.poly.migrationRemoveRelation;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_material.dart';

@PolymerRegister('custom-migration-remove-relation')
class MigrationRemoveRelation extends PolymerElement {
    @Property(notify: true)
    List relations;
    @Property(notify: true)
    Map colorPalette;

    MigrationRemoveRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

}
