library configView;
import 'package:polymer/polymer.dart';
import "dart:html";
import "dart:convert" show JSON;
import "../poly/project.dart";
import "../poly/migration.dart";

@CustomTag('custom-config-view')
class ConfigView extends PolymerElement {
  @published Map config;

  ConfigView.created() : super.created();

}
