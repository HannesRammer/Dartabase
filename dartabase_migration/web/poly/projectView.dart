@HtmlImport('projectView.html')
library dartabase.poly.projectView;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import "package:polymer_elements/paper_material.dart";
import "../poly/configView.dart";
import "../poly/migrationListView.dart";
import "../poly/createMigration.dart";
import '../poly/pm.dart';

@PolymerRegister('custom-project-view')
class ProjectView extends PolymerElement {
    @property
    Project project;

    ProjectView.created() : super.created();


}
