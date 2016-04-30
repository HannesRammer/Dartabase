@HtmlImport('removeMigrationRelation.html')
library dartabase.poly.removeMigrationRelation;

import 'dart:async';

// Import the paper element from Polymer.
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_button.dart";

import "../poly/pm.dart";

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-remove-migration-relation')
class RemoveMigrationRelation extends PolymerElement {
    @Property(notify: true)
    Project project;

    @property
    List existingRelations;

    @property
    String selectedRelation;

    @property
    List<List> removeRelations = new List();

    RemoveMigrationRelation.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future addTable(event, [_]) async {
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');
        List relation = new List();
        add("removeRelations", relation);
        List names = await project.getTableNames();
        List filteredNames = new List();
        for(String name in names){
            if(name.indexOf("_2_") > -1){
                filteredNames.add(name);
            }
        }
        set("existingRelations", filteredNames);
    }

    @reflectable
    void cancelTable(event, [_]) {
        set("removeRelations", new List());
        set("selectedRelation", "");
        var tableButton = querySelector("#tableButton");
        tableButton.classes.toggle('hidden');

    }

}
