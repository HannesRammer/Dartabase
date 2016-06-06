![logo](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/Database-Migration-Logo-150.png) Dartabase Migration 1.0.0-rc.2 GUI GUIDE
=========================

  Serverside Database migration 
  for simple version controlled database structure manipulation using MySQL/PGSQL without having to write SQL 
    
  combine the power of [Dartabase Model](http://pub.dartlang.org/packages/dartabase_model) and Dartabase Migration
  
  !!now supporting scaffolding!! see bottom of the page
    
  inspired by Ruby on Rails

  Tested on 
    
    Dart SDK version 1.16.0

  Uses
  [Polymer](https://github.com/dart-lang/polymer-dart) version "^1.0.0-rc.16"
  MYSQL via [sqljocky](http://pub.dartlang.org/packages/sqljocky) "^0.14.1"
  
  PGSQL via [postgresql](http://pub.dartlang.org/packages/postgresql) version "^0.3.3"

-----------------
Other Tutorials and readme's
  **TUTORIAL 1** [HOW TO SETUP AND RUN MIGRATION AND MODEL](https://github.com/HannesRammer/DartabaseTutorials/blob/master/tutorials/TUT1.md)

-----------------

structure of this file
1.[How to setup](#how-to-setup)
2.[How to update existing dartabase migration version](#how-to-update-dartabase-migration)
3.[How to create migrations](#how-to-create-migrations)
4.[How to run migrations](#how-to-run-migrations)
5.[How to revert migrations](#how-to-revert-migrations)
[About column id](#about-column-id)
[About create updated at column](#about-create-updated-at-column)
[About up and down](#about-up-and-down)
[About order of execution](#about-order-of-execution)
[About dartabase data types](#about-dartabase-data-types)

-----------------

  
### 1. HOW TO SETUP <a name="how-to-setup"></a>

USE THIS INSTALL GUIDE AND IGNORE THE INSTALL PAGE!!! 
This is a stand alone app!

1.Download dartabase_migration somewhere on your drive 

2.run 'Pub Get' on dartabase_migration/pubspec.yaml

3.Execute dartabase_migration/bin/simpleServer.dart 

4.Execute dartabase_migration/tool/index.html which will open in chromeium

now you should see page with a button

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/newProject.PNG)


5.click on add project, now you should see

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createProject.PNG)

6.fill in the form and click enhance or create

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createdProject1.PNG)

7.after reload you should see the created object

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/fixedConfig.PNG)


8.dartabase_migration will create files and folders below to do its magic

      dartabase_migration/bin/projectsMapping.json       
        -maps project names to absolute project path
      yourProject/db/
      yourProject/db/config.json          
        -dartabase config file to connect IP/PORT/DBType
      yourProject/db/schema.json          
        -current dartabase_migration structure as JSON used by Dartabase tools
      yourProject/db/schemaVersion.json   
        -safes name of latest migrated version
      yourProject/db/migrations           
        -folder for your database migration files

9.IMPORTANT if your config data is not correct it might be that dartabase will stop running

in this case make sure to insert the correct data into the config.json file created in your project
-yourProject/db/config.json file 
  so dartabase_migration can connect to your existing database. and rerun simpleServer.dart and index.html

    eg.
    --------config.json---------
    {
        "adapter": "MySQL",
        "database": "dbName",
        "username": "dbUsername",
        "password": "dbPassword",
        "host": "localhost",
        "port": "3306",
        "ssl": "false"
    }
    ----------------------------
    
*******************************************************************************************

### 2. HOW TO UPDATE EXISTING DARTABASE MIGRATION VERSION  <a name="how-to-update-dartabase-migration"></a>

**GENEREL UPDATE**

it is important to keep a backup of 'dartabase_migration/bin/projectsMapping.json' 
    
    1.download the new version of dartabase migration 
    
    2a.replace all files from your current running version 
      (but not projectsMapping.json)
    2b. extract all files into a new folder and paste a copy of bin/projectsMapping.json
  
**LOST 'projectsMapping.json' DONT PAN!C** 
 

    1.create a file named projectsMapping.json inside 'dartabase_migration/bin/'
      
      inside the file enter a json key value pair of a projectname of your choice
      
          keys    : project_names (your choice/short is good ;)
          values  : project absolute project path
      
      eg.
      {
         "mysql":"C:\\myServer",
         "pgsql":"C:\\pgServer"
      }
  
**MOVED/RENAMED project**

    Rename the values when moving/renaming one of your projects
      
now you should be able to find your projects again when running dbUp or dbDown
          
*******************************************************************************************

### 3. HOW TO CREATE MIGRATIONS <a name="how-to-create-migrations"></a>
  
  
1. select the project you want to create a migration for
  
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/fixedConfig.PNG)

2. open the "create migration" view, enter a migration name and click on the action you want to execute

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/openedProject.PNG)

**createTable**
    
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createTable1.PNG)

enter a table name and additional columns if needed like seen below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createTable2.PNG)


 
**createColumn**

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createColumn1.PNG)

select an existing table name and add additional columns like seen below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createColumn2.PNG)
**removeColumn**
    
 ![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeColumn1.PNG)

select an existing table and the existing column you want to remove, like below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeColumn2.PNG)

**removeTable**
  
  ![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeTable1.PNG)

select an existing table you want to remove, like below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeTable2.PNG)
      
**createRelation**

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createRelation1.PNG)

select two existing tables to create a relation between them like below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createRelation2.PNG)

**removeRelation**


![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeRelation1.PNG)

select two existing tables to create a relation between them like below

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/removeRelation2.PNG)

