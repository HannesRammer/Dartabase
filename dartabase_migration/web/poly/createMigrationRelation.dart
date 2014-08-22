import 'package:polymer/polymer.dart';

@CustomTag('custom-create-migration-relation')
class CreateMigrationRelation extends PolymerElement {
  @published String table = "";
  @published Map colorPalette = toObservable({});
  CreateMigrationRelation.created() : super.created();
}
