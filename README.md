Dartabase
=========

    Serverside Database migration inspired by Ruby on Rails

    MYSQL via http://pub.dartlang.org/packages/sqljocky version 0.5.4
    PGSQL via http://pub.dartlang.org/packages/postgresql version 0.2.8

HOW TO SETUP
------------
    IGNORE THE INSTALL PAGE!!! Curently this is a stand alone app!

    1.Download Dartabase somewhere on your drive and run install on Dartabase/pubspec.yaml

    2.Execute Dartabase/bin/dbInit.dart to initiate the Dartabase tool for your project.

    3.follow the instructions
      *enter a project name
      *enter path to project root folder

    4.Dartabase will create files and folders needed for Dartabase to do its magic
      *Dartabase/bin/projectsMapping.json       #maps project names to absolute project path
      *$yourProjectName/db/
      *$yourProjectName/db/config.json          #setting database information needed to connect IP/PORT/DBType
      *$yourProjectName/db/schema.json          #current database structure as JSON
      *$yourProjectName/db/schemaVersion.json   #safes name of latest migrated version
      *$yourProjectName/db/migrations           #folder where you can add your database migrations

    5.Edit the config.json file so Dartabase can connect to your existing database.

    eg.
    --------config.json---------
    {
        "adapter": "MySQL",
        "database": "dbName",
        "username": "dbUsername",
        "password": "dbPassword",
        "host": "localhost",
        "port": "3306"
    }
    ----------------------------

    for postgresql use

    "adapter": "PGSQL"    (all capital)

*******************************************************************************************
HOW TO CREATE MIGRATIONS
------------------------
	
	Either
	
	1a.execute Dartabase/bin/createMigration.dart and follow the instructions
		*enter project name
		*enter migration name eg. "create_table_user"
	
	it will create a dummy migration inside
	
	"$yourProjectName/db/migrations/YYYYMMTTHHMMSS_create_table_user" 
	
	or
	
    1b.Create a migration json file "timestamp_action.json" 

        inside "$yourProjectName/db/migrations"

        eg. "20130709134700_create_table_user.json"

    2.inside your migration file you have a fixed structure!

    a JSON object with a key "UP" and a json object value

    to use migrations you can specify 4 keys/actions inside the "UP" value

        createTable
        -----------
        "createTable" key takes a json object as value

            keys    : non_existent_table_names
            values  : json object
                        keys    : non_existent_column_names
                        values  : dartabase_mapped_datatypes

            eg.
            "createTable": {
                "new_table_name_one": {
                    "new_column_name": "DATATYPE"
                }
            }

        createColumn
        ------------
        "createColumn" key takes a json object as value

            keys    : existing_table_names
            values  : json object
                        keys    : non_existent_column_names
                        values  : dartabase_mapped_datatypes

            eg.
            "createColumn": {
                "existing_table_name_one": {
                    "new_column_name": "DATATYPE"
                }
            }

        removeColumn
        ------------
        "removeColumn" key takes a json object as value

            keys    : existing_table_names
            values  : array[existing_column_names]

            eg.
            "removeColumn": {
                "existing_table_name_one": ["existing_column_name_one"]
            }

        removeTable
        -----------
        "removeTable" key takes array of existing_table_names

            eg.
            "removeTable": ["existing_table_name_one"]

        A simple migration could look like

        ----------20130709134700_create_table_user.json--------------
        {
            "UP": {
                "createTable": {
                    "user": {
                        "name": "VARCHAR"
                    }
                }
            },
            "DOWN": {
                "removeTable": ["user"]
            }
        }

    We create a table name "user" with column "name" and datatype variable length of characters

*******************************************************************************************
UP AND DOWN
-----------

    Additionally to the "UP" key you can specify all actions inside the "DOWN" key

    actions inside "UP" are executed during migration
    actions inside "DOWN" are executed when reverting migrations

    since we created a table named "user", we might want to remove it once we want to revert the migration

    !!!ATTENTION be sure your don't need the data inside a table/column before you remove it!!!

*******************************************************************************************
ORDER OF EXECUTION
------------------

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
                removeTable

   but I cant think of a feasible example where that might bring up problems.

