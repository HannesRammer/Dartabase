@HtmlImport('text_effect.html')
library dartabase.poly.textEffect;

import "dart:convert" show JSON;
import "dart:html" as dom;
import "dart:math";
import 'dart:async';
import 'package:material_paper_colors/material_paper_colors.dart' as MPC;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_pages.dart';
import "package:polymer_elements/paper_listbox.dart";
import "package:polymer_elements/paper_toast.dart";
import "package:polymer_elements/paper_dropdown_menu.dart";
import "package:polymer_elements/paper_item.dart";
import "package:polymer_elements/paper_checkbox.dart";
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_radio_group.dart';
import 'package:polymer_elements/paper_radio_button.dart';
import 'package:polymer_elements/iron_form.dart';

@PolymerRegister('custom-text-effect')
class TextEffect extends PolymerElement {
    @Property(notify: true)
    num width = 5;

    num opacity = 0.0;
    List array = [];
    List hLines = [];
    List vLines = [];
    List b1 = ["loop", "line", "box"];
    List b2 = ["loop", "line", "box"];

    TextEffect.created() : super.created();

    @reflectable
    void clickHandler(dom.Event event, [_]) {
        (((Polymer.dom(event) as PolymerEvent).localTarget as dom.Element).parent as dom.FormElement).submit();
    }

    @reflectable
    void createHorizontalLine(num startPosX, num startPosY, num size, num hTravelDistance, color, String behaviour, String direction) {
        var id = hLines.length;

        dom.DivElement hLinesDiv = new dom.DivElement();
        //var hLinesDiv = document.createElement("div");
        hLinesDiv.setAttribute("id", "hLineContainer_${id}");
        hLinesDiv.style.position = "absolute";
        hLinesDiv.style.left = "${startPosX}px";
        //hLinesDiv.style.top = startPosY}px";
        dom.DivElement div = new dom.DivElement();
        div.setAttribute("class", "hLine");
        div.setAttribute("id", "hLine_${id}");
        div.style.height = "${width}px";
        div.style.transition = "3s"; //NEW
        div.style.width = "0px";
        div.style.position = "absolute";
        div.style.left = "0px";
        div.style.top = "${startPosY}px";
        setHorizontalLineColor(div, color);

        dom.DivElement editor = new dom.DivElement();

        editor.setAttribute("id", "hEditor_${id}");
        editor.setAttribute("class", "editor");
        if (behaviour == "once") {
            editor.setAttribute("style", "position:absolute;top:0px;opacity:0;");
        } else {
            editor.setAttribute("style", "position:absolute;top:0px;opacity:1;");
        }

        dom.DivElement hStartPoint = new dom.DivElement();

        hStartPoint.setAttribute("id", "hStartPoint_${id}");
        hStartPoint.setAttribute("class", "hStartPoint");

        hStartPoint.setAttribute("style", "background:#00ffff;width:${width}px;height:${width}px;position:absolute;left:${startPosX}px;top:${startPosY}px;");

        dom.DivElement hCrossLine = new dom.DivElement();


        hCrossLine.setAttribute("id", "hCrossLine_${id}");
        hCrossLine.setAttribute("class", "hCrossLine");
        //console.log(hTravelDistance}_${size);
        if (direction == "left") {
            hCrossLine.setAttribute("style", "background:#00ffff;height:${width}px;position:absolute;left:${(startPosX - hTravelDistance + width)}px;top:${startPosY}px;width:${(hTravelDistance -
                    width)}px;opacity:0.2;z-index:999;");
        } else if (direction == "right") {
            hCrossLine.setAttribute(
                    "style", "background:#00ffff;height:${width}px;position:absolute;left:${(startPosX + width)}px;top:${startPosY}px;width:${(hTravelDistance - width)}px;opacity:0.2;z-index:999;");
        }
        if (behaviour != "once") {
            hCrossLine.onMouseOver.listen((dom.MouseEvent e) {
                num mouseX = e.page.x;
                num mouseY = e.page.y;
                //var pageCoords = "( ${e.pageX}, ${e.pageY} )";
                //var clientCoords = "( ${e.clientX}, ${e.clientY} )";
                PaperMaterial pm = Polymer.dom(this.root).querySelector("paper-material");
                num hSX = num.parse(pm.style.left.split("px")[0]);
                num hSY = num.parse(pm.style.top.split("px")[0]);
                num hEX = num.parse(pm.style.left.split("px")[0]) + num.parse(pm.style.width.split("px")[0]);
                num hEY = num.parse(pm.style.top.split("px")[0]) + num.parse(pm.style.height.split("px")[0]);

                num crossSize = num.parse(pm.style.width.split("px")[0]);
                num travelRight;
                num travelLeft;
                //console.log("MouseX${mouseX);
                //console.log("hSX${hSX);
                //console.log("hEX${hEX);

                if (direction == "left") {
                    travelRight = hSX - mouseX;
                    travelLeft = mouseX - hEX - width;
                } else if (direction == "right") {
                    travelRight = hEX - mouseX;
                    travelLeft = crossSize - travelRight;
                }
                createHorizontalLine(
                        mouseX,
                        hSY,
                        (size / 2),
                        travelLeft,
                        "rgb(255,0,0)",
                        "once",
                        "left");
                createHorizontalLine(
                        mouseX,
                        hSY,
                        (size / 2),
                        travelRight,
                        "rgb(255,0,0)",
                        "once",
                        "right");
            });
        }

