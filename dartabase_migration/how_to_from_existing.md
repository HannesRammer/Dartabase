
###Dartabase Documentation
1.[Dartabase Migration - How to install and use](https://pub.dartlang.org/packages/dartabase_migration)

2.[Dartabase Model - How to how to install and use](https://pub.dartlang.org/packages/dartabase_model)

###Dartabase Tutorials
1.[How to create a Dartabase supported app from scratch](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_scratch.md)

2.[How to create a Dartabase supported app for an existing database](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_existing.md) - current



![logo](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/Database-Migration-Logo-150.png) How to create an app from existing Database
=========================

-----------------

1. create a new dart app with "generated sample content" for "Polymer Web Application"
  ![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/1.create_dart_app.png)
  
2. lets call this app "hello_world" at path "C:\darttestproject\hello_world"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/2.create_dart_app.png)

3. now your project should look similar to the image below
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/3.created_dart_app.png)

4. now add the following dependencies to your pubspec.yaml
  dartabase_model: ^1.1.0 #theMagic
  routes: '^0.1.4' #needed for database backend 
  analyzer: ">=0.27.1 <0.27.2" #wired windows problem
  reflectable: "^0.5.2" #my app wont execute without this line
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/4.add_dependencies.png)
  
5. run "pub get" - I often execute "pub update" right after "pub get" because machines are just machines too :)
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/5.run_pub_get.png)

6. run dartabase_migration\bin\simple_server.dart
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/6.start_dartabase_server.png)

7. run dartabase_migration\web\tool\index.html
   click "add project"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/7.start_dartabase_client.png)

8. since we dont have a database yet, we are going to create a database in "mysql workbench" called "hello_world" 
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/10.create_database.png)
  
9. once the database is created we can go back to the browser
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/11.created_database.png)

10. enter the required fields like below and click "enhance or create"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/8.add_project.png)

11. the page will reload and you shold see your project listed like below
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/9.added_project.png)

 #add some database structure

12.  once we click on a project, we can create a migration. 
      since our database is empty, lets create a table "hello_world_table" and a column "hello_world_column"
 the columns "id", "created_at" and, "updated_at" are automatically generated. 
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/12.create_migration.png)

13. click "create" and after the prompt has shown, reload the page
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/13.created_migration.png)

14. so far we only generated the migration. to apply our migration into the database, switch to the "run Migration" view.
here you see all your generated structure modifications in a version controlled manner
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/14.run_migration.png)

15. select the goal migration we want to execute, in this case ".._create_table_hello_world.json" and click "migrate to newer version" and refresh the website.
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/15.select_and_run_migration.png)

16. now that we made some changes to the database structure, open the "create Scaffold" view of your project.
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/16.open_scaffold.png)
  
17. the newest feature of Dartabase is to generate fa the whole backend/admin webapp 
red: by us created migrations
orange: database relation models in dart (scaffold)
blue: server files, serverfunctions, rouiting (scaffold)
pink: database config and current schema structure
green: frontend for the backend (scaffold)
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/17.created_scaffold_project_overview.png)

18. add the entry point "web/db/index.html" for the backend/admin app
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/18.add_entry_point.png)

19. start "hello_world\db\server\simple_server.dart" followd by "hello_world\web\db\index.html"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/19.run_project_server_and_client.png)
  
  20.the resulting app allows to display edit and delete all database entries
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/20.client_view.png)

since we have not stored anything in our "hello_world" database the blue box is empty (fields to create new db entries will follow soon).

now you are ready to use the dartabase_model functions findBy() ... save(), and delete()

eg. 

*******************************************************************************************

Please let me know about bugs you find and or improvements/features you would like to see in future.

ENJOY & BE NICE ;)