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
  
  print("\nProject name *:* Path *:* Current schema version");
  print("-----------------------------");
  Map schemaV;
  for(var name in projectMapping.keys){
    schemaV = DBHelper.jsonFilePathToMap("${projectMapping[name]}/db/schemaVersion.json");
    print("$name *:* ${projectMapping[name]} *:* ${schemaV['schemaVersion']}");
    
  }
  Stream<List<int>> stream = stdin;
  
  stream
      .transform(new StringDecoder())
      .transform(new LineTransformer())
      .listen((String line) { /* Do something with line. */
   if(projectMapping[line]!=null){
          
          
          Directory directory = new Directory("${projectMapping[line]}/db/migrations");
          List files = directory.listSync();
          if (files.length > 0) {
            print("\nMigration number : Name");
            for(int i=0;i<files.length;i++){ 
              String version = files[i].path.split("migrations")[1].replaceAll("\\","") ;
              if(schemaV['schemaVersion'] == version ){
                print("${i} : $version <--- current version");
              }else{
                print("${i} : $version");
              }
            }
          }
          print("please enter goal migration number");
          
         rootPath = projectMapping[line];   
          
        }else if(rootPath != null){
          lastMigrationNumber = int.parse(line);
          run("UP");  
        }else{
          rootPath = line;
          run("UP");
        }
   
            
        
      },
      onDone: () { /* No more lines */ 
        print("Dartabase migration done!");
      },
     onError: (e) { /* Error on input. */ 
       print("Dartabase migration error! $e");
     });
}