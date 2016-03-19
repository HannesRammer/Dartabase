@HtmlImport('migrationRemoveRelation.html')
library dartabase.poly.migrationRemoveRelation;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-remove-relation')
class MigrationRemoveRelation extends PolymerElement {
    @Property(notify: true)
    List relations;
    @Property(notify: true)
    Map colorPalette;

    MigrationRemoveRelation.created() : super.created();
}
