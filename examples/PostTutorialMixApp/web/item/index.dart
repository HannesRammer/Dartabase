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
    params = loadParams(window);
    querySelector("#home").onClick.listen((e) => window.location.assign(homeUrl));
    querySelector("#create").onClick.listen((e){ 
      if(params["inlineEdit"]=="true"){
        appendInlineEmptyItem();
      }else{
        window.location.assign(itemCreateUrl);
      }
    });
    print("Request List");
    var url = "http://127.0.0.1:8090/$itemsLoadUrl";
    var request = HttpRequest.getString(url).then(displayList);
  });
}

/*
 * void displayItem(responseText)
 * 
 * transforms the json response into a map,
 * passing it to the created poly object
*/
void displayList(responseText) {
  List items = JSON.decode(responseText);
  Element polyItemHeader = new Element.tag('custom-item');
  polyItemHeader.apperance = "header";
  if(params["inlineEdit"] == "true"){
    polyItemHeader.inlineEdit = true;
  }
  
  content.append(polyItemHeader);
        
  items.forEach((item){
    Element polyItem = new Element.tag('custom-item');
    polyItem.object = item;
    polyItem.apperance = "index";
    if(params["inlineEdit"] == "true"){
      polyItem = setInlineEditOption(polyItem);
    }
    content.append(polyItem);
  });
}

Element setInlineEditOption(polyItem){
  polyItem.inlineEdit = true;
  polyItem.onClick.listen((event){ 
    if(polyItem.apperance == "index"){
      polyItem.apperance = "edit";
      polyItem.title="click to edit!";  
    }
  });
  return polyItem;
}

void appendInlineEmptyItem(){
  Element polyItem = new Element.tag('custom-item');
  polyItem.apperance = "create";
  polyItem = setInlineEditOption(polyItem);
  content.append(polyItem);
}


