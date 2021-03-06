@HtmlImport("createMigration.html")
library dartabase.poly.createMigration;

import "dart:convert" show JSON;
import "dart:html" as dom;

import "package:web_components/web_components.dart" show HtmlImport;
import "package:polymer/polymer.dart";
import "package:polymer_elements/iron_pages.dart";
import "package:polymer_elements/iron_form.dart";
import "package:polymer_elements/paper_toast.dart";
import "package:polymer_elements/paper_button.dart";
import "package:polymer_elements/paper_material.dart";
import "package:polymer_elements/paper_input.dart";
import "package:polymer_elements/paper_tabs.dart";
import "package:polymer_elements/paper_tab.dart";
import "package:dev_string_converter/dev_string_converter.dart";
import "../poly/createMigrationTable.dart";
import "../poly/createMigrationColumn.dart";
import "../poly/createMigrationRelation.dart";
import "../poly/removeMigrationRelation.dart";
import "../poly/removeMigrationColumn.dart";
import "../poly/removeMigrationTable.dart";

import "../poly/pm.dart";

@PolymerRegister("custom-create-migration")
class CreateMigration extends PolymerElement {
    @Property(notify: true)
    Project project;

    @Property(notify: true)
    String color;

    @Property(notify: true)
    String newMigrationName;

    @Property(notify: true)
    List<Map> removeColumn;

    @Property(notify: true)
    List<Map> removeTable;
    @Property(notify: true)
    int editMode = 0;

    @Property(notify: true)
    List existingTableNames;
    @Property(notify: true)
    Map existingTables;

    @Property(notify: true)
    String cleanTime;

    CreateMigration.created() : super.created();

    void ready() {
        print("$runtimeType::ready()");
    }


    @reflectable
    transition(event, [_]) {
        IronPages ip = Polymer.dom(this.root).querySelector("iron-pages");
        ip.selectNext();
    }

    @reflectable
    doIt(name) {
        DateTime now = new DateTime.now();
        cleanTime = now.toString().split(".")[0].replaceAll(" ", "").replaceAll(":", "").replaceAll("-", "");
        set("project.migrationActions.generatedName", "${cleanTime}_${toTableName(name)}");
        return "${cleanTime}_${toTableName(name)}";
    }

    @reflectable
    createMigration(dom.Event event, [_]) async {
        dom.HttpRequest request = new dom.HttpRequest(); // create a new XHR

        // add an event handler that is called when the request finishes
        request.onReadyStateChange.listen((_) {
            if (request.readyState == dom.HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
                // data saved OK.
                print(request.responseText); // output the response from the server
                updateView(request.responseText);
            }
        });

        // POST the data to the server
        var url = "http://127.0.0.1:8075/createMigration?migrationActions=${Uri.encodeQueryComponent(JSON.encode(project.migrationActions))}&projectRootPath=${Uri.encodeQueryComponent(project.path)}";
        request.open("POST", url);

        request.send(); // perform the async POST
        await request.onLoadEnd.first;
    }

    @reflectable
    void clickHandler(dom.Event event, [_]) {
        (((Polymer.dom(event) as PolymerEvent).localTarget as dom.Element).parent as dom.FormElement).submit();
    }

    updateView(String responseText) {
        PaperToast pt = Polymer.dom($["toast1"]).querySelector("#toast1");
        pt.text = responseText;
        pt.show(pt.text);
        set("project.migrationActions", {
            "migrationName":"",

            "createTables": new List(),
            "createColumns":new List(),
            "createRelations":new List(),
            "removeTables":new List(),
            "removeColumns":new List(),
            "removeRelations":new List()
        });

        var paperButtons = Polymer.dom(this.root).querySelector(".hidden");
        if (paperButtons != null) {
            for (PaperButton pb in paperButtons) {
                pb.classes.toggle("hidden");
            }
        }

        print(responseText);
    }
}
