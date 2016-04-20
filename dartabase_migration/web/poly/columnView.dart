@HtmlImport('columnView.html')
library dartabase.poly.columnView;

// Import the paper element from Polymer.
import'package:polymer_elements/paper_material.dart';
import'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_button.dart';
import "../poly/table.dart";

// Import the Polymer and Web Components scripts.
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

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

    @property
    Map column;

    @property
    Table createTable;

    void ready() {
        print("$runtimeType::ready()");
    }


    @reflectable
    void addColumn(event, [_]) {
        if (createTable.columns == null) {
            createTable.columns = [];
            print("columnView.dart COLUMNS NOT INITIALIZES CORRECT");
        }
        createTable.columns.add({});
    }
}


