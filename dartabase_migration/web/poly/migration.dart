library dartabase.poly.migration;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;

class Migration extends Observable {
  final num index;
  final String version;
  @observable Map colorPalette;
  @observable Map actions;
  @observable String state;

  Migration({this.index, this.version,this.colorPalette, this.actions, this.state});

}
