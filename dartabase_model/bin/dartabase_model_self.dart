library dartabaseModelSelf;

import "dart:io";
import "dart:async";

import 'package:dartabase_core/dartabase_core.dart';

var MAX = 1;

class fsy {
  static var bool = true;
  fsy();
      
  
}

void main() {
  print("Start");
  File file = new File("dartabase_model.dart");
  var future = file.readAsString();
  future.then((_) { 
    for(var i=0;i<MAX;i++){
        print("01$i.Future complete");
    }
  });
  print("02");
  var completerSync = new Completer.sync();
  completerSync.future.then((_) { 
    for(var i=0;i<MAX;i++){
      print("03$i.completerSync complete");
    }
  });
  completerSync.complete(null);
  print("04");
  var completerAsync = new Completer();
  completerAsync.future.then((_) { 
    for(var i=0;i<MAX;i++){
      print("05$i.completerAsync complete");
    }
  });
  completerAsync.complete(null);
  print("06");
  File file2 = new File("dartabaseModel.dart");
  var future2 = file.readAsString();
  future2.then((_) { 
    for(var i=0;i<MAX;i++){
      print("07$i.Future2 complete");
    }
    var futureInFuture = file.readAsString();
    futureInFuture.then((_) { 
      for(var i=0;i<MAX;i++){
        print("08$i.futureInFuture complete");
      }
    });
  });
  print("09");
  var completerSync2 = new Completer.sync();
  completerSync2.future.then((_) { 
    for(var i=0;i<MAX;i++){
        print("10$i.completerSync2 complete");
    }
    var futureInCompleter = file.readAsString();
    futureInCompleter.then((_) { 
      for(var i=0;i<MAX;i++){
        print("11$i.futureInCompleter complete");
      }
    });
  });
  completerSync2.complete(null);
  print("12");
  var completerAsync2 = new Completer();
  completerAsync2.future.then((_) {
    for(var i=0;i<MAX;i++){
        print("13$i.completerAsync2 complete");
    }
  });
  completerAsync2.complete(null);
  print("End");
}
