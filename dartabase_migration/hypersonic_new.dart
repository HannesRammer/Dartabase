import 'dart:io';
import 'dart:math';

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/
String currentBox = "-1 -1";

void main() {
    List inputs;
    inputs = stdin.readLineSync().split(' ');
    int width = int.parse(inputs[0]);
    int height = int.parse(inputs[1]);
    int myId = int.parse(inputs[2]);
    int myX = int.parse(inputs[2]);
    int myY = int.parse(inputs[2]);
    int sx = myX;
    int sy=myY;
    int myRange = 0;
    String pos = "";
    List securePositions;
    String currentGoal = "-1 -1";
    List doneBoxes = [];
    String word = "";
    int bombsLeft = 0;

    // game loop
    int countdown = 0;
    while (true) {
        securePositions = [];
        //stderr.writeln('1currentGoal:$currentGoal myX:$myX myY:$myY');
        if (countdown > 0) {
            //stderr.writeln("countdown:$countdown");
            countdown--;
        }
        List boxes = [];
        List items = [];
        List walls = [];
        for (int i = 0; i < height; i++) {
            String row = stdin.readLineSync();
            for (int j = 0; j < row.length; j++) {
                String letter = row[j];
                if ((letter == "0" || letter == "1" || letter == "2") && !doneBoxes.contains("${j} ${i}")) {
                    boxes.add("${j} ${i}");
                    //walls.add("${j} ${i}");
                }
                if ((letter == "X" )) {
                    walls.add("${j} ${i}");
                }
                if ((letter == "." )) {
                    securePositions.add("${j} ${i}");
                }
            }
            //stderr.writeln('row: $row');
        }
        //update free way before removal of dead bomb area
        securePositions = getFreeWay(myX, myY, walls, securePositions);
        //stderr.writeln('boxes:$boxes');
        stderr.writeln('securePositions AFTER FREEWAY:$securePositions');
        int entities = int.parse(stdin.readLineSync());

        List bombs = [];

        //update  and act up on Entities
        for (int i = 0; i < entities; i++) {
            inputs = stdin.readLineSync().split(' ');
            //stderr.writeln('$inputs');
            int entityType = int.parse(inputs[0]);
            int owner = int.parse(inputs[1]);
            int x = int.parse(inputs[2]);
            int y = int.parse(inputs[3]);
            int param1 = int.parse(inputs[4]);
            int range = int.parse(inputs[5]);
            if (entityType == 2) {
                // is item
                if (!items.contains("$x $y")) {
                    items.add("$x $y");
                }
            }
            if (entityType == 1 /*&& owner == myId*/) {
                // is bomb
                if (!bombs.contains("$x $y")) {
                    bombs.add("$x $y");
                    //stderr.writeln('2bombs : $bombs');
                }
                //remove bomb area from secure locations
                stderr.writeln('bomb :"$x $y"');
                stderr.writeln('range :$range');
                stderr.writeln('range :$range');
                stderr.writeln('securePositions DURING Bomb:$securePositions');


                securePositions = removeDmgAreaFromSecureLocations(x, y, range, securePositions);
                stderr.writeln('2securePositions DURING Bomb:$securePositions');
            }
            if (entityType == 0 && owner == myId) {
                // is me
                myX = x;
                myY = y;
                myRange = range;
                bombsLeft = param1;
            }
        }
        // stderr.writeln('securePositions:$securePositions');
        //stderr.writeln('doneBoxes.contains(currentBox):${doneBoxes.contains(currentBox)}');
        stderr.writeln('securePositions AFTER Bomb:$securePositions');
        //securePositions = getFreeWay(myX, myY, bombs, securePositions);
        stderr.writeln('2securePositions AFTER Bomb:$securePositions');
        //decide if move or bomb

        //stderr.writeln('#################### START BOT #####################');
        //start bot
        String box;
        String item;
        String text;


        String bombPosition;
        String closestPosition;
        var action;
//stderr.writeln("myX:$myX myY:$myY currentGoal:$currentGoal countdown : ${countdown} !doneBoxes.contains(currentBox):${!doneBoxes.contains(currentBox)}-");
        if (("$myX $myY" != "$sx $sy" && "$myX $myY" == currentGoal && !doneBoxes.contains(currentBox))) {
            action = "bomb";
            word = "BOMB";
            countdown = 8;
            doneBoxes.add(currentBox);
//            boxes.remove(currentBox);

            currentGoal = "";
            //securePositions = removeDmgAreaFromSecureLocations(myX, myY, myRange, securePositions);
        } else {
            action = "move";
            word = "MOVE";
        }


        // if ( countdown == 0) {
        if ( boxes.isNotEmpty) {
            //                  stderr.writeln('boxes exist');
            //
            stderr.writeln('2securePositions:$securePositions');
            bombPosition = getBombGoal(boxes, myX, myY, myRange, doneBoxes, securePositions);
            currentGoal = bombPosition;
            stderr.writeln('BOMB POSITION: $bombPosition');


            if(currentGoal =="" || currentGoal== null){
                currentGoal = getClosestCoordinates(securePositions, myX, myY);
            }

            stderr.writeln('BOMB POSITION: $currentGoal');
        }else  {
            closestPosition = getClosestCoordinates(securePositions, myX, myY);
            stderr.writeln('secure : myX:$myX myY:$myY');
            currentGoal = closestPosition;
        }
        //}

        //stderr.writeln('decide if move or bomb: $action');

        //stderr.writeln("bombs-----------------:$bombs");
        text = '$word ${currentGoal}';
        //stderr.writeln(text);
        print('$text');
        //print('MOVE 0 1');
    }
}

