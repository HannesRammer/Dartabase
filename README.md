Dartabase Tools
===================

    This package will be split into seperate packages
    This page will from now on only show a list of all the Dartabase packages
    
![logo](https://raw.githubusercontent.com/HannesRammer/Dartabase/master/dartabase_migration/Database-Migration-Logo-150.png) [Dartabase Migration](http://pub.dartlang.org/packages/dartabase_migration) 0.6.x
--------------------
  Database Migration is for simple version controlled database structure manipulation 
  for MySQL or PGSQL without having to write SQL
  !!now supports scaffolding!!
  scaffolding generates migration, client and server files via a string like this
  
  web_language[name:VARCHAR,is_cool:BOOLEAN]-m-c-s
      
[Dartabase Model](http://pub.dartlang.org/packages/dartabase_model) 0.6.x
--------------------
  Database Models is for simple data manipulation and builds on Migration 
  for MySQL or PGSQL without having to write SQL

  eg.
  if you have a class named WebLanguage
  
  to update a single database object:

     new WebLanguage().findBy("name","javascript").then((webLanguage){
      webLanguage.name = "dart";
      webLanguage.is_cool = true;
      webLanguage.save();
     });

  //BETA
  Also possible to create and remove direct relations between objects.
  
    
ENJOY & BE NICE ;)