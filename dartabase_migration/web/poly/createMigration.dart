library createMigration;
import 'package:polymer/polymer.dart';
import "../poly/project.dart";
import "../poly/table.dart";

@CustomTag('custom-create-migration')
class CreateMigration extends PolymerElement {
  @published Project project = toObservable(new Project());
  @observable String newMigrationName = "";
  @observable List<Table> upCreateTable = toObservable([]);
  @observable int editMode = 0;

  CreateMigration.created() : super.created();

  transition(e) {
    if (this.editMode == 0) {
      this.editMode = 1;
      
    } else {
      this.editMode = 0;
    }
  }
  
 createTable(){
   Table table = new Table();
   List columns = new List();
   table.columns = columns;
   upCreateTable.add(table);
 }
}
