
import "package:polymer/polymer.dart";
import "package:web_components/web_components.dart";

class Table extends JsProxy {
    @reflectable
    String name;
    @reflectable
    List columns;

    Table({this.name, this.columns});

}
