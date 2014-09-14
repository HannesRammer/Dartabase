import 'package:polymer/polymer.dart';
import "../poly/table.dart";
import "../poly/project.dart";

@CustomTag('custom-create-migration-column')
class CreateMigrationColumn extends PolymerElement {
   @published Project project;
   @published Table table;
   @published List existingTableNames;
   
   CreateMigrationColumn.created() : super.created();
   
   void addColumn(){
      if(table.columns == null){
        table.columns=toObservable([]);  
      }
      table.columns.add(toObservable([]));
    }
}
