import 'package:polymer/polymer.dart';
import "../poly/table.dart";
import "../poly/project.dart";

@CustomTag('custom-remove-migration-column')
class RemoveMigrationColumn extends PolymerElement {
   @published Project project;
   @published Table table;
   @published Map existingTables= toObservable({});
   @published Map existingColumns= toObservable({});
   
   RemoveMigrationColumn.created() : super.created();
   
   void addColumn(){
      if(table.columns == null){
        table.columns=toObservable({});  
      }
      table.columns.add(toObservable([]));
      print(2);
    }
   
   void updateColumns(event, detail, target){
     print(2);
   }
}
