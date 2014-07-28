import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-create-table')
class MigrationCreateTable extends PolymerElement {
  @published String tableName = "";
  @published Map columns = toObservable({});
  @published Map colorPalette = toObservable({});
  MigrationCreateTable.created() : super.created();
}
