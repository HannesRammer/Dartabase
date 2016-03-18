@HtmlImport('projectView.html')
library dartabase.poly.projectView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_toast.dart";
import "../poly/configView.dart";
import "../poly/createMigration.dart";
import "../poly/migrationView.dart";
import '../poly/project.dart';
import "dart:html";
import "dart:async";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-project-view')
class ProjectView extends PolymerElement {
    @Property(notify: true)
    Project project;
    @Property(notify: true)
    Map schema = {};

    ProjectView.created() : super.created();

    @reflectable
    setActive(Event e, var detail, DivElement target) {
        project.setSelectedMigrationByIndex(
                num.parse(target.getAttribute('index')));
    }

    @reflectable
    Future runMigration() async{
        var url = "http://127.0.0.1:8079/runMigration?projectRootPath=${project
                .path}&direction=${project.migrationDirection}";
        if (project.migrationDirection == "UP") {
            url += "&index=${project.selectedMigration.index - 1}";
        } else if (project.migrationDirection == "DOWN") {
            url += "&index=${project.selectedMigration.index}";
        }
        var responseText = await HttpRequest.getString(url);
        updateView(responseText);
    }

    updateView(responseText) {
        PaperToast test = document.querySelector('#toast');
        project.requestMigrations();
        test.text = responseText + project.currentMigration.toString();
        test.show();
    }
}
