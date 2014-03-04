import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import '../../lib/paths.dart';
import '../../lib/params.dart';

DivElement content = querySelector("#content");

Map params = {};
  
/*
 * void main()
 * 
 * displays form to create a new object
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    querySelector("#view_items").onClick.listen((e) => window.location.assign(itemsUrl));
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    params = loadParams(window);
    Element polyItem = new Element.tag('custom-item');
    polyItem.apperance = "edit";
    content.append(polyItem);
  });
}

