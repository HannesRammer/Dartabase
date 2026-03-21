import 'dart:io';
import 'dart:math';

List snafflesToExclude;
List snafflesToExcludeOnStop;
List bludgersToExclude;
int mana = -1;

/**
 * Grab Snaffles and try to throw them through the opponent's goal!
 * Move towards a Snaffle and use your team id to determine where you need to throw it.
 **/
void main() {
    List inputs;
    int myTeamId = int.parse(stdin.readLineSync()); // if 0 you need to score on the right of the map, if 1 you need to score on the left
    Map goalsData = getGoalData(myTeamId);
    Map myGoal = goalsData["my"];
    Map opGoal = goalsData["op"];
    List myTeam;
    List opponentTeam;
    List snaffles, ppuks;
    List bludgers = [];
    String text = "";
    bool special = false;
    List specialList = [];
    // game loop
    while (true) {
        String action = "";
        snaffles = [];
        ppuks = [];
        snafflesToExclude = [];
        snafflesToExcludeOnStop = [];
        bludgersToExclude = [];
        myTeam = [];
        opponentTeam = [];
        mana += 1;
        stderr.writeln('mana:$mana');

        int entities = int.parse(stdin.readLineSync()); // number of entities still in game
        for (int i = 0; i < entities; i++) {
            inputs = stdin.readLineSync().split(' ');
            int entityId = int.parse(inputs[0]); // entity identifier
            String entityType = inputs[1]; // "WIZARD", "OPPONENT_WIZARD" or "SNAFFLE" (or "BLUDGER" after first league)
            int x = int.parse(inputs[2]); // position
            int y = int.parse(inputs[3]); // position
            int vx = int.parse(inputs[4]); // velocity
            int vy = int.parse(inputs[5]); // velocity
            int state = int.parse(inputs[6]); // 1 if the wizard is holding a Snaffle, 0 otherwise
            Map obj = {
                "id":entityId,
                "x":x,
                "y":y,
                "vx":vx,
                "vy":vy,
                "state":state
            };

            if (entityType == "WIZARD") {
                if (myTeam.length < 2) {
                    myTeam.add(obj);
                } else {
                    updateXY(myTeam, entityId, x, y);
                }
            } else if (entityType == "OPPONENT_WIZARD") {
                if (opponentTeam.length < 2) {
                    opponentTeam.add(obj);
                } else {
                    updateXY(opponentTeam, entityId, x, y);
                }
            } else if (entityType == "SNAFFLE") {
                snaffles.add(obj);
            } else if (entityType == "BLUDGER") {
                obj["obliviate"] = 0;
                if (bludgers.length < 2) {
                    bludgers.add(obj);
                } else {
                    updateXY(bludgers, entityId, x, y);
                }
            }
        }
        //stderr.writeln(snaffles);

        countdownObliviate(bludgers);
        Map snaffleCloseToMyGoal = getClosestSnaffleInRangeOf(myGoal["x"], myGoal["y"], snaffles, [], 7000);
        //stderr.writeln('snaffleToCloseToMyGoal:$snaffleToCloseToMyGoal');

        for (int i = 0; i < 2; i++) {
            action = "pull";
            Map wizard = myTeam[i];
            stderr.writeln('wizard:${i + 1}');
            Map snaffleClosestToMyWizard;
            if (snaffles.length > 2) {
                snaffleClosestToMyWizard = getClosest(wizard["x"], wizard["y"], snaffles, true);
            } else {
                snaffleClosestToMyWizard = getClosest(myGoal["x"], myGoal["y"], snaffles, true);
            }
            //stderr.writeln('snaffleClosestToMyWizard:$snaffleClosestToMyWizard');

            Map snaffleToStop = checkIfOpponentUsesFlipendo(myGoal, snaffles, snafflesToExcludeOnStop);
            //stderr.writeln('snaffleToStop:$snaffleToStop');

            Map dangerousBludger = checkIfBludgerIsToClose(wizard["x"], wizard["y"], bludgers, 900);
            //stderr.writeln('dangerousBludger:$dangerousBludger');
            List snafflesBehindWizardInRange = getSnaffleBehindWizardInRange(wizard, myGoal, snaffles, 4000);
            //stderr.writeln("snafflesBehindWizardInRange:${snafflesBehindWizardInRange}");
            Map bestShot = getFirstFoundShot(wizard, snaffles, opGoal);
            stderr.writeln('bestShot:$bestShot');

            if (wizard["state"] == 0) {
                //stderr.writeln('found snaffle:${snaffleClosestToMyWizard}');
                // Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500)
                // i.e.: "MOVE x y thrust" or "THROW x y power"
                if (snaffleClosestToMyWizard != null) {
                    if(mana>25){
                        text = "ACCIO ${snaffleClosestToMyWizard["id"]} ACCIO save snaffle from gate";
                    }else{
                        text = "MOVE ${snaffleClosestToMyWizard["x"]} ${snaffleClosestToMyWizard["y"]} 150";
                    }

                }

                bool findAnotherOption = true;

                if (bestShot != null && mana >= 20) {
                    var disToGoal =getDistance(bestShot["x"] ,bestShot["y"],opGoal["x"],opGoal["y"]);
                    if(disToGoal >3000 || disToGoal <1000){
                        mana -= 20;
                        text = "FLIPENDO ${bestShot["id"]} shoot Possible Goal";

                    }else{
                        text = "MOVE ${bestShot["x"]} ${bestShot["y"]} 150 move Possible Goal";

                    }
                    findAnotherOption = false;
                }
                if (findAnotherOption) {
                    bool findBetterOption = true;

                    if (snaffleCloseToMyGoal != null) {
                        stderr.writeln('found snaffle:${snaffleCloseToMyGoal}');
                        Map closestWizard = getClosest(snaffleCloseToMyGoal["x"], snaffleCloseToMyGoal["y"], myTeam, false);
                        stderr.writeln('closestWizard["id"] == wizard["id"]:${closestWizard["id"] == wizard["id"]}');
                        bool inRange = getDistance(wizard["x"],wizard["y"],snaffleCloseToMyGoal["x"], snaffleCloseToMyGoal["y"]) < 8000;
                        if (closestWizard["id"] == wizard["id"] && mana >= 20 && inRange) {

                            findBetterOption = false;
                            if (true) {
                                action = getAction(opGoal["x"], snaffleCloseToMyGoal["x"], closestWizard["x"]);
                                if (action == "pull" && (getDistance(wizard["x"], wizard["x"], snaffleCloseToMyGoal["x"], snaffleCloseToMyGoal["y"]) > 100)) {
                                    mana -= 20;
                                    text = "ACCIO ${snaffleCloseToMyGoal["id"]} ACCIO save puk from gate";
                                } else {
                                    text = "MOVE ${snaffleCloseToMyGoal["x"]} ${snaffleCloseToMyGoal["y"]} 150 MOVE AND PULL 1";
                                    //mana -= 20;
                                    //text = "FLIPENDO ${snaffleToCloseToMyGoal["id"]} FLIPENDO save puk from gate";
                                }
                            }
                        }
                    }
                    if (findBetterOption) {
                        /*if (bestShot != null && mana >= 20) {
                        mana -= 20;
                        text = "FLIPENDO ${bestShot["id"]} shoot Possible Goal";
                    } else*/
                        if (snaffleToStop != null && mana >= 10) {
                            mana -= 10;
                            text = "PETRIFICUS ${snaffleToStop["id"]} STOP ${snaffleToStop["id"]}";
                        } else if (!snafflesBehindWizardInRange.isEmpty && snafflesBehindWizardInRange[0].isEmpty && snafflesBehindWizardInRange[0][0] > -1 && mana >= 25) {
                            mana -= 20;
                            text = "ACCIO ${snafflesBehindWizardInRange[0]["id"]} ACCIO behind me";
                        }
                        //else if(tc>-1 && ((mana>=5 && mana <=8) || (mana>=25))) {
                        else if (dangerousBludger != null && mana >= 30) {
                            setObliviate(bludgers, dangerousBludger["id"]);
                            mana -= 5;
                            text = "OBLIVIATE ${dangerousBludger["id"]} obliviate";
                        }
                        //2.bludger too close and mana

                        /*else
                    if(tctm[0] >-1 && mana>=20){
                    mana-=20;
                    text= "FLIPENDO ${tctm[0]} FLIPENDO";

                }*/

                    }
                }
                print(text);
            } else {
                //closestPuk = getClosest(wizard["x"],wizard["y"],puks);

                //if(mana>=20 && puks.length==1){
                //     mana-=20;
                //        print("ACCIO ${pctg} ACCIO");

                //}else{
                if(false){

                }
                if (wizard["y"] < 3000 ) {
                    print("THROW ${opGoal["x"]} ${opGoal["y"]+1000} 500 throw");
                } else if (wizard["y"] > 5000 ) {
                    print("THROW ${opGoal["x"]} ${opGoal["y"]-1000} 500 throw");
                }else {
                    print("THROW ${opGoal["x"]} ${opGoal["y"]} 500 throw");
                }
                //print("THROW ${opGoal[0]} ${opGoal[1]} 500 throw");
                //}

                // Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500)
                // i.e.: "MOVE x y thrust" or "THROW x y power"

            }
            if (special) {
                print(specialList[0]);
                print(specialList[1]);
            }
        }
    }
}

