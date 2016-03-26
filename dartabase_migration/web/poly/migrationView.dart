@HtmlImport('migrationView.html')
library dartabase.poly.migrationView;
// Import the paper element from Polymer.
import "../poly/migrationCreateTable.dart";
import "../poly/migrationCreateColumn.dart";
import "../poly/migrationRemoveColumn.dart";
import "../poly/migrationCreateRelation.dart";
import "../poly/migrationRemoveRelation.dart";
import "../poly/migrationRemoveTable.dart";
import '../poly/pm.dart';
//import '../poly/project.dart';
//import '../poly/migration.dart';

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-view')
class MigrationView extends PolymerElement {
    @Property(notify: true)
    Migration migration;
    @Property(notify: true)
    Project project = new Project();


    MigrationView.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }


}
