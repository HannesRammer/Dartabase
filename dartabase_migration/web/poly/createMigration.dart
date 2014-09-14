library createMigration;
import 'package:polymer/polymer.dart';
import "../poly/project.dart";
import "../poly/table.dart";

@CustomTag('custom-create-migration')
class CreateMigration extends PolymerElement {
  @published Project project;
  @observable String newMigrationName = "";
  @observable List<Table> createColumn = toObservable([]);
  @observable List<Table> removeColumn = toObservable([]);
  
  @observable List<Table> removeTable = toObservable([]);
  @observable int editMode = 0;
  
  @observable List existingTableNames = toObservable([]);
  @observable Map existingTables = toObservable({});

  CreateMigration.created() : super.created();

  transition(e) {
    if (this.editMode == 0) {
      this.editMode = 1;
      
    } else {
      this.editMode = 0;
    }
  }
  
 
 
 addColumn(){
   Table table = toObservable(new Table());
     createColumn.add(table);
     existingTableNames = project.getTableNames();
  }
  
 addRemoveColumn(){
    Table table = toObservable(new Table());
       List columns = toObservable(new List());
            table.columns = columns;
      removeColumn.add(table);
      existingTables = project.tables;  
   }
 
 addRemoveTable(){
    Table table = toObservable(new Table());
      removeTable.add(table);
      existingTableNames = project.getTableNames(); 
   }
  
 createMigration(){
   Map up = {"UP":{}};
   Map down = {"DOWN":{}};
 }
 
}
