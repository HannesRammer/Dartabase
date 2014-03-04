part of example.server ;
class Item extends Model{
  num id;
  String text;
  bool done;
  DateTime created_at;
  DateTime updated_at;
  
  String toString() => "Item id=$id:text=$text:done=$done:created_at:$created_at:updated_at:$updated_at";

  //return all items
  static Future loadItems(HttpResponse res){
    new Item().findAll().then((List items){
      if(!items.isEmpty){
        List jsonList=[];
        items.forEach((Item item){
          Map itemMap = item.toJson();
          print(itemMap);
          jsonList.add(itemMap);
        });
        print("found ${items.length} items");
        res.write(JSON.encode(jsonList));
      }else{
        print("no items found");
        res.write("no items found");
      }
      res.close();  
    });
  }
  
  //return item by id
  static Future loadItem(HttpResponse res,id){
    new Item().findById(int.parse(id)).then((item){
      if(item != null){
        Map itemMap = item.toJson();
        print("found item $itemMap");
        res.write(JSON.encode(itemMap));
      }else{
        print("no item found with id $id");
        res.write("no item found with id $id");
      }
      res.close();  
    });
  }
  
  //save item
  static Future saveItem(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      Map postDataMap = JSON.decode(new String.fromCharCodes(buffer));
      if(postDataMap['id'] == null){
        print("creating item with data $postDataMap");
        fill(new Item(),postDataMap,res);
      }else{
        new Item().findById(postDataMap['id']).then((item){
          print("updating item {$item.id} with data $postDataMap");
          fill(item,postDataMap,res);
        });
      }
    }, onError: printError);
  }
  
  static Future fill(Item item,Map dataMap, HttpResponse res){
    item.done = dataMap['done'];
    item.text = dataMap['text'];
    item.save().then((process){
      if(process == "created" || process == "updated"){
        new Item().findById(item.id).then((Item reloadedItem){
          print("$process item $reloadedItem");
          print("$process item ${reloadedItem.toJson()}");
          res.write(JSON.encode(reloadedItem.toJson()));
          res.close();
        });
      }else{
        print("object not saved during 'process': $process");
        res.write("object not saved during 'process': $process");
        res.close();
      }
    });
  }
  
  //delete item
  static Future deleteItem(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      Map postDataMap = JSON.decode(new String.fromCharCodes(buffer));
      if(postDataMap['id'] == null){
        print("no item id provided");
        res.write("no item id provided");
      }else{
        var id = postDataMap['id'];
        new Item().findById(id).then((item){
          if(item != null){
            print("found item with id $id for deletion");
            item.delete().then((result){
              print("$result");
              res.write("$result");
            });
          }else{
            print("no item with id $id found for deletion");
            res.write("no item with id $id found for deletion");
          }
          res.close();  
        });
      }
    }, onError: printError);
  }
    
}

