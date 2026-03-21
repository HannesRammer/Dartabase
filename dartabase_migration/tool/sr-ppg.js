/**
 * Created by SH on 04.04.2016.
 */
/*
 * Script to display item prices on silkroad for BTC per gram
 * simply go to SR -> log in -> browse drugs
 * once you see a list of items, open the browsers dev console
 * paste the code from below inside the browser console window and hit enter
 * now you should see an additional price for 1 gram
 *
 * YOU NEED TO EXECUTE THE SCRIPT EACH TIME YOU SWITCH PAGES
 * BTC/GRAMM works only for products, that contain a number in the product title followed by "g", "gr", "grm", "gram" or "grams".
 */


//COPY CODE BELOW THIS LINE

var items = document.getElementsByClassName("item");
for(var i=1;i< items.length;i++){
    var title = items[i].children[1].children[0].innerHTML.toLowerCase();
    var itemDetailsTag = items[i].children[2];
    var priceTag = itemDetailsTag.children[0];
    var price = priceTag.innerHTML.substr(1);

    var sl = title.split(" ");
    var gramm = 0;
    for(var j = 0;j<sl.length;j++){
        if(	(sl[j].substr(-5) == "grams" || sl[j].substr(-4) == "gram" || sl[j].substr(-3) == "grm" || sl[j].substr(-2) == "gr" || sl[j].substr(-2) == "gm" || sl[j].substr(-1) == "g") && sl[j].substr(-2) != "mg" ){
            if(!isNaN(parseInt(sl[j]))){
                gramm = parseInt(sl[j]);
            }else{
                gramm = parseInt(sl[j-1]);
            }
        }
    }
    var gp = Math.floor((price/gramm) * 1000000) / 1000000;
    var fString = "1g = "+gp+" BTC";
    priceTag.setAttribute("title", fString);
    if(fString != "1g = Infinity BTC"){
        if (itemDetailsTag.children.length == 3){
            var gpTag = itemDetailsTag.children[2];
            gpTag.innerHTML = fString;
        }else{
            var gpTag = document.createElement("div");
            gpTag.setAttribute("class","gpTag");
            gpTag.setAttribute("style","color:red;");
            gpTag.innerHTML = fString ;
            itemDetailsTag.appendChild(gpTag);
        }
    }
}