List getSnaffleBehindWizardInRange(var wizard, Map myGoal, List snaffles, int range) {
    List puksBehindMe = [];
    for (int i = 0; i < snaffles.length; i++) {
        Map puk = snaffles[i];
        if (myGoal["x"] == 0) {
            if (myGoal["x"] < puk["x"] && puk["x"] < wizard["x"]) {
                puksBehindMe.add(puk);
            }
        } else {
            if (wizard["x"] < puk["x"] && puk["x"] < myGoal["x"]) {
                puksBehindMe.add(puk);
            }
        }
    }
    return puksBehindMe;
}

String getAction(int opGoalX, int snaffleX, int wizardX) {
    String text = "pull";
    if (opGoalX == 0) {
        //goal is left
        if (opGoalX < snaffleX && snaffleX < wizardX) {
            text = "push";
        }
    } else {
        //goal is right
        if (wizardX < snaffleX && snaffleX < opGoalX) {
            text = "push";
        }
    }
    return text;
}

void updateXY(List items, id, x, y) {
    for (var j = 0; j < items.length; j++) {
        if (items[j]["id"] == id) {
            items[j]["x"] = x;
            items[j]["y"] = y;
        }
    }
}

Map getGoalData(int myTeamId) {
    if (myTeamId == 0) {
        return {"my":{"x":0, "y":3750}, "op":{"x":16000, "y": 3750}};
    } else {
        return {"my":{"x":16000, "y":3750}, "op":{"x":0, "y": 3750}};
    }
}