click on "create migration"

it will create a migration inside
  
  "$yourProject/db/migrations/YYYYMMTTHHMMSS_migration_name.json"

if everything works it will show a text mesage inside a toast that asks you to reload the page

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/createdTable.PNG)


*******************************************************************************************

### 4. HOW TO RUN MIGRATIONS  <a name="how-to-run-migrations"></a>

1 . open the run migration view 

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/runMigration1.PNG)


2 . select the preferred migration that is newer than the one marked as current. in this case version 1

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/runMigration2.PNG)

3 . now click on "migrate to newer version".

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/runMigration3.PNG)

dartabase_migration should have executed the actions specified inside the "UP" key
for all files INCLUDING the goal migration version.

Additionally it will update

    -yourProject/db/schema.json
    with the current database structure as JSON

    -yourProject/db/schemaVersion.json
    with the name of latest migrated migration file

*******************************************************************************************

### 5. HOW TO REVERT MIGRATIONS  <a name="how-to-revert-migrations"></a>


1 . open the run migration view 

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/revertMigration1.PNG)


2 . select the preferred migration that is older than the one marked as current. in this case version 1

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/revertMigration2.PNG)

3 . now click on "migrate to older version".

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/revertMigration3.PNG)

dartabase_migration should have executed the actions specified inside the "DOWN" key
for all files EXCLUDING the goal migration version.

Additionally it will update

    -yourProject/db/schema.json
    with the current database structure as JSON

    -yourProject/db/schemaVersion.json
    with the name of latest migrated migration file


*******************************************************************************************

### ABOUT COLUMN ID <a name="about-column-id"></a>

The 'id' column will be generated by 'Dartabase Migration' for every table 
as primary key. 
  
  Dont add 'id' in any of the migration files.
  
