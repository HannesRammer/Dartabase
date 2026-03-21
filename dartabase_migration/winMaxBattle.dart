import 'dart:io';
import 'dart:math';

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/
void main() {
    int n = int.parse(stdin.readLineSync()); // the number of cards for player 1
    List deck1 = [];
    List deck2 = [];
    List cards1 = [];
    List cards2 = [];
    for (int i = 0; i < n; i++) {
        String cardp1 = stdin.readLineSync(); // the n cards of player 1
        deck1.add(removeSuit(cardp1));
    }
    int m = int.parse(stdin.readLineSync()); // the number of cards for player 2
    for (int i = 0; i < m; i++) {
        String cardp2 = stdin.readLineSync(); // the m cards of player 2
        deck2.add(removeSuit(cardp2));
    }
    int rounds = 0;
    String text;
    while (deck1.isNotEmpty && deck2.isNotEmpty) {
        rounds++;
        stderr.writeln('p1:$deck1');
        stderr.writeln('p2:$deck2');
        // Write an action using print()
        // To debug: stderr.writeln('Debug messages...');
        var winner = winnerOfBattle(deck1[0], deck2[0]);
        cards1.add(deck1[0]);
        cards2.add(deck2[0]);
        deck1.removeAt(0);
        deck2.removeAt(0);

        if (winner == 0) {
            //fight();
        }
        if (winner == 1) {
            deck1.addAll(cards1);
            deck1.addAll(cards2);
        }
        if (winner == 2) {
            deck2.addAll(cards1);
            deck2.addAll(cards2);
        }
    }
    if (text == "PAT") {
        print(text);
    } else {
        if (deck1.isEmpty) {
            text = "2 $rounds";
        } else {
            text = "1 $rounds";
        }
        print(text);
    }
}

removeSuit(String card) {
    return card.substring(0, card.length - 1);
}

fight(List cards1, List cards2) {
//    for () {

    //  }
}

war() {

}

winnerOfBattle(card1, card2) {
    String result;
    if (card1 == "J") {
        card1 = "11";
    } else if (card1 == "Q") {
        card1 = "12";
    } else if (card1 == "K") {
        card1 = "13";
    } else if (card1 == "A") {
        card1 = "14";
    }

    if (card2 == "J") {
        card2 = "11";
    } else if (card2 == "Q") {
        card2 = "12";
    } else if (card2 == "K") {
        card2 = "13";
    } else if (card2 == "A") {
        card2 = "14";
    }
    if (card1 == card2) {
        result = "0";
    } else if (card1 > card2) {
        result = "1";
    } else if (card1 < card2) {
        result = "2";
    }
    return result;
}