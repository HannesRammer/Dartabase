library dartabase.poly.migration;

import 'package:observe/observe.dart';
import 'package:observe/mirrors_used.dart';

class Migration extends Observable {
    final num index;
    final String version;
    @observable Map colorPalette = toObservable({});
    @observable Map actions = toObservable({});
    @observable String state;

    Migration(
            {this.index, this.version, this.colorPalette, this.actions, this.state});

}
