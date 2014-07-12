import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:material_paper_colors/material_paper_colors.dart' as MPC;

@CustomTag('custom-create-project')
class CreateProject extends PolymerElement {
  @observable String name = "";
  @observable num page = 0;
  @observable String path = "";
  @published String backgroundColor = MPC.Red["500"];
  @published String color = MPC.RedT["500"][1];

  CreateProject.created() : super.created();

  transition(e) {
    if (page == 0) {
      //this.selectedProject = nodeBind(e.target).templateInstance
      // .model['item'];
      page = 1;
    } else {
      page = 0;
    }
  }

  initiateMigration() {
    var url = "http://127.0.0.1:8079/initiateMigration?name=${name}&path=${path}";
    var request = HttpRequest.getString(url).then(initiationCompleted);
  }

  initiationCompleted(responseText) {
    print(responseText.toString());
    page = 0;
  }

}
