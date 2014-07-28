import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-remove-column')
class MigrationRemoveColumn extends PolymerElement {
  @published String tableName = "";
  @published List columns = toObservable([]);
  @published Map colorPalette = toObservable({});
  MigrationRemoveColumn.created() : super.created();
}