String getBombGoal(List boxes, int myX, int myY, int range, List doneBoxes, List securePositions) {
    String box = getClosestCoordinates(boxes, myX, myY);
    stderr.writeln('BOX: $box');
    stderr.writeln('3securePositions:$securePositions');
    currentBox = box;

    stderr.writeln('$range, $doneBoxes, $securePositions, $myX, $myY');
    stderr.writeln('$doneBoxes');
    stderr.writeln(' $securePositions');
    stderr.writeln(' $myX, $myY');
    //String pos = getBestPositionForBomb(box, boxes, range, walls, securePositions, myX, myY);
    String pos = getFastPositionForBomb(box, boxes, range, doneBoxes, securePositions, myX, myY);
    return pos;
}

String getClosestCoordinates(List boxes, int x, int y) {
    //stderr.writeln('-----------getClosestBox-----------');
    String closestBox = "";
    for (int i = 0; i < boxes.length; i++) {
        String box = boxes[i];
        //stderr.writeln('box: $box');
        if (i == 0) {
            closestBox = box;
        } else {
            int bx = int.parse(box.split(" ")[0]);
            int by = int.parse(box.split(" ")[1]);
            int cbx = int.parse(closestBox.split(" ")[0]);
            int cby = int.parse(closestBox.split(" ")[1]);
            num currentDistance = getDistance(cbx, cby, x, y);
            num nextDistance = getDistance(bx, by, x, y);
            //stderr.writeln('currentDistance:$currentDistance');
            if (nextDistance < currentDistance) {
                closestBox = box;
            }
        }
    }
    //stderr.writeln('closestBox:-$closestBox-');
    return closestBox;
}

double getDistance(int xA, int yA, int xB, int yB) {
    return sqrt((pow((xA - xB), 2) + pow((yA - yB), 2)));
}

String getBestPositionForBomb(String box /*[x,y]*/, List boxes, int range, List walls, List secPos, myX, myY) {
    //stderr.writeln('-----------getBestPositionForBomb-box:$box-$range-$walls----');
    int bx = int.parse(box.split(" ")[0]);
    int by = int.parse(box.split(" ")[1]);
    int bestCount = 0;
    String bestPos = "${bx} ${by}";
    //get  all surrounding points in bomb range
    for (int i = 1; i < range; i++) {
        //int i = 1;
        //stderr.writeln("i:$i");
        //stderr.writeln("getPointsAroundPositionWithRadius box:$box i:$i secPos:$secPos");
        List surroundingBoxPoints = getPointsAroundPositionWithRadius(box, i, walls, secPos);
        //stderr.writeln("result surroundingBoxPoints:$surroundingBoxPoints");
        //stderr.writeln("getClosestCoordinates");
        surroundingBoxPoints = [getClosestCoordinates(surroundingBoxPoints, myX, myY)];
        //stderr.writeln('1surroundingBoxPoints:${surroundingBoxPoints}');
        for (int j = 0; j < surroundingBoxPoints.length; j++) {
            String surroundingBoxPoint = surroundingBoxPoints[j];
            //stderr.writeln('surroundingBoxPoint:-${surroundingBoxPoint}-');
            int counter = 0;
            List counts = [0, 0, 0, 0];
            for (int k = 1; k < range; k++) {
                List possibleBoxPoints = getPointsAroundPositionWithRadius(surroundingBoxPoint, k, walls, boxes);
                //  stderr.writeln('possibleBoxPoints :$possibleBoxPoints');
                counts = countSurroundingBoxes(counts, possibleBoxPoints, boxes);
                //stderr.writeln('counts :$counts');
                counter = counts[0] + counts[1] + counts[2] + counts[3];
            }
            //counts = countSurroundingBoxes(counts, surroundingBoxPoints, boxes);

            if (counter == 4) {
                bestPos = surroundingBoxPoint;
                break;
            } else {
                if (counter > bestCount) {
                    bestCount = counter;
                    bestPos = surroundingBoxPoint;
                }
            }
            //  stderr.writeln('counts:$counts');
        }
    }
    //stderr.writeln('bestPos:$bestPos');
    return bestPos;
}
String getFastPositionForBomb(String box /*[x,y]*/, List boxes, int range, List doneBoxes, List secPos, myX, myY) {
    stderr.writeln('-----------getFastPositionForBomb-box:$box-$range-$doneBoxes----');
    int bx = int.parse(box.split(" ")[0]);
    int by = int.parse(box.split(" ")[1]);
    int bestCount = 0;
    String bestPos = "${bx} ${by}";

    //get  all surrounding points in bomb range
    //int i = 1;
    //stderr.writeln("BESTPOS:$bestPos");
    stderr.writeln("box:$box  secPos:$secPos");
    List surroundingBoxPoints = getPointsAroundPositionWithRadius(box, 1, doneBoxes, secPos);
    stderr.writeln("result surroundingBoxPoints:$surroundingBoxPoints");
    //stderr.writeln("getClosestCoordinates");
    bestPos=getClosestCoordinates(surroundingBoxPoints, myX, myY);

    stderr.writeln('fastPos:$bestPos');
    return bestPos;
}

