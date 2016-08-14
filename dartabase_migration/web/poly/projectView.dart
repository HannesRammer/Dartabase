@HtmlImport('projectView.html')
library dartabase.poly.projectView;

import "dart:html" as dom;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import "package:polymer_elements/paper_material.dart";
import "../poly/configView.dart";
import "../poly/migrationListView.dart";
import "../poly/createMigration.dart";
import "../poly/scaffoldView.dart";
import '../poly/pm.dart';

@PolymerRegister('custom-project-view')
class ProjectView extends PolymerElement {
    @Property(notify: true)
    Project project;

    ProjectView.created() : super.created();

    @reflectable
    toggleConfig(dom.Event event, [_]) {
        var configButton = querySelector("#config_button");
        configButton.classes.toggle('active');
        ConfigView cv = querySelector("custom-config-view");
        cv.classes.toggle("hidden");
    }

    @reflectable
    toggleDoMigration(dom.Event event, [_]) {
        var migrationButton = querySelector("#do_button");
        migrationButton.classes.toggle('active');
        MigrationListView mlv = querySelector("custom-migration-list-view");
        mlv.classes.toggle("hidden");
    }

    @reflectable
    toggleMigration(dom.Event event, [_]) {
        var migrationButton = querySelector("#migration_button");
        migrationButton.classes.toggle('active');
        CreateMigration cm = querySelector("custom-create-migration");
        cm.classes.toggle("hidden");
    }


    @reflectable
    toggleScaffold(dom.Event event, [_]) {
        var migrationButton = querySelector("#scaffold_button");
        migrationButton.classes.toggle('active');
        ScaffoldView sv = querySelector("custom-scaffold-view");
        sv.classes.toggle("hidden");
    }


}
