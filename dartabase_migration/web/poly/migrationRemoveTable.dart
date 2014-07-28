import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-remove-table')
class MigrationRemoveTable extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  MigrationRemoveTable.created() : super.created();
}
