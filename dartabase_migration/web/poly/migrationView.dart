import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('custom-migration-view')
class MigrationView extends PolymerElement {
  @observable String name = "name";
  @observable String path = "path";
  @observable List tables = toObservable([]);
  @observable Map migration = toObservable({});
    
    
  MigrationView.created() : super.created();
  
}