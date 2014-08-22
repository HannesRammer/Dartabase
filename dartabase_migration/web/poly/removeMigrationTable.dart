import 'package:polymer/polymer.dart';

@CustomTag('custom-remove-migration-table')
class RemoveMigrationTable extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  RemoveMigrationTable.created() : super.created();
}