This is to let 'Dartabase Model' decide when to create or update an Object
on save() - see [Dartabase Model](http://pub.dartlang.org/packages/dartabase_model)     
       
*******************************************************************************************

### ABOUT CREATED/UPDATED AT COLUMN <a name="about-create-updated-at-column"></a>

For each table a created_at and updated_at column will be generated automatically.
    
    created_at 
      will only be set to current datetime on creation of table row entry 
    
    updated_at 
      will be set to current datetime on creation of table row entry
      PGSQL
        will be updated when the row has been saved
      MySQL
        will be updated when the row has been saved and a value of the row changed 
         
*******************************************************************************************

### ABOUT UP AND DOWN <a name="about-up-and-down"></a>


Additionally to the "UP" key, migration automatically generates the opposite migration for reverting inside the "DOWN" key

    actions inside "UP" are executed during migration
    actions inside "DOWN" are executed when reverting migrations

since we created a table named "user", 
we might want to remove it once we want to revert the migration

    !!!ATTENTION be sure your don't need the data inside a table/column 
    before you remove it!!!

*******************************************************************************************

### ABOUT ORDER OF EXECUTION  <a name="about-order-of-execution"></a>


Once you have more than one action in the migration file

    eg.
      adding a column
      adding a table
      removing a column

remember that the order of execution inside a migration will be

    createTable
     ->
     createColumn
      ->
      removeColumn
       ->
       createRelation
        ->
        removeRelation
         ->
         removeTable

its always best to keep migration files as simple as possible and therefore create more migration files

*******************************************************************************************


### ABOUT DARTABASE DATA TYPES <a name="about-dartabase-data-types"></a>

dartabase_migration types are Specified in capitals.

on the left hand you see the dartabase_migration data type name
on the right the data type your database will use

####MYSQL

    
    {
      "BINT": "BIGINT",
      "BINT UNSIGNED": "BIGINT UNSIGNED",
      "BINARY": "BINARY",
      "BIT": "BIT",
      "BLOB": "BLOB",
      "BOOLEAN": "BOOLEAN",
      "BYTEARRAY": "BLOB",
      "CHAR": "CHAR(255)",
      "DATE": "DATE",
      "DATETIME": "DATETIME",
      "DOUBLE": "DOUBLE",
      "FLOAT": "FLOAT(2)",
      "FLOAT UNSIGNED": "FLOAT(2) UNSIGNED",
      "INT": "INT",
      "INT": "INT",
      "INT UNSIGNED": "INT UNSIGNED",
      "LBLOB": "LONGBLOB",
      "LTEXT": "LONGTEXT",
      "MBLOB": "MEDIUMBLOB",
      "MINT": "MEDIUMINT",
      "MINT UNSIGNED": "MEDIUMINT UNSIGNED",
      "MTEXT": "MEDIUMTEXT",
      "SINT": "SMALLINT",
      "SINT UNSIGNED": "SMALLINT UNSIGNED",
      "TEXT": "TEXT",
      "TIME": "TIME",
      "TIMESTAMP": "TIMESTAMP",
      "TBLOB": "TINYBLOB",
      "TINT": "TINYINT",
      "TINT UNSIGNED": "TINYINT UNSIGNED",
      "TTEXT": "TINYTEXT",
      "VARBINARY": "VARBINARY(255)",
      "VARCHAR": "VARCHAR(255)"
  }

#### PGSQL

    
    {
      "BINT": "bigint",
      "BINT UNSIGNED": "numeric(20)",
      "BINARY": "bytea",
      "BIT": "bytea",
      "BLOB": "bytea",
      "BOOLEAN": "boolean",
      "BYTEARRAY": "bytea",
      "CHAR": "char(255)",
      "DATE": "date",
      "DATETIME": "timestamp",
      "DOUBLE": "double precision",
      "FLOAT": "real",
      "FLOAT UNSIGNED": "real",
      "INT": "integer",
      "INT UNSIGNED": "bigint",
      "LBLOB": "bytea",
      "LTEXT": "text",
      "MBLOB": "bytea",
      "MINT": "integer",
      "MINT UNSIGNED": "integer",
      "MTEXT": "text",
      "SINT": "smallint",
      "SINT UNSIGNED": "integer",
      "TEXT": "text",
      "TIME": "time",
      "TIMESTAMP": "timestamp",
      "TBLOB": "bytea",
      "TINT": "smallint",
      "TINT UNSIGNED": "smallint",
      "TTEXT": "text",
      "VARBINARY": "bytea",
      "VARCHAR": "varchar(255)"
  }

*******************************************************************************************

SCAFFOLDING //IGNORE below
-----------

HOW TO RUN SCAFFOLDING
----------------------

  Scaffolding is the programmers best friend!
  
  run scaffolding and enter a table name, column names and their DARTABASE type, and scaffolding will generate
  most of the standard code needed to get started developing your app
  
  to generate the code we have to
  
  1. run 'dartabase_migration/bin/scaffolding.dart'
  
  2. Select the project we initialized with dartabase_migration
  
  let say we want to extend our (simple todo list)[https://github.com/HannesRammer/DartabaseTutorials/blob/master/tutorials/TUT1.md] example with a user
    
  3. type 'todo' and hit enter
  
  4. now type 'user_account[name:VARCHAR,active:BOOLEAN]-m-c-s' and hit enter
  
  scaffold will generate something like 
  
  **Migration** (generated adding the -m ) 
  
    -yourProject/db/migrations/20140512025616_create_user_account.json 
  
    A migration file, that will create a table user with the specified 2 columns (and the dartabase autogenerated columns)
  
  **Server model** (generated adding the -s )
   
    -yourProject/bin/userAccount.dart
    
    The dart representation of its database table 
    with simple functions for 
    
    loading a list of all entries
      
      -loadUserAccounts(HttpResponse res) 
    
    viewing, editing and deleting a single entry
    
      -loadUserAccount(HttpResponse res,objectId)
      -editUserAccounts(HttpRequest req,HttpResponse res)
      -deleteUserAccounts(HttpRequest req,HttpResponse res) 
  
  **Client view** (generated adding the -c )
  
    -yourProject/web/userAccount/create.dart 
    -yourProject/web/userAccount/create.html 
    -yourProject/web/userAccount/edit.dart 
    -yourProject/web/userAccount/edit.html 
    -yourProject/web/userAccount/view.dart 
    -yourProject/web/userAccount/view.html 
    -yourProject/web/userAccount/index.dart 
    -yourProject/web/userAccount/index.html 
  
    simple html views to display and manipulate the data from the database 
    
    **Poly view** (generated adding the -c )
  
    -yourProject/web/poly/userAccount.dart 
    -yourProject/web/poly/userAccount.html
    
    the client views all make use of its custom polymer elements 
  
  **paths** (generated adding the -c ) 
  
    -yourProject/lib/paths.dart 
  
    since the client views, have links that connect the pages with each other,
    it is useful to handle the paths in a separate file and use vars instead of strings,
    so in case we want to change the path, we only need to change it in one place. 

HOW TO USE SCAFFOLSING  
----------------------

  1. Migrate the new migration into the database follow the steps from **HOW TO RUN MIGRATIONS**
  
  2. If not already inside your dart server add the line 
    
    import '../lib/paths.dart'; (you have to add "library paths;" at the top of the file if it didnt exisct before)
    
  3. Add the new object model to the dart server
  
    part 'userAccount.dart';
    
  4. Add the following code inside the dart simpleServer 
  
    inside handleGet add
    
    [else] if(path == "/$userAccountsLoadUrl"){
      UserAccount.loadUserAccounts(res);
    }else if(path.contains("/$userAccountLoadUrl")){
      String id= path.split("/$userAccountLoadUrl/")[1];
      UserAccount.loadUserAccount(res, id);
    }
    
    inside handlePost
    
    [else] if(path == "/$userAccountSaveUrl"){
      UserAccount.saveUserAccount(req, res);
    } else if(path == "/$userAccountDeleteUrl"){
      UserAccount.deleteUserAccount(req, res);
    }
    
  only add the first else if there is already an if statement .. obviously ;)
  
  5. now you only need to add a link like below inside your client views
  
     Element linkToUserAccounts = new Element.tag('div');
     linkToUserAccounts.onClick.listen((e) => window.location.assign(userAccountsUrl));
     content.append(linkToUserAccounts);
  
  5. run the dart server, run the client! Enjoy!
   
  
*******************************************************************************************

###TODO


    *workaround for database problems with reserved words
     on creation or when switching DBAdapter from PG to MY.
        eg. table name 'user' will break in MySQL
        fix -> add '_' as prefix to all column and table names
    *test on other systems
    *adding rename action
    *adding option to specify variable length
        currently VARCHAR fix at 255
    *test functionality of all data types
    *and much more

Please let me know about bugs you find and or improvements/features you would like to see in future.

ENJOY & BE NICE ;)