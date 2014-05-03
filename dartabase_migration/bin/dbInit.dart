import "dart:io";
import "dart:convert";
import "dart:async";

import "dartabaseMigration.dart";

/*
 * Initiates Dartabase requirements:
 * 
 * ONLY RUN THIS ONCE FOR EACH PROJECT
 *    
 *   creates 
 *   ##/db/migrations/         //where migration files are saved and executed
 *   ##/db/config.json         //where database config is saved
 *   ##/db/schema.json         //where database structure is saved 
 *   ##/db/schemaVersion.json  //saves latest migrated version number
 *   
 *   //adds mapping of project names and project root paths initiated in Dartabase 
 *   //for faster migration access in
 *   Dartabase/bin/projectsMapping.json  
 */
void main() {
  print("|--------------------------|");
  print("|   Dartabase initiation   |");
  print("|--------------------------|");
  print("");
  print("!!ONLY RUN THIS ONCE FOR EACH PROJECT!!");
  print("");
  Stream<List<int>> stream = stdin;
  int count = 0;
  String name = "";
  stream
      .transform(UTF8.decoder)
      .transform(new LineSplitter())
      .listen((String line) { /* Do something with line. */
        if(count>1){
          initiateDartabase(line,name);  
        }

        if(count == 1){
          name = line;
          count++;
          print("Please enter the absolute path to your project root folder and press the ENTER key to proceed");
          print("eg. c:\\DartProjects\\myApp");
          print("take care of capital letters!!");
        }
        if(count == 0){
          name = line; 
          count++;
          print("Please type or paste a project name and press the ENTER key");
        }
        
      },
      onDone: () { /* No more lines */ 
        print("Dartabase initiation done!");
      },
     onError: (e) { /* Error on input. */ 
       print("Dartabase initiation error! $e");
     });
}