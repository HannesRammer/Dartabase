library projectView;
import 'package:polymer/polymer.dart';
import "dart:html";
import "../poly/project.dart";

@CustomTag('custom-project-view')
class ProjectView extends PolymerElement {
  @published Project project;
  @observable Map schema = toObservable({});

  ProjectView.created() : super.created();

  setActive(Event e, var detail, DivElement target) {
    project.setSelectedMigrationByIndex(num.parse(target.getAttribute('index')));
  }
  runMigration() {
    var url = "http://127.0.0.1:8079/runMigration?projectRootPath=${project.path}&direction=${project.migrationDirection}";
    if (project.migrationDirection == "UP") {
      url += "&index=${project.selectedMigration.index - 1}";

    } else if (project.migrationDirection == "DOWN") {
      url += "&index=${project.selectedMigration.index}";
    }
    var request = HttpRequest.getString(url).then(updateView);
  }

  updateView(responseText) {
    project.requestMigrations();
    querySelector("#toast").text = responseText + project.currentMigration.toString();
    querySelector("#toast").show();
  }
}
