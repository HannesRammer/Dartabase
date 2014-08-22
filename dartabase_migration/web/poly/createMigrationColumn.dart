import 'package:polymer/polymer.dart';

@CustomTag('custom-create-migration-column')
class CreateMigrationColumn extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  
  CreateMigrationColumn.created() : super.created();
}
