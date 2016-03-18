@HtmlImport('createMigrationRelation.html')
library dartabase.poly.createMigrationRelation;

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-create-migration-relation')
class CreateMigrationRelation extends PolymerElement {
    @Property(notify: true)
    String table = "";
    @Property(notify: true)
    Map colorPalette = {};

    CreateMigrationRelation.created() : super.created();
}
