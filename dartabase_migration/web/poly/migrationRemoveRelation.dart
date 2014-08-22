import 'package:polymer/polymer.dart';

@CustomTag('custom-migration-remove-relation')
class MigrationRemoveRelation extends PolymerElement {
  @published List relations = toObservable([]);
  @published Map colorPalette = toObservable({});
  MigrationRemoveRelation.created() : super.created();
}
