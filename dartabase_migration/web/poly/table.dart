library dartabase.poly.table;
import 'package:polymer/polymer.dart';

class Table extends Observable {
  @observable String name = "";
  @observable List columns = toObservable([]);

  Table({this.name,this.columns});

}
