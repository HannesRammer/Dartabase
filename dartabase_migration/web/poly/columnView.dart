import 'package:polymer/polymer.dart';
import "../poly/table.dart";
@CustomTag('custom-column-view')
class ColumnView extends PolymerElement {
  @observable List dbTypes = ["BINT",
              "BINT UNSIGNED",
              "BINARY",
              "BIT",
              "BLOB",
              "BOOLEAN",
              "BYTEARRAY",
              "CHAR",
              "DATE",
              "DATETIME",
              "DOUBLE",
              "FLOAT",
              "FLOAT UNSIGNED",
              "INT",
              "INT",
              "INT UNSIGNED",
              "LBLOB",
              "LTEXT",
              "MBLOB",
              "MINT",
              "MINT UNSIGNED",
              "MTEXT",
              "SINT",
              "SINT UNSIGNED",
              "TEXT",
              "TIME",
              "TIMESTAMP",
              "TBLOB",
              "TINT",
              "TINT UNSIGNED",
              "TTEXT",
              "VARBINARY",
              "VARCHAR"];
  @observable Map column = toObservable({});
  @published Table createTable;
  ColumnView.created() : super.created();
  
  
  void addColumn(){
      if(createTable.columns == null){
        createTable.columns=toObservable([]);
        print("columnView.dart COLUMNS NOT INITIALIZES CORRECT");
      }
      createTable.columns.add(toObservable({}));
    }
}


