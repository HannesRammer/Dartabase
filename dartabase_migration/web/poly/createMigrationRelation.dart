@HtmlImport('createMigrationRelation.html')
library dartabase.poly.createMigrationRelation;

import 'dart:async';

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_button.dart';
import "../poly/columnView.dart";
import "../poly/pm.dart";

@PolymerRegister('custom-create-migration-relation')
class CreateMigrationRelation extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNamesOne;
    @property
    List existingTableNamesTwo;

    CreateMigrationRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        Map relation = {"selectedTableOne":"","selectedTableTwo":""};
        add("project.migrationActions.createRelations", relation);
        set("existingTableNamesOne", await project.getTableNamesWithoutRelation());
        set("existingTableNamesTwo", existingTableNamesOne);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("project.migrationActions.createRelations", new List());
        set("selectedTableOne", "");
        set("selectedTableTwo", "");
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');

    }
}
