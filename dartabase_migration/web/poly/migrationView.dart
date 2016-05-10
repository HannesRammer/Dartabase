@HtmlImport('migrationView.html')
library dartabase.poly.migrationView;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";
import "package:polymer_elements/iron_pages.dart";
import "../poly/migrationActionView.dart";

import '../poly/pm.dart';


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