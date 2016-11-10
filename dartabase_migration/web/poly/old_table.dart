/**import "package:observe/observe.dart";
import "package:observe/mirrors_used.dart"; // for smaller code

class Table extends Observable {
    @observable String name = "";
    @observable List columns = toObservable([]);

    Table({this.name, this.columns});

}
*/