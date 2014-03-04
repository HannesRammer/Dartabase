part of example.server ;
class Item {
  String text;
  bool done;
  
  String toString() => "Item text=$text:done=$done";

  //return all items
  static Future loadItems(HttpResponse res){
    print("implement loadItems");
    res.write("implement loadItems");
    res.close();
  }
  
  //return item by id
  static Future loadItem(HttpResponse res,id){
    print("implement loadItem");
    res.write("implement loadItem");
    res.close();
  }
  
  //save item
  static Future saveItem(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      Map postDataMap = JSON.decode(new String.fromCharCodes(buffer));
      print("implement saveItem");
      res.write("implement saveItem");
      res.close();
    }, onError: printError);
  }
  
  //delete item
  static Future deleteItem(HttpRequest req,HttpResponse res)
  {
    req.listen((List<int> buffer) {
      print("implement deleteItem");
      res.write("implement deleteItem");
      res.close();
    }, onError: printError);
  }
    
}

