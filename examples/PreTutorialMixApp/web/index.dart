import 'dart:html';

void main() {
  querySelector("#view_list").onClick.listen((e) => window.location.assign("item/index.html"));
  querySelector("#view_inline_list").onClick.listen((e) => window.location.assign("item/index.html?inlineEdit=true"));
}


