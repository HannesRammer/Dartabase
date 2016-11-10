@HtmlImport("scaffoldView.html")
library dartabase.poly.scaffoldView;

import "dart:convert" show JSON;
import "dart:html";
import "dart:async";

import "package:web_components/web_components.dart" show HtmlImport;
import "package:polymer/polymer.dart";
import "package:polymer_elements/iron_pages.dart";
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_dropdown_menu.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_checkbox.dart";
import "package:polymer_elements/paper_radio_group.dart";
import "package:polymer_elements/paper_radio_button.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";
import "package:polymer_elements/iron_form.dart";

import "../poly/serverStatus.dart";
import "../poly/pm.dart";

@PolymerRegister("custom-scaffold-view")
class ScaffoldView extends PolymerElement {
    @Property(notify: true)
    Project project;

    @Property(notify: true)
    String color;


    ScaffoldView.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    generateModels(Event event, [_]) async{
        HttpRequest request = new HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
            }
        });
        var url = "http://127.0.0.1:8075/generateModels?projectRootPath=${Uri.encodeQueryComponent(project.path)}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    generateSchema(Event event, [_]) async {
        HttpRequest request = new HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
            }
        });
        var url = "http://127.0.0.1:8075/generateSchema?projectRootPath=${Uri.encodeQueryComponent(project.path)}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    generateViews(Event event, [_]) async {
        HttpRequest request = new HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
            }
        });
        var url = "http://127.0.0.1:8075/generateViews?projectRootPath=${Uri.encodeQueryComponent(project.path)}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    generateServer(Event event, [_]) async{
        HttpRequest request = new HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
            }
        });
        var url = "http://127.0.0.1:8075/generateServer?projectRootPath=${Uri.encodeQueryComponent(project.path)}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    generateAll(Event event, [_]) async{
        await generateSchema(event);
        await generateModels(event);
        await generateViews(event);
        await generateServer(event);
    }

    @reflectable
    transition(event, [_]) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
    }
}