*******************************************************************************************
HOW TO RUN MIGRATIONS
---------------------

    1.Execute Dartabase/bin/dbUp.dart

    2.Follow instructions in console
        *enter project name
        *enter goal migration version

    Dartabase should have executed the actions specified inside the "UP" key
    for all files INCLUDING the goal migration version.

    Additionally it will update

        *$yourProjectName/db/schema.json
        with the current database structure as JSON

        *$yourProjectName/db/schemaVersion.json
        with the name of latest migrated migration file

HOW TO REVERT MIGRATIONS
------------------------

    1.Execute Dartabase/bin/dbDown.dart to execute the Dartabase migration actions you specified inside the "DOWN" key.

    2.Follow instructions in console
        *enter project name
        *enter goal migration version 

    Dartabase should have executed the actions specified inside the "DOWN" key
    for all files EXCLUDING the goal migration version.

    Additionally it will update

        *$yourProjectName/db/schema.json
        with the current database structure as JSON

        *$yourProjectName/db/schemaVersion.json
        with the name of latest migrated migration file


*******************************************************************************************

DARTABASE DATA TYPES
--------------------
Dartabase types are Specified in capitals.

on the left hand you see the Dartabase data type name
on the right the data type your database will use

MYSQL
-----
    {
        "BIGINT": "BIGINT",
        "BIGINT UNSIGNED": "BIGINT UNSIGNED",
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
        "INTEGER": "INT",
        "INTEGER UNSIGNED": "INT UNSIGNED",
        "LONGBLOB": "LONGBLOB",
        "LONGTEXT": "LONGTEXT",
        "MEDIUMBLOB": "MEDIUMBLOB",
        "MEDIUMINT": "MEDIUMINT",
        "MEDIUMINT UNSIGNED": "MEDIUMINT UNSIGNED",
        "MEDIUMTEXT": "MEDIUMTEXT",
        "SMALLINT": "SMALLINT",
        "SMALLINT UNSIGNED": "SMALLINT UNSIGNED",
        "TEXT": "TEXT",
        "TIME": "TIME",
        "TIMESTAMP": "TIMESTAMP",
        "TINYBLOB": "TINYBLOB",
        "TINYINT": "TINYINT",
        "TINYINT UNSIGNED": "TINYINT UNSIGNED",
        "TINYTEXT": "TINYTEXT",
        "VARBINARY": "VARBINARY(255)",
        "VARCHAR": "VARCHAR(255)"
    }

PGSQL
-----
    {
        "BIGINT": "bigint",
        "BIGINT UNSIGNED": "numeric(20)",
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
        "INTEGER": "integer",
        "INTEGER UNSIGNED": "bigint",
        "LONGBLOB": "bytea",
        "LONGTEXT": "text",
        "MEDIUMBLOB": "bytea",
        "MEDIUMINT": "integer",
        "MEDIUMINT UNSIGNED": "integer",
        "MEDIUMTEXT": "text",
        "SMALLINT": "smallint",
        "SMALLINT UNSIGNED": "integer",
        "TEXT": "text",
        "TIME": "time",
        "TIMESTAMP": "timestamp",
        "TINYBLOB": "bytea",
        "TINYINT": "smallint",
        "TINYINT UNSIGNED": "smallint",
        "TINYTEXT": "text",
        "VARBINARY": "bytea",
        "VARCHAR": "varchar(255)"
    }

*******************************************************************************************
ENDING
======
Currently you need to manually stop the scripts from the editor or console after they are done.

And when is it done?

Once it has printed some output and there have been no errors,
it should be done.

*******************************************************************************************
Now you can add migration files for simple database manipulation

TODO
----

	*fix async outputtext
	*workarround for database problems with reserved words when switching DBAdapter from PG to MY.
        eg. table name 'user' will break in MySQL
        fix -> add '_' as prefix to column and table name
    *test on other systems
        currently only tested on Win7 64bit 
        Dart Editor version 0.6.3_r24898 32bit
		Dart SDK version 0.6.3.3_r24898 32bit
    *adding rename action
    *adding option to specify variable length
        currently VARCHAR fix at 255
    *test functionality of all data types
    *improvements, adapt more functionality from db connectors
    *and much more
    *end scripts automatically 

Please let me know about bugs you find and or improvements/features you would like to see in future.

ENJOY & BE NICE ;)