        dom.DivElement hEndPoint = new dom.DivElement();

        hEndPoint.setAttribute("id", "hEndPoint_${id}");
        hEndPoint.setAttribute("class", "hEndPoint");
        var style;

        if (direction == "left") {
            hEndPoint.setAttribute("style", "background:#ff00ff;width:${width}px;height:${width}px;position:absolute;left:${(startPosX - hTravelDistance)}px;top:${startPosY}px;");
        } else if (direction == "right") {
            hEndPoint.setAttribute("style", "background:#ff00ff;width:${width}px;height:${width}px;position:absolute;left:${(startPosX + hTravelDistance)}px;top:${startPosY}px;");
        }

        editor.append(hStartPoint);
        editor.append(hCrossLine);
        editor.append(hEndPoint);

        hLinesDiv.append(div);
        var root = Polymer.dom(this.root);

        root.append(hLinesDiv);
        root.append(editor);

        hLines.add(id);


        animateHorizontalLine(id, size, color, behaviour, direction);
    }

    @reflectable
    void setHorizontalLineColor(div, color) {
        String rgb = rgbString2NumbersString(color);
        String rgba = "rgba(${rgb},0.0) , rgba(${rgb},0.5) ,rgba(${rgb},0.0)";
        div.style.backgroundImage = "linear-gradient(to right , ${rgba})";
        /* W3C */
        div.style.backgroundImage = "-webkit-gradient(linear, top left, top right, color-stop(${rgb}), color-stop(${rgb}),color-stop(${rgb}))";
        /* Chrome,Safari4+ */
        div.style.backgroundImage = "-webkit-linear-gradient(left , ${rgba})";
        /* Chrome10+,Safari5.1+ */
        div.style.backgroundImage = "-moz-linear-gradient(left , ${rgba})";
        /* FF3.6+ */
        div.style.backgroundImage = "-ms-linear-gradient(left, ${rgba})";
        /* IE10+ */
        div.style.backgroundImage = "-o-linear-gradient(left , ${rgba})";
        /* Opera 11.10+ */
        div.style.filter = "progid:DXImageTransform.Microsoft.gradient( startColorstr=${color}, endColorstr=${color},GradientType=0 )";
        /* IE6-9 */
    }

    ///////////////////////////////////////
    @reflectable
//converts string 'rgb(0,0,0)' to string '0,0,0'
    String rgbString2NumbersString(String rgb) {
        return rgb.split("(")[1].split(")")[0];
    }

    @reflectable
    num getDistance(num startPos, num endPos, num size) {
        if (endPos > startPos) {
            return (endPos - startPos - size);
        } else {
            return (startPos - endPos - size);
        }
    }

