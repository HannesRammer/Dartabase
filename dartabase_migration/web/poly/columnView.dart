import 'package:polymer/polymer.dart';

@CustomTag('custom-column-view')
class ColumnView extends PolymerElement {
  @observable String name = "default";
  @observable String type;
  @observable String def;
  @observable String nil;
  
  ColumnView.created() : super.created();
}
