import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-create-column')
class MigrationCreateColumn extends PolymerElement {
  @published String tableName = "";
  @published Map columns = toObservable({});
  @published Map colorPalette = toObservable({});
  MigrationCreateColumn.created() : super.created();
}
