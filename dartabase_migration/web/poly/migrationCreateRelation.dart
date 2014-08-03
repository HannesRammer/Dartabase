import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-create-relation')
class MigrationCreateRelation extends PolymerElement {
  @published List relations = toObservable([]);
  @published Map colorPalette = toObservable({});
  MigrationCreateRelation.created() : super.created();
}
