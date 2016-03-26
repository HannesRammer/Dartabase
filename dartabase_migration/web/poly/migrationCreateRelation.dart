@HtmlImport('migrationCreateRelation.html')
library dartabase.poly.migrationCreateRelation;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-create-relation')
class MigrationCreateRelation extends PolymerElement {
    @Property(notify: true)
    List relations;
    @Property(notify: true)
    Map colorPalette ;

    MigrationCreateRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

}
