![logo](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/Database-Migration-Logo-150.png) Dartabase Migration GUI GUIDE
=========================

  Serverside Database migration 
  for simple version controlled database structure manipulation using MySQL/SQLite/PGSQL without having to write SQL 
    
  combine the power of [Dartabase Model](http://pub.dartlang.org/packages/dartabase_model) and Dartabase Migration
  
  !!now supporting scaffolding!! see bottom of the page (6. how to generate backend code)
    
  inspired by Ruby on Rails

  Tested on 
 
    Windows 10 - MYSQL & PGSQL
    
    Ubuntu 16.04 - MYSQL & PGSQL & SQLITE 
 
  MYSQL via sqljocky2 ^0.14.4-dev
  
  PGSQL via postgresql ^0.3.3
  
  SQLITE via sqlite version "^0.3.0"

-----------------

###WIKI

1.[How to setup](#how-to-setup)

2.[How to update existing dartabase migration version](#how-to-update-dartabase-migration)

3.[How to create migrations](#how-to-create-migrations)

4.[How to run migrations](#how-to-run-migrations)

5.[How to revert migrations](#how-to-revert-migrations)

6.[How to generate backend code from database](#how-to-generate-backend-code-from-db)

7.[How to run generated backend code](#how-to-run-generated-backend-code)

[About column id](#about-column-id)

[About create updated at column](#about-create-updated-at-column)

[About up and down](#about-up-and-down)

[About order of execution](#about-order-of-execution)

[About dartabase data types](#about-dartabase-data-types)

-----------------

####Dartabase Documentation

1.[Dartabase Migration - How to install and use](https://pub.dartlang.org/packages/dartabase_migration) - current

2.[Dartabase Model - How to how to install and use](https://pub.dartlang.org/packages/dartabase_model)

####Dartabase Tutorials

1.[How to create a Dartabase supported app from scratch](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_scratch.md)

2.[How to create a Dartabase supported app for an existing database](https://github.com/HannesRammer/Dartabase/blob/master/dartabase_migration/how_to_from_existing.md) 

####HOMEPAGE
[http://dartabase-app.appspot.com](http://dartabase-app.appspot.com/)

-----------------

  
### 1. HOW TO SETUP <a name="how-to-setup"></a>

USE THIS INSTALL GUIDE AND IGNORE THE INSTALL PAGE!!! 
This is a stand alone app!

1.Download dartabase_migration somewhere to your drive 

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
        "sqlitePath": "pathToSqliteFile",
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

### 6. HOW TO generate backend code from database <a name="how-to-generate-backend-code-from-db"></a>


1. open the "create Scaffold" view in your project.
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/scaffold_view.png)

2. click "generate all at once"
the newest feature of Dartabase is to generate fa the whole backend/admin webapp 

below you can see an example with generated files and folders
red: by us created migrations

orange: database relation models in dart (scaffold)

blue: server files, serverfunctions, rouiting (scaffold)

pink: database config and current schema structure

green: frontend for the backend (scaffold)

![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/created_project_overview.png)


*******************************************************************************************

### 7. HOW TO run generate backend code <a name="how-to-run-generate-backend-code"></a>

1. make sure you add the entry point "web/db/index.html" for the backend/admin app
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/how_to_from_scratch/18.add_entry_point.png)

2. start "dart_demo\db\server\simple_server.dart" followd by "dart_demo\web\db\index.html"
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/run_server_and_client.png)
  
3a. the resulting app allows to display edit and delete all database entries
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/created_scaffold.png)

since we have not stored anything in our database yet the boxes are empty

another example with data could look like this
3b. 
![one](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/doc/from_existing/2_12.png)
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

#### SQLite

    
    {
      "BINT": "INTEGER",
      "BINT UNSIGNED": "INTEGER",
      "BINARY": "NUMERIC",
      "BIT": "NUMERIC",
      "BLOB": "BLOB",
      "BOOLEAN": "NUMERIC",
      "BYTEARRAY": "NUMERIC",
      "CHAR": "TEXT",
      "DATE": "NUMERIC",
      "DATETIME": "NUMERIC",
      "DOUBLE": "REAL",
      "FLOAT": "REAL",
      "FLOAT UNSIGNED": "REAL",
      "INT": "INTEGER",
      "INT UNSIGNED": "INTEGER",
      "LBLOB": "BLOB",
      "LTEXT": "TEXT",
      "MBLOB": "BLOB",
      "MINT": "INTEGER",
      "MINT UNSIGNED": "INTEGER",
      "MTEXT": "TEXT",
      "SINT": "INTEGER",
      "SINT UNSIGNED": "INTEGER",
      "TEXT": "TEXT",
      "TIME": "NUMERIC",
      "TIMESTAMP": "NUMERIC",
      "TBLOB": "BLOB",
      "TINT": "INTEGER",
      "TINT UNSIGNED": "INTEGER",
      "TTEXT": "TEXT",
      "VARBINARY": "NUMERIC",
      "VARCHAR": "TEXT"
    }

   
  
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
