import 'package:polymer/polymer.dart';
import "../poly/table.dart";
@CustomTag('custom-remove-migration-table')
class RemoveMigrationTable extends PolymerElement {
  @published Table table;
  @published Map colorPalette = toObservable({});
  @published List existingTableNames = toObservable([]);
     
  RemoveMigrationTable.created() : super.created();
}
