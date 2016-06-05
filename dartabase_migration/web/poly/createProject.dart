@HtmlImport('createProject.html')
library dartabase.poly.createProject;

import "dart:convert" show JSON;
import "dart:html" as dom;
import 'dart:async';
import 'package:material_paper_colors/material_paper_colors.dart' as MPC;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_pages.dart';
import "package:polymer_elements/paper_listbox.dart";
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
        "databse":"",
        "password":"",
        "port":"",
        "ssl":""
    };

    @Property(notify: true)
    String backgroundColor = MPC.Red["500"];
    @Property(notify: true)
    String color = MPC.RedT["500"][1];

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
        var url = "http://127.0.0.1:8079/initiateMigration?name=${name}&projectRootPath=${path}&config=${JSON.encode(config)}";
        var responseText = await dom.HttpRequest.getString(url);
        initiationCompleted(responseText);
    }

    initiationCompleted(responseText) {
        print(responseText.toString());
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.select("0");
    }

    @reflectable
    void clickHandler(dom.Event event, [_]) {
        (((Polymer.dom(event) as PolymerEvent).localTarget as dom.Element).parent as dom.FormElement).submit();
    }
    
}
