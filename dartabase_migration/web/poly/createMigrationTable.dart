import 'package:polymer/polymer.dart';
import "../poly/table.dart";

@CustomTag('custom-create-migration-table')
class CreateMigrationTable extends PolymerElement {
  @published Table table;
  @observable List columns = toObservable([]);
  CreateMigrationTable.created() : super.created();
  
  void addColumn(){
    if(table.columns == null){
      table.columns=[];  
    }
    table.columns.add(toObservable([]));
    columns.add(toObservable([]));
  }
}