// animate LinesContainer
    @reflectable
    void animateHorizontalLine(id, size, color, behaviour, direction) {
        PaperMaterial pm = Polymer.dom(this.root).querySelector("paper-material");
        num startPosX = num.parse(pm.style.left.split("px")[0]);
        num startPosY = num.parse(pm.style.top.split("px")[0]);
        num endPosX = num.parse(pm.style.left.split("px")[0]) + num.parse(pm.style.width.split("px")[0]);
        num endPosY = num.parse(pm.style.top.split("px")[0]) + num.parse(pm.style.height.split("px")[0]);
        num hTravelDistance = getDistance(startPosX, endPosX, size);

        querySelector("#hLine_${id}").style.top = "${startPosY}px";

        querySelector("#hLineContainer_${id}").style.left = "${startPosX}px";
        querySelector("#hLineContainer_${id}").style.top = "0";

        var hArray = [];
        num parseNum = num.parse(querySelector("#hLine_${id}").style.left.split("px")[0]);
        if (direction == "left") {
            querySelector("#hLine_${id}").style.width = "${size}px";
            querySelector("#hLine_${id}").style.left = "${ parseNum - size}px";


            querySelector("#hLineContainer_${id}").style.left = "${num.parse(querySelector("#hLineContainer_${id}").style.left.split("px")[0]) - hTravelDistance}px";

            querySelector("#hLine_${id}").style.width = "0px";
            num resetPos;
            if (direction == "left") {
                if (behaviour == "toggle") {
                    resetPos = parseNum - hTravelDistance;
                } else {
                    resetPos = parseNum + size;
                }
            } else if (direction == "right") {
                if (behaviour == "toggle") {
                    resetPos = parseNum + hTravelDistance;
                } else {
                    resetPos = parseNum - size;
                }
            }
            checkHorizontalBehaviour(id, resetPos, size, color, behaviour, direction);
        } else if (direction == "right") {
            hArray.add({"width": "0px", "left": "+=${size}px"});
            querySelector("#hLine_${id}").style.width = "${size}px";
            querySelector("#hLineContainer_${id}").style.left = "${num.parse(querySelector("#hLineContainer_${id}").style.left.split("px")[0]) + hTravelDistance}px";

            querySelector("#hLine_${id}").style.width = "0px";
            querySelector("#hLine_${id}").style.left = "${num.parse(querySelector("#hLine_${id}").style.left.split("px")[0]) + size}px";

            num resetPos;
            if (direction == "left") {
                if (behaviour == "toggle") {
                    resetPos = parseNum - hTravelDistance;
                } else {
                    resetPos = parseNum + size;
                }
            } else if (direction == "right") {
                if (behaviour == "toggle") {
                    resetPos = parseNum + hTravelDistance;
                } else {
                    resetPos = parseNum - size;
                }
            }
            checkHorizontalBehaviour(id, resetPos, size, color, behaviour, direction);
        }
    }

    @reflectable
    void checkHorizontalBehaviour(id, resetPos, size, color, behaviour, direction) {
        querySelector("#hLine_${id}").style.left = "${resetPos}px";
        if (behaviour == "loop") {
            animateHorizontalLine(id, size, color, behaviour, direction);
        } else if (behaviour == "line") {

        }
        else if (behaviour == "once") {
            querySelectorAll("#hLineContainer_${id}")[0].remove();
            querySelectorAll("#hEditor_${id}")[0].remove();
            var index = hLines.indexOf(id);
            hLines.removeAt(index);
        } else if (behaviour == "toggle") {
            if (direction == "left") {
                animateHorizontalLine(id, size, color, "toggle", "right");
            } else if (direction == "right") {
                animateHorizontalLine(id, size, color, "toggle", "left");
            }
        }
    }

    @reflectable
    void toggleEditor() {
        if (querySelectorAll(".editor")[0] != null) {
            if (querySelector(".editor").style.opacity == "0") {
                querySelector(".editor").style.opacity = "1";
            }
            else if (querySelector(".editor").style.opacity == "1") {
                querySelector(".editor").style.opacity = "0";
            }
        }
    }

    void ready() {
        print("$runtimeType::ready()");
        addBorderToObject("line");
    }

    @reflectable
    void addBorderToObject(behaviour) {
        PaperMaterial element = querySelector("paper-material");
        //function (index) {
        var borderColor = "rgb(255,0,0)";


        num itemX = num.parse(element.style.left.split("px")[0]);
        num itemY = num.parse(element.style.top.split("px")[0]);
        num itemHeight = num.parse(element.style.height.split("px")[0]);
        num itemWidth = num.parse(element.style.width.split("px")[0]);
//            createHorizontalLine(itemX - width, itemY, (itemWidth / 3), itemWidth + width, "rgb(0,255,255)", behaviour, "right");
        createHorizontalLine(
                itemX,
                itemY - 2,
                (itemWidth / 3),
                itemWidth + (2 * width),
                borderColor,
                behaviour,
                "right");
        createHorizontalLine(
                itemX + itemWidth + (2 * width),
                itemY + itemHeight + 4 + width,
                (itemWidth / 3),
                itemWidth + (2 * width),
                borderColor,
                behaviour,
                "left");
        //createHorizontalLine(itemX, itemY + itemHeight - width, (itemWidth / 3), itemWidth, "rgb(0,255,255)", "cross", "left");
    }
}

/*querySelector("body").mousemove(function (e) {
     var mouseX = e.pageX;
     var mouseY = e.pageY;
     var mouseCX = e.clientX;
     var mouseCY = e.clientY;
     console.log(mouseX+"_MP_"+mouseY);
     console.log(mouseCX+"_MC_"+mouseCY);

     });
     */

