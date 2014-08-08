library configView;
import 'package:polymer/polymer.dart';

@CustomTag('custom-server-status')
class ServerStatus extends PolymerElement {
  @published String status;

  ServerStatus.created() : super.created();

}
