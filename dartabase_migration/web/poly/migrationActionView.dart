
@HtmlImport('migrationActionView.html')
library dartabase.poly.migrationActionView;
// Import the paper element from Polymer.
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";

import "../poly/migrationCreateTable.dart";
import "../poly/migrationCreateColumn.dart";
import "../poly/migrationRemoveColumn.dart";
import "../poly/migrationCreateRelation.dart";
import "../poly/migrationRemoveRelation.dart";
import "../poly/migrationRemoveTable.dart";
import '../poly/pm.dart';


// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-migration-action-view')
class MigrationActionView extends PolymerElement {
    @property
    Migration migration;
    @property
    String direction;

    MigrationActionView.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    bool directionContainsActions(Migration migration, String direction) {
        bool val = false;
        if(migration != null && migration.actions != null && migration.actions[direction] != null){
            val = migration.actions[direction].length > 0;
        }
        return val;
    }

    @reflectable
    bool actionExists(Migration migration, String direction, String action) {
        bool val = false;
        if(migration != null && migration.actions != null &&migration.actions[direction] != null) {
            val = migration.actions[direction][action] != null;
        }
        return val;
    }

    @reflectable
    List getColumnNames(Migration migration, String direction, String action) {
        List names = new List();
        if(migration != null && migration.actions != null && migration.actions[direction] != null && migration.actions[direction][action] != null) {
            names = migration.actions[direction][action].keys.toList();
        }
        return names;
    }

    @reflectable
     getColumns(Migration migration, String direction, String action, String tableName) {
         var columns ;
        if(migration != null && migration.actions != null && migration.actions[direction] != null && migration.actions[direction][action] != null) {
            columns = migration.actions[direction][action][tableName];
        }
        return columns;
    }

    @reflectable
    List getTableNames(Migration migration, String direction, String action) {
        List names = new List();
        if(migration != null && migration.actions != null && migration.actions[direction] != null) {
            names = migration.actions[direction][action];
        }
        return names;
    }

    @reflectable
    List getRelatedNames(Migration migration, String direction, String action) {
        List names = new List();
        if(migration != null && migration.actions != null && migration.actions[direction] != null) {
            names = migration.actions[direction][action];
        }
        return names;
    }
}
