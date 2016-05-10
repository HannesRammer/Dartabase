@HtmlImport('migrationCreateRelation.html')
library dartabase.poly.migrationCreateRelation;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_material.dart';

@PolymerRegister('custom-migration-create-relation')
class MigrationCreateRelation extends PolymerElement {
    @property
    var relations;
    @property
    Map colorPalette;

    MigrationCreateRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    String getRelations(var relations) {
        return relations.toString();
    }
}
