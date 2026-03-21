import 'dart:io';
import 'dart:math';

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/
int thrust=0;
void main() {
    List inputs;
    var boost = 0;
    // game loop
    while (true) {
        inputs = stdin.readLineSync().split(' ');
        int x = int.parse(inputs[0]);
        int y = int.parse(inputs[1]);
        int nextCheckpointX = int.parse(inputs[2]); // x position of the next check point
        int nextCheckpointY = int.parse(inputs[3]); // y position of the next check point
        int nextCheckpointDist = int.parse(inputs[4]); // distance to the next checkpoint
        int nextCheckpointAngle = int.parse(inputs[5]); // angle between your pod orientation and the direction of the next checkpoint
        inputs = stdin.readLineSync().split(' ');
        int opponentX = int.parse(inputs[0]);
        int opponentY = int.parse(inputs[1]);

        // Write an action using print()
        // To debug: stderr.writeln('Debug messages...');
        int t = (nextCheckpointDist/40).toInt();

        if(nextCheckpointAngle>90 || nextCheckpointAngle<-90){
            thrust = 0;
        }else{
            stderr.writeln('nextCheckpointDist:${t}');
            if (nextCheckpointDist <= 4000 && nextCheckpointDist > 2000){
                thrust=int.parse("${t}");
            }else{
                thrust=100;
            }

        }

        // You have to output the target position
        // followed by the power (0 <= thrust <= 100)
        // i.e.: "x y thrust"
        if(boost==0){
            print("${nextCheckpointX} ${nextCheckpointY} $thrust");
        }else{

        }
    }
}

double getDistance(int xA, int yA, int xB, int yB) {
    return sqrt((pow((xA - xB), 2) + pow((yA - yB), 2)));
}