import 'package:polymer/polymer.dart';

@CustomTag('custom-remove-migration-column')
class RemoveMigrationColumn extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  RemoveMigrationColumn.created() : super.created();
}
