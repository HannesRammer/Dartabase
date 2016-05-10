@HtmlImport('dartabaseMigration.html')
library dartabase.poly.dartabaseMigration;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import "package:polymer_elements/paper_input.dart";
import '../poly/serverStatus.dart';
import '../poly/projectView.dart';
import "../poly/pm.dart";

@PolymerRegister('dartabase-migration')
class DartabaseMigration extends PolymerElement {
    @property
    Project selectedProject;
    @property
    List<Project> projects;

    DartabaseMigration.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    transition(event, [_]) {

        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
        if (ip.selected == 0) {
            this.set('selectedProject', new Project());
        } else {
            var model = new DomRepeatModel.fromEvent(event);
             Project p = model.item;
            this.set('selectedProject', p);
        }
    }
}

/**
        Map test() {
        Map m = {
        "game_char": {
        "id": {
        "type": "INT"
        },
        "name": "VARCHAR",
        "created_at": "TIMESTAMP",
        "updated_at": {
        "type": "TIMESTAMP"
        }
        },
        "account": {
        "id": {
        "type": "INT"
        },
        "name": "VARCHAR",
        "password": {
        "type": "VARCHAR",
        "default": "1234",
        "null": "false"
        },
        "created_at": "TIMESTAMP",
        "updated_at": {
        "type": "TIMESTAMP"
        },
        "username": "VARCHAR",
        "char_name": {
        "type": "VARCHAR",
        "default": "pLaYeR"
        },
        "file_id": "INT"
        },
        "dependencyRelations": {
        "account": ["picture"],
        "masterList": ["account"],
        "slaveList": ["picture"]
        },
        "picture": {
        "id": {
        "type": "INT"
        },
        "filename": "VARCHAR",
        "user_id": "INT",
        "created_at": "TIMESTAMP",
        "updated_at": {
        "type": "TIMESTAMP"
        }
        }
        };
        return m;
        }

 */