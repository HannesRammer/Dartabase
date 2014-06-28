library custom.dartabaseMigration;
import 'package:polymer/polymer.dart';
import "project.dart";
import 'package:template_binding/template_binding.dart';

@CustomTag('dartabase-migration')
  class DartabaseMigration extends PolymerElement {
    @observable int page = 0;
    @observable Project selectedProject;
    @observable List projects;

    
    DartabaseMigration.created() : super.created();

    transition(e) {
      if (this.page == 0) {
        this.selectedProject = nodeBind(e.target).templateInstance
          .model['project'];
        this.page = 1;
      } else {
        this.page = 0;
      }
    }
  }
