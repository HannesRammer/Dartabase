@HtmlImport('serverStatus.html')
library dartabase.poly.serverStatus;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_material.dart';

@PolymerRegister('custom-server-status')
class ServerStatus extends PolymerElement {
    @property
    String status;
    @property
    String adapter;

    ServerStatus.created() : super.created();

    @reflectable
    bool isRunning(status) {
        return status == "running";
    }

    void ready() {
        print("$runtimeType::ready()");
    }

}
