import 'package:polymer/polymer.dart';
import '../poly/project.dart';
import '../poly/migration.dart';

@CustomTag('custom-migration-view')
class MigrationView extends PolymerElement {
  @published Migration migration =toObservable(new Migration());
  @observable Project project=toObservable(new Project());


  MigrationView.created() : super.created();

}
