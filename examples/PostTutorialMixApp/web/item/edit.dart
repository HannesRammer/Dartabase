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
 * requests object from db if id is provided 
 * in location search string.
 * then calls displayItem with response
*/
void main() {
  querySelector("#warning").remove();
  initPolymer().run(() {
    querySelector("#view_items").onClick.listen((e) => window.location.assign(itemsUrl));
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    params = loadParams(window);
    if(params['id'] != null){
      String id = params['id'];
      print("requesting item with $id");
      var url = "http://127.0.0.1:8090/$itemLoadUrl/$id";
      var request = HttpRequest.getString(url).then(displayEditItem);
    }
    else{
      content.text="no item id available";
    }
  });
}

/*
 * void displayEditItem(responseText)
 * 
 * transforms the json response into a map,
 * passing it to the created poly object
*/
void displayEditItem(String responseText) {
  Map item = JSON.decode(responseText);
  Element polyItem = new Element.tag('custom-item');
  polyItem.object = toObservable(item);
  polyItem.apperance = "edit";
  content.append(polyItem);
}