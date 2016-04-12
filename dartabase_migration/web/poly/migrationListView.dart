@HtmlImport('migrationListView.html')
library dartabase.poly.migrationListView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_toast.dart";
import "../poly/migrationView.dart";
import '../poly/pm.dart';
import "dart:html";
import "dart:async";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-list-view')
class MigrationListView extends PolymerElement {
    @property
    Project project;
    @property
    Map schema = {};

    MigrationListView.created() : super.created();

    @reflectable
    setSelectedMigration(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        project.setSelectedMigrationByIndex(model.item.index);
        this.set('project.selectedMigration', project.selectedMigration);
        this.notifyPath('project.selectedMigration', project.selectedMigration);
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
    }

    @reflectable
    bool isSelectedMigration(Migration migration) {
        return migration == project.selectedMigration;
    }

    @reflectable
    bool isNothingToDo(String state) {
        return !isOlderMigration(state) && !isNewerMigration(state);
    }
    @reflectable
    bool isCurrentMigration(String state) {
        return state == "current";
    }
    @reflectable
    bool isOlderMigration(String state) {
        return state == "older";
    }
    @reflectable
    bool isNewerMigration(String state) {
        return state == "newer";
    }

}
