@HtmlImport('createProject.html')
library dartabase.poly.createProject;

import "dart:convert" show JSON;
import "dart:html" as dom;
import 'dart:async';


import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_pages.dart';
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_toast.dart";
import "package:polymer_elements/paper_dropdown_menu.dart";
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_checkbox.dart";
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_radio_group.dart';
import 'package:polymer_elements/paper_radio_button.dart';
import 'package:polymer_elements/iron_form.dart';

@PolymerRegister('custom-create-project')
class CreateProject extends PolymerElement {
    @Property(notify: true)
    String name;
    @Property(notify: true)
    String path;

    @Property(notify: true)
    Map config={"adapter":"",
                "username":"",
                "host":"",
        "database":"",
        "password":"",
        "port":"",
        "ssl":""
    };

    @Property(notify: true)
    String backgroundColor = "";
    @Property(notify: true)
    String color = "";

    CreateProject.created() : super.created();

    @reflectable
    toggleView(event, [_]) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();

    }

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    Future initiateMigration(dom.Event event, [_])  async{
        //String config = "&adapter=${adapter}&username=${username}&host=${password}&database=${database}&password=${password}&port=${port}&ssl${ssl}";
        var url = "http://127.0.0.1:8075/initiateMigration?name=${name}&projectRootPath=${path}&config=${JSON.encode(config)}";
        var responseText = await dom.HttpRequest.getString(url);
        generateSchema(event);
        generateModels(event);
        initiationCompleted(responseText);
    }

    @reflectable
    generateModels(dom.Event event, [_]) async{
        dom.HttpRequest request = new dom.HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == dom.HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
                //updateView(request.responseText);
            }
        });
        // POST the data to the server
        var url = "http://127.0.0.1:8075/generateModels?projectRootPath=${path}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    generateSchema(dom.Event event, [_]) async {
        dom.HttpRequest request = new dom.HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == dom.HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
                //updateView(request.responseText);
            }
        });
        // POST the data to the server
        var url = "http://127.0.0.1:8075/generateSchema?projectRootPath=${path}";
        request.open("POST", url);
        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    initiationCompleted(responseText) {
        print(responseText.toString());
        PaperToast pt = Polymer.dom($['toast1']).querySelector("#toast1");
        pt.text = responseText + "please reload the page if not reloaded automatically";

        pt.show(pt.text);
        dom.window.location.reload();

    }

    @reflectable
    void clickHandler(dom.Event event, [_]) {
        (((Polymer.dom(event) as PolymerEvent).localTarget as dom.Element).parent as dom.FormElement).submit();
    }
    
}
