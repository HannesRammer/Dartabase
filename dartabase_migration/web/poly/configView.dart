@HtmlImport('configView.html')
library dartabase.poly.configView;

import "dart:convert" show JSON;
import "dart:html";
import "dart:async";

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import "package:polymer_elements/iron_pages.dart";
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_dropdown_menu.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_checkbox.dart";
import 'package:polymer_elements/paper_radio_group.dart';
import 'package:polymer_elements/paper_radio_button.dart';
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";
import 'package:polymer_elements/iron_form.dart';

import "../poly/serverStatus.dart";
import "../poly/pm.dart";

@PolymerRegister('custom-config-view')
class ConfigView extends PolymerElement {
    @Property(notify: true)
    Project project;

    @Property(notify: true)
    String color;


    ConfigView.created() : super.created();

    @reflectable
    transition(event, [_]) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
    }

    @reflectable
    saveTransition(event, [_]) {
        HttpRequest request = new HttpRequest(); // create a new XHR
        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == HttpRequest.DONE &&
                    (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request
                        .responseText); // output the response from the server
                updateConfig(request.responseText);
            }
        });

        // POST the data to the server
        var url = "http://127.0.0.1:8079/saveConfig?config=${JSON.encode(project.config)}&projectRootPath=${project.path}";
        request.open("POST", url, async: false);
        //String jsonData = '{"config":${JSON.encode(project.config)},"projectRootPath":${project.path}}'; // etc...
        request.send(); // perform the async POST
    }

    updateConfig(String responseText) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
    }

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    isSecureConnection(ssl) {
        bool val = false;
        if (ssl == "true") {
            val = true;
        }
        if (ssl == true) {
            val = true;
        }
        return val;
    }

}
