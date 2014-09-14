import 'package:polymer/polymer.dart';
import "../poly/table.dart";
 

@CustomTag('custom-create-migration-table')
class CreateMigrationTable extends PolymerElement {
  @observable List<Table> createTables = toObservable([]);
    
  CreateMigrationTable.created() : super.created();
  
  @observable int editMode = 0;
  
  addTable(){
     Table table = new Table(columns:toObservable([]));
     table.columns.add(toObservable({}));
     createTables.add(table);
   }
  
  transition(e) {
      if (this.editMode == 0) {
        this.editMode = 1;
        
      } else {
        this.editMode = 0;
      }
    }
}
