library configView;
import 'package:polymer/polymer.dart';

@CustomTag('custom-server-status')
class ServerStatus extends PolymerElement {
  @published String status;
  @published String adapter = null;

  ServerStatus.created() : super.created();

}
