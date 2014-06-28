import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('custom-create-project')
class CreateProject extends PolymerElement {
  @observable String name = "name";
  @observable num page = 0;
  @observable String path = "path";
  @published String color = "#ff0000";

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
