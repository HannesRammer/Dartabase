@HtmlImport('serverStatus.html')
library dartabase.poly.serverStatus;

// Import the Polymer and Web Components scripts.
import 'package:polymer_elements/paper_material.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

@PolymerRegister('custom-server-status')
class ServerStatus extends PolymerElement {
    @Property(notify: true)
    String status;
    @Property(notify: true)
    String adapter = null;

    ServerStatus.created() : super.created();

}