void countdownObliviate(List bludgers) {
    for (int i = 0; i < bludgers.length; i++) {
        //stderr.writeln(bludgers[i]);
        if (bludgers[i]["obliviate"] >= 1) {
            bludgers[i]["obliviate"] -= 1;
        }
    }
}

void setObliviate(List bludgers, int id) {
    for (int i = 0; i < bludgers.length; i++) {
        if (id == bludgers[i]["id"]) {
            bludgers[i]["obliviate"] = 3;
        }
    }
}

num getDistance(int xA, int yA, int xB, int yB) {
    //stderr.writeln('${xA} ${yA} ${xB} ${yB}');
    return sqrt((pow((xA - xB), 2) + pow((yA - yB), 2)));
}

//New functions
List getAllInRangeOf(int centerX, int centerY, List items /*[[id,x,y,vx,vy,state]]*/, range) {
    // stderr.writeln('getAllInRangeOf x:${centerX} y:${centerY} range:${range}');
    List itemsInRange = [];
    for (int i = 0; i < items.length; i++) {
        Map item = items[i];
        var distance = getDistance(centerX, centerY, item["x"], item["y"]);
        //stderr.writeln('dist:$distance');
        if (distance < range) {
            item["distance"] = distance;
            itemsInRange.add(item);
            //stderr.writeln("inrange: ${item}");
        }
    }
    return itemsInRange;
}

