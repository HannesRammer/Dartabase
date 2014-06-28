import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('custom-migration-create-table')
class MigrationCreateTable extends PolymerElement {
  @observable String name = "name";
  @observable String path = "path";
  @published Map table = toObservable({});
    
    
  MigrationCreateTable.created() : super.created();
  
  
  
  
}