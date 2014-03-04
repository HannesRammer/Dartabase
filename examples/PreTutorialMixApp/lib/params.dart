library params;

/*
 * parses the search params from a window location search into a map
 */
Map loadParams(window){
  Map params = {};
  params.clear();
  if(window.location.search != "") {
    List list = window.location.search.substring(1).split("&");
    list.forEach((pair){ 
      List pairList = pair.split("=");
      params[pairList[0]] = pairList[1]; 
    });  
  }
  return params;
}