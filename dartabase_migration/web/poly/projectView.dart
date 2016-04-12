@HtmlImport('projectView.html')
library dartabase.poly.projectView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_material.dart";
import "../poly/configView.dart";
import "../poly/migrationListView.dart";
import "../poly/createMigration.dart";
import '../poly/pm.dart';
import "dart:html";
import "dart:async";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-project-view')
class ProjectView extends PolymerElement {
    @property
    Project project;

    ProjectView.created() : super.created();


}