//New functions
Map getClosestSnaffleInRangeOf(int centerX, int centerY, List items /*[[id,x,y,vx,vy,state]]*/, List snafflesToExclude, range) {
    // stderr.writeln('getAllInRangeOf x:${centerX} y:${centerY} range:${range}');
    Map closestItemInRange = null;
    int widestDistance = range;
    for (int i = 0; i < items.length; i++) {
        Map item = items[i];
        if (!snafflesToExclude.contains(item["id"])) {
            var distance = getDistance(centerX, centerY, item["x"], item["y"]);
            //stderr.writeln('dist:$distance');
            if (distance < range) {
                range = distance;
                //widestDistance = distance;
                item["distance"] = distance;
                closestItemInRange = item;
            }
        }
    }
    //stderr.writeln("closestItemInRange: ${closestItemInRange}");
    return closestItemInRange;
}

Map getClosest(int centerX, int centerY, List items /*[[id,x,y,vx,vy,state]]*/, bool tf) {
    //stderr.writeln('items:${items}');
    Map closestItem = null;
    var shortestDistance = -1;
    for (int i = 0; i < items.length; i++) {
        Map item = items[i];
        //stderr.writeln('item:$item');
        var distance = getDistance(centerX, centerY, item["x"], item["y"]);
        if (tf) {
            if (!snafflesToExclude.contains(item["id"])) {
                if (shortestDistance == -1 || distance < shortestDistance) {
                    shortestDistance = distance;
                    item["distance"] = distance;
                    closestItem = item;
                    snafflesToExclude.add(item["id"]);
                }
            }
        } else {
            if (shortestDistance == -1 || distance < shortestDistance) {
                shortestDistance = distance;
                item["distance"] = distance;
                closestItem = item;
            }
        }
    }
    //stderr.writeln("closestItem: ${closestItem}");
    return closestItem;
}

Map checkIfBludgerIsToClose(int centerX, int centerY, List bludgers /*[[id,x,y,vx,vy,state]]*/, range) {
    // stderr.writeln('items:${items}');
    Map closestBudger = null;
    int targetId = -1;
    for (int i = 0; i < bludgers.length; i++) {
        Map bludger = bludgers[i];
        //if (!bludgersToExclude.contains(bludger["id"])) {
        //stderr.writeln('toCLOSE:$item');
        var distance = getDistance(centerX, centerY, bludger["x"], bludger["y"]);
        //stderr.writeln('dist:$distance');
        if (distance < range && bludger["obliviate"] == 0) {
            //shortestDistance = distance;
            bludger["distance"] = distance;
            //stderr.writeln("toClose: ${bludger}");
            closestBudger = bludger;
        }
        //  bludgersToExclude.add(bludger["id"]);
        //}
    }
    return closestBudger;
}

Map getFirstFoundShot(Map wizard, List snaffles, Map goal) {
    Map foundShot = null;
    var distance = -1;
    for (int i = 0; i < snaffles.length; i++) {
        Map snaffle = snaffles[i];
        if (simulateIfDirectShotIsGoal(wizard, snaffle, goal)) {
            var newDistance = getDistance(snaffle["x"], snaffle["y"], goal["x"], goal["y"]);
            if (distance == -1 || distance > newDistance) {
                distance = newDistance;
                foundShot = snaffle;
            }
            //break;
        }
    }
    return foundShot;
}

