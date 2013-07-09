import "dart:io";
import "dart:async";
import "dartabase.dart";

/**
 * 
 * migrate files inside 
 * ##/db/migrations 
 * in the "UP" key with execution order
 *   -createTable
 *   -createColumn
 *   -removeColumn
 *   -removeTable    
 *  
 * starting with the last migrated version saved in
 * ##/db/schemaVersion.json (if not the first time)
 * 
 */
void main() {
  
  
  print("|--------------------------|");
  print("|   Dartabase  migration   |");
  print("|--------------------------|");
  print("");
  print("Enter the project name and press the ENTER key to proceed");

  projectMapping = DBHelper.jsonFilePathToMap("projectsMapping.json");
  print("");
  print("Project name : Path : Schema version");
  print("-----------------------------");
  for(var name in projectMapping.keys){
    Map schemaV = DBHelper.jsonFilePathToMap("${projectMapping[name]}/db/schemaVersion.json");
    print("$name : ${projectMapping[name]} : ${schemaV['schemaVersion']}");
    
  }
  Stream<List<int>> stream = stdin;
  
  stream
      .transform(new StringDecoder())
      .transform(new LineTransformer())
      .listen((String line) { /* Do something with line. */
        projectMapping = DBHelper.jsonFilePathToMap("projectsMapping.json");
        if(projectMapping[line]!=null){
          run("UP", projectMapping[line]);
        }else{
          run("UP", line);
        }
            
        
      },
      onDone: () { /* No more lines */ 
        print("Dartabase migration done!");
      },
     onError: (e) { /* Error on input. */ 
       print("Dartabase migration error! $e");
     });
}