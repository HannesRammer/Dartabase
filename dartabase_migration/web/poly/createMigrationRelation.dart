@HtmlImport('createMigrationRelation.html')
library dartabase.poly.createMigrationRelation;
import 'dart:async';
// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_button.dart';
import "../poly/columnView.dart";
import "../poly/table.dart";
import "../poly/pm.dart";

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-create-migration-relation')
class CreateMigrationRelation extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingTableNamesOne;
    @property
    List existingTableNamesTwo;
    @property
    String selectedTableOne;
    @property
    String selectedTableTwo;

    @property
    List<List<String>> createRelations = new List();

    CreateMigrationRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        List relation = new List();
        add("createRelations", relation);
        set("existingTableNamesOne", await project.getTableNames());
        set("existingTableNamesTwo", existingTableNamesOne);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("createRelations", new List());
        set("selectedTableOne", "");
        set("selectedTableTwo", "");
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');

    }
}