List getFreeWay(int myX, int myY, List walls, List securePositions) {
    stderr.writeln('freeWay-------------:');
    List wakable = ["$myX $myY"];
    List workable = ["$myX $myY"];
    while (workable.isNotEmpty) {
        //stderr.writeln("workable:$workable");
        List positions = getPointsAroundPositionWithRadius(workable[0], 1, wakable, securePositions);
        wakable.addAll(positions);
        workable.addAll(positions);
        workable.removeAt(0);
    }
    stderr.writeln('freeWay-$wakable-----------:');
    return wakable;
}

List getPointsAroundPositionWithRadius(String position, int range, List excludes, List includes) {
    //stderr.writeln('getSurroundingPointsWith');
    //stderr.writeln('excludes:$excludes');
    //stderr.writeln('INCLUDES WAY:$includes');

    List result = [];
    int bx = int.parse(position.split(" ")[0]);
    int by = int.parse(position.split(" ")[1]);
    String p1 = "${bx - range} ${by}";
    String p2 = "${bx} ${by - range}";
    String p3 = "${bx + range} ${by}";
    String p4 = "${bx} ${by + range}";
    //stderr.writeln('p1:$p1');
    //stderr.writeln('p2:$p2');
    //stderr.writeln('p3:$p3');
    //stderr.writeln('p4:$p4');

    if (!p1.contains("-") && !excludes.contains(p1) && includes.contains(p1)) {
        result.add(p1);
    }
    if (!p2.contains("-") && !excludes.contains(p2) && includes.contains(p2)) {
        result.add(p2);
    }
    if (!p3.contains("-") && !excludes.contains(p3) && includes.contains(p3)) {
        result.add(p3);
    }
    if (!p4.contains("-") && !excludes.contains(p4) && includes.contains(p4)) {
        result.add(p4);
    }
    //stderr.writeln('getPointsAroundPositionWithRadius range:$range ${result}');
    return result;
}

List countSurroundingBoxes(List counts /*[0,0,0,0]*/, List points, List boxes) {
    //stderr.writeln('countSurroundingBoxes');
    //stderr.writeln('counts:$counts');
    //stderr.writeln('points:$points');
    //stderr.writeln('boxes:$boxes');
    int i = 0;
    for (String point in points) {
        if (counts[i] == 0) {
            if (boxes.contains(point)) {
                counts[i] = 1;
            }
        }
        i++;
    }
    //stderr.writeln('surrounding counts:$counts');
    return counts;
}

List removeDmgAreaFromSecureLocations(int x, int y, int range, List securePositions) {
    //stderr.writeln('getSurroundingPointsWith');
    //stderr.writeln('2box:$box');
    /* for (int i = 0; i < securePositions.length; i++) {
        String pos = securePositions[i];
        if (pos.contains("$x ") || pos.contains(" $y")) {
            securePositions.remove(pos);
        }
    }*/
    if (securePositions.contains("$x $y")) {
        securePositions.remove("$x $y");
    }

    // if (0 == x || y == 0) {
    //     securePositions.remove("0 0");
    // }

    for (int i = 1; i < (range); i++) {
        String p1 = "${x - i} ${y}";
        String p2 = "${x} ${y - i}";
        String p3 = "${x + i} ${y}";
        String p4 = "${x} ${y + i}";

        if (securePositions.contains(p1)) {
            securePositions.remove(p1);
        }
        if (securePositions.contains(p2)) {
            securePositions.remove(p2);
        }
        if (securePositions.contains(p3)) {
            securePositions.remove(p3);
        }
        if (securePositions.contains(p4)) {
            securePositions.remove(p4);
        }
    }

    //stderr.writeln('getSurroundingPointsWith range: $range ${[p1, p2, p3, p4]}');
    return securePositions;
}

