import 'package:polymer/polymer.dart';

@CustomTag('custom-remove-migration-relation')
class RemoveMigrationRelation extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  RemoveMigrationRelation.created() : super.created();
}
