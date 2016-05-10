@HtmlImport('columnView.html')
library dartabase.poly.columnView;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import'package:polymer_elements/paper_material.dart';
import'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_button.dart';

@PolymerRegister('custom-column-view')
class ColumnView extends PolymerElement {

    ColumnView.created() : super.created();

    @property
    List dbTypes = ["BINT",
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
    "VARCHAR"
    ];

    @Property(notify:true)
    Map column;

    void ready() {
        print("$runtimeType::ready()");
    }
}


