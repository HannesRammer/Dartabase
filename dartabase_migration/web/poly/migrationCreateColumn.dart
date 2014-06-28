import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('custom-migration-create-column')
class MigrationCreateColumn extends PolymerElement {
  @observable String name = "name";
  @observable String path = "path";
  @published Map table = toObservable({});
    
    
  MigrationCreateColumn.created() : super.created();
  
  
  
  
}