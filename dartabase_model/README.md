Dartabase Model 0.1.0
===================

    Serverside Database Object Models for simple data manipulation 
    that builds on Dartabase Miration 
    inspired by Ruby on Rails models
    
    Version
	    0.1.0 ready for Dart 1.0

	tested on 
		Dart Editor version 0.8.10_r30104 (DEV)
        Dart SDK version 0.8.10.10_r30104
    	
	Uses
    	MYSQL via http://pub.dartlang.org/packages/sqljocky version 0.7.0
    	PGSQL via http://pub.dartlang.org/packages/postgresql version 0.2.11

HOW TO SETUP
------------
    After you have sucessfully finished setting up 'Dartabase Migration' 
    1. Install Dartabase Model the usual pubspec way 
    
    2. Inside your project, at the beginning of the main method insert
        
        Model.initiate("path-to-your-project");

		now it should look kinda like this:
		
			-----dataserver.dart--START--
		
			library dataServer;
	
			import 'package:dartabase_model/dartabase_model.dart';
	
			main(){
			  Model.initiate("C:\\darttestproject\\DartabaseServer");
			  ... your code
			}
		
			-----dataserver.dart--END--
	
	3. Imagine you have ONLY created one database table named 'account' with the column 'name'
	
	4. You have to extend all classes that you want to connected to the database with 'Model'
	   in this case we create a class Account with id, name and a counter
	   
			-----account.dart--START--
		
			part of dataServer;
		
			class Account extends Model{
			  num id;		
			  String name;
			  num counter;
			}
		
			-----account.dart--END--

	5. Now add account.dart as part to dataServer so you can access Account
	   obviously when you have everything in the same file,
	   you dont need 'part' and 'part_of' 
	
			-----dataserver.dart--START--
		
			library dataServer;
	
			import 'package:dartabase_model/dartabase_model.dart';
			part "account.dart";	
			
			main(){
			  Model.initiate("C:\\darttestproject\\DartabaseServer");
			  ... your code
			}
		
			-----dataserver.dart--END--
	 

*******************************************************************************************
HOW TO USE
----------

	1. Saving data
	
	  //simple async save call
	
	  Account account = new Account();
	  account.name="dartabase";
	  account.id=1;
	  account.counter=0;
	  account.save();
	  
	  this will create a new database entry inside account with column name = "dartabase" and increment "id"
	  
	  NOTE: 'id' wont be saved since it is generated for each table as a primary key by Dartabase Migration
	        'counter' wont be saved inside the database since it is not represented in the account table.
	  
	2. Loading data async
	
	  simple find single element call - returns a single account object
		  
		  Account accountRequest = new Account();
		  accountRequest.find_by_id(1).then((account){
		    print("single#${account.name}");	// prints 'dartabase'
		  })
	  
	  simple find many elements call - returns a list of account objects
	   
		  Account accountRequest = new Account();
		  accountfromDB.find_all_by('name','dartabase').then((list){
	        for(var loadedAccount in list){
	      		print("${account.id}${account.name}"); // prints '${id}dartabase'
	        }
	      })
	  
	  NOTE:the result is not returned inside the requestObject, but inside the then
	      
    3. Complex find
       when you want to find an entry with more than one condition curently you can use 
    	
    	  Future find(String sql, bool resultAsList)
    	  
    	  where you provide a normal sql query as a String and tell the function 
    	  
    	  'true' returns a list of elements 
    	  'false' returns the first of the found elements
    	  
    	  
       other available find functions are currently
      
	      Future find_by(String column, var value) 
	      Future find_all_by_id(num id)
	  
	  
	WORKING EXAMPLE:
	
		-----dataserver.dart--START--
	
			library gameServer;
	
			import 'package:dartabase_model/dartabase_model.dart';
			import 'dart:async';
			part "account.dart";
			
			void main() {
			  Model.initiate("C:\\darttestproject\\DartabaseGameServer");
			  
			  Account account = new Account();
			  
			  account.id=0;
			  account.name="sybian";
			  account.save().then((isSaved){
			    Account accountRequest = new Account();
			    accountRequest.find_by_id(1).then((account){
			      print("find ${account.name}");
			    }).then((_){
			      accountRequest.find_all_by_id(1).then((list){
			        for(var loadedAccount in list){
			          print("find_all_by_id ${loadedAccount.id} ${loadedAccount.name}");
			        }
			      }).then((_){
			        accountRequest.find_all_by("name","dartabase").then((list){
			          for(var loadedAccount in list){
			            print("find_all_by ${loadedAccount.id} ${loadedAccount.name}");
			          }
			        });
			      });
			    });
			  });
			}
				
		-----dataserver.dart--END--
		  
	  
	  	

*******************************************************************************************

TODO
----

	*wait for 'await' to make this baby sync
	*implement pgsql parts
    *test functionality in bigger project
    *improve
    *and much more

Please let me know about bugs you find and or improvements/features you would like to see in future.

ENJOY & BE NICE ;)