@HtmlImport('projectView.html')
library dartabase.poly.projectView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_toast.dart";
import "../poly/configView.dart";
import "../poly/createMigration.dart";
import "../poly/migrationView.dart";
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
    @property
    Map schema = {};

    ProjectView.created() : super.created();

    @reflectable
    setSelectedMigration(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        int index = model.index;
        project.setSelectedMigrationByIndex(index);
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
        await updateView(responseText);
    }

    Future updateView(responseText) async {
        PaperToast test = document.querySelector('#toast');
        await project.requestMigrations();
        test.text = responseText + project.currentMigration.toString();
        test.show();
    }

    void ready() {
        print("$runtimeType::ready()");
//        ConfigView cv = Polymer.dom(this.root).querySelector("custom-config-view");
        //this.set('selectedProject',projects[0]);
    }

    @reflectable
    bool isSelectedMigration(Migration migration) {
        return migration == project.selectedMigration;
    }

    @reflectable
    bool isCurrentMigration(String state) {
        return state == "current";
    }
}
