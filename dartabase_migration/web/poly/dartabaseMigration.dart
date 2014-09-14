library custom.dartabaseMigration;
import 'package:polymer/polymer.dart';
import "project.dart";
import 'package:template_binding/template_binding.dart';
import 'package:params/client.dart';

@CustomTag('dartabase-migration')
class DartabaseMigration extends PolymerElement {
  @observable int page = 0;
  @observable Project selectedProject=toObservable(new Project());
  @observable List<Project> projects=toObservable([]);
  @observable DateTime dateTime;
  DartabaseMigration.created() : super.created();

  transition(e) {
    if (this.page == 0) {
      this.selectedProject = nodeBind(e.target).templateInstance.model['project'];
      this.page = 1;
      this.selectedProject.migrationDirection = '';
      this.selectedProject.currentMigration = this.selectedProject.getCurrentMigration();
      this.selectedProject.selectedMigration = this.selectedProject.currentMigration;
    } else {
      this.page = 0;
    }
  }

  test() {
    Map m = {
      "gamechar": {
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
        "charname": {
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
  }
}
