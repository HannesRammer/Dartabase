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
    String need;

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
    var column;

    void ready() {
        print("$runtimeType::ready()");
    }

    @reflectable
    isHeader(name) {
        bool val = false;
        if (name == "header") {
            val = true;
        }
        return val;
    }
    @reflectable
    isView(name) {
        bool val = false;
        if (name == "view") {
            val = true;
        }
        return val;
    }
    @reflectable
    isInput(name) {
        bool val = false;
        if (name == "input") {
            val = true;
        }
        return val;
    }
    @reflectable
    isAuto(name) {
        bool val = false;
        if (name == "auto") {
            val = true;
        }
        return val;
    }
    @reflectable
    isDetail(name) {
        bool val = false;
        if (name == "detail") {
            val = true;
        }
        return val;
    }

    @reflectable
    checkType(current,expected) {
        return current == expected;
    }
}


