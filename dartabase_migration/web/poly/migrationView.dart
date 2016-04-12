@HtmlImport('migrationView.html')
library dartabase.poly.migrationView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";
import "package:polymer_elements/iron_pages.dart";
import "../poly/migrationActionView.dart";

import '../poly/pm.dart';

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-view')
class MigrationView extends PolymerElement {
    @property
    Migration migration;

    @property
    int selected = 0;

    MigrationView.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

}