
###Dartabase Documentation
1.[Dartabase Migration - How to install and use](https://pub.dartlang.org/packages/dartabase_migration)

2.[Dartabase Model - How to how to install and use](https://pub.dartlang.org/packages/dartabase_model)

###Dartabase Tutorials
1.[How to create a Dartabase supported app from scratch](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_scratch.md)

2.[How to create a Dartabase supported app for an existing database](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_existing.md) - current



![logo](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/Database-Migration-Logo-150.png) How to create an app from existing Database
=========================

-----------------

1. create a new dart project with "generated sample content" for "Polymer Web Application"
  ![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_1.png)
  
2. lets call this app "ported_app" at path "C:\darttestproject\ported_app"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_2.png)

3. now your project should look similar to the image below
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_3.png)

4. now add the following dependencies to your pubspec.yaml
  dartabase_model: ^1.1.0 #theMagic
  routes: '^0.1.4' #needed for database backend 
  analyzer: ">=0.27.1 <0.27.2" #wired windows problem
  reflectable: "^0.5.2" #my app wont execute without this line
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_4.png)
  
5. run "pub get" - I often execute "pub update" right after "pub get" because machines are just machines too :)
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_5.png)

6. run dartabase_migration\bin\simple_server.dart
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_6.png)

7. run dartabase_migration\web\tool\index.html
   click "add project"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_7.png)

8. enter the required fields like below and click "enhance or create"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_8.png)
 
9. the page will reload and you shold see your project listed like below
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_9.png)
 
10. since we have an exitsing database, open the "create Scaffold" view of your project.
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_11.png)  

11. the newest feature of Dartabase is to generate the whole backend/admin webapp 
red: by us created migrations

orange: database relation models in dart (scaffold)

blue: server files, serverfunctions, rouiting (scaffold)

pink: database config and current schema structure

green: frontend for the backend (scaffold)

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/created_scaffold.png)

12. add the entry point "web/db/index.html" for the backend/admin app
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/18.add_entry_point.png)

13. start "ported_app\db\server\simple_server.dart" followd by "ported_app\web\db\index.html"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/server_log.png)
  
14. the resulting app allows to display edit and delete all database entries
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_12.png)

since we have data stored in our "ported_app" database, it is now possible to administrate the data.

now you are ready to add more structure with dartabase_migration or data with dartabase_model

*******************************************************************************************

Please let me know about bugs you find and or improvements/features you would like to see in future.

ENJOY & BE NICE ;)
