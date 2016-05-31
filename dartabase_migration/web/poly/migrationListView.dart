@HtmlImport('migrationListView.html')
library dartabase.poly.migrationListView;

import "dart:html";
import "dart:async";

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_toast.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";

import "../poly/migrationView.dart";
import '../poly/pm.dart';

@PolymerRegister('custom-migration-list-view')
class MigrationListView extends PolymerElement {
    @Property(notify: true)
    Project project;

    @Property(notify: true)
    List<Migration> migrations;

    @property
    Map schema = {};

    MigrationListView.created() : super.created();

    @reflectable
    setSelectedMigration(event, [_]) {
        var model = new DomRepeatModel.fromEvent(event);
        var index = model.item.index;
        project.setSelectedMigrationByIndex(model.item.index);
        this.set('project.selectedMigration', project.selectedMigration);
        this.notifyPath('project.selectedMigration', project.selectedMigration);
        var activeButton = querySelector(".selected");
        if(activeButton != null){
            activeButton.classes.toggle("selected");
        }
        var migrationButtons = querySelectorAll(".mig_button")[index];
        migrationButtons.classes.toggle("selected");
    }

    @reflectable
    Future runMigration(event, [_]) async {
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
        PaperToast test = Polymer.dom($['toast1']).querySelector("#toast1");

        List migrations = await project.requestMigrations();

        this.set('project.migrations', migrations);
        //this.notifyPath('project.migrations', migrations);
        test.text = responseText + project.selectedMigration.toString();
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
