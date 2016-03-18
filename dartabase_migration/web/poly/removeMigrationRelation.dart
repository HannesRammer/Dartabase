@HtmlImport('removeMigrationRelation.html')
library dartabase.poly.removeMigrationRelation;
// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-remove-migration-relation')
class RemoveMigrationRelation extends PolymerElement {
    @Property(notify: true)
    String table = "";
    @Property(notify: true)
    Map colorPalette = {};

    RemoveMigrationRelation.created() : super.created();
}