bool simulateIfDirectShotIsGoal(Map wizard, Map snaffle, Map goal) {
    bool simulate = true;
    bool isGoal = false;
    //if (getDistance(snaffle["x"], snaffle["y"], goal["x"], goal["y"]) > 1500) {
    if (true) {
        Map simSnuffleOld = {"x":snaffle["x"]+snaffle["vx"], "y":snaffle["y"]+snaffle["vy"]};
        Map simWizardOld = {"x":wizard["x"]+wizard["vx"], "y":wizard["y"]+wizard["vy"]};
        Map simSnuffle = {"x":snaffle["x"], "y":snaffle["y"]};
        Map simWizard = {"x":wizard["x"], "y":wizard["y"]};

        int dx = simSnuffle["x"] - simWizard["x"];
        int dy = simSnuffle["y"] - simWizard["y"];
        bool goalOnLeft = goal["x"] == 0;
        int rounds = 0;

        bool inDirectionToGoal;
        int poleRadius = 300;
        int goalCenter = 3750;
        int poleDistanceToCenter = 2000;
        int snaffleRadius = 200;
        int goalTop = goalCenter - (poleDistanceToCenter - poleRadius) + snaffleRadius;
        int goalBottom = goalCenter + (poleDistanceToCenter - poleRadius) - snaffleRadius;

        if (goalOnLeft) {
            inDirectionToGoal = goal["x"] < simSnuffle["x"] && simSnuffle["x"] < simWizard["x"];

            if (inDirectionToGoal) {
                stderr.writeln("goalOnLeft:$goalOnLeft");
                while (simulate) {
                    rounds += 1;
                    simSnuffle["x"] += dx;
                    simSnuffle["y"] += dy;
                    bool hitXBound = simSnuffle["x"] < 0 || simSnuffle["x"] > 16000;
                    bool hitYBound = simSnuffle["y"] < 0 || simSnuffle["y"] > 7500;
                    //Map goalBounds = {"top":goalTop, "botton":goalBottom};
                    if (hitXBound) {
                        if (simSnuffle["y"] > goalTop && simSnuffle["y"] < goalBottom) {
                            isGoal = true;
                        }
                        simulate = false;
                    }
                    if (hitYBound) {
                        simulate = false;
                    }
                }
            }
        } else {
            inDirectionToGoal = simWizard["x"] < simSnuffle["x"] && simSnuffle["x"] < goal["x"];
            stderr.writeln("goalOnLeft:$goalOnLeft");
            stderr.writeln("simSnuffle:$simSnuffle");
            if (inDirectionToGoal) {
                while (simulate) {
                    rounds += 1;
                    simSnuffle["x"] += dx;
                    simSnuffle["y"] += dy;
                    bool hitXBound = simSnuffle["x"] < 0 || simSnuffle["x"] > 16000;
                    bool hitYBound = simSnuffle["y"] < 0 || simSnuffle["y"] > 7500;
                    //Map goalBounds = {"top":goalTop, "botton":goalBottom};
                    if (hitXBound) {
                        if (simSnuffle["y"] > goalTop && simSnuffle["y"] < goalBottom) {
                            isGoal = true;
                        }
                        simulate = false;
                    }
                    if (hitYBound) {
                        simulate = false;
                    }
                }
            }
        }
    }
    return isGoal;
}

Map checkIfOpponentUsesFlipendo(Map myGoal, List snaffles /*[[id,x,y,vx,vy,state]]*/, List snafflesToExcludeOnStop) {
    // stderr.writeln('items:${items}');

    Map snaffleToStop = null;
    int targetId = -1;
    for (int i = 0; i < snaffles.length; i++) {
        Map snaffle = snaffles[i];
        if (!snafflesToExcludeOnStop.contains(snaffle["id"])) {
            bool goalOnLeft = myGoal["x"] == 0;
            if ((goalOnLeft && snaffle["vx"] <= -1200) || (!goalOnLeft && snaffle["vx"] >= 1200)) {
                snaffleToStop = snaffle;
            }
            snafflesToExcludeOnStop.add(snaffle["id"]);
        }
    }
    return snaffleToStop;
}
