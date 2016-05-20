@HtmlImport('removeMigrationRelation.html')
library dartabase.poly.removeMigrationRelation;

import 'dart:async';

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";

import "../poly/pm.dart";

@PolymerRegister('custom-remove-migration-relation')
class RemoveMigrationRelation extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingRelations;

    RemoveMigrationRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Map relation = {"selectedRelation":""};
        add("project.migrationActions.removeRelations", relation);
        List names = await project.getRelationTables();
        set("existingRelations", names);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("project.migrationActions.removeRelations", new List());
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');

    }

}
