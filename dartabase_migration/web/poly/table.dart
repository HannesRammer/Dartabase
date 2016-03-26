import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

class Table extends JsProxy {
    @reflectable
    String name;
    @reflectable
    List columns;

    Table({this.name, this.columns});

}
